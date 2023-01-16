{
  # Enable automatic location
  services.geoclue2.enable = true; # TODO: restrict to specific users
  location.provider = "geoclue2";
  services.localtimed.enable = true;
}
