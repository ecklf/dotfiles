_: {
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    # Remove homebrew packages which aren't in the list
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
      "Xcode" = 497799835;
    };
    casks = [
      "affinity-designer"
      "affinity-photo"
      "affinity-publisher"
      "appcleaner"
      "balenaetcher"
      "cleanshot"
      "dbeaver-community"
      "diffmerge"
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
      # "google-cloud-sdk"
      # "ngrok"
      # "topnotch"
    ];
    taps = [ ];
    # brews = [ ]; # ideally not use this at all
  };
}
