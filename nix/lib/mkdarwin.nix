hostname:
{ self
, nixpkgs
, nur
, home-manager
, system
, username
, casks
, overlays
, darwin
, extraModules ? [ ]
}:

let
  systemSpecificOverlays = [
    (final: prev: {
      #   zls = zls-master.packages.${system}.default;
      #   helix = helix-master.packages.${system}.default;
    })
  ];
in
darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit system username hostname casks; };
  modules = [
    ({ pkgs, system, ... }: {
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;
      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.extraOptions = ''
        experimental-features = nix-command flakes
      '';
      nixpkgs = {
        # The platform the configuration will be used on.
        hostPlatform = system;
        overlays = systemSpecificOverlays ++ overlays;
        config.allowUnfree = true;
      };
      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;
    })

    ../darwin
    ../machines/${hostname}

  ] ++ extraModules ++ [
    nur.nixosModules.nur
    ({ config, ... }: {
      home-manager.sharedModules = [ ];
    })

    home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit username hostname casks;
        };
        users."${username}".imports = [
          ../profiles/${username}.nix
        ];
      };
    }
  ];
}
