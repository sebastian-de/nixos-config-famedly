{ pkgs, ... }:
{
  # https://nix-community.github.io/home-manager/options.xhtml
  home.username = "sepp";
  home.homeDirectory = "/home/sepp";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
  programs.fish.enable = true;
  programs.starship.enable = true;

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      charliermarsh.ruff
      jnoortheen.nix-ide
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-python-envs
      myriad-dreamin.tinymist
      rust-lang.rust-analyzer
      streetsidesoftware.code-spell-checker
      streetsidesoftware.code-spell-checker-german
      # not available via Nix, yet:
      # opentofu.vscode-opentofu
      # streetsidesoftware.code-spell-checker-medical-terms
      # streetsidesoftware.code-spell-checker-scientific-terms
    ];
  };

  # Dedicated Chrome instance to log into captive portals without messing with DNS settings
  # programs.captive-browser.enable = true;

  home.packages = with pkgs; [
    chromium # for captive-browser
    element-desktop
    eza
    fishPlugins.fzf-fish
    fishPlugins.z
    fzf
    htop
    jq
    kdePackages.kate
    kdePackages.okular
    kdePackages.partitionmanager
    kdePackages.plasma-nm
    keepassxc
    kubectl
    kubelogin-oidc
    nil
    nixfmt
    openpgp-card-tools
    openssl
    p7zip
    pcsc-tools
    ripgrep
    rsync
    thunderbird
    unzip
    wayland-utils
    wireshark
    wl-clipboard
    xz
    yq-go
    zip
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-extension-htm" = "firefox.desktop";
      "application/x-extension-html" = "firefox.desktop";
      "application/x-extension-shtml" = "firefox.desktop";
      "application/x-extension-xht" = "firefox.desktop";
      "application/x-extension-xhtml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";

      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/io.element.desktop" = "io.element.Element.desktop";
      "x-scheme-handler/element" = "io.element.Element.desktop";
    };
  };

  # https://nix-community.github.io/plasma-manager/options.xhtml
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };
    kwin.virtualDesktops.names = [
      "Desktop 1"
      "Desktop 2"
      "Desktop 3"
    ];
    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 11;
      };
      small = {
        family = "Noto Sans";
        pointSize = 9;
      };
      fixedWidth = {
        family = "FiraCode Nerd Font";
        pointSize = 11;
      };
    };
    panels = [
      {
        location = "left";
        floating = false;
        height = 60;
        widgets = [
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
            };
          }
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:firefox.desktop"
                "applications:org.kde.konsole.desktop"
              ];
            };
          }
          "org.kde.plasma.pager"
          {
            systemTray.items = {
              hidden = [ ];
            };
          }
          {
            kicker = {
              behavior = {
                sortAlphabetically = true;
              };
              settings = {
                icon = "nix-snowflake";
              };
            };
          }
        ];
      }
    ];
    input.keyboard.layouts = [
      {
        layout = "de";
        variant = "nodeadkeys";
      }
    ];
    shortcuts = {
      kwin.Overview = [
        "Meta+W"
        "Meta"
      ];
      plasmashell."activate application launcher" = "Alt+F1";
    };
    configFile = {
      dolphinrc.DetailsMode.ExpandableFolders = false;
      dolphinrc.DetailsMode.PreviewSize = 22;
      dolphinrc.General.OpenExternallyCalledFolderInNewTab = true;

      kcminputrc."Libinput/1739/52839/SYNA8018:00 06CB:CE67 Touchpad".NaturalScroll = true;

      kdeglobals.Sounds.Enable = false;

      klipperrc.General.MaxClipItems = 100;

      kxkbrc.Layout.Options = "caps:escape";

      plasma-localerc.Formats.LANG = "en_US.UTF-8";
      plasma-localerc.Formats.LC_ADDRESS = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_MEASUREMENT = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_MONETARY = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_NAME = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_NUMERIC = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_PAPER = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_TELEPHONE = "de_DE.UTF-8";
      plasma-localerc.Formats.LC_TIME = "de_DE.UTF-8";
    };
  };
}
