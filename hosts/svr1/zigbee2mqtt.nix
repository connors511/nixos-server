{
  config,
  lib,
  pkgs,
  ...
}:
 let
   domain = "zigbee";
   cfg = config.services.zigbee2mqtt;
   mqtt_port = 1883;
   remoteHomeAssistant = true;
 in
 {
  sops.secrets."mqtt/secret/zigbee2mqtt" = {
    sopsFile = ../common/secrets.yaml;
    path = "/var/lib/zigbee2mqtt/secret.yaml";
    owner = "${config.systemd.services.zigbee2mqtt.serviceConfig.User}";
    group = "${config.systemd.services.zigbee2mqtt.serviceConfig.Group}";
  };

  sops.secrets."zigbee_network" = {
    sopsFile = ../common/secrets/zigbee-network;
    path = "/var/lib/zigbee2mqtt/network.yaml";
    format = "binary";
    owner = "${config.systemd.services.zigbee2mqtt.serviceConfig.User}";
    group = "${config.systemd.services.zigbee2mqtt.serviceConfig.Group}";
  };

#  systemd.services."zigbee2mqtt.service".requires = [ "mosquitto.service" ];
#  systemd.services."zigbee2mqtt.service".after = [ "mosquitto.service" ];
  systemd.services."zigbee2mqtt" = {
    requires = [ "mosquitto.service" ];
    after = [ "mosquitto.service" ];
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = lib.mkForce "30s";
      ExecStartPre = [ (pkgs.writeShellScript "wait-for-mqtt" ''
        for i in {1..30}; do
          if (exec 3<>/dev/tcp/localhost/1883) 2>/dev/null; then
            exec 3>&-
            exit 0
          fi
          sleep 2
        done
        exit 1
      '') ];
    };
  };


