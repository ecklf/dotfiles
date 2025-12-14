({
  system,
  lib,
  config,
  username,
  hostname,
  ...
}: {
  options.homelab.jellyfin = {
    enable = lib.mkEnableOption {
      description = "Enable jellyfin service";
    };
    mediaLocation = lib.mkOption {
      type = lib.types.str;
      description = "The media location for jellyfin";
    };
  };

  config = lib.mkIf config.homelab.jellyfin.enable {
    users.users.jellyfin.extraGroups = ["video" "render" "nginx"];

    systemd.services.jellyfin-setup = {
      description = "Setup jellyfin directories with correct permissions";
      wantedBy = ["jellyfin.service"];
      before = ["jellyfin.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p ${config.homelab.jellyfin.mediaLocation}/{data,cache,data/config,data/log}
        chown -R jellyfin:jellyfin ${config.homelab.jellyfin.mediaLocation}
        chmod -R 755 ${config.homelab.jellyfin.mediaLocation}
      '';
    };

    # If the service is not starting debug with `journalctl -xe`
    services.jellyfin = {
      enable = true;
      openFirewall = false; # nginx will handle the proxy
      dataDir = "${config.homelab.jellyfin.mediaLocation}/data";
      cacheDir = "${config.homelab.jellyfin.mediaLocation}/cache";
      # logDir is relative to dataDir by default, so it becomes /storage/set1/service_data/jellyfin/data/log
    };
  };
})
