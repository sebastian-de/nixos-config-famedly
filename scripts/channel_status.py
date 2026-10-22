#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3
"""Show the state of nixos-unstable.

The channel advances to an evaluation once its `nixos/unstable/tested` job has
succeeded and all of its other builds have finished, too. Lists the evaluations
that could still advance the channel and what the oldest of them is waiting
for. Pass an evaluation id to only show what that evaluation is waiting for.
"""

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from datetime import UTC, datetime
from functools import cache, partial
from html.parser import HTMLParser
from itertools import takewhile
from urllib.parse import urlencode

HYDRA = "https://hydra.nixos.org"
PROMETHEUS = "https://prometheus.nixos.org"

# Evaluations to scan for running builds.
RECENT_EVALS = 5
# List at most this many builds per section.
MAX_LISTED = 10

# Hydra's buildstatus values, 0 is success.
BUILD_STATUS = {
    1: "failed",
    2: "dependency failed",
    3: "aborted",
    4: "cancelled",
    6: "failed with output",
    7: "timed out",
    9: "unsupported system",
    10: "log limit exceeded",
    11: "output limit exceeded",
    12: "non-deterministic",
}

COLOR = sys.stdout.isatty()


class StatusError(Exception):
    """Data from Prometheus or Hydra doesn't have the expected shape."""


def colored(text, code):
    return f"\033[{code}m{text}\033[0m" if COLOR else text


def fetch(url, accept="application/json"):
    request = urllib.request.Request(url, headers={"Accept": accept})
    with urllib.request.urlopen(request, timeout=300) as response:
        return response.read()


# Hydra is slow, so fetch every build only once.
@cache
def hydra(path):
    return json.loads(fetch(f"{HYDRA}/{path}"))


def hydra_page(path, parser):
    parser.feed(fetch(f"{HYDRA}/{path}", accept="text/html").decode())
    return parser


def last_id(href):
    """The trailing id of a Hydra link like https://hydra.nixos.org/build/123."""
    return int(href.rsplit("/", 1)[-1])


def classes(attrs):
    return (attrs.get("class") or "").split()


def channel_state():
    """Revision and last update of the channel, and whether the latest finished
    tested build failed. This is the data status.nixos.org shows.

    Fallbacks if Prometheus is unavailable:
    - https://channels.nixos.org/nixos-unstable/git-revision has the revision
      as plain text.
    - https://hydra.nixos.org/job/nixos/unstable/tested/prometheus has
      `hydra_job_failed`, in Prometheus' text format. The failure state is also
      `buildstatus != 0` in the JSON of
      https://hydra.nixos.org/api/latestbuilds?nr=1&project=nixos&jobset=unstable&job=tested
    """
    query = '{__name__=~"channel_revision|channel_update_time|hydra_job_failed",channel="nixos-unstable"}'
    response = json.loads(
        fetch(f"{PROMETHEUS}/api/v1/query?{urlencode({'query': query})}")
    )
    metrics = {r["metric"]["__name__"]: r for r in response["data"]["result"]}
    try:
        return (
            metrics["channel_revision"]["metric"]["revision"],
            int(metrics["channel_update_time"]["value"][1]),
            metrics["hydra_job_failed"]["value"][1] == "1",
        )
    except KeyError as e:
        raise StatusError(f"Prometheus has no {e} for nixos-unstable.") from e


def latest_finished():
    """The build the channel updater advances the channel to: the newest
    successful tested build from an evaluation without unfinished builds.
    NixOS/infra's modules/hydra-mirror.nix checks it about every 10 minutes."""
    return hydra("job/nixos/unstable/tested/latest-finished")


def latest_finished_eval():
    return latest_finished()["jobsetevals"][0]


class EvalsParser(HTMLParser):
    """Collects id, start time, nixpkgs revision and number of queued builds
    from the rows of Hydra's evaluations table. The queued badge is left out if
    nothing is queued."""

    def __init__(self):
        super().__init__()
        self.evals = []
        self._done = False
        self._queued_badge = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if self._done:
            return
        if tag == "a" and "row-link" in classes(attrs):
            self.evals.append({"id": last_id(attrs["href"]), "queued": 0})
        elif not self.evals:
            return
        elif tag == "time" and "data-timestamp" in attrs:
            self.evals[-1]["timestamp"] = int(attrs["data-timestamp"])
        elif (
            tag == "a"
            and "rev-copy" in classes(attrs)
            and (match := re.search(r"\b[0-9a-f]{40}\b", attrs.get("title") or ""))
        ):
            self.evals[-1]["revision"] = match[0]
        elif tag == "span" and "badge-secondary" in classes(attrs):
            self._queued_badge = True

    def handle_endtag(self, tag):
        if tag == "table" and self.evals:
            self._done = True

    def handle_data(self, data):
        if self._queued_badge and data.strip().isdigit():
            self.evals[-1]["queued"] = int(data)
            self._queued_badge = False


