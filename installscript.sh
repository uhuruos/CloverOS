#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

while :; do
    echo
    read -erp "Automatic partitioning (a) or manual partitioning? (m) [a/m] " -n 1 partitioning
    if [[ $partitioning = "a" ]]; then
        read -erp "Enter drive for CloverOS installation: " -i "/dev/sda" drive
        partition=${drive}1
    elif [[ $partitioning = "m" ]]; then
        read -erp "Enter partition for CloverOS installation: " -i "/dev/sda1" partition
        if [[ $partition == /dev/map* ]]; then
            read -erp "Enter drive that contains install partition: " -i "/dev/sda" drive
        else
            drive=${partition%"${partition##*[!0-9]}"}
        fi
    else
        echo "Invalid option"
    fi
    drive=${drive#*/dev/}
    partition=${partition#*/dev/}
    read -erp "Partitioning: $partitioning
Drive: /dev/$drive
Partition: /dev/$partition
Is this correct? [y/n] " -n 1 yn
    if [[ $yn == "y" ]]; then
        break
    fi
done

while :; do
    echo
    read -erp "Enter preferred root password " rootpassword
    read -erp "Enter preferred username " user
    read -erp "Enter preferred user password " userpassword
    read -erp "Is this correct? [y/n] " -n 1 yn
    if [[ $yn == "y" ]]; then
        break
    fi
done

mkdir gentoo

if [[ $partitioning = "a" ]]; then
    echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/$drive
    mkfs.ext4 -F /dev/$partition
fi
tune2fs -O ^metadata_csum /dev/$partition
mount /dev/$partition gentoo

cd gentoo

builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr 's/.*href="stage3-amd64-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.xz
tar pxf stage3*
rm -f stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << EOF | chroot .

emerge-webrsync
eselect profile set "default/linux/amd64/17.0/hardened"

echo '
CFLAGS="-O3 -march=native -pipe -funroll-loops -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution"
CXXFLAGS="\${CFLAGS}"
CPU_FLAGS_X86="mmx mmxext sse sse2 ssse3 sse3"
MAKEOPTS="-j8"
PORTAGE_NICENESS=19
EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=4 -G"
PORTAGE_BINHOST="https://cloveros.ga"
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="**"' >> /etc/portage/make.conf

emerge -uvD world

emerge gnupg aria2
gpg --keyserver hkp://pool.sks-keyservers.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"
echo 'binhost_mirrors=\$PORTAGE_BINHOST",https://useast.cloveros.ga,https://uswest.cloveros.ga,https://ca.cloveros.ga,https://fr.cloveros.ga,https://nl.cloveros.ga,https://uk.cloveros.ga,https://au.cloveros.ga,https://sea.cloveros.ga,"
FETCHCOMMAND_HTTPS="sh -c \"aria2c -x2 -s99 -j99 -k1M -m1 -t2 --connect-timeout=2 --lowest-speed-limit=25K --dir \"\\\${DISTDIR}\" -o \"\\\${FILE}\" \\\\\\\$(sed -e \"s#,#\"\\\${DISTDIR}/\\\${FILE}\"\"\ \"#g\" -e \"s#"\$PKGDIR"##g\" -e \"s#.partial##g\" <<< "\$binhost_mirrors") && aria2c --dir \"\\\${DISTDIR}\" -o \"\\\${FILE}.asc\" \\\\\\\$(sed \"s#cloveros.ga/#cloveros.ga/s/signatures/#\" <<< \"\\\${URI}.asc\") && gpg --verify \"\\\${DISTDIR}/\\\${FILE}.asc\" \"\\\${DISTDIR}/\\\${FILE}\"\""' >> /etc/portage/make.conf

#emerge gentoo-sources genkernel
#wget http://liquorix.net/sources/4.15/config.amd64
#genkernel --kernel-config=config.amd64 all

wget https://cloveros.ga/s/kernel.tar.xz
wget https://cloveros.ga/s/signatures/s/kernel.tar.xz.asc
gpg --verify kernel.tar.xz.asc kernel.tar.xz
rm kernel.tar.xz.asc
tar xf kernel.tar.xz
mv initramfs-genkernel-*-gentoo* kernel-genkernel-*-gentoo* System.map-genkernel-*-gentoo* /boot/
mkdir /lib/modules/
mv *-gentoo*/ /lib/modules/
rm kernel.tar.xz

emerge grub dhcpcd

grub-install --target=i386-pc /dev/$drive &> /dev/null
grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null

rc-update add dhcpcd default

echo "root:$rootpassword" | chpasswd
useradd -M $user
echo "$user:$userpassword" | chpasswd
gpasswd -a $user wheel

emerge -e world xorg-server fvwm spacefm rxvt-unicode nitrogen sudo wpa_supplicant porthole firefox emacs gimp mpv smplayer filezilla rtorrent-ps weechat linux-firmware alsa-utils zsh zsh-completions gentoo-zsh-completions vlgothic hack liberation-fonts nano scrot xbindkeys xinput arandr qastools slock xarchiver p7zip gparted squashfs-tools os-prober

echo 'frozen-files="/etc/sudoers"' >> /etc/dispatch-conf.conf
sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -Ei "s@c([2-6]):2345:respawn:/sbin/agetty 38400 tty@#\0@" /etc/inittab
sed -i "s@c1:12345:respawn:/sbin/agetty 38400 tty1 linux@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@" /etc/inittab
sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel\nupdate_config=1" > /etc/wpa_supplicant/wpa_supplicant.conf
rc-update add alsasound default
rc-update add wpa_supplicant default
eselect fontconfig enable 52-infinality.conf
eselect infinality set infinality
eselect lcdfilter set infinality
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
gpasswd -a $user audio
gpasswd -a $user video
emerge -1O games-envd
gpasswd -a $user games
cd /home/$user/
rm .bash_profile
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.bash_profile
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.zprofile
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.zshrc
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.fvwm2rc
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.Xdefaults
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/wallpaper.png
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.xbindkeysrc
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/screenfetch-dev
chmod +x screenfetch-dev
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/bl.sh
chmod +x bl.sh
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/cloveros_settings.sh
chmod +x cloveros_settings.sh
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/stats.sh
chmod +x stats.sh
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/rotate_screen.sh
chmod +x rotate_screen.sh
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.emacs
mkdir -p .emacs.d/backups .emacs.d/autosaves
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.rtorrent.rc
sed -i "s@/home/user/@/home/$user/@" .rtorrent.rc
mkdir Downloads/
mkdir .rtorrent/
mkdir .mpv/
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.mpv/config -P .mpv/
mkdir -p .config/spacefm/
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.config/spacefm/session -P .config/spacefm/
sed -i "s@/home/user/@/home/$user/@" .config/spacefm/session
mkdir .config/nitrogen/
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
sed -i "s@/home/user/@/home/$user/@" .config/nitrogen/nitrogen.cfg
chown -R $user /home/$user/

emerge --depclean
rm -Rf /usr/portage/packages/*

exit

EOF

reboot
