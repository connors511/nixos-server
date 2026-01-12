{
config,
...
}
:let
  # Internal services (*.lan) - no SSL, no auth
  internalProxy = port: {
    locations."/".proxyPass = "http://127.0.0.1:${toString port}";
  };

  internalProxyRemote = host: port: {
    locations."/".proxyPass = "http://${host}:${toString port}";
  };

  # External services (*.mlad.dk) - with Authelia
  externalProxy = port: {
    enableAuthelia = true;
#    forceSSL = true;
    useACMEHost = "mlad.dk";  # or however you handle certs
    locations."/".proxyPass = "http://127.0.0.1:${toString port}";
  };

  # External without Authelia (Jellyfin, Jellyseerr - own auth)
  externalProxyPublic = host: port: {
#    forceSSL = true;
    useACMEHost = "mlad.dk";
    locations."/".proxyPass = "http://${host}:${toString port}";
  };

in {
  services.nginx.virtualHosts = {
    # Internal (.lan) - proxied to local services
    "home.lan"      = internalProxy 8082;  # Homepage
    "sonarr.lan"    = internalProxyRemote "homeassistant" 8989;
    "radarr.lan"    = internalProxyRemote "homeassistant" 7878;
    "lidarr.lan"    = internalProxyRemote "homeassistant" 8686;
    "prowlarr.lan"  = internalProxyRemote "homeassistant" 9696;
    "navidrome.lan"  = internalProxyRemote "homeassistant" 4533;

    # Internal - proxied to HA
    "jellyfin.lan"  = internalProxyRemote "homeassistant" 8096;
    "requests.lan"  = internalProxyRemote "homeassistant" 5055;

    # External with Authelia
#    "grafana.mlad.dk" = externalProxy 3001;

    # External public (own auth)
    "jellyfin.mlad.dk"  = externalProxyPublic "homeassistant" 8096;
    "requests.mlad.dk"  = externalProxyPublic "homeassistant" 5055;
  };
}
