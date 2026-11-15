---
name: simplify
description: Review changed code for reuse, quality, efficiency, and altitude, then fix any issues found.
---

# Simplify: Code Review and Cleanup

Review all changed files for reuse, quality, efficiency, and altitude. Fix any issues found.

Improve the quality of the changed code. Do not look for correctness bugs, that is a different pass.

## Phase 1: Identify Changes

Run `git diff HEAD` to see all uncommitted changes. If that is empty, run `git diff @{upstream}...HEAD` (or `git diff main...HEAD`) to review the committed range. If there are no git changes at all, review the most recently modified files that the user mentioned or that you edited earlier in this conversation.

## Phase 2: Launch Four Review Agents in Parallel

Use the Task tool to launch all four agents concurrently in a single message. Pass each agent the full diff so it has the complete context. Each agent returns its findings with `file`, `line`, a one-line `summary`, and the concrete cost (what is duplicated, wasted, or harder to maintain).

### Agent 1: Code Reuse Review

For each change, look for similar patterns elsewhere in the codebase, especially utility directories, shared modules, and files adjacent to the changed ones.

1. Existing utilities: newly written code that a helper elsewhere in the codebase could replace
2. Duplicate functions: a new function whose job an existing one already does, name the existing one to call instead
3. Inline logic: hand-rolled string manipulation, manual path handling, custom environment checks, or ad-hoc type guards that an existing utility already covers

### Agent 2: Code Quality Review

Review the same changes for hacky patterns:

1. Redundant state: state that duplicates existing state, cached values that could be derived, observers/effects that could be direct calls
2. Parameter sprawl: adding new parameters to a function instead of generalizing or restructuring existing ones
3. Copy-paste with slight variation: near-duplicate code blocks that should be unified with a shared abstraction
4. Leaky abstractions: exposing internal details that should be encapsulated, or breaking existing abstraction boundaries
5. Stringly-typed code: using raw strings where constants, enums (string unions), or branded types already exist in the codebase
6. Unnecessary JSX nesting: wrapper Boxes/elements that add no layout value — check if inner component props (flexShrink, alignItems, etc.) already provide the needed behavior
7. Deep nesting: branches or wrapper layers that a guard clause or flatter control flow would remove
8. Dead code: unused helpers, parameters, or branches left behind by the change

### Agent 3: Efficiency Review

Review the same changes for efficiency:

1. Unnecessary work: redundant computations, repeated file reads, duplicate network/API calls, N+1 patterns
2. Missed concurrency: independent operations run sequentially when they could run in parallel
3. Hot-path bloat: new blocking work added to startup or per-request/per-render hot paths
4. Recurring no-op updates: state/store updates inside polling loops, intervals, or event handlers that fire unconditionally — add a change-detection guard so downstream consumers aren't notified when nothing changed. Also: if a wrapper function takes an updater/reducer callback, verify it honors same-reference returns (or whatever the "no change" signal is) — otherwise callers' early-return no-ops are silently defeated
5. Unnecessary existence checks: pre-checking file/resource existence before operating (TOCTOU anti-pattern) — operate directly and handle the error
6. Memory: unbounded data structures, missing cleanup, event listener leaks
7. Overly broad operations: reading entire files when only a portion is needed, loading all items when filtering for one
8. Captured scope: long-lived closures or callbacks that keep large enclosing values alive, where a small object holding only the needed fields would do

### Agent 4: Altitude Review

Review the same changes for altitude:

1. Root cause over symptom: a change that patches the visible symptom with a fragile bandaid rather than fixing the underlying cause, so name the deeper fix
2. Special cases on shared infrastructure: conditionals, flags, or special cases layered onto shared code to make one caller work, which is a sign the fix isn't deep enough
3. Generalize instead: prefer the simpler, more general change to the underlying mechanism over adding special cases, and name that change

## Phase 3: Fix Issues

Wait for all four agents to complete, dedup findings that point at the same line or mechanism, and fix each remaining one directly. Skip any finding that is a false positive or not worth addressing, whose fix would change intended behavior, or that would require changes well outside the reviewed diff. Note the skip, do not argue with it.

When done, briefly summarize what was fixed (or confirm the code was already clean).
