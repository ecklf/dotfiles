hostname:
{ inputs
, nixpkgs
, system
, username
, profile
, overlays
, extraModules ? [ ]
, extraHomeModules ? [ ]
, efiSysMountPoint ? "/boot"
}:
let
  systemSpecificOverlays = [ ];
  inherit (nixpkgs) lib;
in
lib.nixosSystem {
  inherit system;
  specialArgs = { inherit system username profile hostname; };
  modules =
    [
      {
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
            inherit inputs username profile hostname;
          };
          users."${username}".imports = [
            /* ../profiles */
          ];
        };
      }
    ];
}

