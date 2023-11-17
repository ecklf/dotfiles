({ pkgs, username, hostname, ... }: {
  system.activationScripts.preActivation = {
    enable = true;
    text = ''
      if [ ! -d "/var/lib/postgresql/" ]; then
        echo "creating PostgreSQL data directory..."
        sudo mkdir -m 750 -p /var/lib/postgresql/
        chown -R ${username}:staff /var/lib/postgresql/
      fi
      if [ ! -d "/var/lib/redis/" ]; then
        echo "creating Redis data directory..."
        sudo mkdir -m 750 -p /var/lib/redis/
        chown -R ${username}:staff /var/lib/redis/
      fi
    '';
  };

  services = {
    postgresql = {
      enable = true;
      initdbArgs = [ "-U ${username}" "--pgdata=/var/lib/postgresql/15" "--auth=trust" "--no-locale" "--encoding=UTF8" ];
      package = pkgs.postgresql_15;
      # TODO(ecklf) automate this
      # psql postgres -c "CREATE USER postgres WITH PASSWORD 'postgres';"
      # psql postgres -c "ALTER USER postgres WITH SUPERUSER;"
      # createdb asdf
    };
    redis = {
      enable = true;
    };
  };

  launchd.user.agents.postgresql.serviceConfig = {
    StandardErrorPath = "/tmp/postgres.error.log";
    StandardOutPath = "/tmp/postgres.log";
  };

  environment = {
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
    shells = [ pkgs.bash pkgs.zsh ];
    loginShell = pkgs.zsh;
    systemPackages = [
      # pkgs.cfssl
      # pkgs.darwin.libiconv # required for -liconv mitmproxy compilation
      # pkgs.httpie
      # pkgs.lima
      # pkgs.mitmproxy
      # pkgs.nats-server
      # pkgs.natscli
      # pkgs.redis
      # pkgs.vector
      # pkgs.watchman
      pkgs.neofetch
      pkgs.ack
      pkgs.act
      pkgs.age
      pkgs.ansible
      pkgs.bitwarden-cli
      pkgs.caddy
      pkgs.cairo
      pkgs.cargo
      pkgs.cargo-nextest
      pkgs.certstrap
      pkgs.cmake
      pkgs.coreutils
      pkgs.curl
      pkgs.dbmate
      pkgs.direnv
      pkgs.dive
      pkgs.emacs
      pkgs.eza
      pkgs.fd
      pkgs.ffmpeg
      pkgs.fnm
      pkgs.fx
      pkgs.fzf
      pkgs.gawk
      pkgs.gh
      pkgs.git
      pkgs.git-lfs
      pkgs.gitui
      pkgs.glow
      pkgs.gnupg
      pkgs.gnused
      pkgs.gnutls
      pkgs.go
      pkgs.gomplate
      pkgs.graphicsmagick
      pkgs.graphviz
      pkgs.helix
      pkgs.hexyl
      pkgs.htop
      pkgs.httpstat
      pkgs.imagemagick
      pkgs.inetutils
      pkgs.ipcalc
      pkgs.jq
      pkgs.jwt-cli
      pkgs.k3d
      pkgs.k9s
      pkgs.kubectl
      pkgs.lazydocker
      pkgs.lazygit
      pkgs.lnav
      pkgs.mutagen
      pkgs.mutagen-compose
      pkgs.ncdu
      pkgs.neofetch
      pkgs.neovim
      pkgs.ngrok
      pkgs.nix-prefetch-github
      pkgs.nixpkgs-fmt
      pkgs.nmap
      pkgs.nnn
      pkgs.nodePackages_latest.aws-cdk
      pkgs.pandoc
      pkgs.parallel
      pkgs.psutils
      pkgs.python310Packages.huggingface-hub
      pkgs.ripgrep
      pkgs.rustc
      pkgs.scrcpy
      pkgs.smartmontools
      pkgs.stow
      pkgs.stylua
      pkgs.subversion
      pkgs.tmux
      pkgs.tree
      pkgs.trippy
      pkgs.trivy
      pkgs.upx
      pkgs.wget
      pkgs.youtube-dl
      pkgs.yq
      pkgs.yubikey-manager
      pkgs.yubikey-personalization
      pkgs.zellij
      pkgs.zig
      pkgs.zoxide
      pkgs.zsh
    ];
  };

  fonts = {
    # This makes all fonts hard-managed via nix, will delete manually added ones
    fontDir.enable = true;
    fonts =
      [
        (pkgs.nerdfonts.override {
          fonts = [
            # "GeistMono"
            "JetBrainsMono"
          ];
        })
      ];
  };

})
