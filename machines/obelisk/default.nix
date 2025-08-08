# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ../../modules/profiles/common
    ../../modules/devices/audio
    #../../modules/services/k3s
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
    supportedFilesystems = ["btrfs"];
  };

  # =========================
  # BEGIN GENERAL CONFIG
  # =========================
  networking = {
    hostName = "obelisk";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
