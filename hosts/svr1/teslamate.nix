{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  postgresDb = "teslamate";
  teslamateVersion = "4.0.1";
  teslamatePort = 4000;
in
{
#    imports = [
#        inputs.teslamate.nixosModules.default
#    ];
#
#  services.teslamate = {
#    enable = true;
#    virtualHost = "tesla.mlad.dk";
#    secretsFile = config.sops.secrets.immich_postgres.path;
#    mqtt = {
#        enable = true;
#    };
#    postgres = {
#        user = postgresDb;
#        database = postgresDb;
#    };
#  };

virtualisation.oci-containers.containers.teslamate = {
      image = "teslamate/teslamate:${teslamateVersion}";
      ports = ["127.0.0.1:${toString teslamatePort}:${toString teslamatePort}"];
      extraOptions = [
        "--pull=newer"
        "--network=host"
        # Force DNS resolution to only be the podman dnsname name server; by default podman provides a resolv.conf
        # that includes both this server and the upstream system server, causing resolutions of other pod names
        # to be inconsistent.
#        "--dns=10.88.0.1"
      ];
      environment = {
        DATABASE_USER=postgresDb;
        DATABASE_NAME=postgresDb;
        DATABASE_HOST="127.0.0.1";
        MQTT_HOST="127.0.0.1";

#       MQTT_HOST =  "192.168.30.208";
       MQTT_USERNAME = "teslamate";
       MQTT_PASSWORD = "No3wLbRAHCUNhWs6KEuk";
        TZ="Europe/Copenhagen";
      };
      environmentFiles = [
        config.sops.secrets.teslamate.path
      ];
      volumes = [
#        "/var/lib/teslamate/import:/opt/app/import"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };


  services.nginx.virtualHosts."tesla.mlad.dk" = {
#    useACMEHost = "mlad.dk";
#    forceSSL = true;
    enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString teslamatePort}";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/teslamate";
    }
  ];


  sops.secrets.teslamate.sopsFile = ./secrets.yaml;

  services.postgresql = {
      enable = true;
      ensureDatabases = [ postgresDb ];
      ensureUsers = [{
        name = postgresDb;
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      }];
    };


  services.grafana.provision = lib.mkIf (config.services.grafana.enable && true){ #config.services.teslamate.enable) {
     enable = true;
     datasources.settings = {
       apiVersion = 1;
       deleteDatasources = [{
         name = "TeslaMate";
         orgId = 1;
       }];
       datasources = [{
         name = "TeslaMate";
         type = "postgres";
         uid = "TeslaMate";
         access = "proxy";
         url = "localhost:${toString config.services.postgresql.settings.port}";
         user = postgresDb;
         database = postgresDb;
         isDefault = false;
         jsonData.database = postgresDb;
         jsonData.sslmode = "disable";
         jsonData.postgresVersion = 1600;
#         jsonData.version = "Flux";
#         jsonData.organization = "mingOrg";
#         jsonData.defaultBucket = "mingBucket";
#         secureJsonData.token = "$__file{${config.services.influxdb2.provision.initialSetup.tokenFile}}";
       }];
     };

     dashboards.settings = {
      apiVersion = 1;
      providers = [
        {
          name = "teslamate";
          orgId = 1;
          folder = "TeslaMate";
          folderUid = "Nr4ofiDZk";
          type = "file";
          disableDeletion = false;
          editable = true;
          updateIntervalSeconds = 86400;
          options.path = lib.sources.sourceFilesBySuffices
            ./teslamate-dashboards
            [ ".json" ];
        }
        {
          name = "teslamate_internal";
          orgId = 1;
          folder = "Internal";
          folderUid = "Nr5ofiDZk";
          type = "file";
          disableDeletion = false;
          editable = true;
          updateIntervalSeconds = 86400;
          options.path = lib.sources.sourceFilesBySuffices
            ./teslamate-dashboards/internal
            [ ".json" ];
        }
        {
          name = "teslamate_reports";
          orgId = 1;
          folder = "Reports";
          folderUid = "Nr6ofiDZk";
          type = "file";
          disableDeletion = false;
          editable = true;
          updateIntervalSeconds = 86400;
          options.path = lib.sources.sourceFilesBySuffices
            ./teslamate-dashboards/reports
            [ ".json" ];
        }
      ];
    };
  };
}