#  services.udev.extraRules = ''
#    SUBSYSTEM=="tty",SUBSYSTEMS=="usb",DRIVERS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", SYMLINK+="sonoff_zigbee", MODE="0660", GROUP="zigbee2mqtt"
#  '';

  services.zigbee2mqtt = {
    enable = true;

    settings = {
     homeassistant = lib.mkIf (remoteHomeAssistant || config.services.home-assistant.enable) {
        discovery_topic = "homeassistant";
                     legacy_entity_attributes = false;
                     legacy_triggers = false;
                     status_topic = "homeassistant/status";
     };
     permit_join = true;
#     serial = {
#       port = "/dev/ttyACM1";
#     };
#      serial.port = "/dev/sonoff_zigbee";
        serial.adapter = "ember";
        serial.port = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231008143900-if00";

      frontend.port = 8080;

         mqtt = {
           base_topic = "zigbee2mqtt";
           include_device_information = true;
           keepalive = 60;
           reject_anauthorized = true;
           # local
           server = "mqtt://localhost"; # Uncomment for local broker
            user = "zigbee2mqtt";
            password = "!secret password";
            # remote
#           server =  "mqtt://192.168.30.208";
#           user = "mqtt";
#           password = "No3wLbRAHCUNhWs6KEuk";

           version = 5;
         };

     # Configuration options
         advanced = {
           legacy_availability_payload = false;

           last_seen = "ISO_8601";
           legacy_api = false;
           log_level = "info";
           log_output = ["console"];

           channel = 25;
           network_key = "!network.yaml network_key";
           ext_pan_id = [246 201 149 238 254 191 91 252];
           pan_id = 21213;
         };
         availability = {
           active = {
            timeout = 60;
           };
           passive = {
            timeout = 2000;
           };
         };

         device_options = {
#           legacy = "false";
           retain = true;
         };
         experimental = {
           new_api = "true";
         };
#         frontend = "false";
         frontend_url = "https://${domain}.mlad.dk";


devices = {
# Sonoff door sensor
#        "0x00124b002acb8be2" = {
#            friendly_name = "0x00124b002acb8be2";
#        };
        "0x00158d00091a64fa" = {
            friendly_name = "kitchen/door/fridge";
        };
        "0x00158d00093e20dc" = {
            friendly_name = "entrance/door";
        };
        "0x00158d000949eb5f" = {
            friendly_name = "bike-room/door/freezer";
        };
        "0x881a14fffe9fe768" = {
            friendly_name = "bike-room/motion";
        };
        "0x048727fffe87d9ff" = {
            friendly_name = "driveway/light/driveway-2";
        };
        "0x048727fffe97e382" = {
            friendly_name = "test/parasoll_door";
        };
        "0x0c4314fffe5be5a2" = {
            friendly_name = "furnace/motion";
        };
        "0x3410f4fffe90cb7d" = {
            friendly_name = "driveway/light/driveway-6";
        };
        "0x385b44fffe9551d7" = {
            friendly_name = "furnace/light";
        };
        "0x385b44fffe956507" = {
            friendly_name = "office/light/desks-north";
        };
        "0x385cfbfffe78518e" = {
            friendly_name = "storage/light";
        };
        "0x385cfbfffe8328f1" = {
            friendly_name = "laundry/light/light-1";
        };
        "0x385cfbfffecefba5" = {
            friendly_name = "laundry/light/light-2";
        };

        "0x54ef44100052bec6" = {
            friendly_name = "bathroom/motion";
        };
        "0x00158d0008e01e6c" = {
            friendly_name = "bathroom/door-aqara";
        };
        "0xd44867fffed44579" = {
            friendly_name = "bathroom/door";
        };

        # Old bathroom lights
        # - 0x385b44fffe391620
	  	# - 0x540f57fffe1e2dd8
	  	# - 0x003c84fffe01f764
	  	# - 0x84b4dbfffef0b637
	  	# - 0x9035eafffef31e46
        "0x001788010f749027" = {
            friendly_name = "bathroom/light/bathtub-2";
        };
        "0x001788010f77488b" = {
            friendly_name = "bathroom/light/painting";
        };
        "0x001788010f74d977" = {
            friendly_name = "bathroom/light/bathtub-1";
        };
        "0x001788010f74d99e" = {
            friendly_name = "bathroom/light/sink-2";
        };
        "0x001788010f747cc5" = {
            friendly_name = "bathroom/light/sink-1";
        };

        "0x50325ffffe451ebd" = {
            friendly_name = "kitchen/light/cabinet";
        };
        "0x385b44fffe57bfa7" = {
            friendly_name = "kitchen/remote";
        };
        "0x54ef44100060c5fa" = {
            friendly_name = "bedroom/radiator-1";
        };
        "0x54ef441000729b5a" = {
            friendly_name = "extension-bathroom/motion";
        };
        "0x84b4dbfffeebda0d" = {
            friendly_name = "driveway/light/house-road";
        };

        "0x001788010b09a6bc" = {
        	friendly_name = "office/motion";
        };
        "0x84b4dbfffeebe678" = {
            friendly_name = "office/light/desks-south";
        };
        "0x84b4dbfffeec2d83" = {
            friendly_name = "driveway/light/house-entrance";
        };
        "0x84b4dbfffeec3efa" = {
            friendly_name = "office/light/workout-north";
        };
        "0x84b4dbfffeec4910" = {
            friendly_name = "office/light/workout-south";
        };


        "0x84ba20fffe2ed945" = {
            friendly_name = "pantry/motion";
        };
        "0x943469fffebc14a8" = {
            friendly_name = "office-stairs/light/bottom";
        };
        "0x943469fffebc1652" = {
            friendly_name = "office-stairs/light/top";
        };
        "0x94deb8fffe705105" = {
            friendly_name = "pantry/light";
        };
        "0x94deb8fffeb8b59a" = {
            friendly_name = "bike-room/light";
        };
        "0xb0c7defffe421a19" = {
            friendly_name = "driveway/light/driveway-7";
        };
        "0xb0c7defffe425912" = {
            friendly_name = "driveway/light/driveway-1";
        };
        "0xb0c7defffe60c175" = {
            friendly_name = "driveway/light/driveway-4";
        };
        "0xb0c7defffe64fdcb" = {
            friendly_name = "driveway/light/driveway-5";
        };
        "0x84ba20fffecd5ed9" = {
            friendly_name = "driveway/remote";
        };
        "0x385b44fffe3d1db8" = {
            friendly_name = "office/remote";
        };
        "0x5c0272fffe8b8478" = {
            friendly_name = "workshop/repeater";
        };
        "0x54ef441000729b43" = {
            friendly_name = "workshop/motion";
        };

        "0x44e2f8fffe4d401b" = {
            friendly_name = "closet-storage/light";
        };
        "0x8c65a3fffec06dd5" = {
            friendly_name = "guest-sofa/light";
        };
        "0x8c65a3fffedee7ea" = {
            friendly_name = "guest-room/light";
        };
        "0xa4c13857d686f9f6" = {
            friendly_name = "living-room/plug/tv-setup";
        };

        "0x00124b002a548a95" = {
            friendly_name = "living-room/button/sonoff";
        };

        "0xa4c138458d48919c" = {
            friendly_name = "server/plug/servers";
        };
        "0xa4c13868bd672da1" = {
            friendly_name = "nous-2";
        };
        "0xa4c138c62d94d19a" = {
            friendly_name = "furnace/plug/misc";
        };

        "0x54ef44100060c4dc" = {
            friendly_name = "kitchen/thermostat";
        };
        "0x54ef44100060c5a4" = {
            friendly_name = "guest-sofa/thermostat-dead";
        };
        "0x54ef44100060b6fa" = {
            friendly_name = "guest-room/thermostat";
        };
        "0x54ef44100060ca5f" = {
            friendly_name = "extension-hallway/thermostat";
        };
        "0x54ef44100060bd33" = {
            friendly_name = "dining-room/thermostat";
        };
        "0x54ef44100060d353" = {
            friendly_name = "closet/thermostat";
        };
        "0x54ef44100060bd23" = {
            friendly_name = "closet-storage/thermostat";
        };
        "0x54ef44100060ca74" = {
            friendly_name = "guest-sofa/thermostat";
        };

# remotes
        "0xc4d8c8fffe8a73b8" ={
            friendly_name = "closet-storage/remote";
        };
        "0xc4d8c8fffe8a38a1" ={
            friendly_name = "guest-room/remote";
        };
        "0xc4d8c8fffe2e6c92" ={
            friendly_name = "guest-sofa/remote";
        };

# water
        "0x38398ffffe0e6121" ={
            friendly_name = "bathroom/water";
        };
        "0x38398ffffe0df13f" ={
            friendly_name = "extension-bathroom/water";
        };
        "0x38398ffffe0da831" ={
            friendly_name = "kitchen/water/sink";
        };

# lights
        "0xb0c7defffe603296" ={
            friendly_name = "driveway/light/fence-1";
        };
        "0xb0c7defffe603290" ={
            friendly_name = "driveway/light/fence-2";
        };
        "0xb0c7defffe60e7bc" ={
            friendly_name = "driveway/light/fence-3";
        };
        "0xb0c7defffe40fa7f" ={
            friendly_name = "driveway/light/fence-4";
        };
        "0x3410f4fffe90be4e" ={
            friendly_name = "driveway/light/fence-5";
        };

        "0x84b4dbfffeec102e" ={
            friendly_name = "terrace/light";
        };
# lock
        "0x003c84fffeff92cf" = {
            friendly_name = "entrace/door/lock";
        };


        "0xd44867fffe3807b6" = {
            friendly_name = "bedroom/light/wardrobe-1";
        };
        "0x286847fffe14f26d" = {
            friendly_name = "bedroom/light/wardrobe-2";
        };

        "0x38398ffffe0ad6bb" = {
            friendly_name = "laundry/water/drain";
        };
        "0x38398ffffe0e40e2" = {
            friendly_name = "bike-room/water";
        };
        "0x38398ffffe0e40db" = {
            friendly_name = "basement-toilet/water";
        };
        "0x0c2a6ffffe2c1bff" = {
            friendly_name = "bedroom/door";
        };

        "0x94ec32fffe005957" = {
            friendly_name = "basement-toilet/light";
        };
        "0x6cfd22fffe353eab" = {
            friendly_name = "basement-toilet/motion";
        };


        "0x08ddebfffe412cee" = {
            friendly_name = "first-floor-storage/light-1";
        };
        "0x44e2f8fffe02f0ce" = {
            friendly_name = "first-floor-storage/light-2";
        };
        "0x54ef4410006bb648" = {
            friendly_name = "first-floor-storage/motion";
        };


        "0x001788010f777314" = {
        	friendly_name = "garden/lights/kloevermarken-1";
        };
        "0x001788010f77789b" = {
        	friendly_name = "garden/lights/kloevermarken-2";
        };
        "0x001788010f77bf2e" = {
        	friendly_name = "garden/lights/kloevermarken-3";
        };
        "0x001788010f74d9b3" = {
        	friendly_name = "garden/lights/kloevermarken-4";
        };

#"0x001788010f777027" = {
#}
#"0x001788010f776672" = {
#
#}
#"0x001788010f335262" = {
#
#}
#"0x001788010f77795b" = {
#
#}
#"0x001788010f77788e" = {
#
#}
#"0x001788010f33590d" = {
#
#}
#"0x001788010f33590d" = {
#
#}
#"0x001788010f334cf0" = {
#
#}
#"0x001788010f74a8ff" = {
#
#}

};
groups = {
        "1" = {
          friendly_name = "bathroom/group/lights";
          devices = [
                "bathroom/light/painting"
                "bathroom/light/sink-2"
                "bathroom/light/sink-1"
                "bathroom/light/bathtub-1"
                "bathroom/light/bathtub-2"
          ];
        };
        "2" = {
          friendly_name = "office/group/lights";
          devices = [
               "office/light/desks-south"
               "office/light/desks-north"
               "office/light/workout-south"
               "office/light/workout-north"
          ];
        };
        "3" = {
          friendly_name = "office-stairs/group/lights";
          devices = [
            "office-stairs/light/top"
            "office-stairs/light/bottom"
          ];
        };

        "4" = {
            friendly_name = "driveway/group/lights-driveway";
            devices = [
                "driveway/light/driveway-1"
                "driveway/light/driveway-2"
                "driveway/light/driveway-6"
                "driveway/light/driveway-7"
                "driveway/light/driveway-4"
                "driveway/light/driveway-5"
            ];
        };
        "5" ={
            friendly_name = "driveway/group/lights-house";
            devices = [
                "driveway/light/house-entrance"
                "driveway/light/house-road"
            ];
        };
        "6" ={
            friendly_name = "laundry/group/lights";
            devices = [
                "laundry/light/light-1"
                "laundry/light/light-2"
            ];
        };
        "7" ={
            friendly_name = "driveway/group/lights-fence";
            devices = [
                "driveway/light/fence-1"
                "driveway/light/fence-2"
                "driveway/light/fence-3"
                "driveway/light/fence-4"
                "driveway/light/fence-5"
            ];
        };
        "8" ={
            friendly_name = "bedroom/group/closet-lights";
            devices = [
                "bedroom/light/wardrobe-1"
                "bedroom/light/wardrobe-2"
            ];
        };

        };
   };
  };

  services.nginx.virtualHosts."${domain}.mlad.dk" = {
  enableAuthelia = true;
#    useACMEHost = "mlad.dk";
#    forceSSL = true;
#    locations."^~ /" = {
#      proxyPass = "http://localhost:${toString config.services.zigbee2mqtt.port}";
#    };

locations."/" = {
      extraConfig = ''
        proxy_pass http://127.0.0.1:${toString cfg.settings.frontend.port};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };

    # Websocket
    locations."/api" = {
      extraConfig = ''
        proxy_pass http://127.0.0.1:${toString cfg.settings.frontend.port}/api;
        proxy_set_header Host $host;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/zigbee2mqtt";
      user = "zigbee2mqtt";
      group = "zigbee2mqtt";
    }
  ];
}
