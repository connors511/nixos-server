{
  programs.nh = {
    enable = true;
    flake = "/home/mlarsen/nixos"; # not a fan of hardcoding this path
    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep-since 7d";
    };
  };
}
