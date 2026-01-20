{
  lib,
  config,
  pkgs,
  ...
}: {
  options.homelab.immich = {
    enable = lib.mkEnableOption {
      description = "Enable immich service";
    };
    mediaLocation = lib.mkOption {
      type = lib.types.str;
      description = "The media location for immich";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "The port of the service";
    };
  };

  config = lib.mkIf config.homelab.immich.enable {
    users.users.immich.extraGroups = ["video" "render" "nginx"];
    services.immich = {
      package = pkgs.unstable.immich;
      enable = true;
      port = config.homelab.immich.port;
      host = "127.0.0.1"; # Changed to localhost since nginx will proxy
      openFirewall = false; # No need to open port directly
      accelerationDevices = null;
      mediaLocation = config.homelab.immich.mediaLocation;
      settings = {
        newVersionCheck.enabled = true;
      };
      environment = {
        IMMICH_TELEMETRY_EXCLUDE = "host,api,io,repo,job";
      };
    };
  };
}
