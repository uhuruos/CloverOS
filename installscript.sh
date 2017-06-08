if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
read -p "Enter preferred root password " rootpassword
read -p "Enter preferred username " user
read -p "Enter preferred user password " userpassword

mkdir gentoo

echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sda
mkfs.ext4 /dev/sda1
mount /dev/sda1 gentoo

cd gentoo

wget https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-20170525.tar.bz2
tar pxf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << EOF | chroot .

emerge-webrsync

echo -e '\nPORTAGE_BINHOST="https://cloveros.ga"\nMAKEOPTS="-j8"\nEMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"\nCFLAGS="-O2 -pipe -march=native"\nCXXFLAGS="${CFLAGS}"' >> /etc/portage/make.conf

emerge grub dhcpcd

#emerge gentoo-sources genkernel
#wget http://liquorix.net/sources/4.9/config.amd64
#MAKEOPTS="-j8" genkernel --kernel-config=config.amd64 all

wget https://raw.githubusercontent.com/chiru-no/cloveros/master/kernel.xz
tar xf kernel.xz
mkdir /lib/modules/
mv kernel/*/ /lib/modules
mv kernel/* /boot/
rmdir kernel

grub-install /dev/sda
grub-mkconfig > /boot/grub/grub.cfg

rc-update add dhcpcd default

echo -e "$rootpassword\n$rootpassword" | passwd

useradd $user
echo -e "$userpassword\n$userpassword" | passwd user
gpasswd -a $user wheel
emerge xorg-server twm feh aterm sudo xfe wpa_supplicant dash
sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -Ei "s/^c([2-6]):2345/#\0/" /etc/inittab
rc-update add wpa_supplicant default
cd /home/$user/
rm .bash_profile
wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.bash_profile
wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.twmrc
wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/wallpaper.png
eselect fontconfig enable 52-infinality.conf
eselect infinality set infinality
eselect lcdfilter set infinality

exit

EOF

reboot
