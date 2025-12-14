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
        branding = {
          hide-desktop-navigation = true;
          show-mobile-header = true;
          hide-footer = true;
          logo-text = "云";
          app-name = "${username}@${hostname}";
          # favicon-url = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/home-assistant.png";
          # app-icon-url = "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/dashboard.png";
          app-background-color = "#0A0A0A";
        };
        pages = [
          {
            name = "Home";
            hide-desktop-navigation = true;
            show-mobile-header = true;
            hide-footer = true;
            head-widgets = [
              {
                type = "server-stats";
                hide-header = true;
                servers = [
                  {
                    type = "local";
                    name = "云端控制台";
                    hide-mountpoints-by-default = true;
                    mountpoints = {
                      "/" = {
                        hide = false;
                      };
                      "/storage/set1" = {
                        hide = false;
                      };
                    };
                  }
                ];
              }
            ];

            columns = [
              {
                size = "small";
                widgets = [
                  # {
                  #   type = "custom-api";
                  #   title = "Network Speedtest";
                  #   title-url = "\${NETWORK_SPEEDTEST_URL}";
                  #   url = "\${NETWORK_SPEEDTEST_URL}/api/v1/results/latest";
                  #   headers = {
                  #     Authorization = "\${NETWORK_SPEEDTEST_API_KEY}";
                  #     Accept = "application/json";
                  #   };
                  #   subrequests = {
                  #     stats = {
                  #       url = "\${NETWORK_SPEEDTEST_URL}/api/v1/stats";
                  #       headers = {
                  #         Authorization = "\${NETWORK_SPEEDTEST_API_KEY}";
                  #         Accept = "application/json";
                  #       };
                  #     };
                  #   };
                  #   options = {
                  #     showPercentageDiff = true;
                  #   };
                  #   template = ''
                  #     {{ $showPercentage := .Options.BoolOr "showPercentageDiff" true }}

                  #     {{ $stats := .Subrequest "stats" }}
                  #     <div class="flex justify-between text-center margin-block-3">
                  #     <div>
                  #         <div class="color-highlight size-h3">{{ .JSON.Float "data.download_bits" | mul 0.000001 | printf "%.2f" }}</div>
                  #         <div class="size-h6">DOWNLOAD</div>
                  #     </div>
                  #     <div>
                  #         <div class="color-highlight size-h3">{{ .JSON.Float "data.upload_bits" | mul 0.000001 | printf "%.2f" }}</div>
                  #         <div class="size-h6">UPLOAD</div>
                  #     </div>
                  #     <div>
                  #         <div class="color-highlight size-h3">{{ .JSON.Float "data.ping" | printf "%.2f ms" }}</div>
                  #         <div class="size-h6">PING</div>
                  #     </div>
                  #     </div>
                  #   '';
                  # }
                  # {
                  #   type = "dns-stats";
                  #   service = "adguard";
                  #   url = "\${ADGUARD_HOME_URL}";
                  #   username = "\${ADGUARD_HOME_USERNAME}";
                  #   password = "\${ADGUARD_HOME_PASSWORD}";
                  # }
                  # {
                  #   type = "custom-api";
                  #   title = "Immich stats";
                  #   cache = "1d";
                  #   url = "\${IMMICH_HOME_URL}/api/server/statistics";
                  #   headers = {
                  #     x-api-key = "\${IMMICH_HOME_API_KEY}";
                  #     Accept = "application/json";
                  #   };
                  #   template = ''
                  #     <div class="flex justify-between text-center">
                  #       <div>
                  #           <div class="color-highlight size-h3">{{ .JSON.Int "photos" | formatNumber }}</div>
                  #           <div class="size-h6">PHOTOS</div>
                  #       </div>
                  #       <div>
                  #           <div class="color-highlight size-h3">{{ .JSON.Int "videos" | formatNumber }}</div>
                  #           <div class="size-h6">VIDEOS</div>
                  #       </div>
                  #       <div>
                  #           <div class="color-highlight size-h3">{{ div (.JSON.Int "usage" | toFloat) 1073741824 | toInt | formatNumber }}GB</div>
                  #           <div class="size-h6">USAGE</div>
                  #       </div>
                  #     </div>
                  #   '';
                  # }
                  # {
                  #   type = "custom-api";
                  #   title = "Nextcloud Stats";
                  #   cache = "1d";
                  #   url = "\${NEXTCLOUD_HOME_URL}/ocs/v2.php/apps/serverinfo/api/v1/info?format=json";
                  #   headers = {
                  #     OCS-APIRequest = "true";
                  #     Authorization = "\${NEXTCLOUD_HOME_API_KEY}";
                  #     Accept = "application/json";
                  #     User-Agent = "GlanceWidget/1.0";
                  #   };
                  #   template = ''
                  #     <div class="flex justify-between text-center">
                  #       <div>
                  #         <div class="color-highlight size-h3">{{ div (.JSON.Result.Get "ocs.data.nextcloud.system.freespace").Float 1073741824 | toInt | formatNumber }}GB</div>
                  #         <div class="size-h6">FREE SPACE</div>
                  #     </div>
                  #       <div>
                  #           <div class="color-highlight size-h3">{{ (.JSON.Result.Get "ocs.data.nextcloud.storage.num_users").Int | formatNumber }}</div>
                  #           <div class="size-h6">USERS</div>
                  #       </div>
                  #       <div>
                  #           <div class="color-highlight size-h3">{{ (.JSON.Result.Get "ocs.data.nextcloud.storage.num_files").Int | formatNumber }}</div>
                  #           <div class="size-h6">FILES</div>
                  #       </div>
                  #     </div>
                  #   '';
                  # }
                  {
                    type = "search";
                    search-engine = "google";
                    target = "_self";
                  }
                  {
                    type = "to-do";
                  }
                  {
                    type = "releases";
                    show-source-icon = true;
                    repositories = [
                      "immich-app/immich"
                      "jellyfin/jellyfin"
                      "paperless-ngx/paperless-ngx"
                      "Stirling-Tools/Stirling-PDF"
                      # "glanceapp/glance"
                      # "go-gitea/gitea"
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  # {
                  #   type = "monitor";
                  #   cache = "1m";
                  #   title = "Networking & Internet";
                  #   sites = [
                  #      {
                  #        title = "AdGuard Home";
                  #        same-tab = true;
                  #        timeout = "5s";
                  #        url = "https://adguard.\${YOUR_BASE_DOMAIN}/";
                  #        icon = "di:adguard-home.png";
                  #      }
                  #      {
                  #        title = "Nginx Proxy Manager";
                  #        same-tab = true;
                  #        timeout = "5s";
                  #        url = "https://nginx.\${YOUR_BASE_DOMAIN}/";
                  #        icon = "di:nginx-proxy-manager.png";
                  #      }
                  #      {
                  #        title = "Speedtest Tracker";
                  #        same-tab = true;
                  #        timeout = "5s";
                  #        url = "https://speedtest.\${YOUR_BASE_DOMAIN}/";
                  #        icon = "di:speedtest-tracker.png";
                  #      }
                  #      {
                  #        title = "Zero Trust Dashboard";
                  #        same-tab = true;
                  #        timeout = "5s";
                  #        url = "https://one.dash.cloudflare.com/\${ZERO_TRUST_USER_ID}/home/quick-start";
                  #        icon = "di:cloudflare-zero-trust.png";
                  #      }
                  #   ];
                  # }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Productivity & Files";
                    sites = lib.flatten (
                      []
                      ++ lib.optional config.homelab.immich.enable [
                        {
                          title = "Immich";
                          url = "https://immich.${config.homelab.baseDomain}";
                          icon = "si:immich";
                        }
                      ]
                      ++ lib.optional config.homelab.jellyfin.enable [
                        {
                          title = "Jellyfin";
                          url = "https://jellyfin.${config.homelab.baseDomain}";
                          icon = "si:jellyfin";
                        }
                      ]
                      ++ lib.optional config.homelab.paperless.enable [
                        {
                          title = "Paperless";
                          url = "https://paperless.${config.homelab.baseDomain}";
                          icon = "si:paperlessngx";
                        }
                      ]
                      ++ lib.optional config.homelab.stirling.enable [
                        {
                          title = "Stirling PDF";
                          url = "https://stirling.${config.homelab.baseDomain}";
                          icon = "si:googledocs";
                        }
                      ]
                    );
                  }
                  # {
                  #   type = "monitor";
                  #   cache = "1m";
                  #   title = "Development & Management";
                  #   sites = [
                  #     {
                  #       title = "Cockpit";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://cockpit.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:cockpit.png";
                  #     }
                  #     {
                  #       title = "Code Server";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://vscode.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:vscode.png";
                  #     }
                  #     {
                  #       title = "Gitea";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://gitea.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:gitea.png";
                  #     }
                  #     {
                  #       title = "Mazanoke";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://mazanoke.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:mazanoke.png";
                  #     }
                  #     {
                  #       title = "Portainer";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://portainer.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:portainer.png";
                  #     }
                  #     {
                  #       title = "Termix";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://termix.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/png/termix.png";
                  #     }
                  #     {
                  #       title = "Warracker";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://warracker.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:warracker.png";
                  #     }
                  #   ];
                  # }
                  # {
                  #   type = "monitor";
                  #   cache = "1m";
                  #   title = "Monitoring & Utilities";
                  #   sites = [
                  #     {
                  #       title = "Uptime Kuma";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://kuma.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:uptime-kuma.png";
                  #     }
                  #     {
                  #       title = "What's up Docker?";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://wud.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:whats-up-docker.png";
                  #     }
                  #     {
                  #       title = "Your Spotify";
                  #       same-tab = true;
                  #       timeout = "5s";
                  #       url = "https://yourspotify.\${YOUR_BASE_DOMAIN}/";
                  #       icon = "di:your-spotify.png";
                  #     }
                  #   ];
                  # }

                  (let
                    sharedRedditProps = {
                      type = "reddit";
                      show-thumbnails = false;
                      collapse-after = 5;
                    };
                  in {
                    type = "group";
                    widgets = [
                      (sharedRedditProps // {subreddit = "apple";})
                      (sharedRedditProps // {subreddit = "selfhosted";})
                      (sharedRedditProps // {subreddit = "homelab";})
                    ];
                  })
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "clock";
                    hide-header = true;
                    time-format = "24h";
                    date-format = "d MMMM yyyy";
                    show-seconds = true;
                    show-timezone = true;
                    timezone = timezone;
                  }
                  {
                    type = "weather";
                    location = "Munich, Germany";
                    units = "metric";
                    hour-format = "24h";
                    hide-location = true;
                    show-area-name = false;
                  }
                  {
                    type = "calendar";
                    first-day-of-week = "monday";
                  }
                ];
              }
            ];
          }
        ];
      };
    };
    # Environment file for secrets
    # systemd.services.glance.serviceConfig.EnvironmentFile = config.sops.secrets."dashboard".path;
  };
})
