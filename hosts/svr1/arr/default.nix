{lib, ...}: {
  imports = [
    ./bazarr.nix
    ./lidarr.nix
    ./prowlarr.nix
    ./radarr.nix
    ./readarr.nix
    ./seerr.nix
    ./sonarr.nix
  ];

  # The applications exit successfully when their web UI requests a restart,
  # including after a backup restore. Restart=on-failure leaves them stopped.
  systemd.services = lib.genAttrs [
    "bazarr"
    "lidarr"
    "prowlarr"
    "radarr"
    "readarr"
    "sonarr"
  ] (_: {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "5s";
    };
  });
}
