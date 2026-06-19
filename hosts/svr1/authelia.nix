{ config, pkgs, ... }:
{
    imports = [
        ./authelia-mixin.nix
    ];

  services.authelia.instances.main = {
    enable = true;
    package = pkgs.unstable.authelia;
    secrets = {
      jwtSecretFile = "/var/lib/authelia-main/jwt-secret";
      storageEncryptionKeyFile = "/var/lib/authelia-main/storage-encryption-file";
      sessionSecretFile = "/var/lib/authelia-main/session-secret-file";
    };
    settings = {
      theme = "dark";
      default_redirection_url = "https://mlad.dk";

      server = {
        address = "tcp://127.0.0.1:9091/";
        buffers = {
            read = 8192;
        };
      };

      log = {
        level = "debug";
        format = "text";
      };

      authentication_backend = {
        file = {
          path = "/var/lib/authelia-main/users_database.yml";
        };
      };

# https://www.authelia.com/configuration/identity-providers/openid-connect/provider/
#      identity_providers = {
#        oidc = {
#            clients = [
#                {
#                    client_id = "mealie";
#                    client_name = "Mealie";
#                    public = true;
#                    authorization_policy = "one_factor";
#                    require_pkce = true;
#                    pkce_challenge_method = "S256";
#                    redirect_uris = ["https://food.mlad.dk/login"];
#                    scopes = [ "openid" "email" "profile" "groups"];
#                    userinfo_signed_response_alg = "none";
#                    token_endpoint_auth_method = "none";
#                }
#            ];
#        };
#      };

      access_control = {
        default_policy = "deny";
        rules = [
          {
            domain = ["auth.mlad.dk"];
            policy = "bypass";
          }
          {
            domain = ["grocy.mlad.dk" "barcode.mlad.dk" "firefly.mlad.dk"];
            resources = ["^/api([/?].*)?$"];
            policy = "bypass";
          }
          {
            domain = ["food.mlad.dk"];
            resources = ["^/(static)([/?].*)?$" "^/api([/?].*)?$"];
            policy = "bypass";
          }
          {
            domain = ["*.mlad.dk"];
            policy = "one_factor";
          }
        ];
      };

      session = {
        name = "authelia_session";
        expiration = "12h";
        inactivity = "45m";
        remember_me_duration = "1M";
        domain = "mlad.dk";
        redis.host = "/run/redis-authelia-main/redis.sock";
      };

      regulation = {
        max_retries = 3;
        find_time = "5m";
        ban_time = "15m";
      };

      storage = {
        local = {
          path = "/var/lib/authelia-main/db.sqlite3";
        };
      };

      notifier = {
        disable_startup_check = false;
        filesystem = {
          filename = "/var/lib/authelia-main/notification.txt";
        };
      };
    };
  };
  services.redis.servers.authelia-main = {
    enable = true;
    user = "authelia-main";
    port = 0;
    unixSocket = "/run/redis-authelia-main/redis.sock";
    unixSocketPerm = 600;
  };
  services.nginx.virtualHosts."auth.mlad.dk" = {
#    enableACME = true;
#    forceSSL = true;
#    acmeRoot = null;

    locations."/" = {
      proxyPass = "http://127.0.0.1:9091";
      proxyWebsockets = true;
    };
  };


  systemd.services.authelia-main.preStart = ''
    [ -f /var/lib/authelia-main/jwt-secret ] || {
      "${pkgs.openssl}/bin/openssl" rand -base64 32 > /var/lib/authelia-main/jwt-secret
    }
    [ -f /var/lib/authelia-main/storage-encryption-file ] || {
      "${pkgs.openssl}/bin/openssl" rand -base64 32 > /var/lib/authelia-main/storage-encryption-file
    }
    [ -f /var/lib/authelia-main/session-secret-file ] || {
      "${pkgs.openssl}/bin/openssl" rand -base64 32 > /var/lib/authelia-main/session-secret-file
    }
  '';

  environment.persistence."/persist".directories = [
      {
        directory = "/var/lib/authelia-main";
        user = "authelia-main";
        group = "authelia-main";
      }
    ];
}
