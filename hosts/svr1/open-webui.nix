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
      ENABLE_WEB_SEARCH = "True";
      HOME = config.services.open-webui.stateDir;
      OPENAI_API_BASE_URL = "https://openrouter.ai/api/v1";
      WEB_LOADER_CONCURRENT_REQUESTS = "4";
      WEB_LOADER_ENGINE = "firecrawl";
      WEB_SEARCH_CONCURRENT_REQUESTS = "2";
      WEB_SEARCH_ENGINE = "tavily";
      WEB_SEARCH_RESULT_COUNT = "5";
      WEBUI_URL = "http://chat.lan";
    };
  };

  services.nginx.virtualHosts."chat.lan" = {
    serverAliases = ["chat"];
    locations."/" = {
      proxyPass = "http://127.0.0.1:3000";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/private/open-webui"
  ];

  sops.secrets = {
    firecrawl-api-key.sopsFile = ./secrets.yaml;
    openrouter-api-key.sopsFile = ./secrets.yaml;
    tavily-api-key.sopsFile = ./secrets.yaml;
  };
  sops.templates."open-webui.env".content = ''
    FIRECRAWL_API_KEY=${config.sops.placeholder.firecrawl-api-key}
    OPENAI_API_KEY=${config.sops.placeholder.openrouter-api-key}
    TAVILY_API_KEY=${config.sops.placeholder.tavily-api-key}
  '';
}
