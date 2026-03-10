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
    overlays = [
      # mas: Mac App Store CLI - override to v6.0.0
      (final: prev: {
        mas = prev.stdenvNoCC.mkDerivation rec {
          pname = "mas";
          version = "6.0.0";
          src =
            let
              sources = {
                aarch64-darwin = {
                  arch = "arm64";
                  hash = "sha256-xyAASl5m/I3wMQdeUtQ/Bn+LIp/75BLRWYn9eT8Z8sw=";
                };
                x86_64-darwin = {
                  arch = "x86_64";
                  hash = "sha256-H3xsgOeeCW6CRQCjWHYz6APciwiobHJZJhGgrGCzSYk=";
                };
              }.${prev.stdenvNoCC.hostPlatform.system}
                or (throw "Unsupported system: ${prev.stdenvNoCC.hostPlatform.system}");
            in
            prev.fetchurl {
              url = "https://github.com/mas-cli/mas/releases/download/v${version}/mas-${version}-${sources.arch}.pkg";
              inherit (sources) hash;
            };
          nativeBuildInputs = with prev; [installShellFiles libarchive p7zip];
          unpackPhase = ''
            runHook preUnpack
            7z x $src
            bsdtar -xf Payload~
            runHook postUnpack
          '';
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            installBin usr/local/opt/mas/bin/mas
            installManPage usr/local/opt/mas/share/man/man1/mas.1
            installShellCompletion --bash usr/local/opt/mas/etc/bash_completion.d/mas
            installShellCompletion --fish usr/local/opt/mas/share/fish/vendor_completions.d/mas.fish
            runHook postInstall
          '';
          meta = {
            description = "Mac App Store command line interface";
            homepage = "https://github.com/mas-cli/mas";
            license = prev.lib.licenses.mit;
            mainProgram = "mas";
            platforms = ["x86_64-darwin" "aarch64-darwin"];
          };
        };
      })
    ];
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
