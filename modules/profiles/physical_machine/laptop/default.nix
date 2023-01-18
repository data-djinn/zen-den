{ ... }:

{
  imports = [
    ../../common

    ../../../devices/touchpad
    ../../../services/location
  ];

  services.tlp.enable = true;

  networking.networkmanager.enable = true;
}
