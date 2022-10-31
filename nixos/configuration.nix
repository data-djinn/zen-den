# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, lib, config, pkgs, ... }: {

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
  ];

  boot.loader = {
    systemd-boot.enable = true;
    # this may need to change during setup of new workstation
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };

  # FIXME: change swap device if extra ram is desired
  boot.initrd.luks.devices."luks-aa02f40a-1e0b-4b50-b7ad-0ac9d24af4ef" = {
    device = "/dev/disk/by-uuid/aa02f40a-1e0b-4b50-b7ad-0ac9d24af4ef";
    keyFile = "/crypto_keyfile.bin";
  };

  # =========================
  # CUSTOM HARDWARE CONFIG
  # =========================
  # FIXME: NVIDIA PROPRIETARY HARDWARE CONFIG
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:00:0";
    intelBusId = "PCI:0:2:0";
  };

  # Misc. hardware config TODO: mv to hardware-configuration.nix?
  services.tlp.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;

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
    hostName = "obelisk"; 
    networkmanager.enable = true;
  };

  i18n.defaultLocale = "en_US.utf8";

  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "caps:swapescape"; # use caps lock as escape key

    libinput.enable = true;  # only required for laptops with touchpad

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

  console.keyMap = "dvorak";

  users.users = {
    djinn = {
      # Be sure to change this (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: Add SSH public key(s) here
      ];
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
