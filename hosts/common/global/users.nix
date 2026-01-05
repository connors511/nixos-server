{
  pkgs,
  config,
  ...
}: {
  programs.fish.enable = true;
  users = {
    mutableUsers = false;
    users = {
      mlarsen = {
        isNormalUser = true;
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQ3YbcJkgVsOOW2lOWwsUUhK2u2zPpLpi9PptnCvkXz"];
        hashedPasswordFile = config.sops.secrets.mlarsen-password.path;

        extraGroups = let
          ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
        in
          [
            "wheel"
            "video"
            "audio"
          ]
          ++ ifTheyExist [
            "network"
            "wireshark"
            "i2c"
            "mysql"
            "docker"
            "podman"
            "git"
            "libvirtd"
            "deluge"
          ];
      };
#      root = {
#        hashedPasswordFile = config.sops.secrets.mlarsen-password.path;
        # so, this may look like a security issue. I'm publicly showing the hash of my password. However:
        # 1. this password is very robust
        # 2. it is not used anywhere else
        # 3. it only works if you have stolen my computer
        # considering the odds of someone stealing my computer AND knowing how to crack this, I feel safe enough to put it here
        # hashedPassword = "$y$j9T$kUE5ysguGwK9ErWIlwDbD0$msmCGMtTYW9HXnvNBhAO/c./HnNgo3yj8/qDxafIl02";
#      };
    };
  };

  sops.secrets.mlarsen-password = {
    sopsFile = ../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.mlarsen = import home/${config.networking.hostName}.nix;

  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};

  # But it seems too tedious
#  sops.secrets.atuin_key = {
#    sopsFile = ../secrets.yaml;
#    path = "/home/mlarsen/secrets/atuin_key";
#    owner = "mlarsen";
#  };
#
#  sops.secrets.atuin_session = {
#    sopsFile = ../secrets.yaml;
#    path = "/home/mlarsen/secrets/atuin_session";
#    owner = "mlarsen";
#  };

  sops.secrets.nextcloud_pass = {
    sopsFile = ../secrets.yaml;
    path = "/home/mlarsen/secrets/nextcloud_pass";
    owner = "mlarsen";
  };
}
