{ inputs, lib, config, pkgs, ... }:
{
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  services.tlp.enable = true;
  services.openssh = {
    enable = true;
    permitRootLogin = "no"; # Forbid root login through SSH.
    passwordAuthentication = false; # Use keys only
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true; # Deduplicate and optimize nix store
    };
  };

  i18n.defaultLocale = "en_US.utf8";

  # TODO: replace sudo with doas?
  security.sudo = {
    enable = true;
    execWheelOnly = true; # patch for CVE-2021-3156
  };

  console.keyMap = "dvorak";

  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 3011;
      };
    };
  };
}
