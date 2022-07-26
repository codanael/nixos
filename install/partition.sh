#!/bin/bash

disk=(/dev/disk/by-id/ata-QEMU_HARDDISK_QM00003)
swap=8GiB
encryption=false
zfsparam=""
user="anael"


# Check if disk var is set
test -z $disk && echo "disk var not defined" && exit 1

# Set encryption params if set to true
if $encryption; then
	zfsparam="$zfsparam -O encryption=aes-256-gcm -O keylocation=prompt -O keyformat=passphrase" 
fi

# Use mirror layout if more than one disk
if [[ ${#disk[@]} -gt 1 ]]; then
	zfsparam="$zfsparam mirror" 
fi

# Create partitions
for x in ${disk}; do
  echo $x
  sgdisk --zap-all $x
  parted $x -- mklabel gpt
  parted $x -- mkpart primary 512MiB -$swap
  parted $x -- mkpart primary linux-swap -$swap 100%
  parted $x -- mkpart ESP fat32 1MiB 512MiB
  parted $x -- set 3 esp on
  sleep 2

  mkswap -L swap $x-part2
  mkfs.fat -F 32 -n EFI $x-part3
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
  "${disk[@]/%/-part1}"

zfs create -o refreservation=1G -o mountpoint=none rpool/reserved
zfs create -o canmount=on -o mountpoint=/ rpool/nixos
zfs create -o canmount=on -o atime=off rpool/nixos/nix
zfs create -o canmount=on -o mountpoint=/var rpool/nixos/var
zfs create -o canmount=on  rpool/nixos/var/log

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

chown -R 1000:100 /mnt/home/$user

mkdir /mnt/boot
mount "${disk}-part3" /mnt/boot
