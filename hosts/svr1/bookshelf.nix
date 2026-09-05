{config, ...}: let
  dataDir = "/var/lib/bookshelf";
  mediaDir = "/share/downloaders";
  port = 8787;
in {
  virtualisation.oci-containers.containers.bookshelf = {
    autoStart = true;
    image = "ghcr.io/pennydreadful/bookshelf:hardcover";
    environment = {
      PGID = "100";
      PUID = "1000";
      TZ = config.time.timeZone;
    };
    ports = ["127.0.0.1:${toString port}:8787"];
    volumes = [
      "${dataDir}:/config"
      "${mediaDir}:${mediaDir}"
    ];
    extraOptions = ["--pull=newer"];
  };

  systemd.services.podman-bookshelf = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    unitConfig.RequiresMountsFor = [mediaDir];
  };

  services.nginx.virtualHosts."bookshelf.lan".locations."/" = {
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
