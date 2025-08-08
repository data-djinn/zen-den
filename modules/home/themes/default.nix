{
  config,
  pkgs,
  lib,
  ...
}: let
  # wallpaper transitions by time of day
  morning = "./pines.jpg";
  afternoon = "./city.jpg";
  evening = "./sunset.jpg";
  night = "./stars.jpg";

  themesDir = "/home/djinn/zen-den/modules/home/themes";
in {
  # Tools we need
  home.packages = with pkgs; [swww];

  ##### swww daemon (Wayland wallpaper)
  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww daemon";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "always";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };

  ##### systemd oneshot + timer
  systemd.user.services.rotate-theme = {
    Unit = {
      Description = "Rotate wallpaper and Alacritty palette";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target" "swww-daemon.service"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${themesDir}/rotate-theme.sh";
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.swww}/bin:${pkgs.bash}/bin";
    };
    Install = {WantedBy = ["graphical-session.target"];};
  };

  systemd.user.timers.rotate-theme = {
    Unit = {Description = "Timer for rotate-theme";};
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
      Unit = "rotate-theme.service";
    };
    Install = {WantedBy = ["timers.target"];};
  };
}