@cache
def evaluations():
    """The latest 10 evaluations of the jobset, newest first.

    Parsed from the jobset page, which takes 1-2 seconds. The JSON of
    https://hydra.nixos.org/jobset/nixos/unstable/evals is the fallback if the
    HTML layout changes: `evals[]` with `id`, `timestamp` and
    `jobsetevalinputs.nixpkgs.revision`, but without queued counts. It takes
    about a minute, though, because every evaluation includes the ids of all its
    ~160k builds (~30 MB).
    """
    evals = hydra_page("jobset/nixos/unstable", EvalsParser()).evals
    if not evals or any(
        e.keys() != {"id", "timestamp", "revision", "queued"} for e in evals
    ):
        raise StatusError(
            "Could not parse Hydra's jobset page, its layout may have changed."
        )
    return evals


def find_eval(eval_id):
    """The evaluation from the jobset page, None if it's older than those."""
    return next((e for e in evaluations() if e["id"] == eval_id), None)


def newer_than_channel(channel_rev):
    """The recent evaluations that could still advance the channel."""
    return list(
        takewhile(lambda e: e["revision"] != channel_rev, evaluations()[:RECENT_EVALS])
    )


class QueuedParser(HTMLParser):
    """Collects the queued builds from an evaluation page: the count from the
    "Queued Jobs (N)" tab label and the builds listed in that tab. Hydra lists
    at most 250 of them and leaves the tab out if nothing is queued."""

    def __init__(self):
        super().__init__()
        self.tabs = set()
        self.count = None
        self.builds = []
        self._label = None
        self._pane = None
        self._build_id = None

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        href = attrs.get("href") or ""
        if tag == "a" and href.startswith("#tabs-"):
            self._label = href[1:]
            self.tabs.add(self._label)
        elif tag == "div" and (attrs.get("id") or "").startswith("tabs-"):
            self._pane = attrs["id"]
        elif (
            self._pane == "tabs-unfinished"
            and tag == "a"
            and "/build/" in href
            and "row-link" not in classes(attrs)
        ):
            self._build_id = last_id(href)

    def handle_endtag(self, tag):
        if tag == "a":
            self._label = None

    def handle_data(self, data):
        if self._label == "tabs-unfinished" and (
            match := re.search(r"\((\d+)\)", data)
        ):
            self.count = int(match[1])
        elif self._build_id and data.strip():
            self.builds.append({"id": self._build_id, "job": data.strip()})
            self._build_id = None


@cache
def queued(eval_id):
    """The builds of an evaluation that haven't finished yet, as
    `{"count": N, "builds": [{"id", "job"}, ...]}`.

    Parsed from the evaluation page, which takes about 5 seconds. Hydra has no
    JSON for this. The fallback is to intersect `builds` from the JSON of
    https://hydra.nixos.org/eval/<id> (~1.6 MB) with the ids of the whole
    Hydra queue from https://hydra.nixos.org/api/queue?nr=100000 (tens of
    thousands of builds).
    """
    parser = hydra_page(f"eval/{eval_id}", QueuedParser())
    if "tabs-inputs" not in parser.tabs or ("tabs-unfinished" in parser.tabs) != (
        parser.count is not None
    ):
        raise StatusError(
            f"Could not parse Hydra's page for evaluation {eval_id}, its layout may have changed."
        )
    return {"count": parser.count or 0, "builds": parser.builds}


def cached_queued_count(eval_id):
    """The number of queued builds from the jobset page, or None if it may be
    stale and the evaluation page has to be checked.

    Hydra counts the queued builds live while an evaluation has unfinished
    builds, but caches the counts once all builds have finished and doesn't
    update them when builds are restarted later. So a 0 is only certain for the
    evaluation the channel updater sees as finished."""
    evaluation = find_eval(eval_id)
    if evaluation and (evaluation["queued"] or eval_id == latest_finished_eval()):
        return evaluation["queued"]
    return None


def queued_count(eval_id):
    count = cached_queued_count(eval_id)
    return queued(eval_id)["count"] if count is None else count


