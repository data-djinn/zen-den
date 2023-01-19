{ ... }:

{
  imports = [
    ../../common

    ../../../devices/touchpad
    ../../../services/location
  ];

  services.tlp.enable = true;

  services.logind = {
    killUserProcesses = false;  # on lock
    lidSwitch = "suspend-then-hibernate";  # battery power
    lidSwitchExternalPower = "lock";  # plugged in
    lidSwitchDocked = "ignore"; # external display

    # lock after 60 seconds of inactivity
    extraConfig = "
      IdleActionSec=60
      IdleAction=lock
      ";
  };

  networking.networkmanager.enable = true;
}
