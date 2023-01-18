{ pkgs, lib, ... }:

let # env vars required for finegrained
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-GO
    export __GLX_VENDOR_LIBRARY_NAME=nvidia::
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
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

      # TODO: move to machine-specific config
      # FIXME: nix-shell -p lshw --run "lshw -c display"
      nvidiaBusId = "PCI:1:00:0";
      intelBusId = "PCI:0:2:0";
    };

    powerManagement = {
      # enable systemd-based graphical suspend to prevent black screen on resume
      enable = true;
      # power down GPU when no applications are running that require nvidia
      finegrained = true;
    };
  };
}
