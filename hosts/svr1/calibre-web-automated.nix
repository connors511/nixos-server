{
  config,
  ...
}: let
  dataDir = "/var/lib/calibre-web-automated";
  ingestDir = "/share/downloaders/Downloads/completed/Books";
  libraryDir = "/share/downloaders/Books";
  port = 8083;
in {
  virtualisation.oci-containers.containers.calibre-web-automated = {
    autoStart = true;
    image = "ghcr.io/crocodilestick/calibre-web-automated:latest";
    environment = {
      NETWORK_SHARE_MODE = "true";
      PGID = "100";
      PUID = "1000";
      TZ = config.time.timeZone;
    };
    ports = ["127.0.0.1:${toString port}:8083"];
    volumes = [
      "${dataDir}:/config"
      "${ingestDir}:/cwa-book-ingest"
      "${libraryDir}:/calibre-library"
    ];
    extraOptions = ["--pull=newer"];
  };

  systemd.services.podman-calibre-web-automated = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    unitConfig.RequiresMountsFor = ["/share/downloaders"];
  };

  services.nginx.virtualHosts."books.lan".locations."/" = {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
  };

  environment.persistence."/persist".directories = [
    {
      directory = dataDir;
      user = "mlarsen";
      group = "users";
      mode = "0770";
    }
  ];
}
