{ config, pkgs, ... }: {

  services.grafana = {
    enable = true;
    domain = "grafana.zen-den.net";
    port = 3030;
    addr = "127.0.0.1";

    # persist across stateless-system resets
    dataDir = "/persist/var/lib/grafana";

    # forego user auth entirely
    auth.anonymous.enable = true;
    auth.anonymous.org_role = "Admin";
    auth.anonymous.org_name = "Main Org.";

    provision = {
      enable = true;
      # TODO: make each machine provision a new data source for itself
      datasources = [{
        name = "zen-den";
        type = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.prometheus.port}";
        isDefault = true;
      }
      {
        name = "zen-den_logs";
        type = "loki";
        access = "proxy";
        url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
      }];
      # FIXME: can't get this damn thing to drop
       # deleteDatasources = [{
       # name = "obelisk";
       # orgId = 1;
       # }];
    };
  };
}
