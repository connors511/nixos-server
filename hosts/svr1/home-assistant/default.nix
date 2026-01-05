{config, pkgs, ...}: let
  homeassistantHost = "homeassistant.mlad.dk";

  homeassistantRoot = "/var/lib/hass";
  homeassistantVersion = "2024.6.1";

in {
imports = [
#./custom.nix
./blueprints
./postgres.nix
./weather.nix
./zones.nix
];
    services.home-assistant = {
        enable = true;
        package = (pkgs.home-assistant.override { extraPackages = ps: [ ps.psycopg2 ]; });
      };

      services.home-assistant.extraComponents = [ "pushover" "mqtt" "sun" "hue" "tuya" ];
      services.home-assistant.config =
        let
          hiddenEntities = [
            "sensor.last_boot"
            "sensor.date"
          ];
        in
        {
          frontend = { };
          http = {
            use_x_forwarded_for = true;
            trusted_proxies = [
              "127.0.0.1"
              "::1"
            ];
          };
          history.exclude = {
            entities = hiddenEntities;
            domains = [
              "automation"
              "updater"
            ];
          };
          "map" = { };
          shopping_list = { };
          backup = { };
          logbook.exclude.entities = hiddenEntities;
          logger.default = "info";
          sun = { };
          prometheus.filter.include_domains = [ "persistent_notification" ];
#          device_tracker = [
#            {
#              platform = "luci";
#              host = "rauter.r";
#              username = "!secret openwrt_user";
#              password = "!secret openwrt_password";
#            }
#          ];
          config = { };
          mobile_app = { };

          cloud = { };
          network = { };
          zeroconf = { };
          system_health = { };
          default_config = { };
          system_log = { };
#          sensor = [
#            {
#              platform = "template";
#              sensors.shannan_joerg_distance.value_template = ''{{ distance('person.jorg_thalheim', 'person.shannan_lekwati') | round(2) }}'';
#              sensors.joerg_last_updated = {
#                friendly_name = "Jörg's last location update";
#                value_template = ''{{ states.person.jorg_thalheim.last_updated.strftime('%Y-%m-%dT%H:%M:%S') }}Z'';
#                device_class = "timestamp";
#              };
#              sensors.shannan_last_updated = {
#                friendly_name = "Shannan's last location update";
#                value_template = ''{{ states.person.shannan_lekwati.last_updated.strftime('%Y-%m-%dT%H:%M:%S') }}Z'';
#                device_class = "timestamp";
#              };
#            }
#          ];
        };

      services.nginx.virtualHosts."${homeassistantHost}" = {
        extraConfig = ''
          proxy_buffering off;
        '';

        enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
#        locations."/".extraConfig = ''
#          proxy_pass http://127.0.0.1:8123;
#          proxy_set_header Host $host;
#          proxy_redirect http:// https://;
#          proxy_http_version 1.1;
#          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#          proxy_set_header Upgrade $http_upgrade;
#          proxy_set_header Connection $connection_upgrade;
#        '';
      };

      sops.secrets."home-assistant" = {
        sopsFile = ./../secrets/home-assistant;
        owner = "hass";
        format = "binary";
        path = "${homeassistantRoot}/secrets.yaml";
        restartUnits = [ "home-assistant.service" ];
      };



  environment.persistence."/persist".directories = [
    {
      directory = homeassistantRoot;
      user = "hass";
      group = "hass";
#      mode = "0750";
    }
  ];
}
