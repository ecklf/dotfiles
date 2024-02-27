({ pkgs, username, hostname, ... }: {
  services = { };

  environment = {
    systemPackages = [
      pkgs.coreutils
    ];
  };

  fonts = {
    # This makes all fonts hard-managed via nix, might delete manually added ones
    fontDir.enable = true;
    fonts =
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
