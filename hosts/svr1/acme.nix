{config, ...}: {
  # Enable acme for usage with nginx vhosts
  security.acme = {
#    defaults.email = "trucmuche909@gmail.com";
    defaults.email = "matthias@msalconsulting.dk";
    acceptTerms = true;

#    certs."bizel.fr" = {
#      domain = "*.bizel.fr";
#      dnsProvider = "ovh";
#      dnsPropagationCheck = true;
#      credentialsFile = config.sops.secrets.ovhDns.path;
#    };

    certs."mlad.dk" = {
      domain = "*.mlad.dk";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      enableDebugLogs = true;
      # inspo: https://go-acme.github.io/lego/dns/cloudflare/
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare-api-key.path;
      };
    };
    certs."preview.mlad.dk" = {
		domain = "preview.mlad.dk";
		extraDomainNames = [ "*.preview.mlad.dk" ];
		dnsProvider = "cloudflare";
		dnsResolver = "1.1.1.1:53";
		dnsPropagationCheck = true;
		enableDebugLogs = true;
		credentialFiles = {
			"CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare-api-key.path;
		};
	};
    certs."ansikt.dk" = {
      domain = "*.ansikt.dk";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      enableDebugLogs = true;
      # inspo: https://go-acme.github.io/lego/dns/cloudflare/
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets.cloudflare-api-key.path;
      };
    };
  };

  environment.persistence = {
    "/persist".directories = ["/var/lib/acme"];
  };

  sops.secrets.cloudflare-api-key = {
    sopsFile = ./secrets.yaml;
  };

  users.users.nginx.extraGroups = ["acme"];
}
