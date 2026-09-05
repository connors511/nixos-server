# homepage.nix
# NixOS configuration for Homepage dashboard
#
# Secrets: Create an environment file with your API keys:
#   HOMEPAGE_VAR_JELLYFIN_API_KEY=<from Jellyfin Dashboard → API Keys>
#   HOMEPAGE_VAR_SONARR_API_KEY=<from Sonarr → Settings → General>
#   HOMEPAGE_VAR_RADARR_API_KEY=<from Radarr → Settings → General>
#   HOMEPAGE_VAR_LIDARR_API_KEY=<from Lidarr → Settings → General>
#   HOMEPAGE_VAR_PROWLARR_API_KEY=<from Prowlarr → Settings → General>
#   HOMEPAGE_VAR_HA_TOKEN=<Home Assistant long-lived access token>
#
# With agenix, encrypt this file and reference via:
#   environmentFile = config.age.secrets.homepage-env.path;
#
# Without agenix (less secure, for testing):
#   environmentFile = "/etc/homepage/secrets.env";

{ config, ... }:

let
  # Base URLs - adjust IPs/hostnames to match your setup
  homeassistant = "http://homeassistant.lan";
  sonarr = "http://sonarr.lan";
  radarr = "http://radarr.lan";
  lidarr = "http://lidarr.lan";
  prowlarr = "http://prowlarr.lan";
  jellyfin = "http://jellyfin.lan";
  jellyseerr = "http://requests.lan";
  navidrome = "http://navidrome.lan";
  proxmox = "https://proxmox.lan:8006";

in {
#	sops.secrets.homepage-env = {
#	  sopsFile = ./secrets/homepage.env.yaml;
#	  owner = "homepage-dashboard";
#	  group = "homepage-dashboard";
#	};

  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "home.lan,localhost:8082,127.0.0.1:8082";

#  	environmentFile = config.sops.secrets.homepage-env.path;

    settings = {
      title = "mlad.dk";
      favicon = "https://mlad.dk/favicon.ico";
      headerStyle = "clean";

      layout = {
        Media = {
          style = "row";
          columns = 3;
        };
        Downloads = {
          style = "row";
          columns = 3;
        };
        AI = {
          style = "row";
          columns = 2;
        };
        Infrastructure = {
          style = "row";
          columns = 4;
        };
      };
    };

    # Top bar widgets
    widgets = [
      {
        resources = {
          label = "System";
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        datetime = {
          text_size = "xl";
          format = {
            dateStyle = "long";
            timeStyle = "short";
            hourCycle = "h23";
          };
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    services = [
      # ========== MEDIA ==========
      {
        "Media" = [
          {
            "Jellyfin" = {
              icon = "jellyfin";
              href = "http://jellyfin.lan";
              description = "Media streaming";
#              widget = {
#                type = "jellyfin";
#                url = jellyfin;
#                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
#                enableBlocks = true;
#                enableNowPlaying = true;
#              };
            };
          }
          {
            "Seerr" = {
              icon = "jellyseerr";
              href = "http://requests.lan";
              description = "Media requests";
#              widget = {
#                type = "jellyseerr";
#                url = jellyseerr;
#                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
#              };
            };
          }
          {
            "Navidrome" = {
              icon = "navidrome";
              href = "http://navidrome.lan";
              description = "Music";
#              widget = {
#                type = "jellyseerr";
#                url = jellyseerr;
#                key = "{{HOMEPAGE_VAR_JELLYSEERR_API_KEY}}";
#              };
            };
          }
        ];
      }

      # ========== DOWNLOADS / ARR STACK ==========
      {
        "Downloads" = [
          {
            "Sonarr" = {
              icon = "sonarr";
              href = "http://sonarr.lan";
              description = "TV Shows";
#              widget = {
#                type = "sonarr";
#                url = sonarr;
#                key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
#                enableQueue = true;
#              };
            };
          }
          {
            "Radarr" = {
              icon = "radarr";
              href = "http://radarr.lan";
              description = "Movies";
#              widget = {
#                type = "radarr";
#                url = radarr;
#                key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
#                enableQueue = true;
#              };
            };
          }
          {
            "Lidarr" = {
              icon = "lidarr";
              href = "http://lidarr.lan";
              description = "Music";
#              widget = {
#                type = "lidarr";
#                url = lidarr;
#                key = "{{HOMEPAGE_VAR_LIDARR_API_KEY}}";
#              };
            };
          }
          {
            "Prowlarr" = {
              icon = "prowlarr";
              href = "http://prowlarr.lan";
              description = "Indexer manager";
#              widget = {
#                type = "prowlarr";
#                url = prowlarr;
#                key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
#              };
            };
          }
          {
            "Bazarr" = {
              icon = "bazarr";
              href = "http://bazarr.lan";
              description = "Subtitle manager";
            };
          }
          {
            "NZBGet" = {
              icon = "nzbget";
              href = "http://nzbget.lan";
              description = "Usenet downloader";
            };
          }
        ];
      }

      # ========== AI ==========
      {
        "AI" = [
          {
            "Open WebUI" = {
              icon = "open-webui";
              href = "http://chat.lan";
              description = "AI chat";
            };
          }
          {
            "SearXNG" = {
              icon = "searxng";
              href = "http://search.lan";
              description = "Private metasearch";
            };
          }
        ];
      }

      # ========== INFRASTRUCTURE ==========
      {
        "Infrastructure" = [
          {
            "Home Assistant" = {
              icon = "home-assistant";
              href = "http://ha.lan";
              description = "Home automation";
#              widget = {
#                type = "homeassistant";
#                url = homeassistant;
#                key = "{{HOMEPAGE_VAR_HA_TOKEN}}";
#              };
            };
          }
          {
            "Proxmox 01" = {
              icon = "proxmox";
              href = proxmox;
              description = "Virtualization";
#              widget = {
#                type = "proxmox";
#                url = proxmox;
#                username = "api@pam!homepage";
#                password = "{{HOMEPAGE_VAR_PROXMOX_TOKEN}}";
#              };
            };
          }
          {
            "Proxmox 02" = {
              icon = "proxmox";
              href = "https://proxmox02:8006/";
              description = "Virtualization";
            };
          }
          {
            "Proxmox 03" = {
              icon = "proxmox";
              href = "https://proxmox03:8006/";
              description = "Virtualization";
            };
          }
          {
            "Grafana" = {
              icon = "grafana";
              href = "http://grafana.lan";
              description = "Monitoring dashboards";
            };
          }
        ];
      }

      # ========== NETWORK / MONITORING ==========
      {
        "Network" = [
          {
            "OPNsense" = {
              icon = "opnsense";
              href = "https://opnsense.lan/";
              description = "Router/Firewall";
            };
          }
          {
            "AdGuard Home" = {
              icon = "adguard-home";
              href = "http://opnsense.lan:3000/";
              description = "DNS ad blocking";
            };
          }
        ];
      }
    ];

    # Bookmarks section (optional - quick links without widgets)
    bookmarks = [
      {
        "Quick Links" = [
          { "GitHub" = [{ icon = "github"; href = "https://github.com"; }]; }
          { "Cloudflare" = [{ icon = "cloudflare"; href = "https://dash.cloudflare.com"; }]; }
        ];
      }
    ];
  };
}
