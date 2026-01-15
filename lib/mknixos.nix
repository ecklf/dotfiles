hostname: {
  inputs,
  nixpkgs,
  nixpkgs-unstable,
  nixpkgs-master,
  nur,
  sops-nix,
  system,
  username,
  overlays,
  extraModules ? [],
  extraHomeModules ? [],
  efiSysMountPoint ? "/boot",
  timezone ? "Europe/Berlin",
  homeStateVersion,
}: let
  systemSpecificOverlays = [
    (final: prev: {
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
  inherit (nixpkgs) lib;
in
  lib.nixosSystem {
    inherit system;
    specialArgs = {inherit system username hostname timezone homeStateVersion;};
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
        ../hosts/${hostname}/system.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit inputs username hostname timezone system homeStateVersion;
            };
            sharedModules = [
              ../modules/home
            ];
            users."${username}".imports = [
              ../hosts/${hostname}/home.nix
            ];
          };
        }
      ];
  }
