{
  inputs,
  lib,
  pkgs,
  ...
}: let
  ingestDir = "/share/downloaders/Downloads/completed/Books";
in {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/shelfmark.nix"
  ];

  users.users.shelfmark = {
    isSystemUser = true;
    group = "users";
  };

  services.shelfmark = {
    enable = true;
    package = pkgs.unstable.shelfmark;
    environment = {
      CALIBRE_WEB_URL = "http://books.lan";
      CONFIG_DIR = "/var/lib/shelfmark";
      INGEST_DIR = ingestDir;
      SEARCH_MODE = "universal";
      TZ = "Europe/Copenhagen";
    };
  };

  systemd.services.shelfmark = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    unitConfig.RequiresMountsFor = ["/share/downloaders"];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "shelfmark";
      Group = "users";
      PrivateUsers = lib.mkForce false;
      ReadWritePaths = [ingestDir];
      UMask = lib.mkForce "0002";
    };
  };

  services.nginx.virtualHosts."shelfmark.lan".locations."/" = {
    proxyPass = "http://127.0.0.1:8084";
    proxyWebsockets = true;
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/shelfmark";
      user = "shelfmark";
      group = "users";
      mode = "0750";
    }
  ];
}
