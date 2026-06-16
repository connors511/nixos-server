{
  config,
  pkgs,
  lib,
  ...
}:
let
  configure_prom = builtins.toFile "prometheus.yml" ''
    scrape_configs:
    - job_name: 'svr1-node'
      stream_parse: true
      static_configs:
      - targets:
        - 127.0.0.1:9100
    - job_name: 'hass'
      scrape_interval: 60s
      metrics_path: /api/prometheus
      bearer_token_file: ${config.sops.secrets."hass/token".path}
      scheme: http
      static_configs:
        - targets: ['homeassistant.lan:8123']
  '';
  configure_hass_prom = builtins.toFile "prometheus-hass.yml" ''
    scrape_configs:
    - job_name: 'hass'
      scrape_interval: 60s
      metrics_path: /api/prometheus
      bearer_token_file: ${config.sops.secrets."hass/token".path}
      scheme: http
      static_configs:
        - targets: ['homeassistant.lan:8123']
  '';
in
{

  users.users.victoriametrics = {
    isSystemUser = true;
    group = "victoriametrics";
  };
  users.groups.victoriametrics = {};

  services.victoriametrics = {
    enable = true;
    extraOptions = [
      "-search.maxPointsSubqueryPerTimeseries=300000"
    ];
    retentionPeriod = "120"; # 10 years in months
  };

  systemd.services.victoriametrics.serviceConfig = {
    User = "victoriametrics";
    Group = "victoriametrics";
    DynamicUser = lib.mkForce false;
    StateDirectory = lib.mkForce "";
    BindPaths = "/persist/var/lib/private/victoriametrics:/var/lib/victoriametrics";
    PrivateUsers = lib.mkForce false;
  };

  networking.firewall.allowedTCPPorts = [9100 8428];

  services.prometheus.exporters.node.enable = true;
  systemd.services.export-to-prometheus = {
    path = with pkgs; [victoriametrics];
    enable = true;
    requires = ["victoriametrics.service" "network-online.target"];
    after = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    script = "vmagent -promscrape.config=${configure_prom} -remoteWrite.url=http://127.0.0.1:8428/api/v1/write";
  };
#  systemd.services.import-from-hass = {
#    path = with pkgs; [victoriametrics];
#    enable = true;
#    requires = ["victoriametrics.service" "network-online.target"];
#    after = ["network-online.target"];
#    wantedBy = ["multi-user.target"];
#    script = "vmagent -promscrape.config=${configure_hass_prom} -remoteWrite.url=http://127.0.0.1:8428/api/v1/write";
#  };


    systemd.services.prometheus.serviceConfig.BindPaths = "/persist/var/lib/victoriametrics:/var/lib/victoriametrics";


  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/victoriametrics";
      user = "victoriametrics";
      group = "victoriametrics";
      mode = "0700";
    }
  ];


  sops.secrets."hass/token" = {
    sopsFile = ./secrets.yaml;
#    owner = "victoriametrics";
#    group = "victoriametrics";
  };

  services.grafana.provision = lib.mkIf (config.services.grafana.enable && config.services.victoriametrics.enable) {
    enable = true;
     datasources.settings = {
       apiVersion = 1;
       datasources = [{
         name = "victoriametrics";
         type = "prometheus";
         uid = "victoriametis";
         access = "proxy";
         url = "http://localhost${toString config.services.victoriametrics.listenAddress}";
         isDefault = true;
#         jsonData.version = "Flux";
#         jsonData.organization = "mingOrg";
#         jsonData.defaultBucket = "mingBucket";
#         secureJsonData.token = "$__file{${config.services.influxdb2.provision.initialSetup.tokenFile}}";
       }];
     };
     };
}
