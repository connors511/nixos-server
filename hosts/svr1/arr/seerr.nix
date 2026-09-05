{pkgs, ...}: {
  # The pinned NixOS revision still exposes the service under its former
  # Jellyseerr module name. Run the current Seerr package from unstable.
  services.jellyseerr = {
    enable = true;
    package = pkgs.unstable.seerr;
  };

  services.nginx.virtualHosts = {
    "requests.lan".locations."/" = {
      proxyPass = "http://127.0.0.1:5055";
      proxyWebsockets = true;
    };

    "requests.mlad.dk" = {
      useACMEHost = "mlad.dk";
      locations."/" = {
        proxyPass = "http://127.0.0.1:5055";
        proxyWebsockets = true;
      };
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/private/jellyseerr"
  ];
}
