{
    inputs,
  config,
  pkgs,
  ...
}:
let
    postgresDb = "mealie";
in
{
  services.mealie = {
    enable = true;
    # https://github.com/Birdy2014/nixos-config/blob/4d9925c230ab7088e913c8e666f8529435db9f6c/hosts/seidenschwanz/services/mealie.nix#L12
    package = inputs.nixpkgs.legacyPackages.x86_64-linux.mealie.overrideAttrs
                    (old: {
                      patches = (old.patches or [ ]) ++ [
                        (pkgs.fetchpatch {
                          url =
                            "https://github.com/mealie-recipes/mealie/commit/445754c5d844ccf098f3678bc4f3cc9642bdaad6.patch";
                          hash = "sha256-ZdATmSYxhGSjoyrni+b5b8a30xQPlUeyp3VAc8OBmDY=";
                          revert = true;
                        })
                      ];
                    });
    port = 9000;

    settings = {
#        REMOTE_USER_AUTH = 1;
#        CSRF_TRUSTED_ORIGINS = "https://mealie.mlad.dk";
#        CORS_ALLOW_ALL_ORIGINS = true;

        BASE_URL = "https://mealie.mlad.dk";

        DB_ENGINE = "postgres";
        POSTGRES_USER = postgresDb;
        POSTGRES_PASSWORD = "";
        POSTGRES_SERVER = "localhost";
        POSTGRES_DB = postgresDb;

#        OIDC_AUTH_ENABLED=true;
#        OIDC_SIGNUP_ENABLED=true;
#        OIDC_CONFIGURATION_URL=https://auth.example.com/.well-known/openid-configuration;
#        OIDC_CLIENT_ID="mealie";
#        OIDC_AUTO_REDIRECT=false;
#        OIDC_ADMIN_GROUP="mealie-admins";
#        OIDC_USER_GROUP="mealie-users";
    };
  };

  services.nginx.virtualHosts."mealie.mlad.dk" = {
#    enableAuthelia = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.mealie.port}";
    };
  };


  services.postgresql = {
      enable = true;
      ensureDatabases = [ postgresDb ];
      ensureUsers = [{
        name = postgresDb;
        ensureDBOwnership = true;
      }];
    };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/mealie";
      user = "mealie";
      group = "mealie";
    }
  ];
}
