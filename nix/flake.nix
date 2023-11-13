{
  description = "macOS";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # nixos-22.11
    # Manages configs links things into your home directory
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # Controls system level software and settings including fonts
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  # outputs = { self, nixpkgs, darwin, home-manager }: {
  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
    let
      configuration = { pkgs, lib, ... }: {
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;
        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
        # Necessary for using flakes on this system.
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;
        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        # environment.systemPackages =
        #   [
        #     pkgs.vim
        #   ];
        # nix.package = pkgs.nix;

        # # Set Git commit hash for darwin-version.
        # system.configurationRevision = self.rev or self.dirtyRev or null;

        # Installs a version of nix, that dosen't need "experimental-features = nix-command flakes" in /etc/nix/nix.conf
        # services.nix-daemon.package = pkgs.nixFlakes;
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#macOS14
      # Switch darwin flake using:
      # $ darwin-rebuild switch --flake ~/nix-flake#macOS14
      darwinConfigurations."macOS14" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          # https://github.com/nix-community/home-manager/issues/2942
          config.allowUnfree = true;
          # config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
          #   "ngrok"
          #   "ngrok-3.3.4"
          # ];
        };
        modules = [
          configuration
          ./modules/darwin
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.ecklf.imports = [
                ./modules/home-manager/macOS14.nix
              ];
            };
          }
        ];
      };
      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."macOS14".pkgs;
    };
}
