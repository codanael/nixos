#!/bin/bash

disk=(/dev/disk/by-id/ata-QEMU_HARDDISK_QM00003)
swap=8GiB
encryption=false
zfsparam=""
user="anael"

# Check if disk var is set
test -z $disk && echo "disk var not defined" && exit 1

nixos-generate-config --root /mnt

swapconf="swapDevices = ["
for x in ${disk[@]}; do
swapconf="$swapconf { device = \"$x-part2\";randomEncryption = true;}"
done

swapconf="$swapconf ];"

cp /etc/machine-id /mnt/persist/etc

mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration-zfs.nix 
sed -i "s|./hardware-configuration.nix|./hardware-configuration-zfs.nix ./zfs.nix|g" /mnt/etc/nixos/configuration.nix

sed -i 's|fsType = "tmpfs";|fsType = "tmpfs"; options = [ "defaults" "size=4G" "mode=755" ];|g' \
/mnt/etc/nixos/hardware-configuration-zfs.nix

sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' \
/mnt/etc/nixos/hardware-configuration-zfs.nix

sed -i 's|fsType = "vfat";|fsType = "vfat"; options = [ "X-mount.mkdir" ];|g' \
/mnt/etc/nixos/hardware-configuration-zfs.nix

sed -i "s|swapDevices = \[ \];|${swapconf}|g" \
/mnt/etc/nixos/hardware-configuration-zfs.nix

rm -f /mnt/etc/nixos/zfs.nix

tee -a /mnt/etc/nixos/zfs.nix <<EOF
{ config, pkgs, ... }:

{ boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "$(head -c 8 /etc/machine-id)";
EOF

tee -a /mnt/etc/nixos/zfs.nix <<EOF
  services.openssh = {
    enable = true;
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
    "L /var/lib/bluetooth - - - - /persist/var/lib/bluetooth"
  ];
  environment.etc."NetworkManager/system-connections" = {
    source = "/persist/etc/NetworkManager/system-connections/";
  };
  environment.etc."machine-id".source
    = "/persist/etc/machine-id";
EOF

rootPwd=$(mkpasswd -m SHA-512 -s)

tee -a /mnt/etc/nixos/zfs.nix <<EOF
users.users.root.initialHashedPassword = "${rootPwd}";
}
EOF

echo "nixos-install -v --show-trace --no-root-passwd --root /mnt && umount -Rl /mnt && zpool export -a"
