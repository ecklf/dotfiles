hostname: {
  inputs,
  nixpkgs-unstable,
  nixpkgs-master,
  nur,
  home-manager,
  system,
  username,
  profile,
  overlays,
  darwin,
  homeStateVersion,
  extraModules ? [],
  patchBld ? false,
}: let
  systemSpecificOverlays = [
    (final: prev: {
      #   zls = zls-master.packages.${system}.default;
      #   helix = helix-master.packages.${system}.default;
      unstable = import nixpkgs-unstable {
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
    specialArgs = {inherit inputs system username profile hostname homeStateVersion;};
    modules =
      [
        ({
          system,
          lib,
          ...
        }: {
          ids.gids = lib.mkIf patchBld {nixbld = 30000;};
          # The user used for options that previously applied to the user running darwin-rebuild.
          system.primaryUser = username;
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;
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
        # nur.modules.nixos.default
        ({...}: {
          home-manager.sharedModules = [];
        })

        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit system username profile hostname homeStateVersion;
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
