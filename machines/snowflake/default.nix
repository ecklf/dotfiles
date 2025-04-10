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

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # END HARDWARE CONFIGURATION

  sops = {
    defaultSopsFile = ./secrets/networks.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/root/age-keys.txt";
      generateKey = true;
    };
    secrets.wireless_env = {};
  };

  time.timeZone = timezone;

  networking = {
    hostName = hostname;
    wireless = {
      # Enables wireless support via wpa_supplicant.
      enable = true;
      secretsFile = config.sops.secrets.wireless_env.path;
      networks = {
        "chiboshijian".pskRaw = "ext:m1_psk";
      };
    };
    firewall = {
      enable = true;
      # Samba ports
      allowedTCPPorts = [445 139];
      allowedUDPPorts = [137 138];
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # To search: $ nix search wget
  environment.systemPackages = with pkgs; [
    apfs-fuse
    cryptsetup
    wget
    vim
  ];

  home-manager.users."${username}" = {
    programs.home-manager.enable = true;
    programs.zsh.enable = true;
    home.stateVersion = "24.05";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Mount encrypted drive
  fileSystems."/share" = {
    neededForBoot = false;
    device = "/dev/mapper/media_crypt";
    mountPoint = "/mnt/share";
    options = [
      "defaults"
      "nofail"
    ];
    fsType = "ext4";
  };

  environment.etc.crypttab = {
    enable = true;
    text = ''
      media_crypt /dev/disk/by-uuid/65e8c3f1-0d46-4625-8406-03d0a654645d /root/keyfile luks,nofail,timeout=10
    '';
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
        "fruit:appl" = "yes";
        "fruit:model" = "Xserve";
        "workgroup" = "WORKGROUP";
        "server string" = "%h server (Samba, NixOS)";
        # "server string" = "nixos";
        "netbios name" = "${hostname}";
        "security" = "user";
        # "use sendfile" = "yes";
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
        "min receivefile size" = "16384";
        "getwd cache" = "true";
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
        path = "/mnt/share";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "wheel";
      };
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

  services.interception-tools = {
    enable = true;
    plugins = with pkgs; [
      interception-tools-plugins.caps2esc
    ];
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc -m 1 | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  system.stateVersion = "24.05";
}
