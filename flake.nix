{
  description = "NixOS and Darwin flakes";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
        inherit inputs nixpkgs nixpkgs-unstable nixpkgs-master nur sops-nix overlays;
        system = "x86_64-linux";
        username = "soma";
        profile = "k8s";
        timezone = "Germany/Berlin";
        extraModules = [
          disko.nixosModules.disko
        ];
        extraHomeModules = [];
      };
      skia = mkNixOS "skia" {
        inherit inputs nixpkgs nixpkgs-unstable nixpkgs-master nur sops-nix overlays;
        system = "x86_64-linux";
        username = "skia";
        profile = "k8s";
        timezone = "Germany/Berlin";
        extraModules = [
          disko.nixosModules.disko
        ];
        extraHomeModules = [];
      };
      kairos = mkNixOS "kairos" {
        inherit inputs nixpkgs nixpkgs-unstable nixpkgs-master nur sops-nix overlays;
        system = "x86_64-linux";
        username = "kairos";
        profile = "vps";
        timezone = "America/New_York";
        extraModules = [];
        extraHomeModules = [];
      };
      snowflake = mkNixOS "snowflake" {
        inherit inputs nixpkgs nixpkgs-unstable nixpkgs-master nur sops-nix overlays;
        system = "x86_64-linux";
        username = "ecklf";
        profile = "minimal";
        extraModules = [];
        extraHomeModules = [];
      };
    };
    darwinConfigurations = {
      omega = mkDarwin "omega" {
        inherit inputs nixpkgs-unstable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        profile = "personal";
        patchBld = true;
      };
      vercel = mkDarwin "vercel" {
        inherit inputs nixpkgs-unstable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        profile = "work";
      };
      lambda = mkDarwin "lambda" {
        inherit inputs nixpkgs-unstable nixpkgs-master nur darwin home-manager overlays;
        system = "x86_64-darwin";
        username = "lambda";
        profile = "minimal";
      };
      mbp = mkDarwin "mbp" {
        inherit inputs nixpkgs-unstable nixpkgs-master nur darwin home-manager overlays;
        system = "aarch64-darwin";
        username = "ecklf";
        profile = "nobrew";
      };
    };
  };
}
