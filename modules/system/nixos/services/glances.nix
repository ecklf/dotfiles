({
  system,
  lib,
  config,
  username,
  hostname,
  ...
}: {
  options.homelab.glances = {
    enable = lib.mkEnableOption {
      description = "Enable glances service";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "The port of the service";
    };
  };

  config = lib.mkIf config.homelab.glances.enable {
    services.glances = {
      enable = true;
      openFirewall = false;
      port = config.homelab.glances.port;
      extraArgs = [
        "--webserver"
        "--time"
        "5"
      ];
    };
  };
})
