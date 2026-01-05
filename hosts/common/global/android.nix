{pkgs, ...}: {
  programs.adb.enable = true;
  users.users.mlarsen.extraGroups = ["adbusers"];
  environment.systemPackages = with pkgs; [
    adbfs-rootless
  ];
}
