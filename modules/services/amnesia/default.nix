{pkgs, ...}: {
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

    mkdir -pm 755 /persist/etc/NetworkManager
    mkdir -pm 755 /persist/etc/ssh

    mkdir -pm 755 /persist/var/lib
    mkdir /persist/var/lib/acme
    mkdir /persist/var/lib/bluetooth
  '';

  environment.etc = {
    "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    adjtime.source = "/persist/etc/adjtime"; # persist files' last modified date across reboots
    machine-id.source = "/persist/etc/machine-id";
  };

  services.openssh = {
    hostKeys = [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };

  systemd.tmpfiles.rules = [
    "L /var/lib/acme - - - - /persist/var/lib/acme"
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
    "L /var/lib/prometheus - - - - /persist/var/lib/prometheus"
  ];
}
