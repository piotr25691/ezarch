#!/bin/bash

# ezArch - An easy way to get Arch installed on your machine!
#
# This script consists of two parts:
# - ezarch.sh: installs the base system to your hard disk
# - ezarch-chroot.sh: does post-setup of your newly installed arch system
#
# To get started, run ezarch.sh
# Be aware that this will wipe your drive clean, so check if you got backups,
# or that you don't need stuff currently on your hard disk.
#
# This script requires an IDE, SCSI or SATA disk, MMC storage is not supported.
#
# Enjoy using Arch btw!

# Prompt the user to select the device to install Arch on
# Blind assumptions caused the script to try install to a non-writable device, hence why this has been implemented.
lsblk
echo Please enter the device name to use...
read DEV

# Ask the user for the hostname
# The hostname is the name used to identify the device on your network.
# In case of home networks, this does not really matter, but you can still name your device here.
read -p "Please enter a hostname to use: " HOSTNAME

# Determine BIOS/UEFI mode, and partition the drive appropriately
# In the older versions of this script, only BIOS was supported.
if [ -e /sys/firmware/efi/efivars ]
then
    parted ${DEV} \ mklabel gpt \ mkpart primary 1 120M \ mkpart primary 120M 100% -s
    mkfs.vfat ${DEV}1
    mkfs.btrfs -f ${DEV}2
    mount -o compress-force=zstd:15 ${DEV}2 /mnt
    mkdir -p /mnt/boot/efi
    mkdir /mnt/etc
    mount ${DEV}1 /mnt/boot/efi
else
    parted ${DEV} \ mklabel msdos \ mkpart primary 1 120M \ mkpart primary 120M 100% -s
    mkfs.vfat ${DEV}1
    mkfs.btrfs -f ${DEV}2
    mount -o compress-force=zstd:15 ${DEV}2 /mnt
    mkdir /mnt/boot
    mkdir /mnt/etc
    mount ${DEV}1 /mnt/boot
fi

# Add BTRFS to /etc/mkinitcpio.conf
# This script uses the BTRFS filesystem to allow you to save some storage.
# If you want to use EXT4 instead, look elsewhere.
echo "HOOKS=(base udev autodetect modconf block filesystems fsck btrfs)" >> /mnt/etc/mkinitcpio.conf

# Install the system
# This installs the bare minimum of packages required to install Arch.
# You can add any additional dependencies yourself afterwards.
pacstrap /mnt linux-hardened linux-firmware pacman dhcpcd sed which micro systemd-sysvcompat pam sudo gzip networkmanager iwd btrfs-progs


# Set up the previously selected hostname
echo $HOSTNAME >> /mnt/etc/hostname

# Generate /etc/fstab
# This file determines the mount points and other stuff necessary for Arch to use your drive.
genfstab -U /mnt >> /mnt/etc/fstab

# Start post-setup tasks
cp ./ezarch-chroot.sh /mnt
arch-chroot /mnt ./ezarch-chroot.sh $DEV

# Setup is finished
# You can reboot after seeing this message, only if no commands errored out.
echo "You have successfully installed Arch Linux on your computer. You may now reboot."
