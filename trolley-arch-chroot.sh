#!/bin/bash
if [ -e /dev/vda ]
then
    DEV=/dev/vda
else
    DEV=/dev/sda
fi
pacman --noconfirm -Sy grub
# install grub
grub-install --target=i386-pc --force $DEV
grub-mkconfig -o /boot/grub/grub.cfg
read -p "Please enter your root password: " ROOTPASS
echo "root:$ROOTPASS" | chpasswd
read -p "Enter the username of your user: " USERNAME
useradd -m $USERNAME
usermod -aG wheel $USERNAME
read -p "Please enter your user password: " USERPASS
echo "$USERNAME:$USERPASS" | chpasswd
# remove all the useless stuf
pacman --noconfirm -R grub
systemctl enable dhcpcd
systemctl enable iwd
systemctl enable NetworkManager
exit
