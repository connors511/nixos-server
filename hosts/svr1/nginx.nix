{
  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    clientMaxBodySize = "300m";
    resolver = {
      addresses = [ "10.10.1.1" ];
      valid = "30s";
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];

  # catch-all
  services.nginx.virtualHosts."_" = {
    useACMEHost = "mlad.dk";
    forceSSL = false;
    default = true;
    locations."~ .*".return = "403";
  };
}
