#!/bin/bash
if [ -e /dev/vda ]
then
    DEV=/dev/vda
else
    DEV=/dev/sda
fi
# install grub
pacman --noconfirm -Sy grub
grub-install --target=i386-pc --force $DEV
grub-mkconfig -o /boot/grub/grub.cfg
# set up root password
read -p "Please enter your root password: " ROOTPASS
echo "root:$ROOTPASS" | chpasswd
# set up normal user
read -p "Enter the username of your user: " USERNAME
useradd -m $USERNAME
usermod -aG wheel $USERNAME
read -p "Please enter your user password: " USERPASS
echo "$USERNAME:$USERPASS" | chpasswd
# set up sudo
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //g' /etc/sudoers
# delete grub after config
pacman --noconfirm -R grub
# enable the network
systemctl enable dhcpcd
systemctl enable iwd
systemctl enable NetworkManager
exit
