{
  config,
  pkgs,
  lib,
  ...
}: {
  sops.secrets.cloudflared-creds = {
    format = "binary";
    sopsFile = ./../common/secrets/cloudflare-cred-file;
  };

  sops.secrets.cloudflare-token = {
    format = "binary";
    sopsFile = ./../common/secrets/cloudflare-cert.pem;
  };

  environment.etc."cloudflared/cert.pem".source = config.sops.secrets.cloudflare-token.path;

  services.cloudflared = {
    enable = true;
    tunnels = {
      "homelab-01" = {
        credentialsFile = config.sops.secrets.cloudflared-creds.path;
        default = "http_status:404";
        originRequest.noTLSVerify = true;
        ingress = {
          "mlad.dk" = {
            service = "http://localhost:80";
          };
          "ansikt.dk" = {
            service = "http://localhost:80";
          };
          "*.mlad.dk" = {
            service = "http://localhost:80";
          };
          "*.ansikt.dk" = {
            service = "http://localhost:80";
          };
        };
      };
    };
  };
}
