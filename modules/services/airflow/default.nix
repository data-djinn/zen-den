{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.airflow;
in {
  options.services.airflow = {
    enable = mkEnableOption "Apache Airflow";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "The port on which Airflow webserver will listen.";
    };

    data_dir = mkOption {
      type = types.path;
      default = "/var/lib/airflow";
      description = ''
        The folder where Airflow data will be stored,\
        e.g. /dags subdirectory";
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups.airflow = {};
    users.users.airflow = {
      isSystemUser = true;
      home = "${cfg.data_dir}";
      description = "system airflow user";
      group = "airflow";
      shell = pkgs.bash;
      extraGroups = ["podman"];
    };

    virtualisation.podman.enable = true;

    systemd.services.airflow = {
      description = "Apache Airflow";
      after = ["podman.service"];
      requires = ["podman.service"];
      path = [pkgs.coreutils];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "forking";
        PermissionsStartOnly = true;

        ExecStartPre = [
          # Ensure DAGs folder exists and has proper permissions
          ''${pkgs.coreutils}/bin/mkdir -p ${cfg.data_dir}/dags''
          ''${pkgs.coreutils}/bin/mkdir -p ${cfg.data_dir}/containers''
          ''${pkgs.coreutils}/bin/chown -R airflow:airflow ${cfg.data_dir}''
          ''${pkgs.coreutils}/bin/chmod 755 ${cfg.data_dir}''

          # Remove any existing container named "airflow"
          ''${pkgs.podman}/bin/podman rm -f airflow || true''

          # Initialize the Airflow database
          ''
            ${pkgs.podman}/bin/podman \
            run --rm -v airflow_db:/opt/airflow -v ${cfg.data_dir}/dags:/opt/airflow/dags \
            --env "AIRFLOW__CORE__LOAD_EXAMPLES=false" \
            --env "_AIRFLOW_WWW_USER_CREATE=true" \
            --env "_AIRFLOW_DB_MIGRATE=true" \
            --env "_AIRFLOW_WWW_USER_PASSWORD=admin" \
            --pull=missing apache/airflow:slim-2.10.2 airflow db init
          ''
        ];

        ExecStart = ''
          ${pkgs.podman}/bin/podman run -d --rm --name airflow \
            -p ${toString cfg.port}:8080 \
            -v airflow_db:/opt/airflow \
            -v ${cfg.data_dir}/dags:/opt/airflow/dags \
            -e AIRFLOW__CORE__LOAD_EXAMPLES=False \
            --pull=missing \
            apache/airflow:slim-2.10.2 \
            airflow webserver
        '';
        ExecStop = "${pkgs.podman}/bin/podman stop airflow";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    networking.firewall.allowedTCPPorts = [cfg.port];
  };
}
