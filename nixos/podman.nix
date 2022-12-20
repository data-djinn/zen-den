{ pkgs, ... }:
{
  virtualisation = {
    podman = {
      enable = true;

      # alias docker='podman'
      dockerCompat = true;

      # required for containers under podman-compose to be able to communicate
      defaultNetwork.dnsname.enable = true;
    };
  };
}
