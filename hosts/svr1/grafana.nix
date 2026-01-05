{
  config,
  pkgs,
  ...
}:
# @see https://github.com/badele/nix-homelab/blob/main/nix/nixos/roles/grafana/default.nix
let
# Copy all json dashboard
  grafana-dashboards = pkgs.stdenv.mkDerivation {
    name = "grafana-dashboards";
    src = ./.;
    installPhase = ''
      mkdir -p $out/
      install -D -m755 $src/grafana-dashboards/*.json $out/
    '';
  };
in
{
  services.grafana = {
     enable = true;

     settings = {
       analytics.reporting_enabled = false;
      "auth.proxy".enabled = true;
      "auth.proxy".header_name = "Remote-User";
      "auth.proxy".headers = "Name:Remote-Name Email:Remote-Email Groups:Remote-Groups";

      server = {
        root_url = "https://grafana.mlad.dk";
        domain = "grafana.mlad.dk";
        enforce_domain = false;
        enable_gzip = true;
        http_addr = "0.0.0.0";
        http_port = 3001;
      };

      "auth.anonymous".enabled = true;
      "auth.anonymous".org_name = "Kløvermarken";
      "auth.anonymous".org_role = "Viewer";

       security = {
         admin_user = "mlarsen";
         admin_password = "$__file{${config.sops.secrets.grafana-admin-password.path}}";
       };
     };

     provision.dashboards.settings.providers = [{
       name = "default";
       options.path = grafana-dashboards;
     }];
   };

  services.nginx.virtualHosts."grafana.mlad.dk" = {
    enableAuthelia = true;
    locations."/".extraConfig = "proxy_pass http://localhost:3001;";
  };

  sops.secrets.grafana-admin-password = {
    sopsFile = ./secrets.yaml;
    owner = "grafana";
  };
}
