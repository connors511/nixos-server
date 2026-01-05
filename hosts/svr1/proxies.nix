{
  config,
  pkgs,
  services,
  ...
}: {

#    services.nginx.virtualHosts."n8n.mlad.dk" = {
#        locations."/" = {
##          proxyPass = "http://n8n.coolify.home";
#
#            proxyPass = "http://coolify.home";
#            proxyWebsockets = true;
##            extraConfig = ''
##              proxy_set_header Host $host;
##              proxy_set_header X-Real-IP $remote_addr;
##              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
##              proxy_set_header X-Forwarded-Proto $scheme;
##              proxy_set_header X-Forwarded-Host $host;
##              proxy_set_header X-Forwarded-Port $server_port;
##              proxy_redirect off;
##              proxy_buffering off;
##              proxy_http_version 1.1;
##              proxy_set_header Connection "";
##
##              access_log /var/log/nginx/n8n_access.log combined;
##              error_log /var/log/nginx/n8n_error.log debug;
##            '';
#        };
#    };
}
