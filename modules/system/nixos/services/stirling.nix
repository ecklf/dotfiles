{
  lib,
  config,
  pkgs,
  ...
}: {
  options.homelab.stirling = {
    enable = lib.mkEnableOption {
      description = "Stirling PDF";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "The port of the service";
    };
  };

  config = lib.mkIf config.homelab.stirling.enable {
    services.stirling-pdf = {
      enable = true;
      package = pkgs.unstable.stirling-pdf;
      environment = {
        SERVER_PORT = config.homelab.stirling.port;
        INSTALL_BOOK_AND_ADVANCED_HTML_OPS = "true";
      };
    };
  };
}
