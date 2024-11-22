{
  description = "NixOS and Darwin flakes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nur.url = "github:nix-community/NUR";
    # Controls macOS system level software and settings including fonts
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manages configs links and home directory
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs @ { self
    , nixpkgs
    , nixpkgs-stable
    , nixpkgs-master
    , nur
    , darwin
    , home-manager
    }:
    let
      mkDarwin = import ./lib/mkdarwin.nix;
      mkNixOS = import ./lib/mknixos.nix;
      overlays = [ ];
    in
    {
      nixosConfigurations = {
        snowflake = mkNixOS "snowflake" {
          inherit inputs nixpkgs nixpkgs-stable nixpkgs-master overlays;
          system = "x86_64-linux";
          username = "ecklf";
          profile = "server";
          extraModules = [ ];
          extraHomeModules = [ ];
        };
      };

      darwinConfigurations = {
        omega = mkDarwin "omega" {
          inherit self nixpkgs nixpkgs-stable nixpkgs-master nur darwin home-manager overlays;
          system = "aarch64-darwin";
          username = "ecklf";
          profile = "personal";
          casks = "personal";
        };
        vercel = mkDarwin "vercel" {
          inherit self nixpkgs nixpkgs-stable nixpkgs-master nur darwin home-manager overlays;
          system = "aarch64-darwin";
          username = "ecklf";
          profile = "work";
          casks = "work";
        };
      };
    };
}
