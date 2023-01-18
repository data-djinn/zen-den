{ ... }: {

  services.tailscale.enable = true;

  # implicitly trust packets routed over Tailscale
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
