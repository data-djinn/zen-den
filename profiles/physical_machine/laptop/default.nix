{ ... }:

{
  imports = [
    ../../common
    ../pc

    ../../modules/system/devices/touchpad
    ../../../modules/services/location
  ];

  services.tlp.enable = true;

  networking.networkmanager.enable = true;
}
