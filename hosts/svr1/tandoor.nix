{
  config,
  pkgs,
  ...
}: {
  services.tandoor-recipes = {
    enable = true;
    package = pkgs.tandoor-recipes;
    port = 7453;
#    address = "food.mlad.dk";

    extraConfig = {
        REMOTE_USER_AUTH = 1;
        CSRF_TRUSTED_ORIGINS = "https://food.mlad.dk";
        CORS_ALLOW_ALL_ORIGINS = true;
        BASE_PATH = "https://food.mlad.dk";
    };
  };

  services.nginx.virtualHosts."food.mlad.dk" = {
    enableAuthelia = true;
#    useACMEHost = "mlad.dk";
#    forceSSL = true;
#    locations."^~ /" = {
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.tandoor-recipes.port}";
    };
  };


#    systemd.services.prometheus.serviceConfig.BindPaths = "/persist/var/lib/victoriametrics:/var/lib/victoriametrics";


  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/private/tandoor-recipes";
      user = "tandoor_recipes";
      group = "tandoor_recipes";
    }
  ];
}
