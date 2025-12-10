({
  system,
  lib,
  config,
  username,
  hostname,
  ...
}: {
  options.homelab.homepage = {
    enable = lib.mkEnableOption {
      description = "Enable homepage service";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = "The port for the homepage service";
    };
  };

  config = lib.mkIf config.homelab.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = config.homelab.homepage.port;
      environmentFile = config.sops.secrets."homepage_dashboard".path;
      settings = {
        title = "云端控制台";
        favicon = "https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/png/heimdall.png";
        headerStyle = "boxedWidgets";
        theme = "dark";
        color = "zinc";
        customCSS = ''
          body, html {
            font-family: SF Pro Display, Helvetica, Arial, sans-serif !important;
          }
          .font-medium {
            font-weight: 700 !important;
          }
          .font-light {
            font-weight: 500 !important;
          }
          .font-thin {
            font-weight: 400 !important;
          }
          #information-widgets {
            padding-left: 1.5rem;
            padding-right: 1.5rem;
          }
          div#footer {
            display: none;
          }
          .services-group.basis-full.flex-1.px-1.-my-1 {
            padding-bottom: 3rem;
          };
        '';
        layout = [
          {
            Services = {
              style = "row";
              columns = 3;
            };
          }
          {
            Storage = {
              style = "row";
              columns = 2;
            };
          }
        ];
      };
      services = [
        {
          Services = lib.flatten ([]
            ++ lib.optional config.homelab.immich.enable [
              {
                Immich = {
                  icon = "immich.png";
                  href = "https://immich.${config.homelab.baseDomain}";
                  description = "Photo Management";
                  widget = {
                    # Immich server major version
                    version = 2;
                    type = "immich";
                    url = "http://127.0.0.1:${toString config.homelab.immich.port}";
                    key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}";
                  };
                };
              }
            ]
            ++ lib.optional config.homelab.jellyfin.enable [
              {
                Jellyfin = {
                  icon = "jellyfin.png";
                  href = "https://jellyfin.${config.homelab.baseDomain}";
                  description = "Media Server";
                  widget = {
                    type = "jellyfin";
                    url = "http://127.0.0.1:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                  };
                };
              }
            ]
            ++ lib.optional config.homelab.paperless.enable [
              {
                Paperless-ngx = {
                  icon = "paperless.png";
                  href = "https://paperless.${config.homelab.baseDomain}";
                  description = "Document Management";
                  widget = {
                    type = "paperlessngx";
                    url = "http://127.0.0.1:${toString config.homelab.paperless.port}";
                    key = "{{HOMEPAGE_VAR_PAPERLESS_API_KEY}}";
                  };
                };
              }
            ]);
        }
      ];
      widgets = lib.flatten ([]
        ++ lib.optional config.homelab.glances.enable [
          {
            glances = {
              url = "https://glances.${config.homelab.baseDomain}";
              version = 4;
              cpu = true;
              mem = true;
              cputemp = true; # disabled by default
              uptime = true; # disabled by default
              expanded = false; # show the expanded view
              disk = "/storage"; # disabled by default, use mount point of disk(s) in glances. Can also be a list (see below)
              diskUnits = "bytes"; # optional, bytes (default) or bbytes. Only applies to disk
              # label = "MyMachine"; # optional
            };
          }
        ]
        ++ [
          {
            datetime = {
              text_size = "md";
              format = {
                dateStyle = "short";
                timeStyle = "short";
              };
            };
          }
          {
            openmeteo = {
              label = "Munich";
              latitude = 48.1351;
              longitude = 11.5820;
              timezone = "Europe/Berlin";
              units = "metric";
              cache = 5;
              maximumFractionDigits = 1;
            };
          }
        ]);
      bookmarks = [
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/";
                }
              ];
            }
          ];
        }
      ];
    };
  };
})
