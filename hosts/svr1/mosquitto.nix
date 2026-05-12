{
  config,
  pkgs,
  ...
}: {
  sops.secrets."mqtt/pass/zigbee2mqtt" = {
    sopsFile = ../common/secrets.yaml;
    owner = "mosquitto";
    group = "mosquitto";
  };
  sops.secrets."mqtt/pass/hass" = {
    sopsFile = ../common/secrets.yaml;
    owner = "mosquitto";
    group = "mosquitto";
  };

  sops.secrets."mqtt/pass/watts" = {
    sopsFile = ../common/secrets.yaml;
    owner = "mosquitto";
    group = "mosquitto";
  };
  sops.secrets."mqtt/pass/espaltherma" = {
    sopsFile = ../common/secrets.yaml;
    owner = "mosquitto";
    group = "mosquitto";
  };

  sops.secrets."mqtt/pass/govee" = {
    sopsFile = ../common/secrets.yaml;
    owner = "mosquitto";
    group = "mosquitto";
  };
  sops.secrets."mqtt/pass/teslamate" = {
    sopsFile = ../common/secrets.yaml;
    owner = "mosquitto";
    group = "mosquitto";
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
          address = "0.0.0.0";
          settings.allow_anonymous = true;
          omitPasswordAuth = false;
          acl = [ "topic readwrite #" ];

          users.hass = {
            acl = [
              "readwrite #"
            ];
            passwordFile = config.sops.secrets."mqtt/pass/hass".path;
          };
          users.watts = {
            acl = [
              "readwrite #"
            ];
            passwordFile = config.sops.secrets."mqtt/pass/watts".path;
          };
          users.espaltherma = {
            acl = [
              "readwrite #"
            ];
            passwordFile = config.sops.secrets."mqtt/pass/espaltherma".path;
          };
          users.govee = {
            acl = [
              "readwrite #"
            ];
            passwordFile = config.sops.secrets."mqtt/pass/govee".path;
          };
          users.teslamate = {
            acl = [
              "readwrite #"
            ];
            passwordFile = config.sops.secrets."mqtt/pass/teslamate".path;
          };

#          users."${config.services.zigbee2mqtt.settings.advanced.mqtt.user}" = {
          users.zigbee2mqtt = {
            acl = [
              "readwrite #"
            ];
            passwordFile = config.sops.secrets."mqtt/pass/zigbee2mqtt".path;
          };
      }
    ];
  };

    networking.firewall = {
      allowedTCPPorts = [ 1883 ];
    };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/mosquitto";
      user = "mosquitto";
      group = "mosquitto";
    }
  ];
}
