# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, lib, config, pkgs, ... }:

let  # env vars required for finegrained
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-GO
    export __GLX_VENDOR_LIBRARY_NAME=nvidia::
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{

  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware), use something like:
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # It's strongly recommended you take a look at
    # https://github.com/nixos/nixos-hardware
    # and import modules relevant to your hardware.

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    # You can also split up your configuration and import pieces of it here.
    ./erase_your_darlings.nix
  ];

  # =========================
  # CUSTOM BOOT CONFIG
  # =========================

  boot = {
    loader = {
      systemd-boot.enable = true;
      # this may need to change during setup of new workstation
      efi = {
        canTouchEfiVariables = true;
      };
    };
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
  };

  # =========================
  # CUSTOM HARDWARE CONFIG
  # =========================

  # Install latest nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # install shell script defined above
  environment.systemPackages = [ nvidia-offload ];

  # enable secondary monitors at boot time
  specialisation = {
    external-display.configuration = {
      system.nixos.tags = [ "external-display" ];
      hardware.nvidia = {
        prime.offload.enable = lib.mkForce false;
        powerManagement = {
          enable = lib.mkForce false;
          finegrained = lib.mkForce false;
        };
      };
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.nvidia = {
    prime = {
      offload.enable = true;

      # FIXME: nix-shell -p lshw --run "lshw -c display"
      nvidiaBusId = "PCI:1:00:0";
      intelBusId = "PCI:0:2:0";
    };

    powerManagement = {
      enable = true;  # enable systemd-based graphical suspend to prevent black screen on resume
      finegrained = true;  # power down GPU when no applications are running that require nvidia
    };
  };

  # Misc. hardware config TODO: mv to hardware-configuration.nix?
  services.tlp.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # =========================
  # BEGIN GENERAL CONFIG
  # =========================
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
      auto-optimise-store = true;  # Deduplicate and optimize nix store
    };
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "no"; # Forbid root login through SSH.
    passwordAuthentication = false; # Use keys only
  };

  networking = {
    hostName = "obelisk";  # FIXME
    networkmanager.enable = true;
  };

  i18n.defaultLocale = "en_US.utf8";

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "caps:swapescape"; # use caps lock as escape key

    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;  # only required for laptops with touchpad
        tapping = true;
      };
    };

    desktopManager.xterm.enable = false;
    displayManager = {
      defaultSession = "none+i3";  # no desktop, i3 tiling wm
      lightdm.enable = true;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu # app launch bar (ctrl + E)
	    i3status  # default i3 status bar
	    i3lock  # lock/login screen
      ];
    };
  };

  # Enable automatic location
  services.geoclue2.enable = true;  # TODO: restrict to specific users
  location.provider = "geoclue2";
  services.localtimed.enable = true;

  console.keyMap = "dvorak";

  users.users = {
    djinn = {
      # FIXME: Be sure to change this (using passwd) after rebooting!
      initialPassword = "personwomanmancameratv";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add SSH public key(s) here
      ];
      # TODO: replace sudo with doas
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };

  # TODO: replace sudo with doas?
  security.sudo = {
    enable = true;
    execWheelOnly = true;  # patch for CVE-2021-3156
  };

  # create sym link to wallpaper file in repo
  systemd.user.services.wallpaper-setter = {
    script = ''
        ln -sf ${config.users.users.djinn.home}/nix-config/nixos/nix_flakes_background.jpeg ${config.users.users.djinn.home}/.background-image
      '';
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
