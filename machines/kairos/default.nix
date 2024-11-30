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

  config.homeManagerModules.extraPackages = [
    pkgs.rustup # The Rust toolchain installer
    pkgs.dive # A tool for exploring each layer in a docker image
    pkgs.docker # NVIDIA Container Toolkit
    pkgs.docker-compose # Multi-container orchestration for Docker
    pkgs.lazydocker # A simple terminal UI for both docker and docker-compose
  ];
}
