{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.homelab.headscale;
  domain = "headscale.${config.homelab.baseDomain}";
in {
  options.homelab.headscale = {
    enable = lib.mkEnableOption "Headscale and a Tailscale subnet router";
    subnetRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["192.168.10.0/24"];
      description = "LAN networks advertised by this host; approve them separately in Headscale.";
    };
  };

  config = lib.mkIf (config.homelab.enable && cfg.enable) {
    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 18080;
      settings = {
        server_url = "https://${domain}";
        metrics_listen_addr = "127.0.0.1:9090";
        grpc_listen_addr = "127.0.0.1:50443";
        dns = {
          magic_dns = true;
          base_domain = "tail.${config.homelab.baseDomain}";
          override_local_dns = false;
        };
        # No additional public STUN/DERP listener; retain public relay fallback.
        derp.server.enabled = false;
        # Enrollment is manual. Adding another user does not grant LAN access.
        policy = {
          mode = "file";
          path = pkgs.writeText "headscale-policy.json" (builtins.toJSON {
            acls = [
              {
                action = "accept";
                src = ["ecklf@"];
                dst = ["*:*"];
              }
            ];
          });
        };
      };
    };

    services.nginx.virtualHosts.${domain} = {
      onlySSL = true;
      useACMEHost = config.homelab.baseDomain;
      # Forward public TCP 443 to this dedicated TLS listener, NOT yun:443:
      # the shared listener also hosts other, potentially unauthenticated apps.
      listen = [
        {
          addr = "0.0.0.0";
          port = 8443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 8443;
          ssl = true;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      # Authenticate manually before adding routes. Keep control-server DNS local.
      extraSetFlags = lib.optionals (cfg.subnetRoutes != []) [
        "--accept-dns=false"
        "--advertise-routes=${lib.concatStringsSep "," cfg.subnetRoutes}"
      ];
    };
    networking.firewall = {
      allowedTCPPorts = [8443];
      checkReversePath = "loose";
    };
  };
}
