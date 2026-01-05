{
  config,
  pkgs,
  ...
}: {
  services.influxdb2 = {
    enable = true;
    provision = {
      enable = true;
      initialSetup = {
        organization = "default";
        bucket = "default";
        passwordFile = pkgs.writeText "admin-pw" "ExAmPl3PA55W0rD";
        tokenFile = pkgs.writeText "admin-token" "verysecureadmintoken";
      };
      organizations."Kløvermarken" = {
        buckets.mingBucket = {
          retention = 2592000; # 30 Days
        };
        auths.mingToken = {
          description = "some auth token";
          readBuckets = ["mingBucket"];
          writeBuckets = ["mingBucket"];
        };
      };
      users = {
        ming = {
          present = true;
          passwordFile = pkgs.writeText "tmp-pw" "abcgoiuhaoga";
        };
      };
    };
  };

  services.grafana.provision = lib.mkIf (config.services.grafana.enable && config.services.influxdb2.enable) {
    enable = true;
     datasources.settings = {
       apiVersion = 1;
       datasources = [{
         name = "ming_influxdb";
         type = "influxdb";
         uid = "influxdb2";
         access = "proxy";
         url = "http://localhost:8086";
         isDefault = true;
         jsonData.version = "Flux";
         jsonData.organization = "mingOrg";
         jsonData.defaultBucket = "mingBucket";
         secureJsonData.token = "$__file{${config.services.influxdb2.provision.initialSetup.tokenFile}}";
       }];
     };
     };
}
