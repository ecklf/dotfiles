({
  pkgs,
  username,
  ...
}: let
  isWorkMachine = false;
in {
  homebrewModules = {
    affinity = true;
    developer = true;
    messenger = true;
    monitor = true;
    personal = !isWorkMachine;
    work = isWorkMachine;
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

  activationScriptModules.extraPreActivationScripts = [
    ''
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
    ''
  ];

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
})
