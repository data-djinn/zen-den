{ ... }:

{
  imports = [
    ../../common
  ];

  # ==== TOUCHPAD ====
  services.libinput = {
    enable = true;
    touchpad = {
      disableWhileTyping = true; 
      naturalScrolling = true;
    };
  };
   
  # ==== LID BEHAVIOR ====
  services.logind = {
    killUserProcesses = false; # on lock
    lidSwitch = "suspend-then-hibernate"; # battery power
    lidSwitchExternalPower = "lock"; # plugged in
    lidSwitchDocked = "ignore"; # external display

    # lock after 60 seconds of inactivity
    extraConfig = "
      IdleActionSec=60
      IdleAction=lock
      ";
  };

  #===== NETWORKING ====
  services.tlp.enable = true;

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
}
