{
  config,
  pkgs,
  ...
}: {
  boot.initrd.postMountCommands = pkgs.lib.mkBefore ''
    mkdir -pm 700 /persist/var/lib/${config.services.prometheus.stateDir}
    chown -R prometheus:prometheus /persist/var/lib/prometheus/
    ln -s /persist/var/lib/${config.services.prometheus.stateDir}
  '';

  networking.firewall.allowedTCPPorts = [config.services.prometheus.port];

  services.prometheus = {
    enable = true;
    port = 3010;
    stateDir = "prometheus/zen-den";

    scrapeConfigs = [
      {
        job_name = "icarus";
        static_configs = [
          {
            targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
          }
        ];
      }
    ];
  };
}
