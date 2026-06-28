{
  modulesPath,
  username,
  timezone,
  config,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/" = {
    device = "/dev/vda2";
    fsType = "ext4";
  };
  swapDevices = [{device = "/dev/vda3";}];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features = {
        buildkit = true;
      };
    };
  };

  time.timeZone = timezone;

  sops = {
    defaultSopsFile = ../../lib/secrets/networks.yaml;
    age = {
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      generateKey = true;
    };
    secrets.acme_kairos = {};
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [80 443];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ecklf@icloud.com";
      dnsPropagationCheck = true;
    };
    certs."xiangji.duckdns.org" = {
      dnsProvider = "duckdns";
      environmentFile = config.sops.secrets.acme_kairos.path;
      dnsPropagationCheck = true;
      extraLegoFlags = ["--cert.timeout" "300"];
    };
  };

  users.users.nginx.extraGroups = ["acme"];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."xiangji.duckdns.org" = {
      forceSSL = true;
      useACMEHost = "xiangji.duckdns.org";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8000";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto https;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Real-IP $remote_addr;
        '';
      };
    };
  };

  users.users."${username}".extraGroups = ["docker"];

  system.stateVersion = "24.05";
}
