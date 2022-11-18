{pkgs, ...}:

{
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    adjtime.source = "/persist/etc/adjtime"; # persist files' last modified date across reboots
    NIXOS.source = "/persist/etc/NIXOS";  # TODO: where is this used?
    machine-id.source = "/persist/etc/machine-id";
    passwd.source = "/persist/etc/passwd";
    shadow.source = "/persist/etc/shadow";
  };
  
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -p /mnt
    mount -o subvol=/ /dev/mapper/enc /mnt
    
    # rm any subvolumes created by previous session before deleting /root
    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    umount /mnt    
    '';
}
