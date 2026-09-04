{
config,
...
}
:let
  remoteProxyLocation = host: port: {
    proxyPass = "http://$upstream";
    extraConfig = ''
      set $upstream "${host}:${toString port}";
    '';
  };

  # Internal services (*.lan) - no SSL, no auth
  internalProxy = port: {
    locations."/".proxyPass = "http://127.0.0.1:${toString port}";
  };

  internalProxyRemote = host: port: {
    locations."/" = remoteProxyLocation host port;
  };
  internalProxyRemoteWs = host: port: {
	  locations."/" = {
		proxyPass = "http://$upstream";
		extraConfig = ''
		  set $upstream "${host}:${toString port}";
		'';
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
    locations."/" = remoteProxyLocation host port;
  };
  ansiktPreview = host: port: {
#    forceSSL = true;
    useACMEHost = "preview.mlad.dk";
    locations."/" = remoteProxyLocation host port;
  };

	externalProxyPublicWs = host: port: {
	  useACMEHost = "mlad.dk";
	  locations."/" = {
		proxyPass = "http://$upstream";
		extraConfig = ''
		  set $upstream "${host}:${toString port}";
		'';
		proxyWebsockets = true;
	  };
	};

in {
  services.nginx.virtualHosts = {
    # Internal (.lan) - proxied to local services
    "home.lan"      = internalProxy 8082;  # Homepage
    "bazarr.lan"    = internalProxyRemote "homeassistant.lan" 6767;
    "lidarr.lan"    = internalProxyRemote "homeassistant.lan" 8686;
    "nzbget.lan"    = internalProxyRemote "homeassistant.lan" 6789;
    "prowlarr.lan"  = internalProxyRemote "homeassistant.lan" 9696;
    "radarr.lan"    = internalProxyRemote "homeassistant.lan" 7878;
    "readarr.lan"   = internalProxyRemote "homeassistant.lan" 8787;
    "sonarr.lan"    = internalProxyRemote "homeassistant.lan" 8989;
    "navidrome.lan" = internalProxyRemote "homeassistant.lan" 4533;
    "chat.lan"  = internalProxyRemoteWs "stable-diffusion.lan" 3000;
    "chat"  = internalProxyRemoteWs "stable-diffusion.lan" 3000;

#    "multica.lan" = internalProxyRemoteWs "multica-lxc" 3000;
#    "multica-app.lan" = internalProxyRemoteWs "multica-lxc" 3000;
#	"multica-api.lan" = internalProxyRemoteWs "multica-lxc" 8080;

#    "multica.mlad.dk" = externalProxyPublicWs "multica-lxc" 3000;
    "preview.mlad.dk" = ansiktPreview "ansikt.lan" 80;
    "*.preview.mlad.dk" = ansiktPreview "ansikt.lan" 80;
    "bh.mlad.dk" = externalProxyPublic "ansikt.lan" 80;

    "wine.mlad.dk" = externalProxyPublic "stable-diffusion.lan" 4000;

#    "sd.lan"	= internalProxyRemote "stable-diffusion" 8188;

    # Keep canonical media routes on Home Assistant during migration.
    "jellyfin.lan" = internalProxyRemote "homeassistant.lan" 8096;
    "requests.lan" = internalProxyRemote "homeassistant.lan" 5055;

    "dp.mlad.dk" = externalProxyPublic "ansikt.lan" 88;
    "crm.mlad.dk" = externalProxyPublic "ansikt.lan" 88;
    "tp.mlad.dk" = externalProxyPublic "ansikt.lan" 88;
    "dp.lan"	= internalProxyRemote "ansikt.lan" 88;

    # External with Authelia
#    "grafana.mlad.dk" = externalProxy 3001;

    # External public (own auth)
    "jellyfin.mlad.dk" = externalProxyPublic "homeassistant.lan" 8096;
    "requests.mlad.dk" = externalProxyPublic "homeassistant.lan" 5055;
#    "ansikt.mlad.dk" = externalProxyPublicWs "frigate" 4000;
#    "img.ansikt.mlad.dk" = externalProxyPublic "frigate" 8080;
    "ansikt.dk" = externalProxyPublicWs "frigate" 4000;
    "img.ansikt.dk" = externalProxyPublic "frigate" 8080;
  };
}
