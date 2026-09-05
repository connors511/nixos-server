{config, ...}: {
  services.searx = {
    enable = true;
    environmentFile = config.sops.templates."searxng.env".path;

    settings = {
      use_default_settings.engines.keep_only = [
        "bing"
        "qwant"
        "startpage"
        "mojeek"
        "wikipedia"
      ];

      engines = [
        {
          name = "qwant";
          disabled = false;
        }
        {
          name = "mojeek";
          disabled = false;
        }
      ];

      outgoing.source_ips = ["0.0.0.0"];

      server = {
        base_url = "http://search.lan/";
        bind_address = "127.0.0.1";
        port = 8888;
        secret_key = "$SEARX_SECRET_KEY";
        limiter = false;
      };

      search = {
        formats = [
          "html"
          "json"
        ];
      };
    };
  };

  services.nginx.virtualHosts."search.lan".locations."/".proxyPass =
    "http://127.0.0.1:8888";

  sops.secrets.searxng-secret-key.sopsFile = ./secrets.yaml;
  sops.templates."searxng.env".content = ''
    SEARX_SECRET_KEY=${config.sops.placeholder.searxng-secret-key}
  '';
}
