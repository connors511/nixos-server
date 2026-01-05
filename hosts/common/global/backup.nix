{
  config,
  lib,
  pkgs,
  ...
}: let
  exclude_patterns = [
    "**/.git"
    "**/*.pyc"
    "/home/*/.direnv"
    "/home/*/.cache"
    "/home/*/.config/Code"
    "/home/*/.config/heroic"
    "/home/*/.config/Beeper"
    "/home/*/.config/chromium"
    "/home/*/.config/discord"
    "/home/*/.config/obsidian"
    "/home/*/.config/Ledger Live"
    "/home/*/.config/VSCodium"
    "/home/*/.config/vesktop"
    "/home/*/.local/share/Trash"
    "/home/*/.local/share/lutris"
    "/home/*/.local/share/containers"
    "/home/*/.local/share/JetBrains"
    "/home/*/.local/share/pnpm"
    "/home/*/.local/share/proton"
    "/home/*/.local/share/Steam"
    "/home/*/.npm"
    "/home/*/.m2"
    "/home/*/.gradle"
    "/home/*/.opam"
    "/home/*/.clangd"
    "/home/*/.mozilla/firefox/*/storage"
    "/home/*/.vcpkg"
    "/home/*/.vscode"
    "/home/*/Android"
    # all my code is in VCS
    "/home/*/code"
    "/home/*/Downloads"
    "/home/*/Games"
    "/home/*/Nextcloud"
    "/home/*/Unity/Hub"
    "/persist/var/lib/containers"
    "/persist/swapfile"
  ];

  baseConfig = {
    inherit exclude_patterns;

    compression = "auto,zstd,10";
    relocated_repo_access_is_ok = true;

    keep_daily = 7;
    keep_weekly = 4;
    keep_monthly = 6;
    keep_yearly = 1;

#    checks = [
#      {
#        name = "repository";
#      }
#      {
#        name = "spot";
#        frequency = "1 week";
#        count_tolerance_percentage = 10;
#        data_sample_percentage = 10;
#        data_tolerance_percentage = 0.5;
#        xxh64sum_command = pkgs.writeShellScript "xxhash64" ''
#          exec ${pkgs.xxHash}/bin/xxhsum -H64 "$1"
#        '';
#      }
#    ];

    ssh_command = "${pkgs.openssh}/bin/ssh -oBatchMode=yes -i ${config.sops.secrets.mlarsen-backup-ssh.path}";

    healthchecks.ping_url = "https://hc-ping.com/db0ac8fa-0bcf-4e77-b8cf-2b50eaaa3449";
  };
in {
  services.borgmatic = {
    enable = true;
    configurations =
      {
        "default" =
          baseConfig
          // {
            repositories = [
              {
                label = "ssh-${config.networking.hostName}";
                path = "ssh://u413036@backup.mlad.dk:23/./${config.networking.hostName}";
              }
            ];
            source_directories = [
              "/persist"
              "/home"
            ];

            encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."${config.networking.hostName}-borgbackup-passphrase".path}";
          };
      }
      //
      # TODO: maybe move this to a separate file
      lib.optionalAttrs (config.networking.hostName == "svr1")
      {
        "shared" =
          baseConfig
          // {
            repositories = [
              {
                label = "ssh-shared";
                path = "ssh://u413036@backup.mlad.dk:23/./shared";
              }
            ];
            source_directories = [
              "/shared"
            ];

            encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.shared-borgbackup-passphrase.path}";
          };
      };
  };

  sops.secrets.mlarsen-backup-ssh.sopsFile = ../secrets.yaml;

  systemd.timers.borgmatic = {
    enable = true;
    description = "borgmatic backup";
    wantedBy = ["timers.target"];
    timerConfig = {
      Unit = "borgmatic.service";
      OnCalendar = "*-*-* 00:00:00";
      Persistent = true;
      WakeSystem = true;
    };
  };
}
