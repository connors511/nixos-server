{config, ...}: {
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/share/downloaders/Music";
    };
  };

  services.nginx.virtualHosts."navidrome.new.lan" = {
    locations."^~ /" = {
      proxyPass = "http://${config.services.navidrome.settings.Address}:${toString config.services.navidrome.settings.Port}";
    };
  };

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/private/navidrome";
        mode = "0755";
        user = "navidrome";
        group = "navidrome";
      }
    ];
  };
}
