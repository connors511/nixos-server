{
  services.jellyfin.enable = true;

  services.nginx.virtualHosts = {
    "jellyfin.lan".locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      proxyWebsockets = true;
    };

    "jellyfin.mlad.dk" = {
      useACMEHost = "mlad.dk";
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
      };
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/jellyfin";
      user = "jellyfin";
      group = "jellyfin";
      mode = "0750";
    }
  ];
}
