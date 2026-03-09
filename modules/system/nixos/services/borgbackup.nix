{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.homelab.borgbackup;
  # Build the repo URL dynamically using a script
  borgWrapper = pkgs.writeShellScript "borg-wrapper" ''
    BORG_HOST=$(cat ${cfg.sshHostFile})
    BORG_USER=$(cat ${cfg.sshUserFile})
    BORG_PORT=$(cat ${cfg.sshPortFile})
    export BORG_REPO="ssh://$BORG_USER@$BORG_HOST:$BORG_PORT/./backups/$1"
    shift
    exec ${pkgs.borgbackup}/bin/borg "$@"
  '';
in {
  options.homelab.borgbackup = {
    enable = lib.mkEnableOption "Enable borgbackup for homelab services";
    sshHostFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing SSH host for the remote borg repository";
    };
    sshUserFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing SSH user for the remote borg repository";
    };
    sshPortFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing SSH port for the remote borg repository";
    };
    immich = {
      enable = lib.mkEnableOption "Enable borgbackup for immich";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create a systemd service for immich backup instead of using services.borgbackup.jobs
    # This allows us to read secrets at runtime
    systemd.services.borgbackup-job-immich = lib.mkIf cfg.immich.enable {
      description = "BorgBackup job for immich";
      startAt = "daily";
      path = [pkgs.borgbackup pkgs.openssh];
      environment = {
        BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key -o StrictHostKeyChecking=accept-new";
      };
      serviceConfig = {
        Type = "oneshot";
        PrivateTmp = true;
      };
      script = ''
        # Read secrets
        BORG_HOST=$(cat ${cfg.sshHostFile})
        BORG_USER=$(cat ${cfg.sshUserFile})
        BORG_PORT=$(cat ${cfg.sshPortFile})
        export BORG_REPO="ssh://$BORG_USER@$BORG_HOST:$BORG_PORT/./backups/immich"
        export BORG_PASSCOMMAND="cat ${config.sops.secrets.borg_pass.path}"

        # Immich creates automatic database backups in mediaLocation/backups
        # with format: immich-db-backup-YYYYMMDDTHHMMSS-vX.X.X-pgXX.X.sql.gz
        #
        # We backup:
        # - library, upload, profile: original assets
        # - backups: automatic database dumps from Immich
        #
        # We exclude thumbs and encoded-video as they can be regenerated

        # Create backup
        borg create \
          --compression auto,zstd \
          --exclude '${config.homelab.immich.mediaLocation}/thumbs' \
          --exclude '${config.homelab.immich.mediaLocation}/encoded-video' \
          "::immich-{now}" \
          ${config.homelab.immich.mediaLocation}

        # Prune old backups (keep within 1 day)
        borg prune --keep-within 1d
      '';
    };
  };
}
