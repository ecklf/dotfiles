({ pkgs, username, hostname, ... }: {
  system.activationScripts.postUserActivation = {
    enable = true;
    text = builtins.readFile ./../../scripts/patch-screencapture-approvals.sh;
  };

  services = { };

  environment = {
    systemPackages = [
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
