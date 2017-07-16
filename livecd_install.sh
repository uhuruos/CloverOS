#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

read -erp "Automatic partitioning (a) or manual partitioning? (m) [a/m] " -n 1 partitioning
echo
if [[ $partitioning = "a" ]]; then
    read -erp "Enter drive for CloverOS installation: " -i "/dev/sda" drive
    partition=${drive}1
elif [[ $partitioning = "m" ]]; then
    sudo gparted &> /dev/null &
    read -erp "Enter partition for CloverOS installation: " -i "/dev/sda1" partition
    drive=${partition%"${partition##*[!0-9]}"}
else
    echo "Invalid option."
    exit 1
fi
drive=${drive#*/dev/}
partition=${partition#*/dev/}
read -erp "Partitioning: $partitioning
Drive: /dev/$drive
Partition: /dev/$partition
Is this correct? [y/n] " -n 1 yn
if [[ $yn != "y" ]]; then
    exit 1
fi
echo

read -erp "Enter preferred root password " rootpassword
read -erp "Enter preferred username " user
read -erp "Enter preferred user password " userpassword

livecduser=livecd

mkdir gentoo

if [[ $partitioning = "a" ]]; then
    echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
    mkfs.ext4 -F /dev/$partition
fi
mount /dev/$partition gentoo

unsquashfs -f -d gentoo /mnt/cdrom/image.squashfs

cat << EOF | chroot gentoo

echo "root:$rootpassword" | chpasswd
useradd -M $user
echo "$user:$userpassword" | chpasswd
gpasswd -a $user wheel

grub-install --target=i386-pc /dev/$drive
grub-mkconfig > /boot/grub/grub.cfg

sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
sed -i "s@c1:12345:respawn:/sbin/agetty -a $livecduser --noclear 38400 tty1 linux@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@" /etc/inittab
sed -i '/^#/!d' /home/$livecduser/.bash_profile
sed -i 's/^#\(.*\)/\1/g' /home/$livecduser/.bash_profile

gpasswd -a $user video
gpasswd -a $user audio
sed -i "s@/home/$livecduser/@/home/$user/@" /home/$livecduser/.rtorrent.rc
mv /home/$livecduser/ /home/$user/
chown -R $user /home/$user/
if [[ $user != $livecduser ]]; then
    userdel $livecduser
fi
rm /home/$user/livecd_install.sh

EOF

reboot
