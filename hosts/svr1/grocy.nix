{config, ...}:
let barcodeBuddyPort = 9421;
    grocyHostName = "grocy.mlad.dk";
in
{
# TODO: This should be an Authelia-mixin option
    services.nginx.virtualHosts."${grocyHostName}" = {
    enableAuthelia = true;
    locations."~ \\.php$".extraConfig = ''
         # Basic Authelia Config
         # Send a subsequent request to Authelia to verify if the user is authenticated
         # and has the right permissions to access the resource.
         auth_request /authelia;
         # Set the `target_url` variable based on the request. It will be used to build the portal
         # URL with the correct redirection parameter.
         auth_request_set $target_url https://$http_host$request_uri;
         # Set the X-Forwarded-User and X-Forwarded-Groups with the headers
         # returned by Authelia for the backends which can consume them.
         # This is not safe, as the backend must make sure that they come from the
         # proxy. In the future, it's gonna be safe to just use OAuth.
         auth_request_set $user $upstream_http_remote_user;
         auth_request_set $groups $upstream_http_remote_groups;
         auth_request_set $name $upstream_http_remote_name;
         auth_request_set $email $upstream_http_remote_email;
         proxy_set_header Remote-User $user;
         proxy_set_header Remote-Groups $groups;
         proxy_set_header Remote-Name $name;
         proxy_set_header Remote-Email $email;
         proxy_set_header X-Forwarded-User $user;
         proxy_set_header X-Forwarded-Groups $groups;
     fastcgi_param REMOTE_USER $user;
     fastcgi_param REMOTE_GROUPS $groups;
         # If Authelia returns 401, then nginx redirects the user to the login portal.
         # If it returns 200, then the request pass through to the backend.
         # For other type of errors, nginx will handle them as usual.
         error_page 401 =302 https://auth.mlad.dk/?rd=$target_url;
     '';
    };

  services.grocy = {
    enable = true;
    hostName = grocyHostName;

    nginx.enableSSL = false;

    settings = {
      currency = "DKK";
      culture = "da";
      calendar = {
        showWeekNumber = true;
        firstDayOfWeek = 1;
      };
    };
  };

  services.phpfpm.pools.grocy.settings = {
        "listen.group" = "nginx";
    };

    environment.etc."grocy/config.php".text = ''
        Setting('AUTH_CLASS', 'Grocy\Middleware\ReverseProxyAuthMiddleware');
        Setting('REVERSE_PROXY_AUTH_USE_ENV', true);
        Setting('MEAL_PLAN_FIRST_DAY_OF_WEEK', '1');
        Setting('FEATURE_FLAG_LABEL_PRINTER', true);
        // Setting('MODE', 'dev');
    '';



  environment.persistence."/persist" = {
    directories = [
        config.services.grocy.dataDir
        "/var/lib/barcodebuddy"
    ];
  };

#  virtualisation.oci-containers.containers = {
#      barcodebuddy = {
#        image = "f0rc3/barcodebuddy";
#        volumes = [ "/var/lib/barcodebuddy:/var/www/html" ];
#        autoStart = true;
#        ports = [ "${toString barcodeBuddyPort}:80" ];
#        environment = {
#          TZ = "Europe/Copenhagen";
#          BBUDDY_DISABLE_AUTHENTICATION = "true";
#          TRUSTED_PROXIES = "*";
#        };
#      };
#  };


  services.nginx.virtualHosts."barcode.mlad.dk" = {
    locations."/".proxyPass = "http://localhost:${toString barcodeBuddyPort}";
    enableAuthelia = true;
  };

}
