mkdir gentoo

echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 gentoo

cd gentoo

wget https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20170525.tar.bz2
tar pxvf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

chroot . /bin/bash -x <<'EOF'

emerge-webrsync

echo -e '\nPORTAGE_BINHOST="https://cloveros.ga"\nMAKEOPTS="-j8"\nEMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"\nCFLAGS="-O2 -pipe -march=native"\nCXXFLAGS="${CFLAGS}"' >> /etc/portage/make.conf

emerge grub dhcpcd gentoo-sources genkernel

wget http://liquorix.net/sources/4.9/config.amd64
MAKEOPTS="-j8" genkernel --kernel-config=config.amd64 all

grub-install /dev/sda
grub-mkconfig > /boot/grub/grub.cfg

rc-update add dhcpcd default

passwd

useradd user
passwd user
emerge xorg-server twm
cd /home/user/
wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.twmrc
wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.bash_profile

exit

EOF

reboot
