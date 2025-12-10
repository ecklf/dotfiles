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
    ../../modules/system/nixos/services
  ];

  homelab.enable = true;
  homelab.baseDomain = "ecklf.duckdns.org";
  homelab.samba.enable = true;
  homelab.immich.enable = true;
  homelab.immich.mediaLocation = "/storage/set1/service_data/immich";
  homelab.glances.enable = true;
  homelab.glances.port = 61208;
  homelab.jellyfin.enable = true;
  homelab.jellyfin.mediaLocation = "/storage/set1/service_data/jellyfin";

  homelab.paperless.enable = true;
  homelab.paperless.port = 28981;
  homelab.paperless.mediaLocation = "/storage/set1/service_data/paperless";

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Intel hardware acceleration support
      # libva-vdpau-driver
      intel-compute-runtime
      intel-ocl
      vpl-gpu-rt # QSV on 11th gen or newer
    ];
  };
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

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

  # Ensure Jellyfin directories exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /storage/set1/service_data/jellyfin 0755 jellyfin jellyfin -"
    "d /storage/set1/service_data/jellyfin/data 0755 jellyfin jellyfin -"
    "d /storage/set1/service_data/jellyfin/data/config 0755 jellyfin jellyfin -"
    "d /storage/set1/service_data/jellyfin/data/log 0755 jellyfin jellyfin -"
    "d /storage/set1/service_data/jellyfin/cache 0755 jellyfin jellyfin -"
  ];

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
