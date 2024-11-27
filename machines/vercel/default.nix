({pkgs, ...}: let
  scriptFiles = [
    ./../../scripts/patch-screencapture-approvals.sh
    ./../../scripts/patch-default-apps.sh
  ];
  activationScript = builtins.concatStringsSep "\n" (map (file: builtins.readFile file) scriptFiles);
in {
  homebrewModules = {
    personal = false;
    work = true;
    photography = true;
    movie = true;
    music = false;
    latex = false;
    downloader = false;
    tax = false;
    language = false;
    wine = false;
    game = false;
  };

  system.activationScripts.extraActivation = {
    enable = true;
    text = activationScript;
  };

  services = {};

  environment = {
    systemPackages = [
      pkgs.coreutils
      pkgs.master.duti
    ];
  };

  fonts = {
    packages = [
      (pkgs.nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "GeistMono"
        ];
      })
    ];
  };
})
