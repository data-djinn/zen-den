{
  config,
  pkgs,
  ...
}: {
  boot.initrd.postMountCommands = pkgs.lib.mkBefore ''
    mkdir -pm 700 /persist/var/lib/prometheus
    chown prometheus:prometheus /persist/var/lib/prometheus/
  '';

  networking.firewall.allowedTCPPorts = [config.services.prometheus.port];

  services.prometheus = {
    enable = true;
    port = 3010;
    stateDir = "prometheus/prometheus-zen-den";

    scrapeConfigs = [
      {
        job_name = "zen-den";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };
}
