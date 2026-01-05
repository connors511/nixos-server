{config, pkgs, lib, ...}:
let
    importerTag = "version-1.5.2";
    importerExternalPort = "8081";
in
{
  services.firefly-iii = {
    enable = true;
    settings = {
      APP_KEY_FILE = config.sops.secrets.firefly-key.path;
      APP_ENV = "production";
      DB_CONNECTION = "pgsql";
      DB_DATABASE = "firefly-iii";
#      DB_HOST = "localhost";
      DB_USERNAME = "firefly-iii";
      TRUSTED_PROXIES = "**";
#      AUTHENTICATION_GUARD = "remote_user_guard";
#      AUTHENTICATION_GUARD_HEADER = "REMOTE_USER";
#      AUTHENTICATION_GUARD_EMAIL = "REMOTE_EMAIL";

      APP_DEBUG = true;
      APP_LOG_LEVEL = "debug";
    };
    enableNginx = true;
    virtualHost = "firefly.mlad.dk";
  };

  services.postgresql = let
    inherit (config.services.firefly-iii) settings;
  in {
    ensureDatabases = [settings.DB_DATABASE];
    ensureUsers = [
      {
        name = settings.DB_DATABASE;
        ensureDBOwnership = true;
#        ensurePermissions = {"${settings.DB_DATABASE}.*" = "ALL PRIVILEGES";};
      }
    ];
  };

#  services.nginx.virtualHosts.${config.services.firefly-iii.virtualHost} = {
#    enableAuthelia = false;
#
#    locations."~ \\.php$".extraConfig = ''
#           # Basic Authelia Config
#           # Send a subsequent request to Authelia to verify if the user is authenticated
#           # and has the right permissions to access the resource.
#           auth_request /authelia;
#           # Set the `target_url` variable based on the request. It will be used to build the portal
#           # URL with the correct redirection parameter.
#           auth_request_set $target_url https://$http_host$request_uri;
#           # Set the X-Forwarded-User and X-Forwarded-Groups with the headers
#           # returned by Authelia for the backends which can consume them.
#           # This is not safe, as the backend must make sure that they come from the
#           # proxy. In the future, it's gonna be safe to just use OAuth.
#           auth_request_set $user $upstream_http_remote_user;
#           auth_request_set $groups $upstream_http_remote_groups;
#           auth_request_set $name $upstream_http_remote_name;
#           auth_request_set $email $upstream_http_remote_email;
#           proxy_set_header Remote-User $user;
#           proxy_set_header Remote-Groups $groups;
#           proxy_set_header Remote-Name $name;
#           proxy_set_header Remote-Email $email;
#           proxy_set_header X-Forwarded-User $user;
#           proxy_set_header X-Forwarded-Groups $groups;
#       fastcgi_param REMOTE_USER $user;
#       fastcgi_param REMOTE_GROUPS $groups;
#       fastcgi_param REMOTE_EMAIL $email;
#       fastcgi_pass_request_headers on;
#       fastcgi_pass_header           Remote-User;
#       fastcgi_pass_header           Remote-Email;
#           # If Authelia returns 401, then nginx redirects the user to the login portal.
#           # If it returns 200, then the request pass through to the backend.
#           # For other type of errors, nginx will handle them as usual.
#           error_page 401 =302 https://auth.mlad.dk/?rd=$target_url;
#       '';
#   };

  sops.secrets.firefly-key = {
    owner = "firefly-iii";
    group = "nginx";
    sopsFile = ./secrets.yaml;
  };

  environment.persistence."/persist" = {
    directories = [config.services.firefly-iii.dataDir];
#    files = [
#        { directory = "${config.services.firefly-iii.dataDir}/import-config";
#          files = [ "./firefly/*.json" ];
#        }
#      ];
  };

  virtualisation.oci-containers.containers.firefly-iii-importer = lib.mkIf (config.services.firefly-iii.enable){
        image = "fireflyiii/data-importer:${importerTag}";
        ports = ["127.0.0.1:${toString importerExternalPort}:8080"];
        extraOptions = [
          "--pull=newer"
          # Force DNS resolution to only be the podman dnsname name server; by default podman provides a resolv.conf
          # that includes both this server and the upstream system server, causing resolutions of other pod names
          # to be inconsistent.
  #        "--dns=10.88.0.1"
        ];
        environment = {
            IGNORE_DUPLICATE_ERRORS = "false";
            TZ = "Europe/Copenhagen";
            FIREFLY_III_URL = "https://firefly.mlad.dk";
            VANITY_URL = "https://firefly.mlad.dk";
            TRUSTED_PROXIES = "**";
            JSON_CONFIGURATION_DIR = "/configurations";
        };
        environmentFiles = [
          config.sops.templates.firefly-import-env.path
        ];
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
#          "${config.services.firefly-iii.dataDir}/import-config:/configurations"
        ];
      };

  services.nginx.virtualHosts."firefly-import.mlad.dk" =  lib.mkIf (config.services.firefly-iii.enable){
    locations."/".proxyPass = "http://localhost:${toString importerExternalPort}";
    enableAuthelia = true;
  };

  sops.secrets.firefly-access-token = {
#    owner = "firefly-iii";
#    group = "nginx";
    sopsFile = ./secrets.yaml;
  };
  sops.secrets.firefly-nordigen-id = {
#    owner = "firefly-iii";
#    group = "nginx";
    sopsFile = ./secrets.yaml;
  };
  sops.secrets.firefly-nordigen-key = {
#    owner = "firefly-iii";
#    group = "nginx";
    sopsFile = ./secrets.yaml;
  };
  sops.templates."firefly-import-env".content = ''
    FIREFLY_III_ACCESS_TOKEN=${config.sops.placeholder.firefly-access-token}
    NORDIGEN_ID=${config.sops.placeholder.firefly-nordigen-id}
    NORDIGEN_KEY=${config.sops.placeholder.firefly-nordigen-key}
  '';
}
