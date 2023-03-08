{ pkgs, ...}:
{
  networking.firewall.allowedTCPPorts = [ 6443 ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  # services.k3s.extraFlags = toString [ "--TBD" ];
  environment.systemPackages = [ pkgs.k3s pkgs.lvm2 helm ];

  # Needed for rook
  boot.kernelModules = [ "ceph" ];
}
