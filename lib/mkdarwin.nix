hostname: {
  inputs,
  nixpkgs-stable,
  nixpkgs-master,
  nur,
  home-manager,
  system,
  username,
  profile,
  overlays,
  darwin,
  extraModules ? [],
}: let
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
    specialArgs = {inherit inputs system username profile hostname;};
    modules =
      [
        ({system, ...}: {
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;
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

        ../modules/system/darwin
        ../machines/${hostname}
      ]
      ++ extraModules
      ++ [
        nur.nixosModules.nur
        ({...}: {
          home-manager.sharedModules = [];
        })

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit system username profile hostname;
            };
            sharedModules = [
              ../modules/home
            ];
            users."${username}".imports = [
              ../profiles/${profile}.nix
            ];
          };
        }
      ];
  }
