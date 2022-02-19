#!/bin/bash
if [ -e /dev/vda ]
then
    DEV=/dev/vda
else
    DEV=/dev/sda
fi

# ask for hostname
read -p "Please enter a hostname to use: " HOSTNAME

# check boot mode and create paritions appropriately
if [ -e /sys/firmware/efi/efivars ]
then
    parted ${DEV} \ mklabel gpt \ mkpart primary 1 120M \ mkpart primary 120M 100% -s
else
    parted ${DEV} \ mklabel msdos \ mkpart primary 1 120M \ mkpart primary 120M 100% -s
# format partitions
mkfs.vfat ${DEV}1
mkfs.btrfs -f ${DEV}2
# mount file systems
mount -o compress-force=zstd:15 ${DEV}2 /mnt
mkdir /mnt/boot
mkdir /mnt/etc
mount ${DEV}1 /mnt/boot
# add btrfs to mknitcpio
echo "HOOKS=(base udev autodetect modconf block filesystems fsck btrfs)" >> /mnt/etc/mkinitcpio.conf
# install the system
pacstrap /mnt linux-hardened linux-firmware pacman dhcpcd sed which micro systemd-sysvcompat pam sudo gzip networkmanager iwd btrfs-progs
# set the hostname
echo $HOSTNAME >> /mnt/etc/hostname
# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
# perform chroot tasks
cp ./trolley-arch-chroot.sh /mnt
arch-chroot /mnt ./trolley-arch-chroot.sh
echo "Finished! You can now reboot, if there are any issues please report them on github."
