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
  # BEGIN HARDWARE CONFIGURATION
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f9072d6b-a770-4b50-aeeb-b77f5058fc16";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/97B0-C0DE";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=077"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/8a4c5305-7140-4d91-8161-b0b0425618a4";}
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # END HARDWARE CONFIGURATION

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Intel hardware acceleration support
    ];
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
      # Samba + Immich
      allowedTCPPorts = [445 139 2283 5201];
      allowedUDPPorts = [137 138 2283 5201];
    };
  };

  # Use the systemd-boot EFI boot loader.

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["zfs"];
    zfs = {
      # https://wiki.nixos.org/wiki/ZFS#Importing_on_boot
      # Runs `sudo zpool import storage` on boot
      extraPools = ["storage"];
      forceImportRoot = false;
    };
  };

  environment.systemPackages = with pkgs; [
    apfs-fuse
    cryptsetup
    git
    wget
    curl
    neovim
    vim
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  fileSystems."/share" = {
    neededForBoot = false;
    device = "storage/set1";
    fsType = "zfs";
    mountPoint = "/mnt/share";
    options = [
      "defaults"
      "nofail"
      "zfsutil"
    ];
  };

  # Make shares visible for windows 10 clients
  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    # Post install: run this setup
    # sudo pdbedit -L -v
    # sudo smbpasswd -a nix
    settings = {
      global = {
        # Phase 1: macOS Compatibility - VFS modules for efficient metadata handling
        # This prevents ._ AppleDouble files from causing slowdowns
        "vfs objects" = "catia fruit streams_xattr";
        # Fruit module optimizations for macOS clients
        "fruit:appl" = "yes";
        "fruit:model" = "Xserve";
        "fruit:metadata" = "stream";
        "fruit:resource" = "stream";
        "fruit:locking" = "netatalk";
        "fruit:encoding" = "native";
        "fruit:time machine" = "no";

        # Phase 2: Disable SMB signing for home network (reduces CPU/protocol overhead)
        "server signing" = "disabled";
        "client signing" = "disabled";

        "workgroup" = "WORKGROUP";
        "server string" = "%h server (Samba, NixOS)";
        # "server string" = "nixos";
        "netbios name" = "${hostname}";
        "security" = "user";
        # Enables sendfile syscall for better performance
        "use sendfile" = "yes";
        "min protocol" = "SMB2";
        "max protocol" = "SMB3";
        # Note: localhost is the ipv6 localhost ::1
        # "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        # "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "server role" = "standalone server";
        "obey pam restrictions" = "yes";
        # This boolean parameter controls whether Samba attempts to sync the Unix
        # password with the SMB password when the encrypted SMB password in the
        # passdb is changed.
        "unix password sync" = "yes";
        "write cache size" = "2097152";
        "min receivefile size" = "16384";
        # Enables async I/O for reads larger than 16KB
        "aio read size" = "16384";
        # Enables async I/O for writes larger than 16KB
        "aio write size" = "16384";
        # Increases read buffer size for better sequential read throughput
        "read size" = "65536";
        "getwd cache" = "true";
        # Closes idle connections after 60 minutes to save resources
        "deadtime" = "60";
        # Improves write performance by disabling strict sync
        "strict sync" = "no";
        # Improves performance by not syncing after every write
        "sync always" = "no";
        # Optimizes TCP connections for better performance
        "socket options" = "TCP_NODELAY IPTOS_THROUGHPUT SO_RCVBUF=131072 SO_SNDBUF=131072";
        # Enable SMB3 multi-channel support for better throughput
        "server multi channel support" = "yes";
        # Reduce logging overhead
        "log level" = "0";
        # Better oplock handling for improved caching
        "kernel oplocks" = "yes";
      };
      homes = {
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        # File creation mask is set to 0700 for security reasons. If you want to
        # create files with group=rw permissions, set next parameter to 0775.
        "create mask" = "0700";
        # Directory creation mask is set to 0700 for security reasons. If you want to
        # create dirs. with group=rw permissions, set next parameter to 0775.
        "directory mask" = "0700";
        # By default, \\server\username shares can be connected to by anyone
        # with access to the samba server.
        # Un-comment the following parameter to make sure that only "username"
        # can connect to \\server\username
        # This might need tweaking when using external authentication schemes
        "valid users" = "%S";
      };
      public = {
        path = "/mnt/share/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "wheel";
        # Pre-allocates disk space for better large file write performance
        "strict allocate" = "yes";
        # Aligns file allocations to 1MB boundaries for optimal ZFS performance
        "allocation roundup size" = "1048576";
        # Phase 1: Inherit VFS modules for macOS compatibility
        "vfs objects" = "catia fruit streams_xattr";
        # Phase 3: Optimize for large sequential writes
        "oplocks" = "no";
        "level2 oplocks" = "no";
        "read raw" = "yes";
        "write raw" = "yes";
      };
      camera = {
        path = "/mnt/share/camera";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "wheel";
        # Pre-allocates disk space for better large file write performance
        "strict allocate" = "yes";
        # Aligns file allocations to 1MB boundaries for optimal ZFS performance
        "allocation roundup size" = "1048576";
        # Phase 1: Inherit VFS modules for macOS compatibility
        "vfs objects" = "catia fruit streams_xattr";
        # Phase 3: Optimize for large sequential writes (camera files)
        "oplocks" = "no";
        "level2 oplocks" = "no";
        "read raw" = "yes";
        "write raw" = "yes";
      };
    };
  };

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "libvirtd" "docker"];
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com''
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+ZSLLubx/+U947o2n0mc3zm3A2ezAkCsCYKIcg3RQs ecklf@icloud.com''
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzp3OPA8XUVrapGPaL4plEuVE9wwhevUkKbtynXrYUZ ecklf@icloud.com''
  ];

  users.users.immich.extraGroups = ["video" "render"];
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0"; # Makes it accessible on your network
    openFirewall = true; # Auto-opens the port
    accelerationDevices = null;
    mediaLocation = "/storage/set1/immich";
    environment = {
      IMMICH_VERSION = "2.3.1";
      IMMICH_TELEMETRY_EXCLUDE = "host,api,io,repo,job";
    };
  };

  # systemd.services.kbdrate-setup = {
  #   description = "Set keyboard repeat rate and delay";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "local-fs.target" ];
  #   serviceConfig = with pkgs; {
  #     Type = "oneshot";
  #     ExecStart = "${kbd}/bin/kbdrate -r 500 -d 0";
  #   };
  # };

  # services.interception-tools = {
  #   enable = true;
  #   plugins = with pkgs; [
  #     interception-tools-plugins.caps2esc
  #   ];
  #   udevmonConfig = ''
  #     - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
  #       DEVICE:
  #         EVENTS:
  #           EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
  #   '';
  # };

  system.stateVersion = "25.11";
}
