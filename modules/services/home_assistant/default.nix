{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "met"
      "radio_browser"
    ];
    config = {
      default_config = { };
    };
  };
}
