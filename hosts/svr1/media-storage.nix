{lib, ...}: let
  mountPoint = "/share/downloaders";
  mediaServices = [
    "bazarr"
    "jellyfin"
    "lidarr"
    "radarr"
    "readarr"
    "sonarr"
    "nzbget"
    "navidrome"
  ];
  writers = [
    "bazarr"
    "lidarr"
    "radarr"
    "readarr"
    "sonarr"
  ];
in {
  fileSystems.${mountPoint} = {
    device = "omv.lan:/Media";
    fsType = "nfs4";
    options = [
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
    ];
  };

  # OMV owns the Media tree as GID 100 (users). NFS permissions use numeric
  # IDs, so each service needs the matching local supplementary group.
  users.users = lib.genAttrs mediaServices (_: {
    extraGroups = ["users"];
  });

  systemd.services = lib.genAttrs mediaServices (name: {
    after = ["network-online.target"];
    wants = ["network-online.target"];
    unitConfig.RequiresMountsFor = [mountPoint];
    serviceConfig = lib.optionalAttrs (builtins.elem name writers) {
      UMask = lib.mkForce "0002";
    };
  });
}
