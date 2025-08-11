{
  virtualisation = {
    podman = {
      enable = true;
      # alias docker='podman'
      dockerCompat = true;
      # required for containers under podman-compose to be able to communicate
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  # enable multi-architecture builds
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
}
