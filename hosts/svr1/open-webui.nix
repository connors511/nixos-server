{
  config,
  pkgs,
  ...
}: {
  services.open-webui = {
    enable = true;
    package = pkgs.unstable.open-webui;
    port = 3000;
    environmentFile = config.sops.templates."open-webui.env".path;

    environment = {
      ENABLE_OLLAMA_API = "False";
      OPENAI_API_BASE_URL = "https://openrouter.ai/api/v1";
      WEBUI_URL = "http://chat.new.lan";
    };
  };

  services.nginx.virtualHosts."chat.new.lan" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/private/open-webui"
  ];

  sops.secrets.openrouter-api-key.sopsFile = ./secrets.yaml;
  sops.templates."open-webui.env".content = ''
    OPENAI_API_KEY=${config.sops.placeholder.openrouter-api-key}
  '';
}
