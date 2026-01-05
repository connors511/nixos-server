{pkgs, ...}: {
  users.extraGroups.plugdev = {};
  users.extraUsers.mlarsen.extraGroups = ["plugdev" "dialout"];

  environment.systemPackages = [pkgs.openocd];
  services.udev.packages = [pkgs.openocd];
}
