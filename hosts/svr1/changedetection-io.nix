{
  services.changedetection-io = {
    enable = true;
    baseURL = "https://changedetection.mlad.dk";
    behindProxy = true;
    playwrightSupport = true;
  };

  services.nginx.virtualHosts."changedetection.mlad.dk" = {
#    useACMEHost = "mlad.dk";
#    forceSSL = true;
    enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/changedetection-io";
        user = "changedetection-io";
        group = "changedetection-io";
        mode = "0755";
      }
    ];
  };
}
