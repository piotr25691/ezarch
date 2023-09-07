#!/bin/bash
DEV=$1

# Install the GRUB bootloader
# This is the part that allows you to boot into the system.
pacman --noconfirm -Sy grub efibootmgr
if [ -e /sys/firmware/efi/efivars ]
then
    grub-install --target=x86_64-efi --force $DEV
else
    grub-install --target=i386-pc --force $DEV
fi
grub-mkconfig -o /boot/grub/grub.cfg

# Ask for and set up the root password.
# Please pick something secure, or you'll get kids fucking around in your computer.
echo "Please enter your root password: "
read -s ROOTPASS
echo "root:$ROOTPASS" | chpasswd

# Ask and setup the username and password of the regular user.
# This user will have sudo privileges, so please set up a secure password if you don't want kids fucking around in your computer.
read -p "Enter the username of your user: " USERNAME
useradd -m $USERNAME
usermod -aG wheel $USERNAME
echo "Please enter your user password: "
read -s USERPASS
echo "$USERNAME:$USERPASS" | chpasswd

# Enable wheel privileges for doas
# They don't get configured with the installation of the package.
printf "permit persist :wheel\npermit nopass root\n" > /etc/doas.conf

# Create symlinks to micro
# The default text editor of choice in ezArch is Micro.
# If you want to go back to Nano, or use Vim, delete the symlinks and install the corresponding package.
ln -s $(which micro) /bin/nano
ln -s $(which micro) /bin/vim

# Delete GRUB after setup
# GRUB packages are not needed after setup, so they will be deleted to save space.
pacman --noconfirm -R grub efibootmgr

# Enable network services
# These services will allow you to connect to the internet.
systemctl enable dhcpcd
systemctl enable iwd
systemctl enable NetworkManager

# Remove the chroot file
# This also saves space.
rm -rf /ezarch-chroot.sh
exit