def tested(eval_id):
    return hydra(f"eval/{eval_id}/job/tested")


def constituents(build_id):
    return hydra(f"build/{build_id}/constituents")


def prefetch(calls):
    """Run the calls concurrently to warm the caches of the cached functions."""
    with ThreadPoolExecutor() as pool:
        for future in [pool.submit(call) for call in calls]:
            future.result()


def details_fetches(eval_id, list_queued=False):
    """The requests needed to show an evaluation once its tested build is known:
    the constituents of an unsuccessful tested build, and the evaluation page if
    the queued count may be stale or the queued builds are listed."""
    calls = []
    if state(tested(eval_id)) != "ok":
        calls.append(partial(constituents, tested(eval_id)["id"]))
    if list_queued or cached_queued_count(eval_id) is None:
        calls.append(partial(queued, eval_id))
    return calls


def state(build):
    if build["finished"] != 1:
        return "running"
    return "ok" if build["buildstatus"] == 0 else "failed"


def status(build):
    if state(build) == "running":
        return "running"
    return BUILD_STATUS.get(build["buildstatus"], f"status {build['buildstatus']}")


def format_time(timestamp):
    return datetime.fromtimestamp(timestamp, UTC).strftime("%Y-%m-%d %H:%M UTC")


def hours_ago(timestamp):
    return int(time.time() - timestamp) // 3600


def format_progress(builds, width=""):
    counts = Counter(map(state, builds))
    return (
        f"{counts['ok']:{width}}/{len(builds):<{width}} ok,"
        f" {counts['running']:{width}} running, {counts['failed']} failed"
    )


def print_builds(title, builds, label=status):
    print(title)
    for build in builds[:MAX_LISTED]:
        print(f"  {label(build):<18} {build['job']}")
        print(f"  {'':<18} {HYDRA}/build/{build['id']}")
    if len(builds) > MAX_LISTED:
        print(f"  ... and {len(builds) - MAX_LISTED} more")


def print_channel(channel_rev, update_time, job_failed):
    print(
        f"nixos-unstable is at {channel_rev[:12]}, last advanced"
        f" {format_time(update_time)} ({hours_ago(update_time)}h ago)"
    )
    if job_failed:
        print(
            colored(
                "status.nixos.org shows a build problem: the latest finished tested build failed.",
                31,
            )
        )

    build = latest_finished()
    finished_eval = latest_finished_eval()
    # nixname is e.g. nixos-26.11pre1080855.7a0f122f5090
    finished = (
        f"evaluation {finished_eval} ({format_time(build['timestamp'])},"
        f" {build['nixname'].rsplit('.', 1)[-1]})"
    )
    channel_eval = next(
        (e["id"] for e in evaluations() if e["revision"] == channel_rev), None
    )
    if channel_eval is None:
        print(f"Hydra's latest-finished points to {finished}.")
    elif finished_eval > channel_eval:
        print(
            colored(f"Channel update pending to {finished}", 32)
            + ", the channel updater picks it up within about 10 minutes."
        )
    else:
        relation = (
            "which the channel is already at"
            if finished_eval == channel_eval
            else "which is older than the channel"
        )
        print(
            f"Hydra's latest-finished points to {finished}, {relation}: newer"
            " evaluations still have unfinished builds, so the channel updater does nothing."
        )


def pending_evals(channel_rev):
    """Evaluations newer than the channel that could still advance it, newest
    first: those whose tested job hasn't failed. Stops at the first complete one
    (tested succeeded, nothing queued), the channel advances to it next."""
    pending = []
    for evaluation in newer_than_channel(channel_rev):
        build = tested(evaluation["id"])
        if state(build) == "failed":
            continue
        pending.append(evaluation)
        if state(build) == "ok" and queued_count(evaluation["id"]) == 0:
            break
    return pending


def print_pending_evals(pending):
    """The pending evaluations with their queued builds and the progress of
    their tested job."""
    print("Pending evaluations:")
    for evaluation in pending:
        build = tested(evaluation["id"])
        progress = (
            "succeeded"
            if state(build) == "ok"
            else format_progress(constituents(build["id"]), width=3)
        )
        print(
            f"  {evaluation['id']}  {evaluation['revision'][:12]}"
            f"  started {format_time(evaluation['timestamp'])} ({hours_ago(evaluation['timestamp']):2d}h ago)"
            f"  queued {queued_count(evaluation['id']):5d}  tested {progress}"
        )
    if not pending:
        print("  none")


