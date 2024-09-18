{ inputs, lib, config, pkgs, ... }:
{
  #======== SECURITY =========
  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "no"; # Forbid root login through SSH.
    passwordAuthentication = false; # Use keys only
  };

  security.sudo = {
    enable = true;
    execWheelOnly = true; # patch for CVE-2021-3156
    # TODO: "logfile=/persist/var/log/sudo.log lecture=\"never\""
  };

  security.audit = {
    enable = true;
    rules = [ "-a exit,always -F arch=b64 -S execve" ];
  };
  security.auditd.enable = true;

  #======== NETWORK =========
  services.tlp.enable = true;

  #======== DEFAULTS =========
  i18n.defaultLocale = "en_US.utf8";
  console.keyMap = "dvorak";
  
  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };


  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true; # Deduplicate and optimize nix store
    };
  };

  #======== MONITORING =========
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
