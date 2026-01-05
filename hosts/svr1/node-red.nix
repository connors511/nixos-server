{
  config,
  pkgs,
  lib,
  ...
}:
let
  myNodeRed = pkgs.runCommand "node-red" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.nodePackages.node-red}/bin/node-red $out/bin/node-red \
      --set PATH '${lib.makeBinPath [ pkgs.git pkgs.openssh pkgs.nodePackages.npm pkgs.gcc ]}:$PATH' \
  '';
in
{
  services.node-red = {
    enable = true;
    package = myNodeRed;
    configFile = "/var/lib/node-red/settings.js";
  };

  # Because Node-RED devs don't believe that this is an issue that needs to be
  # solved in the node application itself, but rather hardcoded into the env of
  # their docker image.
  # https://github.com/node-red/node-red-docker/issues/191
  # https://github.com/node-red/node-red/issues/2420
  programs.ssh.knownHosts."github.com".publicKey =
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==";


  services.nginx.virtualHosts."node-red.mlad.dk" = {
#    enableAuthelia = true;
#    useACMEHost = "mlad.dk";
#    forceSSL = true;
    locations."^~ /" = {
      proxyPass = "http://localhost:${toString config.services.node-red.port}";
      proxyWebsockets = true;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/lib/node-red";
      user = "node-red";
      group = "node-red";
    }
  ];


  sops.secrets."node-red-config" = {
    sopsFile = ./secrets/node-red-config.js;
    path = "/var/lib/node-red/settings.js";
    format = "binary";
    owner = "${config.systemd.services.node-red.serviceConfig.User}";
    group = "${config.systemd.services.node-red.serviceConfig.Group}";
  };

  sops.secrets."node-red-ssh-public" = {
    sopsFile = ./secrets/node-red-ssh-public;
    path = "/var/lib/node-red/projects/.sshkeys/mlarsen/id_ed25519.pub";
    format = "binary";
    mode = "0644";
    owner = "${config.systemd.services.node-red.serviceConfig.User}";
    group = "${config.systemd.services.node-red.serviceConfig.Group}";
  };

  sops.secrets."node-red-ssh-private" = {
    sopsFile = ./secrets/node-red-ssh-private;
    path = "/var/lib/node-red/projects/.sshkeys/mlarsen/id_ed25519";
    format = "binary";
    mode = "0600";
    owner = "${config.systemd.services.node-red.serviceConfig.User}";
    group = "${config.systemd.services.node-red.serviceConfig.Group}";
  };

#  systemd.services.node-red.path = with pkgs; [
#
#              # module installation
#              nodePackages.npm
#              bash
#              gcc
#              nodejs
#              # projects
#              git
#              openssl
#              openssh
##                ssh-keygen
#   ];


#    system.userActivationScripts.home-setup-tomato.text = ''
#
#        # optionally check if the current user id is the one of tomato, as this runs for every user
#
#        ${pkgs.git}/bin/git clone https://github.com/connors511/node-red-config /var/lib/node-red
#
#        # optionally git pull to keep them up to date
#
#    '';

}