def print_tested(eval_id, list_failed, list_running):
    build = tested(eval_id)
    if state(build) == "ok":
        print(colored("tested job succeeded.", 32))
        return
    label, code = {
        "running": ("tested job is still running", 33),
        "failed": ("tested job failed", 31),
    }[state(build)]
    print(f"{colored(label, code)}: {HYDRA}/build/{build['id']}")

    builds = constituents(build["id"])
    print(f"  {format_progress(builds)}")

    failed = sorted(
        (b for b in builds if state(b) == "failed"),
        key=lambda b: (status(b), b["job"]),
    )
    running = sorted(
        (b for b in builds if state(b) == "running"), key=lambda b: b["job"]
    )
    if failed and list_failed:
        print()
        print_builds("Failed constituents:", failed)
    if running and list_running:
        print()
        print_builds("Running constituents:", running)


def print_queued(eval_id, list_builds):
    count = queued_count(eval_id)
    if count == 0:
        print(colored("All builds of this evaluation have finished.", 32))
        return
    print(
        colored(
            f"{count} build{'s' if count != 1 else ''} of this evaluation"
            f" {'are' if count != 1 else 'is'} still queued",
            33,
        )
        + ", the channel only advances once all have finished."
    )
    if not list_builds:
        return
    # Builds left over from older evaluations have lower ids, they are the
    # likely stragglers.
    print()
    print_builds(
        "Queued builds:"
        if count <= MAX_LISTED
        else "Queued builds with the lowest ids:",
        sorted(queued(eval_id)["builds"], key=lambda b: b["id"]),
        label=lambda _: "queued",
    )


def print_eval_details(eval_id, list_failed, list_running, list_queued):
    evaluation = find_eval(eval_id)
    if evaluation:
        print(
            f"Evaluation {eval_id} from {format_time(evaluation['timestamp'])},"
            f" nixpkgs {evaluation['revision'][:12]}"
        )
    else:
        print(f"Evaluation {eval_id}")
    print(f"  {HYDRA}/eval/{eval_id}")
    prev_id = next((e["id"] for e in evaluations() if e["id"] < eval_id), None)
    if prev_id:
        print(
            f"  Changes since previous evaluation: {HYDRA}/eval/{eval_id}?compare={prev_id}"
        )
    print()

    print_tested(eval_id, list_failed, list_running)
    print()

    print_queued(eval_id, list_queued)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "eval_id",
        type=int,
        nargs="?",
        help="only show details for this evaluation"
        " (default: show the channel state and the oldest pending evaluation)",
    )
    parser.add_argument(
        "-f",
        "--list-failed",
        action="store_true",
        help=f"list up to {MAX_LISTED} failed builds of the evaluation"
    )
    parser.add_argument(
        "-q",
        "--list-queued",
        action="store_true",
        help=f"list up to {MAX_LISTED} queued builds of the evaluation"
    )
    parser.add_argument(
        "-r",
        "--list-running",
        action="store_true",
        help=f"list up to {MAX_LISTED} running constituents of an unfinished tested job",
    )
    args = parser.parse_args()

    # Hydra takes up to 5 seconds per request, so fetch everything printed
    # below concurrently: first the tested builds, then what showing the
    # evaluations needs on top of that.
    try:
        if args.eval_id:
            eval_id = args.eval_id
            prefetch([evaluations, latest_finished, partial(tested, eval_id)])
            prefetch(details_fetches(eval_id, args.list_queued))
        else:
            channel_rev, update_time, job_failed = channel_state()
            candidates = [e["id"] for e in newer_than_channel(channel_rev)]
            fallback = evaluations()[0]["id"]
            prefetch(
                [latest_finished]
                + [partial(tested, i) for i in {fallback, *candidates}]
            )
            # Evaluations whose tested job failed can't advance the channel.
            # If all of them failed, the newest evaluation is shown instead.
            possible = [i for i in candidates if state(tested(i)) != "failed"]
            prefetch(c for i in possible or [fallback] for c in details_fetches(i))
            pending = pending_evals(channel_rev)
            eval_id = pending[-1]["id"] if pending else fallback

            print_channel(channel_rev, update_time, job_failed)
            print()
            print_pending_evals(pending)
            print()

        print_eval_details(eval_id, args.list_failed, args.list_running, args.list_queued)
    except urllib.error.URLError as e:
        sys.exit(f"Fetching status failed: {e}")
    except StatusError as e:
        sys.exit(str(e))


if __name__ == "__main__":
    main()
