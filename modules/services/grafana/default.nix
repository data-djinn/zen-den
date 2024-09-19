{
  config,
  pkgs,
  ...
}: {
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -pm 700 /persist/var/lib/grafana
    chown grafana:grafana /persist/var/lib/grafana
  '';

  networking.firewall.allowedTCPPorts = [config.services.grafana.port];

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.zen-den.net";
      http_port = 3030;
      http_addr = "127.0.0.1";
    };

    # persist across stateless-system resets
    dataDir = "/persist/var/lib/grafana";

    provision = {
      enable = true;
      # TODO: make each machine provision a new data source for itself
      datasources = {
        settings.datasources = [
          {
            name = "icarus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
          {
            name = "icarus_logs";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
    };
  };
}
