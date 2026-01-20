{
  lib,
  config,
  ...
}: {
  options.homelab.paperless = {
    enable = lib.mkEnableOption {
      description = "Enable paperless service";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "The port for the paperless service";
    };
    mediaLocation = lib.mkOption {
      type = lib.types.str;
      description = "The media location for the paperless service";
    };
  };

  config = lib.mkIf config.homelab.paperless.enable {
    systemd.services.paperless-setup = {
      description = "Setup paperless directories with correct permissions";
      wantedBy = ["paperless-scheduler.service"];
      before = ["paperless-scheduler.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        mkdir -p ${config.homelab.paperless.mediaLocation}/{media,consume,index,log}
        chown -R paperless:paperless ${config.homelab.paperless.mediaLocation}
        chmod -R 755 ${config.homelab.paperless.mediaLocation}
      '';
    };

    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = config.homelab.paperless.port;
      dataDir = config.homelab.paperless.mediaLocation;
      # These directories might be failing to create on first run
      # Check `journalctl -xe` for paperless logs
      mediaDir = "${config.homelab.paperless.mediaLocation}/media";
      consumptionDir = "${config.homelab.paperless.mediaLocation}/consume";
      passwordFile = config.sops.secrets."paperless_admin_password".path;
      # consumptionDirIsPublic = true;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [
          ".DS_STORE/*"
          "desktop.ini"
        ];
        PAPERLESS_OCR_LANGUAGE = "eng+deu"; # English and German OCR support
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
        };
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
        PAPERLESS_URL = "https://paperless.${config.homelab.baseDomain}";
      };
    };
  };
}
