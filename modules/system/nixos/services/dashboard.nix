({
  system,
  lib,
  config,
  username,
  hostname,
  timezone,
  ...
}: {
  options.homelab.dashboard = {
    enable = lib.mkEnableOption {
      description = "Enable glance dashboard service";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "The port for the glance dashboard service";
    };
  };

  config = lib.mkIf config.homelab.dashboard.enable {
    services.glance = {
      enable = true;
      settings = {
        server.port = config.homelab.dashboard.port;
        environmentFile = config.sops.secrets."dashboard".path;
        pages = [
          {
            name = "Startpage";
            width = "slim";
            hide-desktop-navigation = true;
            center-vertically = true;
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    autofocus = true;
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
                      {
                        title = "Immich";
                        url = "http://127.0.0.1:${toString config.homelab.immich.port}";
                        icon = "si:immich";
                      }
                      {
                        title = "Jellyfin";
                        url = "http://127.0.0.1:8096";
                        icon = "si:jellyfin";
                      }
                      {
                        title = "Paperless";
                        url = "http://127.0.0.1:${toString config.homelab.paperless.port}";
                        icon = "si:paperlessngx";
                      }
                      # {
                      #   title = "Gitea";
                      #   url = "https://gitea.${config.homelab.baseDomain}";
                      #   icon = "si:gitea";
                      # }
                      # {
                      #   title = "qBittorrent";
                      #   url = "https://qtorrent.${config.homelab.baseDomain}";
                      #   icon = "si:qbittorrent";
                      # }
                      # {
                      #   title = "AdGuard Home";
                      #   url = "https://adguard.${config.homelab.baseDomain}";
                      #   icon = "si:adguard";
                      # }
                      # {
                      #   title = "Vaultwarden";
                      #   url = "https://vault.${config.homelab.baseDomain}";
                      #   icon = "si:vaultwarden";
                      # }
                    ];
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "General";
                        links = [
                          {
                            title = "Gmail";
                            url = "https://mail.google.com/mail/u/0/";
                          }
                          {
                            title = "Amazon";
                            url = "https://www.amazon.com/";
                          }
                          {
                            title = "Github";
                            url = "https://github.com/";
                          }
                        ];
                      }
                      {
                        title = "Entertainment";
                        links = [
                          {
                            title = "YouTube";
                            url = "https://www.youtube.com/";
                          }
                          {
                            title = "Prime Video";
                            url = "https://www.primevideo.com/";
                          }
                          {
                            title = "Disney+";
                            url = "https://www.disneyplus.com/";
                          }
                        ];
                      }
                      {
                        title = "Social";
                        links = [
                          {
                            title = "Reddit";
                            url = "https://www.reddit.com/";
                          }
                          {
                            title = "Twitter";
                            url = "https://twitter.com/";
                          }
                          {
                            title = "Instagram";
                            url = "https://www.instagram.com/";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
})
