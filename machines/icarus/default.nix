{
  inputs,
  config,
  pkgs,
  ...
}: let
  apple-silicon-support =
    builtins.fetchTarball
    "https://github.com/tpwrules/nixos-apple-silicon/archive/main.tar.gz";
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
    # import latest asahi kernel modules
    "${apple-silicon-support}/apple-silicon-support"
    ../../modules/profiles/physical_machine/laptop
    ../../modules/services/prometheus
    ../../modules/services/grafana
    ../../modules/services/loki
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = ["btrfs"];

  networking.hostName = "icarus"; # Define your hostname.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Enable sound.
  hardware.asahi = {
    withRust = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    setupAsahiSound = true;
  };

  hardware.opengl = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
  ];
  services.udev.packages = [pkgs.yubikey-personalization];

  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
