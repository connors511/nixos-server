{
  services.sonarr = {
    enable = true;
  };

  services.nginx.virtualHosts."sonarr.new.lan" = {
    locations."^~ /" = {
      proxyPass = "http://127.0.0.1:8989";
    };
  };

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/sonarr";
        user = "sonarr";
        group = "sonarr";
        mode = "0755";
      }
    ];
  };
}
