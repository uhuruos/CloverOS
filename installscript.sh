sudo su
echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mkdir gentoo
mount /dev/sda1 gentoo
cd gentoo

wget http://distfiles.gentoo.org/releases/amd64/autobuilds/20170504/stage3-amd64-20170504.tar.bz2
tar pxvf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

chroot .

emerge-webrsync

echo -e "\nMAKEOPTS=\"-j8\"\nEMERGE_DEFAULT_OPTS=\"--keep-going=y --autounmask-write=y --jobs=8\"\nCFLAGS=\"-O3 -pipe -march=native\"\nCXXFLAGS=\"\${CFLAGS}\"" 
>> /etc/portage/make.conf

emerge grub dhcpcd gentoo-sources genkernel

wget http://liquorix.net/sources/4.9/config.amd64
MAKEOPTS="-j8" genkernel --kernel-config=config.amd64 all

grub-install /dev/sda
grub-mkconfig > /boot/grub/grub.cfg

rc-update add dhcpcd default

passwd

exit

reboot

emerge xorg-server enlightenment:0.17
useradd -m user
gpasswd -a user wheel
passwd user
echo "enlightenment_start" > /home/user/.xinitrc
echo '[[ $(tty) = "/dev/tty1" ]] && exec startx' >> /home/user/.bash_profile

