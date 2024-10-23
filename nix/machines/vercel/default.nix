({ pkgs, username, hostname, ... }:
let
  scriptFiles = [
    ./../../scripts/patch-screencapture-approvals.sh
    ./../../scripts/patch-default-apps.sh
  ];
  activationScript = builtins.concatStringsSep "\n" (map (file: builtins.readFile file) scriptFiles);
in
{

  system.activationScripts.extraActivation = {
    enable = true;
    text = activationScript;
  };

  services = { };

  environment = {
    systemPackages = [
      pkgs.duti
      pkgs.coreutils
    ];
  };

  fonts = {
    packages =
      [
        (pkgs.nerdfonts.override {
          fonts = [
            "JetBrainsMono"
            "GeistMono"
          ];
        })
      ];
  };
})
