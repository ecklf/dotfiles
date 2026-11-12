{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.homelab.headscale;
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
      address = "0.0.0.0";
      port = 8443;
      settings = {
        # The real hostname is supplied by the required runtime EnvironmentFile.
        server_url = "https://headscale.invalid";
        # Native TLS keeps the encrypted hostname out of Nginx/Nix store configs.
        # UniFi must forward public TCP 443 directly to this TLS listener.
        tls_letsencrypt_challenge_type = "TLS-ALPN-01";
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

    sops.templates."headscale.env" = {
      mode = "0400";
      restartUnits = ["headscale.service"];
      content = ''
        HEADSCALE_SERVER_URL=https://${config.sops.placeholder.dyn_dns_domain}
        HEADSCALE_TLS_LETSENCRYPT_HOSTNAME=${config.sops.placeholder.dyn_dns_domain}
      '';
    };
    systemd.services.headscale.serviceConfig = {
      EnvironmentFile = config.sops.templates."headscale.env".path;
      ExecStartPre = pkgs.writeShellScript "headscale-check-hostname" ''
        case "$HEADSCALE_TLS_LETSENCRYPT_HOSTNAME" in
          ""|*[!a-zA-Z0-9.-]*|.*|*.)
            echo "dyn_dns_domain must be a bare DNS hostname, without a URL scheme, port, or path" >&2
            exit 1
            ;;
        esac
        if [ "$HEADSCALE_SERVER_URL" != "https://$HEADSCALE_TLS_LETSENCRYPT_HOSTNAME" ]; then
          echo "Headscale URL and certificate hostname must match" >&2
          exit 1
        fi
      '';
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
