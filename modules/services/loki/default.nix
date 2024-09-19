# Loki Server
#
# Scope: Log aggregator
{
  config,
  pkgs,
  ...
}: {
  boot.initrd.postMountCommands = pkgs.lib.mkBefore ''
    mkdir -pm 700 /persist/var/lib/loki
    chown loki:loki /persist/var/lib/loki
  '';

  networking.firewall.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
    config.services.promtail.configuration.server.http_listen_port
    config.services.promtail.configuration.server.grpc_listen_port
  ];

  services.loki = {
    enable = true;
    dataDir = "/persist/var/lib/loki";

    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3020;
      };

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        # Any chunk not receiving new logs in this time will be flushed
        chunk_idle_period = "30m";
        # All chunks will be flushed when they hit this age, default is 1h
        max_chunk_age = "2h";
        # Loki will attempt to build chunks up to 1.5MB, flushing if chunk_idle_period or max_chunk_age is reached first
        chunk_target_size = 1572864;
        # Must be greater than index read cache TTL if using an index cache (Default index read cache TTL is 5m)
        chunk_retain_period = "30s";
      };

      schema_config = {
        configs = [
          {
            from = "2023-01-16";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/persist/var/lib/loki/tsdb-index";
          cache_location = "/persist/var/lib/loki/tsdb-cache";
        };
        filesystem = {
          directory = "/persist/var/lib/loki/chunks";
        };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        allow_structured_metadata = true;
      };

      table_manager = {
        retention_deletes_enabled = true;
        retention_period = "336h";
      };

      compactor = {
        working_directory = "/persist/var/lib/loki";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3021;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/tmp/positions.yaml";
      };
      clients = [
        {
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "24h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };
}
