({ pkgs, username, hostname, ... }: {
  system.activationScripts.preActivation = {
    enable = true;
    text = ''
      if [ ! -d "/usr/local/bin/gsed" ]; then
        sudo ln -s $(which sed) /usr/local/bin/gsed
        echo "Symbolic link created for gsed."
      fi
    '';
  };

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
