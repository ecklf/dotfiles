hostname:
{ self
, nixpkgs
, nixpkgs-stable
, nixpkgs-master
, nur
, home-manager
, system
, username
, profile
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
      stable = import nixpkgs-stable {
        system = system;
        config.allowUnfree = true;
      };
      master = import nixpkgs-master {
        system = system;
        config.allowUnfree = true;
      };
    })
  ];
in
darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit system username profile hostname casks; };
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
          inherit username profile hostname;
        };
        users."${username}".imports = [
          ../profiles
        ];
      };
    }
  ];
}
