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
  environment = {
    shells = [pkgs.bashInteractive pkgs.zsh];
    pathsToLink = ["/share/zsh"];
    systemPackages = [
      pkgs.coreutils
      pkgs.busybox
    ];
  };
  # Users
  users.defaultUserShell = pkgs.zsh;
  users.users."${username}" = {
    isNormalUser = true;
    # Post install: set a new password with ‘passwd’
    initialPassword = "init123";
    # Enable ‘sudo’ for the user
    extraGroups = ["wheel"];
  };
})
