({
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
          description = "Enable mkDarwinModules";
        };
        minimal = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install minimal software";
        };
        developer = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install developer software";
        };
        affinity = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install affinity-suite software";
        };
        messenger = lib.mkOption {
          default = true;
          type = lib.types.bool;
          description = "Install messenger software";
        };
        monitor = lib.mkOption {
          default = true;
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
      masApps =
        config.homebrewModules.extraApps
        // lib.optionalAttrs config.homebrewModules.minimal {
          "Cursor Pro" = 1447043133;
          "Dato" = 1470584107;
          "Hidden Bar" = 1452453066;
          "Keynote" = 409183694;
          "Keystroke Pro" = 1572206224;
          "Mirror Magnet" = 1563698880;
          "Numbers" = 409203825;
          "One Thing" = 1604176982;
          "Pages" = 409201541;
          "Pure Paste" = 1611378436;
          "Theine" = 955848755;
          "Velja" = 1607635845;
          "rcmd • App Switcher" = 1596283165;
        }
        // lib.optionalAttrs config.homebrewModules.developer {
          "Couverture" = 1552415914;
          "EasyRes" = 688211836;
          "System Color Picker" = 1545870783;
          "Xcode" = 497799835;
        }
        // lib.optionalAttrs config.homebrewModules.messenger {
          "WhatsApp" = 310633997;
        }
        // lib.optionalAttrs config.homebrewModules.personal {
          "Notability" = 360593530;
        }
        // lib.optionalAttrs config.homebrewModules.movie {
          "Final Cut Pro" = 424389933;
        }
        // lib.optionalAttrs config.homebrewModules.music {
          "Logic Pro" = 634148309;
        };
      taps = [
        "homebrew/cask-versions"
      ];
      # Ideally leave this empty and only use nix to manage this
      brews = let
        brewList = lib.flatten ([]
          ++ config.homebrewModules.extraBrews
          ++ lib.optional config.homebrewModules.personal [
            "czkawka"
          ]);
      in
        lib.mkIf (lib.length brewList > 0) brewList;

      casks = lib.flatten (
        config.homebrewModules.extraCasks
        ++ lib.optional config.homebrewModules.minimal [
          "appcleaner"
          "bitwarden"
          "cleanshot"
          "iina"
          "keka"
          "ledger-live"
          "librewolf"
          "lm-studio"
          "obsidian"
          "raycast"
          "vivaldi"
          "vlc"
          "yubico-authenticator"
        ]
        ++ lib.optional config.homebrewModules.developer [
          "dbeaver-community"
          "diffmerge"
          "figma"
          "firefox@developer-edition"
          "google-chrome"
          "gpg-suite"
          "graphql-playground"
          "iterm2"
          "lm-studio"
          "orbstack"
          "rapidapi"
          "safari-technology-preview"
          "utm"
          "visual-studio-code"
          "yaak"
        ]
        ++ lib.optional config.homebrewModules.affinity [
          "affinity-designer"
          "affinity-photo"
          "affinity-publisher"
        ]
        ++ lib.optional config.homebrewModules.messenger [
          "discord"
          "spotify"
          "telegram"
        ]
        ++ lib.optional config.homebrewModules.disk [
          "balenaetcher"
          "macfuse"
          "veracrypt"
        ]
        ++ lib.optional config.homebrewModules.monitor [
          "logitech-options"
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
          "handbrake"
          "obs"
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
          # "lulu"
          # "wireshark"
        ]
        ++ lib.optional config.homebrewModules.tax [
          "wiso-steuer-2022"
          # "wiso-steuer-2023"
          # "wiso-steuer-2024"
        ]
        ++ lib.optional config.homebrewModules.language [
          "anki"
        ]
        ++ lib.optional config.homebrewModules.wine [
          "whisky"
        ]
        ++ lib.optional config.homebrewModules.game [
          "steam"
        ]
      );
    };
  };
})
