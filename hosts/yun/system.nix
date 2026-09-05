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
    borgbackup.enable = true;
    borgbackup.sshHostFile = config.sops.secrets.borg_ssh_host.path;
    borgbackup.sshUserFile = config.sops.secrets.borg_ssh_user.path;
    borgbackup.sshPortFile = config.sops.secrets.borg_ssh_port.path;
    borgbackup.sshKeyPath = "/home/${username}/.ssh/id_ed25519";
    borgbackup.passFile = config.sops.secrets.borg_pass.path;
    borgbackup.encryptedFolders.immich = {
      source = config.homelab.immich.mediaLocation;
      target = "immich";
      exclude = [
        "${config.homelab.immich.mediaLocation}/thumbs"
        "${config.homelab.immich.mediaLocation}/encoded-video"
      ];
    };
    # After restoring, regenerate excluded dirs with:
    # sudo -u paperless paperless-manage document_thumbnails
    # sudo -u paperless paperless-manage document_index reindex
    borgbackup.encryptedFolders.paperless = {
      source = config.homelab.paperless.mediaLocation;
      target = "paperless";
      exclude = [
        "${config.homelab.paperless.mediaLocation}/consume"
        "${config.homelab.paperless.mediaLocation}/index"
        "${config.homelab.paperless.mediaLocation}/log"
        "${config.homelab.paperless.mediaLocation}/media/thumbnail"
      ];
    };
    borgbackup.unencryptedFolders.camera = {
      source = "/storage/set1/camera";
      target = "camera";
    };
    glances.enable = true;
    glances.port = 61208;
    jellyfin.enable = true;
    jellyfin.mediaLocation = "/storage/set1/service_data/jellyfin";
    paperless.enable = true;
    paperless.port = 28981;
    paperless.mediaLocation = "/storage/set1/service_data/paperless";
    dashboard.enable = true;
    dashboard.port = 5678;
    stirling.enable = true;
    stirling.port = 7890;
    # Lightweight LXQt desktop with VNC for clawdbot computer-use
    vnc.enable = true;
    vnc.port = 5900;
  };

  virtualisation.docker.enable = true;
  users.users.hermes.extraGroups = ["docker"];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    extraDependencyGroups = ["messaging"];
    extraPackages = [pkgs.docker];
    environmentFiles = [config.sops.templates."hermes-signal.env".path];
    workingDirectory = "/var/lib/hermes/workspace";
    settings = {
      model = {
        provider = "openai-codex";
        default = "gpt-6-astra";
      };
      platforms.signal.enabled = true;
      terminal = {
        backend = "docker";
        cwd = "/workspace";
        docker_mount_cwd_to_workspace = true;
        container_persistent = true;
      };
    };
  };

  systemd.services.signal-cli = {
    description = "signal-cli HTTP daemon for Hermes Agent";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    path = [pkgs.master.signal-cli pkgs.jre_headless];
    serviceConfig = {
      User = "hermes";
      Group = "hermes";
      Environment = "HOME=/var/lib/hermes";
      WorkingDirectory = "/var/lib/hermes";
      EnvironmentFile = config.sops.templates."hermes-signal.env".path;
      ExecStart = pkgs.writeShellScript "signal-cli-daemon" ''
        signal_http="''${SIGNAL_HTTP_URL#http://}"
        signal_http="''${signal_http#https://}"
        exec ${pkgs.master.signal-cli}/bin/signal-cli \
          --account "$SIGNAL_ACCOUNT" \
          daemon --http "$signal_http"
      '';
      Restart = "always";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ReadWritePaths = ["/var/lib/hermes"];
    };
  };

  systemd.services.hermes-agent = {
    after = ["signal-cli.service"];
    requires = ["signal-cli.service"];
  };

  time.timeZone = timezone;

  sops = {
    defaultSopsFile = ../../lib/secrets/networks.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      # keyFile = "/root/age-keys.txt";
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = true;
    };
    secrets.wireless = {};
    secrets.acme_yun = {};
    secrets.dashboard = {};
    secrets.paperless_admin_password = {
      mode = "0400";
    };
    secrets.borg_pass = {
      sopsFile = ./secrets/general.yaml;
      mode = "0400";
    };
    secrets.borg_ssh_host = {
      sopsFile = ./secrets/general.yaml;
    };
    secrets.borg_ssh_user = {
      sopsFile = ./secrets/general.yaml;
    };
    secrets.borg_ssh_port = {
      sopsFile = ./secrets/general.yaml;
    };
    secrets.signal_account = {
      sopsFile = ./secrets/general.yaml;
      mode = "0400";
    };
    secrets.signal_http_url = {
      sopsFile = ./secrets/general.yaml;
      mode = "0400";
    };
    secrets.signal_allowed_users = {
      sopsFile = ./secrets/general.yaml;
      mode = "0400";
    };
  };

  sops.templates."hermes-signal.env" = {
    content = ''
      SIGNAL_HTTP_URL=${config.sops.placeholder.signal_http_url}
      SIGNAL_ACCOUNT=${config.sops.placeholder.signal_account}
      SIGNAL_ALLOWED_USERS=${config.sops.placeholder.signal_allowed_users}
    '';
    owner = "hermes";
    group = "hermes";
    mode = "0400";
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
      # Samba + Immich + Nginx + VNC
      allowedTCPPorts = [80 443 445 139 5201 5900];
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
  services.openssh = {
    enable = true;
    settings = {
      Macs = [
        # Default obtained from nix eval .#nixosConfigurations.yun.config.services.openssh.settings.Macs
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        # Required for echo https://replay.software/help/echo/troubleshooting
        "hmac-sha2-256"
        "hmac-sha2-512"
      ];
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 6,11,19 * * * ${username} /storage/set1/cronjobs/cron.sh >> /storage/set1/cronjobs/cron.log 2>&1"
    ];
  };

  environment.systemPackages = [
    pkgs.apfs-fuse
    pkgs.cryptsetup
    pkgs.git
    pkgs.wget
    pkgs.curl
    pkgs.eza
    pkgs.vim
    pkgs.sops
    pkgs.master.signal-cli
    pkgs.master.yt-dlp
    pkgs.master.jq
  ];

  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker" "nginx" "hermes"];
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
