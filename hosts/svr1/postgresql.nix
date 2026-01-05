{config, lib, pkgs, ...}: {
  services.postgresql = {
    enable = true;
package = pkgs.postgresql_16;
  initialScript = pkgs.writeText "init-sql-script" ''
    CREATE EXTENSION cube;
    CREATE EXTENSION earthdistance;
  '';
  };

  services.postgresqlBackup = {
    enable = true;
    compression = "zstd";
#     extraPlugins = with pkgs.postgresql_16.pkgs; [ pg_repack ];

  };


  services.postgresql.authentication = lib.mkForce ''
    # Generated file; do not edit!
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
    '';

  environment.persistence."/persist" = {
    directories = [
      {
        directory = "/var/lib/postgresql";
        user = "postgres";
        group = "postgres";
        mode = "0750";
      }
      {
        directory = config.services.postgresqlBackup.location;
        user = "postgres";
        group = "postgres";
        mode = "0750";
      }
    ];
  };
}
