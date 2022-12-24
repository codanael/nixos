#!/bin/bash

DISK=(/dev/disk/by-id/ata-QEMU_HARDDISK_QM00003)
SWAP=8
# RPOOL = 200
encryption=false
zfsparam=""
user="anael"


# Check if disk var is set
test -z $DISK && echo "DISK var not defined" && exit 1

# Set encryption params if set to true
if $encryption; then
	zfsparam="$zfsparam -O encryption=aes-256-gcm -O keylocation=prompt -O keyformat=passphrase" 
fi

# Use mirror layout if more than one DISK
if [[ ${#DISK[@]} -gt 1 ]]; then
	zfsparam="$zfsparam mirror" 
fi

# Create partitions
for x in ${DISK}; do
  echo $x
  if ls $x-*; then wipefs -a $x-*; fi
  # Zapping disk
  sgdisk --zap-all $x
  # EFI partition
  sgdisk -n1:1M:+1G -t1:EF00 $x
  # SWAP if size is defined
  test -z $SWAP || sgdisk -n3:0:+${SWAP}G -t3:8200 $x
  # Root pool takes all left space if not defined
  if test -z $RPOOL; then
      sgdisk -n2:0:0   -t2:BF00 $x
  else
      sgdisk -n2:0:+${RPOOL}G -t2:BF00 $x
  fi
  # Space left at the end for small difference between disks
  sgdisk -a1 -n4:24K:+1000K -t4:EF02 $x
  
  sleep 2

  mkswap -L swap $x-part3
  mkfs.vfat -n EFI $x-part1
done

# Create ZFS pool
zpool create \
  -o ashift=12 \
  -o autotrim=on \
  -R /mnt \
  -O canmount=off \
  -O mountpoint=none \
  -O acltype=posixacl \
  -O compression=zstd \
  -O dnodesize=auto \
  -O normalization=formD \
  -O relatime=on \
  -O xattr=sa \
  $zfsparam rpool \
  "${DISK[@]/%/-part2}"

mount -t tmpfs tmpfs /mnt

zfs create -o refreservation=1G -o mountpoint=none rpool/reserved
zfs create -o canmount=off -o mountpoint=/ rpool/nixos
zfs create -o canmount=on -o atime=off rpool/nixos/nix
zfs create -o canmount=off -o mountpoint=/var rpool/nixos/var
zfs create -o canmount=on  rpool/nixos/var/log

zfs create -o canmount=on -o mountpoint=/persist rpool/persist

zfs create -o canmount=off -o mountpoint=/ rpool/userdata
zfs create -o canmount=on rpool/userdata/home
zfs create -o canmount=on -o mountpoint=/root rpool/userdata/home/root
zfs create -o canmount=on rpool/userdata/home/$user
zfs create -o canmount=on rpool/userdata/home/$user/Desktop
zfs create -o canmount=on rpool/userdata/home/$user/Downloads
zfs create -o canmount=on rpool/userdata/home/$user/Documents
zfs create -o canmount=on rpool/userdata/home/$user/Music
zfs create -o canmount=on rpool/userdata/home/$user/Videos
zfs create -o canmount=on rpool/userdata/home/$user/Pictures

mkdir -p /mnt/persist/etc/NetworkManager/system-connections
mkdir -p /mnt/persist/var/lib/bluetooth
mkdir -p /mnt/persist/etc/ssh
mkdir -p /mnt/persist/etc/nixos
mkdir -p /mnt/etc/nixos

mount --bind /mnt/persist/etc/nixos /mnt/etc/nixos

mkdir /mnt/boot
mount "${DISK}-part1" /mnt/boot

chown -R 1001 /mnt/userdata/home/$user