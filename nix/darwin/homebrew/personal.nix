_: {
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    # Automatically remove packages not contained in list
    onActivation.cleanup = "zap";
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
      "rcmd • App Switcher" = 1596283165;
      "System Color Picker" = 1545870783;
      "Theine" = 955848755;
      "Velja" = 1607635845;
      "WhatsApp" = 310633997;
      "Xcode" = 497799835;
    };
    taps = [
      "homebrew/cask-versions"
    ];
    # Ideally leave this empty and only use nix to manage this 
    brews = [
      "czkawka"
    ];
    casks = [
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "anki"
      "appcleaner"
      "balenaetcher"
      "bitwarden"
      "chromium"
      "cleanshot"
      "darktable"
      "dbeaver-community"
      "diffmerge"
      "discord"
      "figma"
      "firefox@developer-edition"
      "google-chrome"
      "gpg-suite"
      "handbrake"
      "iina"
      "imageoptim"
      "iterm2"
      "jdownloader"
      "keka"
      "ledger-live"
      "librewolf"
      "lm-studio"
      "logitech-options"
      "macfuse"
      "mactex"
      "monitorcontrol"
      "notion"
      "obs"
      "obsidian"
      "orbstack"
      "rapidapi"
      "raycast"
      "spotify"
      "steam"
      "telegram"
      "texstudio"
      "transmission"
      "tunnelblick"
      "utm"
      "veracrypt"
      "visual-studio-code"
      "vivaldi"
      "vlc"
      "whisky"
      "windscribe"
      "wiso-steuer-2022"
      "xnviewmp"
      "yaak"
      "yubico-authenticator"
      # "blackhole-16ch"
      # "lulu"
      # "ngrok"
      # "topnotch"
      # "wireshark"
      "safari-technology-preview"
    ];
  };
}
