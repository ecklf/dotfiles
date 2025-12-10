({
  system,
  pkgs,
  lib,
  config,
  username,
  hostname,
  ...
}: {
  imports = [
    ./activationScripts
    ./homebrew.nix
  ];

  options.darwinModules = lib.mkOption {
    type = lib.types.submodule {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          description = "Enable darwinModules";
        };
        lsQuarantine = lib.mkOption {
          type = lib.types.bool;
          description = "Whether to enable LSQuarantine for downloaded files";
        };
        screenshot = lib.mkOption {
          type = lib.types.submodule {
            options = {
              path = lib.mkOption {
                type = lib.types.str;
                description = "Screenshot folder path";
              };
              format = lib.mkOption {
                type = lib.types.enum ["png" "jpg"];
                description = "Screenshot file format ['png', 'jpg']";
              };
            };
          };
        };
        extraNerdFonts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Extra nerd fonts to install";
        };
      };
    };
    default = {
      enable = true;
      lsQuarantine = false;
      screenshot = {
        format = "png";
        path = "~/Pictures/";
      };
      extraNerdFonts = [];
    };
  };

  config = lib.mkIf config.darwinModules.enable {
    users.users.${username} = {
      home = "/Users/${username}";
      shell = pkgs.zsh;
    };
    networking = {
      hostName = hostname;
      computerName = hostname;
      localHostName = hostname;
    };
    environment = {
      systemPath =
        if system == "aarch64-darwin"
        then ["/opt/homebrew/bin"]
        else ["/usr/local/bin"];
      systemPackages = [
        pkgs.coreutils
        pkgs.master.duti
      ];
      pathsToLink = ["/Applications"];
      shells = [pkgs.bash pkgs.zsh];
    };
    fonts = {
      packages = [
        pkgs.inter
        pkgs.nerd-fonts.geist-mono
        pkgs.nerd-fonts.noto
        pkgs.nerd-fonts.inconsolata
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.iosevka
        pkgs.nerd-fonts.iosevka-term
      ];
    };
    system = {
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
      defaults = {
        LaunchServices.LSQuarantine = config.darwinModules.lsQuarantine;
        universalaccess = {
          # Use scroll gesture with the Ctrl (^) modifier key to zoom
          closeViewScrollWheelToggle = true;
          # Follow the keyboard focus while zoomed in
          closeViewZoomFollowsFocus = true;
        };
        dock = {
          autohide = true;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.0;
          show-recents = false;
          tilesize = 55;
        };
        trackpad = {
          TrackpadThreeFingerDrag = true;
        };
        finder = {
          # CreateDesktop = false; # Disable icons on desktop
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = true;
          AppleShowAllExtensions = true;
          FXEnableExtensionChangeWarning = false;
          # Default view — “icnv” = Icon, “Nlsv” = List, “clmv” = Column, “Flwv” = Gallery
          FXPreferredViewStyle = "Nlsv";
          # Change the default search scope. Use “SCcf” to default to current folder.
          FXDefaultSearchScope = "SCcf";
        };
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          # Boost keyboard speed and disable any auto correction
          KeyRepeat = 1;
          InitialKeyRepeat = 10;
          ApplePressAndHoldEnabled = false;
          # Disable keyboard auto correction
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
          # Always show scrollbars
          AppleShowScrollBars = "Always";
          # Whether to use expanded save panel by default
          NSNavPanelExpandedStateForSaveMode = true;
          NSNavPanelExpandedStateForSaveMode2 = true;
          # Whether to use the expanded print panel by default
          PMPrintingExpandedStateForPrint = true;
          PMPrintingExpandedStateForPrint2 = true;
          # Whether to save new documents to iCloud by default
          NSDocumentSaveNewDocumentsToCloud = false;
        };
        CustomUserPreferences = {
          NSGlobalDomain = {
            # Sequoia+: Double click window title bar to fill screen
            AppleActionOnDoubleClick = "Fill";
            # Reduce menu bar spacing
            NSStatusItemSpacing = 12; # X
            NSStatusItemSelectionPadding = 6; # Y
            # Set accent and highlight color to purple (requires restart of Finder or reboot)
            # AppleAccentColor = 5;
            # AppleHighlightColor = "0.968627 0.831373 1.000000 Purple";
            # Auto mode for light/dark mode
            # AppleInterfaceStyleSwitchesAutomatically = 1;
            # Disable shake mouse to locate cursor
            CGDisableCursorLocationMagnification = 1;
            # Add a context menu item for showing the Web Inspector in web views
            WebKitDeveloperExtras = true;
          };
          "com.apple.dock" = {
            wvous-br-corner = 10; # Put display to sleep
            wvous-br-modifier = 1048576; # Require CMD to be held
          };
          "com.apple.WindowManager" = {
            # Sequoia+: Disable margins on tiled windows
            EnableTiledWindowMargins = 0;
            # Sonoma+: Disable click to show desktop
            EnableStandardClickToShowDesktop = 0;
          };
          "com.apple.finder" = {
            # When performing a search, display folders first
            _FXSortFoldersFirst = true;
            # ShowExternalHardDrivesOnDesktop = true;
            # ShowHardDrivesOnDesktop = true;
            # ShowMountedServersOnDesktop = true;
            # ShowRemovableMediaOnDesktop = true;
            NewWindowTarget = "PfHm";
            NewWindowTargetPath = "file:///Users/${username}/";
          };
          "com.apple.symbolichotkeys" = {
            AppleSymbolicHotKeys = {
              # Disable 'Cmd + Space' for Spotlight Search
              "64" = {
                enabled = false;
              };
              # Disable 'Cmd + Alt + Space' for Finder search window
              "65" = {
                enabled = false;
              };
            };
          };
          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.screencapture" = {
            location = config.darwinModules.screenshot.path;
            type = config.darwinModules.screenshot.format;
          };
          "com.apple.controlcenter" = {
            # Disable recent items
            NumberOfRecents = 0;
          };
          # "com.apple.Safari" = {
          #   # Privacy: don’t send search queries to Apple
          #   UniversalSearchEnabled = false;
          #   SuppressSearchSuggestions = true;
          #   # Press Tab to highlight each item on a web page
          #   WebKitTabToLinksPreferenceKey = true;
          #   ShowFullURLInSmartSearchField = true;
          #   # Prevent Safari from opening ‘safe’ files automatically after downloading
          #   AutoOpenSafeDownloads = false;
          #   ShowFavoritesBar = false;
          #   IncludeInternalDebugMenu = true;
          #   IncludeDevelopMenu = true;
          #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
          #   WebContinuousSpellCheckingEnabled = true;
          #   WebAutomaticSpellingCorrectionEnabled = false;
          #   AutoFillFromAddressBook = false;
          #   AutoFillCreditCardData = false;
          #   AutoFillMiscellaneousForms = false;
          #   WarnAboutFraudulentWebsites = true;
          #   WebKitJavaEnabled = false;
          #   WebKitJavaScriptCanOpenWindowsAutomatically = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
          # };
          # "com.apple.mail" = {
          #   # Disable inline attachments (just show the icons)
          #   DisableInlineAttachmentViewing = true;
          # };
          "com.apple.AdLib" = {
            allowApplePersonalizedAdvertising = false;
          };
          # "com.apple.print.PrintingPrefs" = {
          #   # Automatically quit printer app once the print jobs complete
          #   "Quit When Finished" = true;
          # };
          # "com.apple.SoftwareUpdate" = {
          #   AutomaticCheckEnabled = true;
          #   # Check for software updates daily, not just once per week
          #   ScheduleFrequency = 1;
          #   # Download newly available updates in background
          #   AutomaticDownload = 1;
          #   # Install System data files & security updates
          #   CriticalUpdateInstall = 1;
          # };
          # "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
          # Prevent Photos from opening automatically when devices are plugged in
          # "com.apple.ImageCapture".disableHotPlug = true;
          # Turn on app auto-update
          # "com.apple.commerce".AutoUpdate = true;
        };
      };
    };
  };
})
