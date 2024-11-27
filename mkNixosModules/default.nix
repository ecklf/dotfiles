({
  username,
  pkgs,
  ...
}: {
  nix = {
    package = pkgs.nixVersions.stable;
    settings.auto-optimise-store = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.permittedInsecurePackages = [];
  # Shells and environment
  programs.zsh.enable = true;
  environment.shells = [pkgs.bashInteractive pkgs.zsh];
  environment.pathsToLink = ["/share/zsh"];
  # Users
  users.users."${username}" = {
    isNormalUser = true;
    # Post install: set a new password with ‘passwd’
    initialPassword = "init123";
    # Enable ‘sudo’ for the user
    extraGroups = ["wheel"];
  };
})
