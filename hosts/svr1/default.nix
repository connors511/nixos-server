# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    ../common/global
    ../common/optional/impermanence-disko.nix
    ../common/optional/podman.nix
#    ../common/optional/samba-client.nix
    ./acme.nix
    ./cloudflared.nix
#    ./actualbudget.nix
#     ./arr/bazarr.nix
#     ./arr/lidarr.nix
    # ./arr/radarr.nix
    # ./arr/readarr.nix
    # ./arr/prowlarr.nix
    # ./arr/sonarr.nix
#    ./calibre-server.nix
#    ./firefly.nix
    ./grocy.nix
#    ./immich.nix
#    ./home-assistant
    ./hardware-configuration.nix
#    ./mattermost.nix
#    ./microbin.nix
#    ./navidrome.nix
#    ./netdata.nix
#    ./nextcloud.nix
#    ./nfs.nix
    ./nginx.nix
#    ./paperless.nix
#    ./plausible.nix
    # ./plex.nix
    ./postgresql.nix
    # ./qbittorrent.nix # needs to change the docker image to aarm64
#    ./rss.nix
#    ./tandoor.nix
#    ./uptime-kuma.nix
#    ./wallabag.nix
#    ./web-server.nix
#    ./wiki-js.nix
    ./node-red.nix
    ./mosquitto.nix
    ./zigbee2mqtt.nix
    ./authelia.nix
    ./grafana.nix
    ./victoriametrics.nix
    ./teslamate.nix
#    ./mealie.nix
    ./changedetection-io.nix
    ./ntfy.nix
    ./proxies.nix
    ./homepage.nix
  ];

  networking = {
    hostName = "svr1";
    useDHCP = true;
  };

  time.timeZone = "Europe/Copenhagen";

  environment.systemPackages = with pkgs; [
    rsync
    git
    vim
    just
  ];

  sops.secrets.svr1-borgbackup-passphrase.sopsFile = ./secrets.yaml;

  # Read the doc before updating
  system.stateVersion = "22.11";
  nixpkgs.config.allowBroken = true;
}
