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
  internalProxyRemoteWs = host: port: {
	  locations."/" = {
		proxyPass = "http://${host}:${toString port}";
		proxyWebsockets = true;
	  };
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
  ansiktPreview = host: port: {
#    forceSSL = true;
    useACMEHost = "preview.mlad.dk";
    locations."/".proxyPass = "http://${host}:${toString port}";
  };

	externalProxyPublicWs = host: port: {
	  useACMEHost = "mlad.dk";
	  locations."/" = {
		proxyPass = "http://${host}:${toString port}";
		proxyWebsockets = true;
	  };
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

    "multica.lan" = internalProxyRemoteWs "multica-lxc" 3000;
    "multica-app.lan" = internalProxyRemoteWs "multica-lxc" 3000;
	"multica-api.lan" = internalProxyRemoteWs "multica-lxc" 8080;

    "multica.mlad.dk" = externalProxyPublicWs "multica-lxc" 3000;
    "preview.mlad.dk" = ansiktPreview "ansikt" 80;
    "*.preview.mlad.dk" = ansiktPreview "ansikt" 80;
    "bh.mlad.dk" = externalProxyPublic "ansikt" 80;


#    "sd.lan"	= internalProxyRemote "stable-diffusion" 8188;

    # Internal - proxied to HA
    "jellyfin.lan"  = internalProxyRemote "homeassistant" 8096;
    "requests.lan"  = internalProxyRemote "homeassistant" 5055;

    "dp.mlad.dk" = externalProxyPublic "ansikt" 88;
    "dp.lan"	= internalProxyRemote "ansikt" 88;

    # External with Authelia
#    "grafana.mlad.dk" = externalProxy 3001;

    # External public (own auth)
    "jellyfin.mlad.dk"  = externalProxyPublic "homeassistant" 8096;
    "requests.mlad.dk"  = externalProxyPublic "homeassistant" 5055;

#    "ansikt.mlad.dk" = externalProxyPublicWs "frigate" 4000;
#    "img.ansikt.mlad.dk" = externalProxyPublic "frigate" 8080;
    "ansikt.dk" = externalProxyPublicWs "frigate" 4000;
    "img.ansikt.dk" = externalProxyPublic "frigate" 8080;
  };
}
