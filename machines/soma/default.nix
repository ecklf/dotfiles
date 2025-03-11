{
  pkgs,
  username,
  timezone,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  time.timeZone = timezone;
  boot.tmp.cleanOnBoot = true;

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com"
  ];
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Or the group with sudo privileges
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com"
    ];
  };

  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD:ALL
  '';

  system.stateVersion = "24.05";
}
