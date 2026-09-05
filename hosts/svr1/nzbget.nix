{
  services.nzbget = {
    enable = true;
    # /config is the container's state directory. The native NixOS service
    # keeps the equivalent state, including nzbget.conf, here instead.
    settings.MainDir = "/var/lib/nzbget";
  };

  services.nginx.virtualHosts."nzbget.lan" = {
    locations."^~ /" = {
      proxyPass = "http://127.0.0.1:6789";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/nzbget";
      user = "nzbget";
      group = "nzbget";
      mode = "0750";
    }
  ];
}
