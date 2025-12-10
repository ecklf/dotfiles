{
  config,
  lib,
  pkgs,
  username,
  hostname,
  timezone,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ../../modules/system/nixos/services
  ];

  homelab = {
    enable = true;
    baseDomain = "ecklf.duckdns.org";
    acme = {
      email = "ecklf@icloud.com";
      dnsProvider = "duckdns";
    };
    samba.enable = true;
    immich.enable = true;
    immich.mediaLocation = "/storage/set1/service_data/immich";
    immich.port = 2283;
    glances.enable = true;
    glances.port = 61208;
    jellyfin.enable = true;
    jellyfin.mediaLocation = "/storage/set1/service_data/jellyfin";
    paperless.enable = true;
    paperless.port = 28981;
    paperless.mediaLocation = "/storage/set1/service_data/paperless";
    dashboard.enable = true;
    dashboard.port = 5678;
  };

  time.timeZone = timezone;

  sops = {
    defaultSopsFile = ../../lib/secrets/networks.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      # keyFile = "/root/age-keys.txt";
      keyFile = "/home/nixos/.config/sops/age/keys.txt";
      generateKey = true;
    };
    secrets.wireless = {};
    secrets.acme_yun = {};
    secrets.dashboard = {};
    secrets.paperless_admin_password = {
      mode = "0400";
    };
  };

  networking = {
    hostId = "a0aefbe2"; # first 8 characters from /etc/machine-id
    hostName = hostname;
    wireless = {
      enable = false;
      secretsFile = config.sops.secrets.wireless.path;
      networks = {
        "squirrel-house".pskRaw = "ext:sh_psk";
      };
    };
    firewall = {
      enable = true;
      # Samba + Immich + Nginx
      allowedTCPPorts = [80 443 445 139 5201];
      allowedUDPPorts = [137 138 5201];
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["zfs"];
    zfs = {
      # https://wiki.nixos.org/wiki/ZFS#Importing_on_boot
      # Runs `sudo zpool import storage` on
      extraPools = ["storage"];
      forceImportRoot = false;
    };
  };
  services.zfs.autoScrub.enable = true;
  services.openssh.enable = true;

  environment.systemPackages = [
    pkgs.apfs-fuse
    pkgs.cryptsetup
    pkgs.git
    pkgs.wget
    pkgs.curl
    pkgs.vim
    pkgs.sops
  ];

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "libvirtd" "docker" "nginx"];
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com''
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com''
  ];
  system.stateVersion = "25.11";
}
