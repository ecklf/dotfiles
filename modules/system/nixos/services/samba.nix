{
  lib,
  config,
  username,
  hostname,
  ...
}: {
  options.homelab.samba = {
    enable = lib.mkEnableOption {
      description = "Samba shares";
    };
  };

  config = lib.mkIf config.homelab.samba.enable {
    # Make shares visible for windows 10 clients
    services.samba-wsdd.enable = true;
    services.samba = {
      enable = true;
      openFirewall = true;
      # Post install: run this setup
      # sudo pdbedit -L -v
      # sudo smbpasswd -a nix
      settings = {
        global = {
          "min protocol" = "SMB2";
          "workgroup" = "WORKGROUP";
          "server string" = "%h server (Samba, NixOS)";
          "netbios name" = "${hostname}";
          # "server string" = "nixos";

          # macOS: this prevents ._ AppleDouble files from causing slowdowns
          "vfs objects" = "catia fruit streams_xattr";
          # Try this fix
          "fruit:advertise_fullsync" = "true";
          # Fruit module optimizations for macOS clients
          "fruit:appl" = "yes";
          "fruit:model" = "MacSamba";
          "fruit:metadata" = "stream";
          "fruit:veto_appledouble" = "no";
          "fruit:nfs_aces" = "no";
          "fruit:wipe_intentionally_left_blank_rfork" = "yes ";
          "fruit:delete_empty_adfiles" = "yes";
          "fruit:posix_rename" = "yes";
          "fruit:time machine" = "no";
          # Enable server-side copy support
          # https://wiki.samba.org/index.php/Server-Side_Copy#Introduction
          "fruit:copyfile" = "yes";

          # Security
          "security" = "user";
          # Note: localhost is the ipv6 localhost ::1
          # "hosts allow" = "192.168.0. 127.0.0.1 localhost";
          # "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "server role" = "standalone server";
          "obey pam restrictions" = "yes";
          # This boolean parameter controls whether Samba attempts to sync the Unix
          # password with the SMB password when the encrypted SMB password in the
          # passdb is changed.
          # "unix password sync" = "yes";

          # Performance optimizations
          # "use sendfile" = "yes"; # Enables sendfile syscall for better performance
          # "min receivefile size" = "16384";
          # "aio read size" = "16384"; # Enables async I/O for reads larger than 16KB
          # "aio write size" = "16384"; # Enables async I/O for writes larger than 16KB
          # "getwd cache" = "yes";
          # "strict sync" = "no"; # Don't wait for writes to hit disk (rely on OS cache)
          # "sync always" = "no"; # Improve write performance
          # "strict locking" = "no"; # Reduce locking overhead
          "deadtime" = "60"; # Closes idle connections after 60 minutes to save resources
          # Optimizes TCP connections for better performance - increased buffer sizes
          # "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=524288 SO_SNDBUF=524288";
          "server multi channel support" = "yes"; # Enable SMB3 multi-channel support for better throughput
          # Reduce logging overhead
          "log level" = "0";
          # "kernel oplocks" = "yes"; # Better oplock handling for improved caching
        };
        homes = {
          browseable = "no";
          "read only" = "no";
          "guest ok" = "no";
          # File creation mask is set to 0700 for security reasons. If you want to
          # create files with group=rw permissions, set next parameter to 0775.
          "create mask" = "0700";
          # Directory creation mask is set to 0700 for security reasons. If you want to
          # create dirs. with group=rw permissions, set next parameter to 0775.
          "directory mask" = "0700";
          # By default, \\server\username shares can be connected to by anyone
          # with access to the samba server.
          # Un-comment the following parameter to make sure that only "username"
          # can connect to \\server\username
          # This might need tweaking when using external authentication schemes
          "valid users" = "%S";
        };
        public = {
          path = "/storage/set1/public";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0755";
          "directory mask" = "0755";
          "force user" = "${username}";
          "force group" = "wheel";
          # Share-specific performance optimizations
          "strict allocate" = "yes";
          "allocation roundup size" = "4096";
        };
        # hdd = {
        #   path = "/storage/set1/hdd";
        #   browseable = "yes";
        #   "read only" = "no";
        #   "guest ok" = "no";
        #   "create mask" = "0755";
        #   "directory mask" = "0755";
        #   "force user" = "${username}";
        #   "force group" = "wheel";
        #   # Share-specific performance optimizations
        #   "strict allocate" = "yes";
        #   "allocation roundup size" = "4096";
        # };
        camera = {
          path = "/storage/set1/camera";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0755";
          "directory mask" = "0755";
          "force user" = "${username}";
          "force group" = "wheel";
          # Share-specific performance optimizations
          "strict allocate" = "yes";
          "allocation roundup size" = "4096";
        };
      };
    };
  };
}
