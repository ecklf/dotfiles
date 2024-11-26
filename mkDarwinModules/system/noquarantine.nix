({
  lib,
  config,
  ...
}: {
  options = {
    noquarantine.enable = lib.mkEnableOption "Disables LSQuarantine";
  };

  config = lib.mkIf config.noquarantine.enable {
    system = {
      defaults = {
        LaunchServices = {
          LSQuarantine = false;
        };
      };
    };
  };
})
