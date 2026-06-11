{ ... }:
{
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
