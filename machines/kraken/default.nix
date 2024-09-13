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

    ../../modules/profiles/common

    # ../../modules/services/k3s
    ../../modules/services/amnesia
    ../../modules/services/home_assistant
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
    hostName = "kraken"; # FIXME
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
