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

  # Disable mdadm RAID monitoring (not using software RAID)
  boot.swraid.enable = false;

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

  users.groups.k8s = {};
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "k8s" "networkmanager"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com"
    ];
  };

  security.sudo.extraConfig = ''
    ${username} ALL=(ALL) NOPASSWD:ALL
  '';

  networking.firewall.allowedTCPPorts = [
    80
    443
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      # "--debug"
      "--disable=traefik"
      "--write-kubeconfig-mode=644"
    ];
  };

  system.stateVersion = "24.05";
}
