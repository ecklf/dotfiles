({
  pkgs,
  username,
  ...
}: let
  scriptFiles = [
    ./../../scripts/patch-screencapture-approvals.sh
    ./../../scripts/patch-default-apps.sh
  ];
  activationScript = builtins.concatStringsSep "\n" (map (file: builtins.readFile file) scriptFiles);
in {
  homebrewModules = {
    personal = true;
    work = false;
    disk = true;
    photography = true;
    movie = true;
    music = true;
    latex = true;
    downloader = true;
    tax = true;
    language = true;
    wine = true;
    game = true;
  };

  system.activationScripts.preActivation = {
    enable = true;
    text = ''
      if [ ! -L "/usr/local/bin/gsed" ]; then
        sudo ln -s "$(which sed)" /usr/local/bin/gsed
        echo "Symbolic link created for gsed."
      fi

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

  system.activationScripts.extraActivation = {
    enable = true;
    text = activationScript;
  };

  services = {
    postgresql = {
      enable = true;
      initdbArgs = ["-U ${username}" "--pgdata=/var/lib/postgresql/15" "--auth=trust" "--no-locale" "--encoding=UTF8"];
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
    systemPackages = [
      pkgs.coreutils
      pkgs.master.duti
    ];
  };

  fonts = {
    packages = [
      pkgs.inter
      (pkgs.nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "GeistMono"
        ];
      })
    ];
  };
})
