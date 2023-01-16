# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware), use something like:
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # It's strongly recommended you take a look at
    # https://github.com/nixos/nixos-hardware
    # and import modules relevant to your hardware.

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware.nix

    ../../profiles/physical_machine/laptop

    ../../modules/system/stateless_system.nix
    ../../modules/system/devices/touchpad
    ../../modules/system/devices/gpu/nvidia

    ../../modules/services/prometheus
    ../../modules/services/loki
    ../../modules/services/grafana
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
  # BEGIN GENERAL CONFIG
  # =========================
  networking = {
    hostName = "obelisk"; # FIXME
    networkmanager.enable = true;
  };

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
