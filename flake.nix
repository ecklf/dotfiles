{
  description = "NixOS and Darwin flakes";
  inputs = {
    # Darwin/macOS inputs
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    # NixOS inputs
    nixpkgs-nixos.url = "github:nixos/nixpkgs";
    nixpkgs-nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-nixos-master.url = "github:nixos/nixpkgs/master";
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-master,
    nixpkgs-nixos,
    nixpkgs-nixos-unstable,
    nixpkgs-nixos-master,
    nur,
    sops-nix,
    darwin,
    home-manager,
    disko,
  }: let
    mkDarwin = import ./lib/mkdarwin.nix;
    mkNixOS = import ./lib/mknixos.nix;
    overlays = [];
  in {
    nixosConfigurations = {
      soma = mkNixOS "soma" {
        inherit inputs nur sops-nix overlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-unstable = nixpkgs-nixos-unstable;
        nixpkgs-master = nixpkgs-master;
        system = "x86_64-linux";
        username = "soma";
        timezone = "Europe/Berlin";
        extraModules = [
          disko.nixosModules.disko
        ];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      skia = mkNixOS "skia" {
        inherit inputs nur sops-nix overlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-unstable = nixpkgs-nixos-unstable;
        nixpkgs-master = nixpkgs-master;
        system = "x86_64-linux";
        username = "skia";
        timezone = "Europe/Berlin";
        extraModules = [
          disko.nixosModules.disko
        ];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      kairos = mkNixOS "kairos" {
        inherit inputs nur sops-nix overlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-unstable = nixpkgs-nixos-unstable;
        nixpkgs-master = nixpkgs-master;
        system = "x86_64-linux";
        username = "kairos";
        timezone = "America/New_York";
        extraModules = [];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      snowflake = mkNixOS "snowflake" {
        inherit inputs nur sops-nix overlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-unstable = nixpkgs-nixos-unstable;
        nixpkgs-master = nixpkgs-master;
        system = "x86_64-linux";
        username = "ecklf";
        extraModules = [];
        extraHomeModules = [];
        homeStateVersion = "24.05";
      };
      yun = mkNixOS "yun" {
        inherit inputs nur sops-nix overlays;
        nixpkgs = nixpkgs-nixos;
        nixpkgs-unstable = nixpkgs-nixos-unstable;
        nixpkgs-master = nixpkgs-master;
        system = "x86_64-linux";
        username = "nixos";
        extraModules = [];
        extraHomeModules = [];
        homeStateVersion = "25.11";
      };
    };
    darwinConfigurations = {
      omega = mkDarwin "omega" {
        inherit inputs nixpkgs-unstable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        patchBld = true;
        homeStateVersion = "24.05";
      };
      vercel = mkDarwin "vercel" {
        inherit inputs nixpkgs-unstable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        homeStateVersion = "24.05";
      };
    };
  };
}
