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
echo "Please enter your root password below."
passwd
read -p "Enter the username of your user: " USERNAME
useradd $USERNAME
usermod -aG wheel $USERNAME
echo "Please enter your user password below."
passwd $USERNAME
# remove all the useless stuf
pacman --noconfirm -R grub
systemctl enable dhcpcd
systemctl enable iwd
systemctl enable NetworkManager
exit
