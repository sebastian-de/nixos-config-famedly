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
    input.keyboard = {
      layouts = [
        {
          layout = "de";
          variant = "nodeadkeys";
        }
      ];
      options = [
        "caps:escape"
      ];
    };
    input.touchpads = [
      {
        disableWhileTyping = true;
        enable = true;
        middleButtonEmulation = false;
        name = "SYNA8018:00 06CB:CE67 Touchpad";
        naturalScroll = true;
        productId = "ce67";
        tapToClick = true;
        vendorId = "06cb";
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

      kdeglobals.Sounds.Enable = false;

      klipperrc.General.MaxClipItems = 100;

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

  programs.konsole = {
    enable = true;
    defaultProfile = "home";
    customColorSchemes.srcery = {
      Background.Color = "28,27,25";
      BackgroundFaint.Color = "18,18,18";
      BackgroundIntense.Color = "18,18,18";
      Color0.Color = "28,27,25";
      Color0Faint.Color = "28,27,25";
      Color0Intense.Color = "145,129,117";
      Color1.Color = "239,47,39";
      Color1Faint.Color = "239,47,39";
      Color1Intense.Color = "247,83,65";
      Color2.Color = "81,159,80";
      Color2Faint.Color = "81,159,80";
      Color2Intense.Color = "152,188,55";
      Color3.Color = "251,184,41";
      Color3Faint.Color = "251,184,41";
      Color3Intense.Color = "254,208,110";
      Color4.Color = "44,120,191";
      Color4Faint.Color = "44,120,191";
      Color4Intense.Color = "104,168,228";
      Color5.Color = "224,44,109";
      Color5Faint.Color = "224,44,109";
      Color5Intense.Color = "255,92,143";
      Color6.Color = "10,174,179";
      Color6Faint.Color = "10,174,179";
      Color6Intense.Color = "43,228,208";
      Color7.Color = "186,166,127";
      Color7Faint.Color = "186,166,127";
      Color7Intense.Color = "252,232,195";
      Foreground.Color = "252,232,195";
      ForegroundFaint.Color = "252,232,195";
      ForegroundIntense.Color = "252,232,195";
      General = {
        Anchor = "0.5,0.5";
        Blur = true;
        ColorRandomization = false;
        Description = "srcery";
        FillStyle = "Tile";
        Opacity = 0.85;
        Wallpaper = "";
        WallpaperFlipType = "NoFlip";
        WallpaperOpacity = 1;
      };
    };
    profiles.home = {
      colorScheme = "srcery";
      font = {
        name = "FiraCode Nerd Font";
        size = 11;
      };
      extraConfig = {
        Appearance = {
          BorderWhenActive = false;
          DimmValue = 20;
          FocusBorderColor = "81,159,80";
          LineSpacing = 0;
          TabColor = "20,22,24,0";
        };
        "Cursor Options".CursorShape = 0;
        "Encoding Options".DefaultEncoding = "UTF-8";
        General = {
          AlternatingBars = 1;
          DimWhenInactive = false;
          ErrorBars = 1;
          LocalTabTitleFormat = "%w";
          RemoteTabTitleFormat = "%w";
          ShowTerminalSizeHint = false;
          TerminalCenter = true;
          TerminalMargin = 2;
        };
        "Interaction Options" = {
          CopyTextAsHTML = false;
          WordCharacters = ":@-./_~?&=%+#";
        };
        Scrolling = {
          HighlightScrolledLines = false;
          HistoryMode = 2;
          HistorySize = 10000;
          MarkerSize = 2;
          ScrollBarPosition = 2;
        };
        "Terminal Features".BlinkingCursorEnabled = false;
      };
    };
    extraConfig = {
      FileLocation = {
        scrollbackUseCacheLocation = true;
        scrollbackUseSystemLocation = false;
      };
      General.ConfigVersion = 1;
      KonsoleWindow = {
        RememberWindowSize = false;
        ShowWindowTitleOnTitleBar = true;
      };
      MainWindow.MenuBar = "Disabled";
      "Shortcut Schemes"."Current Scheme" = "home";
      SplitView.SplitViewVisibility = "AlwaysHideSplitHeader";
      TabBar.TabBarVisibility = "AlwaysShowTabBar";
    };
  };
}
