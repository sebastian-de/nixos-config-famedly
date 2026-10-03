{ pkgs, flake-inputs, ... }:
let
  unstable = flake-inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./plasma-manager.nix
    ./nixvim.nix
  ];

  # https://nix-community.github.io/home-manager/options.xhtml
  home.username = "sepp";
  home.homeDirectory = "/home/sepp";
  home.stateVersion = "25.05";

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/go/bin"
    "$HOME/.cargo/bin"
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "z";
        src = pkgs.fishPlugins.z.src;
      }
    ];
    functions = {
      ans_env = {
        description = "Switch to Famedly ansible-environment";
        body = ''
          cd ~/src/ansible-environment/
          set -g -x ANSIBLE_CALLBACK_RESULT_FORMAT yaml
        '';
      };
      develop = {
        wraps = "nix develop";
        body = ''
          nix develop --command fish
        '';
      };
      e = {
        wraps = "$EDITOR";
        body = ''
          command $EDITOR $argv;
        '';
      };
      fish_user_key_bindings = {
        body = ''
          # https://fishshell.com/docs/current/cmds/bind.html
          bind \cy _fzf_jump_directory  # Ctrl-y
        '';
      };
      # https://github.com/PatrickF1/fzf.fish/discussions/231
      # fzf jump directory function, requires: https://github.com/jethrokuan/z
      _fzf_jump_directory = {
        body = ''
          if not type -q z
            set_color red
              echo "_fzf_jump_directory: z not found." >&2
            set_color normal
            return 1
          end

          set current_token (commandline --current-token)

          set command_z (
            z -l | sort -rn | cut -c 12- | _fzf_wrapper --query=$current_token $fzf_jump_directory_opts --preview='_fzf_preview_file {}'
          )

          if test $status -eq 0
            cd $command_z
          end

          commandline --function repaint
        '';
      };
      glagdo = {
        description = "show a nice git graph";
        wraps = "git log --all --graph --decorate --oneline";
        body = ''
          git log --all --graph --decorate --oneline $argv;
        '';
      };
      gmcb = {
        description = "Merge current branch into default branch";
        body = ''
          set source_branch (git rev-parse --abbrev-ref HEAD) || return 1
          set target_branch (git symbolic-ref refs/remotes/origin/HEAD | sed 's|^refs/remotes/origin/||') || return 1

          echo "Merge $source_branch into $target_branch"
          git switch $target_branch || return 1
          git pull || return 1
          git merge $source_branch
        '';
      };
      gscc = {
        description = "Checkout collection submodule at specified commit";
        body = ''
          set collection $argv[1] || return 1
          set commit $argv[2] || return 1

          echo "Set ansible_collections/famedly/$collection to commit $commit"
          cd ansible_collections/famedly/$collection || return 1
          git fetch || return 1
          git checkout $commit
          cd ../../..
        '';
      };
      gsdb = {
        description = "Switch collection submodule to default branch and update it";
        body = ''
          set collection $argv[1] || return 1

          echo "Set ansible_collections/famedly/$collection to branch main"
          git config -f .gitmodules submodule.ansible_collections/famedly/$collection.branch main || return 1
          git submodule update --force ansible_collections/famedly/$collection
        '';
      };
      gssb = {
        description = "Switch collection submodule to specific branch and update it";
        body = ''
          set collection $argv[1] || return 1
          set branch $argv[2] || return 1

          echo "Set ansible_collections/famedly/$collection to branch $branch"
          git config -f .gitmodules submodule.ansible_collections/famedly/$collection.branch $branch || return 1
          git submodule update --force --remote ansible_collections/famedly/$collection
        '';
      };
      ib = {
        description = "alias for ip -color=auto -brief -human";
        wraps = "ip -color=auto -brief -human";
        body = ''
          ip -color=auto -brief -human $argv;
        '';
      };
      ip = {
        wraps = "ip -color=auto -human";
        body = ''
          command ip -color=auto -human $argv;
        '';
      };
      k = {
        wraps = "kubectl";
        body = ''
          command kubectl $argv;
        '';
      };
      ls = {
        wraps = "eza -l";
        body = ''
          command eza -l $argv;
        '';
      };
      p = {
        description = "switch between full und simple prompt";
        body = ''
          if test -n "$STARSHIP_CONFIG"
            set -e STARSHIP_CONFIG
          else
            set -gx STARSHIP_CONFIG "$HOME/.config/starship-simple.toml"
            echo # newline after switch
          end
        '';
      };
    };
  };

  programs.fzf = {
    enable = true;
    # keybindings come from the fzf.fish plugin (both bind Ctrl+R);
    # the module still provides the package and FZF_DEFAULT_OPTS
    enableFishIntegration = false;
    colors = {
      fg = "-1";
      "fg+" = "#d0d0d0";
      bg = "-1";
      "bg+" = "#303030";
      hl = "#68a8e4";
      "hl+" = "#5fd7ff";
      info = "#fbb829";
      marker = "#008080";
      prompt = "#ff8700";
      spinner = "#ef2f27";
      pointer = "#519f50";
      header = "#98bc37";
      border = "#918175";
      label = "#baa67f";
      query = "#fce8c3";
    };
  };

  # starship-settings.nix is generated from the upstream TOML to preserve
  # Nerd Font glyphs.
  programs.starship = {
    enable = true;
    settings = import ./starship-settings.nix;
  };
  # used by the fish function `p` to switch to a minimal prompt
  xdg.configFile."starship-simple.toml".source = ./starship-simple.toml;
  # Konsole shortcut scheme "home" (not covered by plasma-manager)
  xdg.dataFile."konsole/shortcuts/home".source = ./konsole-shortcut-scheme-home.xml;

  programs.git = {
    enable = true;
    signing = {
      key = "6AFCC2184CF487AD0567F54E38E74E644AE5E3DE";
      signByDefault = true;
    };
    settings = {
      init.defaultBranch = "main";
      user = {
        name = "Sebastian Fleer";
        email = "s.fleer@famedly.com";
      };
      core.editor = "nvim";
      credential.helper = "cache --timeout=3600";
      pull = {
        ff = "only";
        rebase = false;
      };
      merge.conflictstyle = "zdiff3";
      diff.colorMoved = "default";
      push.autoSetupRemote = true;
    };
    ignores = [
      ".k8s"
      ".kube"
      ".vscode/"
      "sf-test*"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options.navigate = true;
  };

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        startup_mode = "Maximized";
        opacity = 0.85;
        blur = true;
      };
      colors = {
        primary = {
          background = "#1c1b19";
          foreground = "#fce8c3";
        };
        cursor = {
          text = "CellBackground";
          cursor = "#fbb829";
        };
        normal = {
          black = "#1c1b19";
          red = "#ef2f27";
          green = "#519f50";
          yellow = "#fbb829";
          blue = "#2c78bf";
          magenta = "#e02c6d";
          cyan = "#0aaeb3";
          white = "#baa67f";
        };
        bright = {
          black = "#918175";
          red = "#f75341";
          green = "#98bc37";
          yellow = "#fed06e";
          blue = "#68a8e4";
          magenta = "#ff5c8f";
          cyan = "#2be4d0";
          white = "#fce8c3";
        };
      };
      font.normal = {
        family = "FiraCode Nerd Font";
        style = "regular";
      };
      terminal.shell.program = "${pkgs.zellij}/bin/zellij";
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "srcery";
      pane_frames = false;
      copy_command = "wl-copy";
      show_startup_tips = false;
    };
    # keybinds with clear-defaults=true and plugin declarations cannot be
    # expressed via settings; kept in zellij-extra.kdl.
    extraConfig = builtins.readFile ./zellij-extra.kdl;
    themes.srcery = ./zellij-srcery.kdl;
  };

  programs.gpg = {
    enable = true;
    settings.keyid-format = "long";
    scdaemonSettings.disable-ccid = true;
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    grabKeyboardAndMouse = true;
    defaultCacheTtlSsh = 1800;
    maxCacheTtlSsh = 3600;
    pinentry.package = pkgs.pinentry-qt;
  };

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      charliermarsh.ruff
      jnoortheen.nix-ide
      mkhl.direnv
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-python-envs
      myriad-dreamin.tinymist
      rust-lang.rust-analyzer
      streetsidesoftware.code-spell-checker
      streetsidesoftware.code-spell-checker-german
      # not available via Nix, yet:
      # gruntwork.terragrunt-ls
      # opentofu.vscode-opentofu
      # streetsidesoftware.code-spell-checker-medical-terms
      # streetsidesoftware.code-spell-checker-scientific-terms
      # tilt-dev.tiltfile
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

  home.packages = with pkgs; [
    chromium
    dnsutils
    element-desktop
    eza
    hcloud
    htop
    jq
    just
    kdePackages.kate
    kdePackages.okular
    kdePackages.partitionmanager
    kdePackages.plasma-nm
    keepassxc
    kubectl
    kubelogin-oidc
    kubernetes-helm
    nil
    nixfmt
    mpv
    openpgp-card-tools
    openssl
    opentofu
    p7zip
    pcsc-tools
    ripgrep
    rsync
    scaleway-cli
    talos-pilot
    talosctl
    tilt
    typst
    unzip
    uv
    wayland-utils
    wget
    wireshark
    wl-clipboard
    xz
    yq-go
    zip

    # nixos-unstable
    unstable.headlamp
    unstable.opencode
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # firefox
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";

      # thunderbird
      "application/x-extension-ics" = "thunderbird.desktop";
      "message/rfc822" = "thunderbird.desktop";
      "text/calendar" = "thunderbird.desktop";
      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "x-scheme-handler/mid" = "thunderbird.desktop";
      "x-scheme-handler/news" = "thunderbird.desktop";
      "x-scheme-handler/nntp" = "thunderbird.desktop";
      "x-scheme-handler/snews" = "thunderbird.desktop";
      "x-scheme-handler/webcal" = "thunderbird.desktop";
      "x-scheme-handler/webcals" = "thunderbird.desktop";

      # element
      "x-scheme-handler/io.element.desktop" = "io.element.Element.desktop";
      "x-scheme-handler/element" = "io.element.Element.desktop";
    };
  };
}
