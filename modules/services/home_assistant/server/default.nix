{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
  };
  
  environment.systemPackages = with pkgs; [
    virt-manager  # for virt-install
    usbutils  # for lsusb
    ];

    users.users.djinn = {
      extraGroups = [ "libvirtd" ];
      packages = with pkgs; [
        spice
      ];
    };

  # BRIDGE INTERFACE TO SHARE NETWORK CARD WITH HOST DEVICE
  networking = {
    defaultGateway = "10.0.0.1";
    bridges.br0.interfaces = [ "en61s0" ];
    interfaces.br0 = {
      useDHCP = false;
      ipv4.addresses = [{
        "address" = "10.0.0.5";
        "prefixLength" = 24;
      }];
    };
    # open spice remote monitor port
    firewall.allowedTCPPorts = [ 
      5900
    ];
  };
}
