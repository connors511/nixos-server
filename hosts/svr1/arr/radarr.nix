{
  services.radarr = {
    enable = true;
  };

  services.nginx.virtualHosts."radarr.lan" = {
    locations."^~ /" = {
      proxyPass = "http://127.0.0.1:7878";
    };
  };

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/radarr";
        user = "radarr";
        group = "radarr";
        mode = "0755";
      }
    ];
  };
}
