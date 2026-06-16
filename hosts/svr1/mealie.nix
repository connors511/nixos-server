{
  config,
  ...
}:
{
  services.mealie = {
    enable = true;
    database.createLocally = true;
    port = 9000;

    settings = {
#        REMOTE_USER_AUTH = 1;
#        CSRF_TRUSTED_ORIGINS = "https://mealie.mlad.dk";
#        CORS_ALLOW_ALL_ORIGINS = true;

        BASE_URL = "https://mealie.mlad.dk";

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


  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/mealie";
      user = "mealie";
      group = "mealie";
    }
  ];
}
