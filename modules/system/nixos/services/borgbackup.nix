{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.homelab.borgbackup;
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
    sshKeyPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/ssh/ssh_host_ed25519_key";
      description = "Path to SSH private key for borg remote access";
    };
    passFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing borg passphrase for encrypted backups";
    };
    encryptedFolders = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "Source folder path to backup";
          };
          target = lib.mkOption {
            type = lib.types.str;
            description = "Target folder name in remote backups directory";
          };
          retention = lib.mkOption {
            type = lib.types.str;
            default = "--keep-within 1d";
            description = "Borg prune retention flags (e.g. '--keep-last 1', '--keep-daily 7 --keep-weekly 4')";
          };
          exclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "List of paths to exclude from backup";
          };
        };
      });
      default = {};
      description = "Attrset of encrypted folder backups";
    };
    unencryptedFolders = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "Source folder path to backup";
          };
          target = lib.mkOption {
            type = lib.types.str;
            description = "Target folder name in remote backups directory";
          };
          retention = lib.mkOption {
            type = lib.types.str;
            default = "--keep-within 1d";
            description = "Borg prune retention flags (e.g. '--keep-last 1', '--keep-daily 7 --keep-weekly 4')";
          };
        };
      });
      default = {};
      description = "Attrset of unencrypted folder backups";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create systemd services for backups
    systemd.services =
      # Generic encrypted folder backup services
      (lib.mapAttrs' (name: folderCfg:
        lib.nameValuePair "borgbackup-job-${name}" {
          description = "BorgBackup job for ${name}";
          startAt = "daily";
          path = [pkgs.borgbackup pkgs.openssh];
          environment = {
            BORG_RSH = "ssh -i ${cfg.sshKeyPath} -o StrictHostKeyChecking=accept-new";
          };
          serviceConfig = {
            Type = "oneshot";
            PrivateTmp = true;
          };
          script = let
            excludeFlags = lib.concatMapStringsSep " " (path: "--exclude '${path}'") folderCfg.exclude;
          in ''
            # Read secrets
            BORG_HOST=$(cat ${cfg.sshHostFile})
            BORG_USER=$(cat ${cfg.sshUserFile})
            BORG_PORT=$(cat ${cfg.sshPortFile})
            export BORG_REPO="ssh://$BORG_USER@$BORG_HOST:$BORG_PORT/./backups/${folderCfg.target}"
            export BORG_PASSCOMMAND="cat ${cfg.passFile}"

            # Initialize repo if it doesn't exist (encrypted with repokey)
            borg info :: 2>/dev/null || borg init --encryption=repokey

            # Create backup with compression
            borg create \
              --compression auto,zstd \
              ${excludeFlags} \
              "::${name}-{now}" \
              ${folderCfg.source}

            # Prune old backups
            borg prune ${folderCfg.retention}
          '';
        }
      ) cfg.encryptedFolders)
      # Generic unencrypted folder backup services
      // (lib.mapAttrs' (name: folderCfg:
        lib.nameValuePair "borgbackup-job-${name}" {
          description = "BorgBackup job for ${name}";
          startAt = "daily";
          path = [pkgs.borgbackup pkgs.openssh];
          environment = {
            BORG_RSH = "ssh -i ${cfg.sshKeyPath} -o StrictHostKeyChecking=accept-new";
            BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
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
            export BORG_REPO="ssh://$BORG_USER@$BORG_HOST:$BORG_PORT/./backups/${folderCfg.target}"

            # Initialize repo if it doesn't exist (unencrypted)
            borg info :: 2>/dev/null || borg init --encryption=none

            # Create backup with compression
            borg create \
              --compression auto,zstd \
              "::${name}-{now}" \
              ${folderCfg.source}

            # Prune old backups
            borg prune ${folderCfg.retention}
          '';
        }
      ) cfg.unencryptedFolders);
  };
}
