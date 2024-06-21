({ pkgs, username, hostname, ... }: {
  system.activationScripts.preActivation = {
    enable = true;
    text = ''
      if [ ! -L "/usr/local/bin/gsed" ]; then
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
