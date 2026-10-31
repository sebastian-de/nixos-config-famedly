{
  pkgs,
  config,
  flake-inputs,
  ...
}:
let
  unstable = flake-inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    ./fish.nix
    ./plasma-manager.nix
    ./neovim.nix
    ./thunderbird.nix
    ./zed.nix
  ];

  # https://nix-community.github.io/home-manager/options.xhtml
  home.stateVersion = "25.05";
  home.username = "sepp";
  home.homeDirectory = "/home/sepp";
  home.packages = with pkgs; [
    chromium
    dnsutils
    hcloud
    jq
    just
    kdePackages.kate
    kdePackages.okular
    kdePackages.plasma-nm
    kubectl
    kubelogin-oidc
    kubernetes-helm
    nil
    nixfmt
    mpv
    openpgp-card-tools
    openssl
    p7zip
    python3
    ripgrep
    rsync
    scaleway-cli
    talos-pilot
    talosctl
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
    zotero

    # nixos-unstable
    unstable.headlamp
    unstable.opencode
  ];
  home.sessionPath = [
    "$HOME/bin"
  ];

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_style = "space";
        indent_size = 2;
      };
      "*.py" = {
        indent_size = 4;
      };
    };
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options.navigate = true;
  };

  programs.direnv = {
    enable = true;
    # enableGitIntegration = true; # git globally ignores .direnv/
    # Touch angrr GC roots on every load so active projects don't expire.
    # The NixOS programs.direnv.angrr integration only applies to the system direnv.
    stdlib = ''
      source ${pkgs.angrr}/share/direnv/lib/angrr.sh
      _angrr_auto_use "$@"
    '';
  };

  programs.element-desktop.enable = true;

  programs.eza.enable = true;

  programs.firefox = {
    enable = true;
    # profile dir under ~/.config instead of ~/.mozilla
    configPath = "${config.xdg.configHome}/mozilla/firefox";
    languagePacks = [
      "en-US"
      "de"
    ];
    nativeMessagingHosts = [
      pkgs.kdePackages.plasma-browser-integration
    ];
    # https://github.com/corbindavenport/just-the-browser/blob/main/firefox/policies.json
    policies = {
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      FirefoxHome = {
        SponsoredStories = false;
        SponsoredTopSites = false;
        Stories = false;
      };
      GenerativeAI = {
        Enabled = false;
        Chatbot = false;
        LinkPreviews = false;
        TabGroups = false;
        Locked = false;
      };
      AIControls = {
        Default = {
          Value = "blocked";
          Locked = false;
        };
        Translations = {
          Value = "available";
          Locked = false;
        };
        PDFAltText = {
          Value = "available";
          Locked = false;
        };
        SmartTabGroups = {
          Value = "blocked";
          Locked = false;
        };
        LinkPreviewKeyPoints = {
          Value = "blocked";
          Locked = false;
        };
        SidebarChatbot = {
          Value = "blocked";
          Locked = false;
        };
        SmartWindow = {
          Value = "blocked";
          Locked = false;
        };
      };
      SearchEngines.Remove = [ "Perplexity" ];
      IPProtectionAvailable = true;
      FirefoxSuggest.SponsoredSuggestions = false;
      VisualSearchEnabled = false;
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

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };

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

  programs.gpg = {
    enable = true;
    settings.keyid-format = "long";
    scdaemonSettings.disable-ccid = true;
  };

  programs.home-manager.enable = true;

  programs.htop.enable = true;

  programs.keepassxc.enable = true;

  # see https://github.com/nix-community/nix-index
  programs.nix-index.enable = true;

  programs.starship = {
    enable = true;
    settings = import ./starship-settings.nix;
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

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    grabKeyboardAndMouse = true;
    defaultCacheTtlSsh = 1800;
    maxCacheTtlSsh = 3600;
    pinentry.package = pkgs.pinentry-qt;
  };

  # used by the fish function `p` to switch to a minimal prompt
  xdg.configFile."starship-simple.toml".source = ./starship-simple.toml;

  # Konsole shortcut scheme "home" (not covered by plasma-manager)
  xdg.dataFile."konsole/shortcuts/home".source = ./konsole-shortcut-scheme-home.xml;

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
      "x-scheme-handler/net.thunderbird" = "thunderbird.desktop";
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
