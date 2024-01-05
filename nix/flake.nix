{
  description = "macOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11
    nfnixpkgs.url = "github:msfjarvis/nixpkgs/hs/nerdfonts-3.1.0"; # pr for nerdfonts 3.1.0 
    nur.url = "github:nix-community/NUR";
    # Controls macOS system level software and settings including fonts
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Manages configs links and home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nfnixpkgs
    , nur
    , darwin
    , home-manager
    }:
    let
      mkDarwin = import ./lib/mkdarwin.nix;
      overlays = [ ];
    in
    {
      darwinConfigurations = {
        omega = mkDarwin "omega" {
          inherit self nixpkgs nfnixpkgs nur darwin home-manager overlays;
          system = "aarch64-darwin";
          username = "ecklf";
          casks = "personal";
        };
        vercel = mkDarwin "vercel" {
          inherit self nixpkgs nfnixpkgs nur darwin home-manager overlays;
          system = "aarch64-darwin";
          username = "ecklf";
          casks = "work";
        };
      };
    };
}
