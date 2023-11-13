({ pkgs, ... }: {
  users.users.ecklf.home = "/Users/ecklf";
  environment.systemPath = [ "/opt/homebrew/bin" ];
  environment.pathsToLink = [ "/Applications" ];
  environment.shells = [ pkgs.bash pkgs.zsh ];
  environment.loginShell = pkgs.zsh;
  environment.systemPackages = [
    # pkgs.cfssl
    # pkgs.darwin.libiconv # required for -liconv mitmproxy compilation
    # pkgs.httpie
    # pkgs.lima
    # pkgs.mitmproxy
    # pkgs.nats-server
    # pkgs.natscli
    # pkgs.redis
    # pkgs.vector
    # pkgs.watchman
    pkgs.ack
    pkgs.act
    pkgs.age
    pkgs.ansible
    pkgs.bitwarden-cli
    pkgs.caddy
    pkgs.cairo
    pkgs.cargo
    pkgs.cargo-nextest
    pkgs.certstrap
    pkgs.cmake
    pkgs.coreutils
    pkgs.curl
    pkgs.dbmate
    pkgs.direnv
    pkgs.dive
    pkgs.emacs
    pkgs.eza
    pkgs.fd
    pkgs.ffmpeg
    pkgs.fnm
    pkgs.fx
    pkgs.fzf
    pkgs.gawk
    pkgs.gh
    pkgs.git
    pkgs.git-lfs
    pkgs.gitui
    pkgs.glow
    pkgs.gnupg
    pkgs.gnused
    pkgs.gnutls
    pkgs.go
    pkgs.gomplate
    pkgs.graphicsmagick
    pkgs.graphviz
    pkgs.helix
    pkgs.hexyl
    pkgs.htop
    pkgs.httpstat
    pkgs.imagemagick
    pkgs.inetutils
    pkgs.ipcalc
    pkgs.jq
    pkgs.jwt-cli
    pkgs.k3d
    pkgs.k9s
    pkgs.kubectl
    pkgs.lazydocker
    pkgs.lazygit
    pkgs.lnav
    pkgs.mutagen
    pkgs.mutagen-compose
    pkgs.ncdu
    pkgs.neofetch
    pkgs.neovim
    pkgs.ngrok
    pkgs.nix-prefetch-github
    pkgs.nixpkgs-fmt
    pkgs.nmap
    pkgs.nnn
    pkgs.nodePackages_latest.aws-cdk
    pkgs.pandoc
    pkgs.parallel
    pkgs.psutils
    pkgs.python310Packages.huggingface-hub
    pkgs.ripgrep
    pkgs.rustc
    pkgs.scrcpy
    pkgs.smartmontools
    pkgs.stow
    pkgs.stylua
    pkgs.subversion
    pkgs.tmux
    pkgs.tree
    pkgs.trippy
    pkgs.trivy
    pkgs.upx
    pkgs.wget
    pkgs.youtube-dl
    pkgs.yq
    pkgs.yubikey-manager
    pkgs.yubikey-personalization
    pkgs.zellij
    pkgs.zig
    pkgs.zoxide
    pkgs.zsh
  ];

  fonts = {
    # This makes all fonts hard-managed via nix, will delete manually added ones
    fontDir.enable = true;
    fonts =
      [
        (pkgs.nerdfonts.override {
          fonts = [
            # "GeistMono"
            "JetBrainsMono"
          ];
        })
      ];
  };

  networking = {
    computerName = "omega";
    hostName = "omega";
    localHostName = "omega";
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
    defaults = {
      # TODO(ecklf) add fix - Use scroll gesture with the Ctrl (^) modifier key to zoom
      # universalaccess.closeViewScrollWheelToggle = true;
      # Whether to enable quarantine for downloaded applications
      LaunchServices.LSQuarantine = false;
      dock = {
        autohide = false;
        show-recents = false;
        tilesize = 64;
      };
      trackpad = {
        TrackpadThreeFingerDrag = true;
      };
      finder = {
        # Whether to show icons on the desktop or not 
        # CreateDesktop = false;
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
          # Set accent and highlight color to purple - TODO(ecklf) does not work reliably yet
          # AppleAccentColor = 5;
          # AppleAquaColorVariant = 1;
          # AppleHighlightColor = "0.968627 0.831373 1.000000 Purple";
          # Auto mode for light/dark mode
          # AppleInterfaceStyleSwitchesAutomatically = 1;
          # Add a context menu item for showing the Web Inspector in web views
          WebKitDeveloperExtras = true;
        };
        "com.apple.dock" = {
          wvous-br-corner = 10; # Put display to sleep
          wvous-br-modifier = 1048576; # Require CMD to be held
        };
        "com.apple.finder" = {
          # When performing a search, display folders first
          _FXSortFoldersFirst = true;
          # ShowExternalHardDrivesOnDesktop = true;
          # ShowHardDrivesOnDesktop = true;
          # ShowMountedServersOnDesktop = true;
          # ShowRemovableMediaOnDesktop = true;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        # "com.apple.screensaver" = {
        #   # Require password immediately after sleep or screen saver begins
        #   askForPassword = 1;
        #   askForPasswordDelay = 0;
        # };
        "com.apple.screencapture" = {
          location = "~/";
          type = "png";
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

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = true;
    masApps = {
      "Color Picker" = 1545870783;
      "Couverture" = 1552415914;
      "Cursor Pro" = 1447043133;
      "Dato" = 1470584107;
      "EasyRes" = 688211836;
      "Final Cut Pro" = 424389933;
      "Hidden Bar" = 1452453066;
      "Keynote" = 409183694;
      "Keystroke Pro" = 1572206224;
      "Logic Pro" = 634148309;
      "Magnet" = 441258766;
      "Mirror Magnet" = 1563698880;
      "Notability" = 360593530;
      "Numbers" = 409203825;
      "One Thing" = 1604176982;
      "Pages" = 409201541;
      "Pure Paste" = 1611378436;
      "RetroClip" = 1332064978;
      "Theine" = 955848755;
      "Velja" = 1607635845;
      "Xcode" = 497799835;
      "rcmd • App Switcher" = 1596283165;
    };
    casks = [
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "appcleaner"
      "balenaetcher"
      "dbeaver-community"
      "discord"
      "figma"
      "google-chrome"
      "gpg-suite"
      "handbrake"
      "iina"
      "imageoptim"
      "iterm2"
      "keka"
      "ledger-live"
      "logitech-options"
      "mactex"
      "monitorcontrol"
      "obs"
      "orbstack"
      "rapidapi"
      "raycast"
      "spotify"
      "telegram"
      "texstudio"
      "utm"
      "veracrypt"
      "visual-studio-code"
      "vivaldi"
      "vlc"
      "wiso-steuer-2022"
      "yubico-authenticator"
      # "blackhole-16ch"
      # "cleanshot"
      # "diffmerge"
      # "google-cloud-sdk"
      # "ngrok"
      # "topnotch"
    ];
    taps = [ ];
    # brews = [ ]; # ideally not use this at all
  };
})
