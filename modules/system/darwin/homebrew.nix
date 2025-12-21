({
  system,
  lib,
  config,
  ...
}: {
  options.homebrewModules = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Enable homebrewModules";
        };
        enableAppStore = lib.mkOption {
          type = lib.types.bool;
          description = "Enable installing App Store software";
          default = true;
        };
        minimal = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install minimal software";
        };
        developer = lib.mkOption {
          type = lib.types.bool;
          description = "Install developer software";
        };
        affinity = lib.mkOption {
          type = lib.types.bool;
          description = "Install affinity-suite software";
        };
        messenger = lib.mkOption {
          type = lib.types.bool;
          description = "Install messenger software";
        };
        monitor = lib.mkOption {
          type = lib.types.bool;
          description = "Install monitor-control applications";
        };
        disk = lib.mkOption {
          type = lib.types.bool;
          description = "Install disk tools";
        };
        personal = lib.mkOption {
          type = lib.types.bool;
          description = "Install personal-related software";
        };
        work = lib.mkOption {
          type = lib.types.bool;
          description = "Install work-related software";
        };
        photography = lib.mkOption {
          type = lib.types.bool;
          description = "Install photography software";
        };
        movie = lib.mkOption {
          type = lib.types.bool;
          description = "Install movie creation software";
        };
        music = lib.mkOption {
          type = lib.types.bool;
          description = "Install music creation software";
        };
        latex = lib.mkOption {
          type = lib.types.bool;
          description = "Install LaTeX software";
        };
        downloader = lib.mkOption {
          type = lib.types.bool;
          description = "Install downloader software";
        };
        tax = lib.mkOption {
          type = lib.types.bool;
          description = "Install tax software";
        };
        language = lib.mkOption {
          type = lib.types.bool;
          description = "Install language study applications";
        };
        wine = lib.mkOption {
          type = lib.types.bool;
          description = "Install wine software";
        };
        game = lib.mkOption {
          type = lib.types.bool;
          description = "Install gaming-related software";
        };
        modelling = lib.mkOption {
          type = lib.types.bool;
          description = "Install 3d modelling software";
        };
        extraApps = lib.mkOption {
          type = lib.types.attrsOf lib.types.int;
          description = "Extra App Store software to install";
          default = {};
        };
        extraBrews = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Extra CLI software to install";
        };
        extraCasks = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Extra GUI software to install";
        };
      };
    };
  };

  config = lib.mkIf config.homebrewModules.enable {
    homebrew = {
      enable = true;
      caskArgs.no_quarantine = true;
      # Automatically remove packages not contained in list
      onActivation.cleanup = "zap";
      global.brewfile = true;
      masApps = lib.mkIf config.homebrewModules.enableAppStore (
        config.homebrewModules.extraApps
        // lib.optionalAttrs config.homebrewModules.minimal {
          "Bitwarden" = 1352778147;
          "Cursor Pro" = 1447043133;
          "Dato" = 1470584107;
          "GoodNotes 6: AI Notes & Docs" = 1444383602;
          "Keynote" = 409183694;
          "Keystroke Pro" = 1572206224;
          "Mirror Magnet" = 1563698880;
          "Numbers" = 409203825;
          "Pages" = 409201541;
          "Passepartout, VPN Client" = 1433648537;
          "Pure Paste" = 1611378436;
          "rcmd • App Switcher" = 1596283165;
          "Theine" = 955848755;
          "Velja" = 1607635845;
        }
        // lib.optionalAttrs config.homebrewModules.developer {
          "Couverture" = 1552415914;
          "System Color Picker" = 1545870783;
          "Gifski" = 1351639930;
          "Xcode" = 497799835;
        }
        // lib.optionalAttrs config.homebrewModules.messenger {
          "WhatsApp" = 310633997;
          "KakaoTalk" = 869223134;
        }
        // lib.optionalAttrs config.homebrewModules.personal {
          "Notability" = 360593530;
          "PDFgear: PDF Editor & Reader" = 6469021132;
        }
        // lib.optionalAttrs config.homebrewModules.movie {
          "Final Cut Pro" = 424389933;
        }
        // lib.optionalAttrs config.homebrewModules.music {
          "Logic Pro" = 634148309;
        }
      );
      taps = ["ecklf/bintrim"];
      # Ideally leave this empty and only use nix to manage this
      brews = let
        brewList = lib.flatten ([]
          ++ config.homebrewModules.extraBrews
          ++ lib.optional config.homebrewModules.personal [
            "libimobiledevice"
            "ideviceinstaller"
            "czkawka"
            "bintrim"
          ]);
      in
        lib.mkIf (lib.length brewList > 0) brewList;

      casks = lib.flatten (
        config.homebrewModules.extraCasks
        ++ lib.optional config.homebrewModules.minimal [
          "appcleaner"
          "cleanshot"
          "forklift"
          "ghostty"
          "iina"
          "iterm2"
          "jordanbaird-ice"
          "keka"
          "ledger-live"
          "obsidian"
          "raycast"
          "vivaldi"
          "vlc"
          "zen"
        ]
        ++ lib.optional (config.homebrewModules.developer && system == "aarch64-darwin") [
          "lm-studio"
        ]
        ++ lib.optional config.homebrewModules.developer [
          "beekeeper-studio"
          "coconutbattery"
          "cursor"
          "dbeaver-community"
          "deskpad"
          "diffmerge"
          "figma"
          "firefox@developer-edition"
          "google-chrome"
          "gpg-suite"
          "nosql-workbench"
          "obs"
          "orbstack"
          "rapidapi"
          "safari-technology-preview"
          "utm"
          "visual-studio-code"
          "wezterm"
          "wireshark-app"
          "yaak"
          "yubico-authenticator"
          "zed"
        ]
        ++ lib.optional config.homebrewModules.affinity [
          "affinity-designer"
          "affinity-photo"
          "affinity-publisher"
        ]
        ++ lib.optional config.homebrewModules.messenger [
          "discord"
          "legcord"
          "spotify"
          "telegram"
          "halloy"
        ]
        ++ lib.optional config.homebrewModules.disk [
          "balenaetcher"
          "macfuse"
          "veracrypt"
        ]
        ++ lib.optional config.homebrewModules.monitor [
          "logi-options+"
          "monitorcontrol"
          "notchnook"
        ]
        ++ lib.optional config.homebrewModules.personal []
        ++ lib.optional config.homebrewModules.work [
          "linear-linear"
          "notion"
          "session-manager-plugin"
          "slack"
          # "zoom"
        ]
        ++ lib.optional config.homebrewModules.photography [
          "darktable"
          "imageoptim"
          "xnviewmp"
        ]
        ++ lib.optional config.homebrewModules.movie [
          "handbrake-app"
        ]
        ++ lib.optional config.homebrewModules.music [
          "blackhole-16ch"
          "spotify"
        ]
        ++ lib.optional config.homebrewModules.latex [
          "mactex"
          "texstudio"
        ]
        ++ lib.optional config.homebrewModules.downloader [
          "jdownloader"
          "transmission"
          "tunnelblick"
          "windscribe"
          "surfshark"
          # "lulu"
        ]
        ++ lib.optional config.homebrewModules.tax []
        ++ lib.optional config.homebrewModules.language [
          "anki"
        ]
        ++ lib.optional config.homebrewModules.wine [
          "whisky"
        ]
        ++ lib.optional config.homebrewModules.game [
          "gog-galaxy"
          "mgba-app"
          "steam"
        ]
        ++ lib.optional config.homebrewModules.game [
          "blender"
          "bambu-studio"
        ]
      );
    };
  };
})
