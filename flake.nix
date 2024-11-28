{
  description = "NixOS and Darwin flakes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # Nix user repository
    nur.url = "github:nix-community/NUR";
    # Atomic secret provisioning for NixOS based on sops
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nix modules for darwin aka macOS
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

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-stable,
    nixpkgs-master,
    nur,
    sops-nix,
    darwin,
    home-manager,
  }: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixOS = import ./lib/mknixos.nix;
    overlays = [];
  in {
    nixosConfigurations = {
      snowflake = mkNixOS "snowflake" {
        inherit inputs nixpkgs nixpkgs-stable nixpkgs-master nur sops-nix overlays;
        system = "x86_64-linux";
        username = "ecklf";
        profile = "server";
        extraModules = [];
        extraHomeModules = [];
      };
    };
    darwinConfigurations = {
      omega = mkDarwin "omega" {
        inherit inputs nixpkgs-stable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        profile = "personal";
      };
      vercel = mkDarwin "vercel" {
        inherit inputs nixpkgs-stable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        profile = "work";
      };
    };
  };
}
