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
    secrets.acme_yun = {};
    secrets.homepage_dashboard = {};
    secrets.paperless_admin_password = {
      owner = "paperless";
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

  # Use the systemd-boot EFI boot loader.

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

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.zfs.autoScrub.enable = true;

  # fileSystems."/share" = {
  #   neededForBoot = false;
  #   device = "storage/set1";
  #   fsType = "zfs";
  #   mountPoint = "/storage/set1";
  #   options = [
  #     "defaults"
  #     "nofail"
  #     "zfsutil"
  #     "xattr=sa"
  #     "noatime"
  #   ];
  # };

  environment.systemPackages = [
    pkgs.apfs-fuse
    pkgs.cryptsetup
    pkgs.git
    pkgs.wget
    pkgs.curl
    pkgs.neovim
    pkgs.vim
    pkgs.master.immich
    pkgs.master.immich-cli
  ];

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
        "min protocol" = "SMB2";
        "workgroup" = "WORKGROUP";
        "server string" = "%h server (Samba, NixOS)";
        "netbios name" = "${hostname}";
        # "server string" = "nixos";

        # macOS: this prevents ._ AppleDouble files from causing slowdowns
        "vfs objects" = "catia fruit streams_xattr";
        # Try this fix
        "fruit:advertise_fullsync" = "true";
        # Fruit module optimizations for macOS clients
        "fruit:appl" = "yes";
        "fruit:model" = "MacSamba";
        "fruit:metadata" = "stream";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes ";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:time machine" = "no";
        # Enable server-side copy support
        # https://wiki.samba.org/index.php/Server-Side_Copy#Introduction
        "fruit:copyfile" = "yes";

        # Security
        "security" = "user";
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
        # "unix password sync" = "yes";

        # Performance optimizations
        # "use sendfile" = "yes"; # Enables sendfile syscall for better performance
        # "min receivefile size" = "16384";
        # "aio read size" = "16384"; # Enables async I/O for reads larger than 16KB
        # "aio write size" = "16384"; # Enables async I/O for writes larger than 16KB
        # "getwd cache" = "yes";
        # "strict sync" = "no"; # Don't wait for writes to hit disk (rely on OS cache)
        # "sync always" = "no"; # Improve write performance
        # "strict locking" = "no"; # Reduce locking overhead
        "deadtime" = "60"; # Closes idle connections after 60 minutes to save resources
        # Optimizes TCP connections for better performance - increased buffer sizes
        # "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288";
        "server multi channel support" = "yes"; # Enable SMB3 multi-channel support for better throughput
        # Reduce logging overhead
        "log level" = "0";
        # "kernel oplocks" = "yes"; # Better oplock handling for improved caching
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
        path = "/storage/set1/public";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "wheel";
        # Share-specific performance optimizations
        "strict allocate" = "yes";
        "allocation roundup size" = "4096";
      };
      # hdd = {
      #   path = "/storage/set1/hdd";
      #   browseable = "yes";
      #   "read only" = "no";
      #   "guest ok" = "no";
      #   "create mask" = "0755";
      #   "directory mask" = "0755";
      #   "force user" = "${username}";
      #   "force group" = "wheel";
      #   # Share-specific performance optimizations
      #   "strict allocate" = "yes";
      #   "allocation roundup size" = "4096";
      # };
      camera = {
        path = "/storage/set1/camera";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0755";
        "directory mask" = "0755";
        "force user" = "${username}";
        "force group" = "wheel";
        # Share-specific performance optimizations
        "strict allocate" = "yes";
        "allocation roundup size" = "4096";
      };
    };
  };

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

  # ACME / Let's Encrypt configuration
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ecklf@icloud.com";
      dnsPropagationCheck = true;
    };
    certs = {
      "ecklf.duckdns.org" = {
        extraDomainNames = ["*.ecklf.duckdns.org"];
        dnsProvider = "duckdns";
        environmentFile = config.sops.secrets."acme_yun".path;
        dnsPropagationCheck = true;
        # Wait 120 seconds for DNS propagation (DuckDNS can be slow)
        # See other options on https://go-acme.github.io/lego/usage/cli/options/
        # Verify with `journalctl -u 'acme-*' -f`
        extraLegoFlags = ["--cert.timeout" "300"];
      };
    };
  };

  # Enable Glances system monitoring
  services.glances = {
    enable = true;
    openFirewall = false; # Only accessible locally
    port = 61208;
    extraArgs = [
      "--webserver"
      "--time"
      "5"
    ];
  };

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    environmentFile = config.sops.secrets."homepage_dashboard".path;
    settings = {
      title = "云端控制台";
      favicon = "https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/heimdall.png";
      headerStyle = "boxedWidgets";
      theme = "dark";
      color = "zinc";
      customCSS = ''
        body, html {
          font-family: SF Pro Display, Helvetica, Arial, sans-serif !important;
        }
        .font-medium {
          font-weight: 700 !important;
        }
        .font-light {
          font-weight: 500 !important;
        }
        .font-thin {
          font-weight: 400 !important;
        }
        #information-widgets {
          padding-left: 1.5rem;
          padding-right: 1.5rem;
        }
        div#footer {
          display: none;
        }
        .services-group.basis-full.flex-1.px-1.-my-1 {
          padding-bottom: 3rem;
        };
      '';
      layout = [
        {
          Services = {
            style = "row";
            columns = 3;
          };
        }
        {
          Storage = {
            style = "row";
            columns = 2;
          };
        }
      ];
    };
    services = [
      {
        Services = [
          {
            Immich = {
              icon = "immich.png";
              href = "https://immich.ecklf.duckdns.org";
              description = "Photo Management";
              widget = {
                # Immich server major version
                version = 2;
                type = "immich";
                url = "http://127.0.0.1:2283";
                key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
              };
            };
          }
          {
            Jellyfin = {
              icon = "jellyfin.png";
              href = "https://jellyfin.ecklf.duckdns.org";
              description = "Media Server";
              widget = {
                type = "jellyfin";
                url = "http://127.0.0.1:8096";
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
              };
            };
          }
          {
            Paperless-ngx = {
              icon = "paperless.png";
              href = "https://paperless.ecklf.duckdns.org";
              description = "Document Management";
              widget = {
                type = "paperlessngx";
                url = "http://127.0.0.1:28981";
                key = "{{HOMEPAGE_VAR_PAPERLESS_API_KEY}}";
              };
            };
          }
        ];
      }
    ];
    widgets = [
      {
        glances = {
          url = "https://glances.ecklf.duckdns.org";
          version = 4;
          cpu = true;
          mem = true;
          cputemp = true; # disabled by default
          uptime = true; # disabled by default
          expanded = false; # show the expanded view
          disk = "/storage"; # disabled by default, use mount point of disk(s) in glances. Can also be a list (see below)
          diskUnits = "bytes"; # optional, bytes (default) or bbytes. Only applies to disk
          # label = "MyMachine"; # optional
        };
      }
      {
        datetime = {
          text_size = "md";
          format = {
            dateStyle = "short";
            timeStyle = "short";
          };
        };
      }
      {
        openmeteo = {
          label = "Munich";
          latitude = 48.1351;
          longitude = 11.5820;
          timezone = "Europe/Berlin";
          units = "metric";
          cache = 5;
          maximumFractionDigits = 1;
        };
      }
    ];
    bookmarks = [
      {
        Developer = [
          {
            Github = [
              {
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
        ];
      }
    ];
  };

  users.users.immich.extraGroups = ["video" "render" "nginx"];
  services.immich = {
    enable = true;
    port = 2283;
    host = "127.0.0.1"; # Changed to localhost since nginx will proxy
    openFirewall = false; # No need to open port directly
    accelerationDevices = null;
    mediaLocation = "/storage/set1/immich";
    settings = {
      newVersionCheck.enabled = true;
    };
    environment = {
      IMMICH_TELEMETRY_EXCLUDE = "host,api,io,repo,job";
    };
  };

  users.users.jellyfin.extraGroups = ["video" "render" "nginx"];

  # Ensure Jellyfin directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /storage/set1/jellyfin 0755 jellyfin jellyfin -"
    "d /storage/set1/jellyfin/data 0755 jellyfin jellyfin -"
    "d /storage/set1/jellyfin/data/config 0755 jellyfin jellyfin -"
    "d /storage/set1/jellyfin/data/log 0755 jellyfin jellyfin -"
    "d /storage/set1/jellyfin/cache 0755 jellyfin jellyfin -"
  ];

  # Create a service to fix permissions before Jellyfin starts
  systemd.services.jellyfin-setup = {
    description = "Setup Jellyfin directories with correct permissions";
    wantedBy = ["jellyfin.service"];
    before = ["jellyfin.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /storage/set1/jellyfin/{data,cache,data/config,data/log}
      chown -R jellyfin:jellyfin /storage/set1/jellyfin
      chmod -R 755 /storage/set1/jellyfin
    '';
  };

  services.jellyfin = {
    enable = true;
    openFirewall = false; # nginx will handle the proxy
    dataDir = "/storage/set1/jellyfin/data";
    cacheDir = "/storage/set1/jellyfin/cache";
    # logDir is relative to dataDir by default, so it becomes /storage/set1/jellyfin/data/log
  };

  services.paperless = {
    enable = true;
    address = "127.0.0.1";
    port = 28981;
    dataDir = "/storage/set1/paperless";
    # These directories might be failing to create on first run
    # Check `journalctl -xe` for paperless logs
    mediaDir = "/storage/set1/paperless/media";
    consumptionDir = "/storage/set1/paperless/consume";
    passwordFile = config.sops.secrets."paperless_admin_password".path;
    # consumptionDirIsPublic = true;
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_OCR_LANGUAGE = "eng+deu"; # English and German OCR support
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      PAPERLESS_URL = "https://paperless.ecklf.duckdns.org";
    };
  };

  users.users.nginx.extraGroups = ["acme"];
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."ecklf.duckdns.org" = {
      default = true;
      forceSSL = true;
      useACMEHost = "ecklf.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8082";
        proxyWebsockets = true;
      };
    };

    virtualHosts."immich.ecklf.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "ecklf.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };

    virtualHosts."glances.ecklf.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "ecklf.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:61208";
        proxyWebsockets = true;
      };
    };

    virtualHosts."jellyfin.ecklf.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "ecklf.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
      locations."/socket" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };

    virtualHosts."paperless.ecklf.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "ecklf.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:28981";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 100M;
          proxy_read_timeout 300s;
          proxy_send_timeout 300s;
        '';
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
