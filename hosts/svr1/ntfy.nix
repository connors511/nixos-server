{
  services.ntfy-sh = {
    enable = true;
    settings = {
     listen-http = ":2586";
     behind-proxy = true;
     base-url = "https://nfty.mlad.dk";
     enable-signup = true;
     enable-login = true;
    };
  };

  services.nginx.virtualHosts."ntfy.mlad.dk" = {
#    useACMEHost = "mlad.dk";
#    forceSSL = true;
   # enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:2586";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/private/ntfy";
        user = "ntfy-sh";
        group = "ntfy-sh";
        mode = "0700";
      }
    ];
  };
}
