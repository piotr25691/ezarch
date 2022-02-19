#!/bin/bash
if [ -e /dev/vda ]
then
    DEV=/dev/vda
else
    DEV=/dev/sda
fi
# install grub

pacman --noconfirm -Sy grub efibootmgr
if [ -e /sys/firmware/efi/efivars ]
then
    grub-install --target=x86_64-efi --force $DEV
else
    grub-install --target=i386-pc --force $DEV
fi
grub-mkconfig -o /boot/grub/grub.cfg
# set up root password
echo "Please enter your root password: "
read -s ROOTPASS
echo "root:$ROOTPASS" | chpasswd
# set up normal user
read -p "Enter the username of your user: " USERNAME
useradd -m $USERNAME
usermod -aG wheel $USERNAME
echo "Please enter your user password: "
read -s USERPASS
echo "$USERNAME:$USERPASS" | chpasswd
# set up sudo
sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //g' /etc/sudoers
# create symlinks for compatibility with micro
ln -s $(which micro) /bin/nano
ln -s $(which micro) /bin/vim
# delete grub after config
pacman --noconfirm -R grub efibootmgr
# enable the network
systemctl enable dhcpcd
systemctl enable iwd
systemctl enable NetworkManager
# remove chroot file after install
rm -rf /trolley-arch-chroot.sh
exit
