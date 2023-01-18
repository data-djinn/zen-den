{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "caps:swapescape";

    desktopManager.xterm.enable = false;
    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };
}
