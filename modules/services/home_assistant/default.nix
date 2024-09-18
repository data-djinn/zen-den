{pkgs, ...}: {
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
    ];
    config = {
      frontend = {};
      default_config = {};
      homeassistant = {
        unit_system = "imperial";
        name = "Home";
        temperature_unit = "F";
        time_zone = "America/New_York";
      };
    };
  };
}
