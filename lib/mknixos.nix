hostname: {
  inputs,
  nixpkgs,
  nixpkgs-stable,
  nixpkgs-master,
  nur,
  sops-nix,
  system,
  username,
  profile,
  overlays,
  extraModules ? [],
  extraHomeModules ? [],
  efiSysMountPoint ? "/boot",
  timezone ? "Europe/Berlin",
}: let
  systemSpecificOverlays = [
    (final: prev: {
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
  inherit (nixpkgs) lib;
in
  lib.nixosSystem {
    inherit system;
    specialArgs = {inherit system username profile hostname timezone;};
    modules =
      [
        {
          nixpkgs.overlays = systemSpecificOverlays ++ overlays;
          nixpkgs.config.allowUnfree = true;
        }
        sops-nix.nixosModules.sops
        ../modules/system/nixos
        ({config, ...}: {
          home-manager.sharedModules = [] ++ extraHomeModules;
        })
      ]
      ++ extraModules
      ++ [
        ../machines/${hostname}
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs username profile hostname timezone;
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
