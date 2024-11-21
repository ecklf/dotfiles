hostname:
{ inputs
, nixpkgs
, nixpkgs-stable
, nixpkgs-master
, system
, username
, profile
, overlays
, extraModules ? [ ]
, extraHomeModules ? [ ]
, efiSysMountPoint ? "/boot"
, timezone ? "Europe/Berlin"
}:
let
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
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit system username profile hostname timezone; };
  modules =
    [
      {
        hostPlatform = system;
        nixpkgs.overlays = systemSpecificOverlays ++ overlays;
        nixpkgs.config.allowUnfree = true;
      }
      ({ config, ... }: {
        home-manager.sharedModules = [ ] ++ extraHomeModules;
      })
      ../os/nixos
    ] ++ extraModules ++ [
      ../machines/${hostname}
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs username profile hostname timezone;
          };
          users."${username}".imports = [
            ../profiles/${profile}
          ];
        };
      }
    ];
}

