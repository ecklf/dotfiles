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
  ];
  options.homelab = {
    enable = lib.mkEnableOption "The homelab services and configuration variables";
    timeZone = lib.mkOption {
      default = "Europe/Berlin";
      type = lib.types.str;
      description = "Timezone used for homelab services";
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      description = "Base domain to access homelab services via reverse proxy";
    };
  };
})
