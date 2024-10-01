# Loki Server
#
# Scope: Log aggregator
{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
    config.services.loki.configuration.server.http_listen_port
    config.services.promtail.configuration.server.http_listen_port
    config.services.promtail.configuration.server.grpc_listen_port
  ];

  systemd.services.loki = {
    after = ["network-online.target" "loki-init.service"];
    wants = ["network-online.target"];
    requires = ["loki-init.service"];
    serviceConfig = {
      User = "loki";
      Group = "loki";
      ReadWritePaths = ["${config.services.loki.dataDir}"];
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${config.services.loki.dataDir}"
      ];

      # restrict capabilities
      CapabilityBoundingSet = "";

      #ProtectSystem = true; # root filesystem read-only
      ProtectHome = true; # make ~/ inaccessible

      # prevent modification to kernel settings, cgroups, & loading new kernel modules
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;

      # Network Isolation disabled to allow access to network interfaces (e.g., eth0)
      # This is necessary for Loki to function properly, but may reduce security
      PrivateNetwork = false;

      # only necessary system calls
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "@file-system"
        "@network-io"
      ];

      NoNewPrivileges = true;
      RestrictRealtime = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      ProcSubnet = "pid";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictSUIDSGID = true;
      RemoveIPC = true;
    };
  };

  systemd.services.loki-init = {
    description = "Initialize Loki data directory";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      ExecStart = [
        "${pkgs.coreutils}/bin/mkdir -p ${config.services.loki.dataDir}"
        "${pkgs.coreutils}/bin/chown -R loki:loki ${config.services.loki.dataDir}"
      ];
    };
  };

  services.loki = {
    enable = true;
    dataDir = "/persist/var/lib/loki";

    configuration = {
      auth_enabled = false;

      # Modified server and ingester configuration to use specific IP and port
      server = {
        http_listen_port = 3020;
        http_listen_address = "127.0.0.1"; # TODO: listen on 0.0.0.0 for external clients
      };

      # Simplified ingester configuration
      ingester = {
        lifecycler = {
          address = "${config.networking.hostName}";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
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
