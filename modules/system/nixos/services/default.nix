({
  system,
  lib,
  config,
  username,
  hostname,
  ...
}: {
  imports = [
    ./samba.nix
    ./immich.nix
    ./glances.nix
    ./jellyfin.nix
    ./paperless.nix
    ./dashboard.nix
  ];
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    baseDomain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain to access homelab services via reverse proxy";
    };
    acme = lib.mkOption {
      type = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            description = "ACME email";
          };
          dnsProvider = lib.mkOption {
            type = lib.types.str;
            description = "ACME provider";
          };
        };
      };
    };
  };

  config = lib.mkIf config.homelab.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        email = config.homelab.acme.email;
        dnsPropagationCheck = true;
      };
      certs = {
        "${config.homelab.baseDomain}" = {
          extraDomainNames = ["*.${config.homelab.baseDomain}"];
          dnsProvider = config.homelab.acme.dnsProvider;
          environmentFile = config.sops.secrets."acme_yun".path;
          dnsPropagationCheck = true;
          # Wait 120 seconds for DNS propagation (DuckDNS can be slow)
          # See other options on https://go-acme.github.io/lego/usage/cli/options/
          # Verify with `journalctl -u 'acme-*' -f`
          extraLegoFlags = ["--cert.timeout" "300"];
        };
      };
    };

    users.users.nginx.extraGroups = ["acme"];
    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      virtualHosts."${config.homelab.baseDomain}" =
        lib.mkIf config.homelab.dashboard.enable
        {
          default = true;
          forceSSL = true;
          useACMEHost = "${config.homelab.baseDomain}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.homelab.dashboard.port}";
            proxyWebsockets = true;
          };
        };

      virtualHosts."immich.${config.homelab.baseDomain}" =
        lib.mkIf config.homelab.immich.enable
        {
          forceSSL = true;
          useACMEHost = "${config.homelab.baseDomain}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.homelab.immich.port}";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 50000M;
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
          };
        };

      virtualHosts."glances.${config.homelab.baseDomain}" =
        lib.mkIf config.homelab.glances.enable
        {
          forceSSL = true;
          useACMEHost = "${config.homelab.baseDomain}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.homelab.glances.port}";
            proxyWebsockets = true;
          };
        };

      virtualHosts."jellyfin.${config.homelab.baseDomain}" =
        lib.mkIf config.homelab.jellyfin.enable
        {
          forceSSL = true;
          useACMEHost = "${config.homelab.baseDomain}";
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

      virtualHosts."paperless.${config.homelab.baseDomain}" =
        lib.mkIf config.homelab.paperless.enable
        {
          forceSSL = true;
          useACMEHost = "${config.homelab.baseDomain}";
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString config.homelab.paperless.port}";
            proxyWebsockets = true;
            extraConfig = ''
              client_max_body_size 100M;
              proxy_read_timeout 300s;
              proxy_send_timeout 300s;
            '';
          };
        };
    };
  };
})
