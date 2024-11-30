{
  config,
  lib,
  pkgs,
  modulesPath,
  username,
  hostname,
  timezone,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  time.timeZone = timezone;
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.hostName = hostname;
  networking.domain = "";
  services.openssh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.root.openssh.authorizedKeys.keys = [];
  users.users."${username}".openssh.authorizedKeys.keys = [];
  system.stateVersion = "23.11";
}
