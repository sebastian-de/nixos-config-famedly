{
  default = "allow";
  tools = {
    terminal = {
      default = "confirm";
      always_allow = [
        # read-only and low-risk; \b also matches the bare command
        {
          pattern = "^(ansible-lint|basename|cat|cd|cut|date|df|diff|direnv|dirname|du|echo|file|grep|head|id|jq|ls|mkdir|paste|printenv|printf|pwd|read|readlink|rg|sleep|sort|stat|tail|test|true|type|uname|uniq|wc|which|whoami)\\b";
        }
        {
          pattern = "^command\\s+-v\\b";
        }
        # env with a command would bypass the deny rules
        {
          pattern = "^env\\s*$";
        }
        {
          pattern = "^(tr|column|fold|rev|seq|xxd|base64|sha256sum|md5sum|cksum|tree|fd)\\b";
        }
        # print a line range only; in-place and -e scripts stay confirmed
        {
          pattern = "^sed\\s+-n\\s+['\"]?[0-9]+(,[0-9]+)?p['\"]?\\s+\\S+\\s*$";
        }
        # -exec/-delete etc. are confirmed below
        {
          pattern = "^find\\b";
        }
        # -i/--split-exp are confirmed below
        {
          pattern = "^yq\\b";
        }
        # back a file up into /tmp before editing, and mark a /tmp script executable
        {
          pattern = "^cp\\s+\\S+\\s+/tmp/\\S+\\s*$";
        }
        {
          pattern = "^chmod\\s+(\\+x|[0-7]{3,4})\\s+/tmp/\\S+\\s*$";
        }
        {
          pattern = "^(ps|uptime|free|nproc|hostname|hostnamectl|locale|lscpu|lsblk|lspci|ss|lsof|journalctl)\\b";
        }
        {
          pattern = "^ip\\s+(addr|route|link)\\b";
        }
        {
          pattern = "^systemctl\\s+(status|show|cat|is-active|is-enabled|is-failed|list-units|list-unit-files|list-timers|list-sockets)\\b";
        }
        # writable subcommands (config, remote add, stash push, ...) are excluded
        {
          pattern = "^git(\\s+-C\\s+\\S+|\\s+--no-pager|\\s+--no-optional-locks)*\\s+(blame|cat-file|diff|grep|log|rev-list|rev-parse|show|show-ref|status|ls-files|describe|shortlog|ls-remote|ls-tree|for-each-ref|merge-base|symbolic-ref|count-objects|worktree\\s+list|stash\\s+(list|show))\\b";
        }
        # listing flags only; anything else writes
        {
          pattern = "^git\\s+branch(\\s+(-a|--all|-r|--remotes|-v|--verbose|-vv|--list|--show-current|--merged|--no-merged|--points-at=\\S+|--format=\\S+|--sort=\\S+|--color=\\S+))*\\s*$";
        }
        # add/remove/set-url/prune write .git/config
        {
          pattern = "^git\\s+remote(\\s+(-v|--verbose))*(\\s+(show|get-url)(\\s+\\S+)*)?\\s*$";
        }
        # query forms only; bare config writes
        {
          pattern = "^git\\s+config\\s+(--get|--get-all|--get-regexp|--list|-l)\\b";
        }
        # a single key reads it; a key plus a value writes it
        {
          pattern = "^git\\s+config\\s+(--get\\s+)?[A-Za-z0-9][A-Za-z0-9._-]*\\s*$";
        }
        # bare and -l/--list list; anything else writes
        {
          pattern = "^git\\s+tag(\\s+(-l|--list)\\b|\\s*$)";
        }
        # status/summary only; update/sync write the worktree
        {
          pattern = "^git(\\s+--no-pager|\\s+-C\\s+\\S+)*\\s+submodule\\s+(status|summary)\\b";
        }
        {
          pattern = "^nix\\s+develop\\b";
        }
        # check builds but changes no files
        {
          pattern = "^nix\\s+(flake\\s+(show|metadata|lock|check)|search)\\b";
        }
        # --eval can fetch imports and build IFDs
        {
          pattern = "^nix-instantiate\\s+(--parse|--eval)\\b";
        }
        {
          pattern = "^nix\\s+eval\\b";
        }
        {
          pattern = "^nix\\s+(derivation\\s+show|path-info|why-depends|log|config\\s+show|registry\\s+list|profile\\s+list|hash\\s+(file|path)|store\\s+(ping|info|verify|diff-closures))\\b";
        }
        # --dry-run/--no-link avoid the ./result symlink
        {
          pattern = "^nix\\s+build\\b.*\\s(--dry-run|--no-link)\\b";
        }
        # plain nixfmt rewrites files
        {
          pattern = "^nixfmt\\s+--check\\b";
        }
        {
          pattern = "^gh\\s+(issue|pr|discussion|gist|release|repo)\\s+(list|view|status)\\b";
        }
        {
          pattern = "^gh\\s+(org|label|secret|ssh-key|gpg-key|cache|alias|extension|workflow|codespace|agent-task)\\s+(list|view)\\b";
        }
        {
          pattern = "^gh\\s+(project\\s+(list|view|field-list|item-list)|run\\s+(list|view|watch)|variable\\s+(list|get)|ruleset\\s+(list|view)|config\\s+(get|list)|auth\\s+status|search|status|browse)\\b";
        }
        {
          pattern = "^gh\\s+pr\\s+(checks|diff)\\b";
        }
        # GET by default; body/method flags are confirmed below
        {
          pattern = "^gh\\s+api\\b";
        }
        {
          pattern = "^gh(\\s+(help|--help|-h|--version))?\\s*$";
        }
        {
          pattern = "^terragrunt\\s+(find|list|browse|catalog|dag\\s+graph|info\\s+print|info\\s+strict\\s+list|hcl\\s+validate)\\b";
        }
        # plain fmt rewrites HCL
        {
          pattern = "^terragrunt\\s+hcl\\s+fmt\\b.*\\s(--check|--diff)\\b";
        }
        # --write is confirmed below
        {
          pattern = "^terragrunt\\s+render\\b";
        }
        {
          pattern = "^terragrunt\\s+stack\\s+(output|run\\s+(plan|show|output|validate))\\b";
        }
        # init writes caches and the lock file; state-migrating flags are confirmed
        {
          pattern = "^terragrunt\\s+(run(-all)?\\s+)?(--all\\s+)?(plan|show|output|validate|state\\s+list|init)\\b";
        }
        {
          pattern = "^terragrunt(\\s+(help|--help|-h|--version))?\\s*$";
        }
        # fmt only with -check
        {
          pattern = "^tofu\\s+(version|validate|plan|show|output|providers(\\s+schema)?|state\\s+(list|show)|fmt\\s+-check)\\b";
        }
        {
          pattern = "^ansible-(doc|inventory)\\b";
        }
        # init writes config; other vault subcommands rewrite the file
        {
          pattern = "^ansible-(config\\s+(list|dump|view|validate)|vault\\s+view)\\b";
        }
        # install/download/build/publish write or upload
        {
          pattern = "^ansible-galaxy\\s+(role\\s+(list|info|search)|collection\\s+(list|verify))\\b";
        }
        # --offline avoids Galaxy installs over the submodule checkouts; --fix is confirmed below
        {
          pattern = "^(/nix/store/[a-z0-9]{32}-[^/]+/bin/)?ansible-lint\\b.*\\s--offline\\b";
        }
        # check_mode: false tasks still change things; --diff alone runs for real
        {
          pattern = "^ansible-playbook\\b.*\\s(--syntax-check|--list-(tasks|hosts|tags)|-C|--check)\\b";
        }
        # module flag last, so -a cannot hide another module
        {
          pattern = "^ansible\\s+(.*\\s)?-m\\s+(ping|setup)\\s*$";
        }
        {
          pattern = "^(python3?|node|npm|pnpm|go|cargo|rustc|tofu|terraform|helm|kubectl|docker|podman|nix|nix-instantiate|nixfmt|nixos-version|ansible(-[a-z]+)?)\\s+(version|-V|--version|--help|-h)\\b";
        }
        {
          pattern = "^(docker|podman)\\s+(ps|images|inspect|logs|stats|top|version|info)\\b";
        }
        # use-context/set/unset rewrite the kubeconfig
        {
          pattern = "^kubectl\\s+(get|describe|logs|top|events|version|explain|api-resources|api-versions|cluster-info|diff|config\\s+view|auth\\s+can-i)\\b";
        }
        {
          pattern = "^helm\\s+(list|history|get|status|template|lint|show|search|env|version|repo\\s+list|plugin\\s+list|dependency\\s+list)\\b";
        }
      ];
      always_deny = [
        # no privilege escalation
        {
          pattern = "^sudo\\b";
        }
        # all ssh* tools
        {
          pattern = "^ssh";
        }
        {
          pattern = "^(scp|sftp)\\b";
        }
      ];
      always_confirm = [
        # body/method flags turn gh api into a POST
        {
          pattern = "gh\\s+api\\b.*\\s(-X|-f|-F|(--method|--raw-field|--field|--input))\\b";
        }
        # render --write writes files; these init flags rebind state
        {
          pattern = "terragrunt\\b.*\\srender\\b.*\\s--write\\b";
        }
        {
          pattern = "terragrunt\\b.*\\sinit\\b.*\\s(-migrate-state|-reconfigure|-force-copy)\\b";
        }
        # --fix rewrites files
        {
          pattern = "ansible-lint\\b.*\\s--fix\\b";
        }
        # -c/--command runs anything
        {
          pattern = "^nix\\s+develop\\b.*\\s(-c|--command)\\b";
        }
        # awk system()/print > and sed e/w execute or write
        {
          pattern = "^awk\\b";
        }
        {
          pattern = "^sed\\b";
        }
        # exec runs commands; allow/deny change trust
        {
          pattern = "^direnv\\s+(exec|allow|deny|block|permit|revoke|prune|reload|watch)\\b";
        }
        # -exec etc. run or write
        {
          pattern = "^find\\b.*\\s(-exec|-execdir|-ok|-okdir|-delete|-fprint|-fprint0|-fprintf|-fls)\\b";
        }
        # in-place/split write files
        {
          pattern = "^yq\\b.*\\s(-i|--inplace|-s|--split-exp)\\b";
        }
        # a second module flag wins
        {
          pattern = "^ansible\\s+(.*\\s)?(-m|--module-name)\\b.*\\s(-m|--module-name)\\b";
        }
      ];
    };
  };
}
