#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

rootpassword=password
user=livecd
userpassword=password

mkdir image
cd image

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

rc-update add dhcpcd default

echo "root:$rootpassword" | chpasswd
useradd $user
echo "$user:$userpassword" | chpasswd
gpasswd -a $user wheel

emerge -e world xorg-server fvwm spacefm rxvt-unicode nitrogen sudo wpa_supplicant porthole firefox emacs gimp mpv smplayer filezilla rtorrent-ps weechat linux-firmware alsa-utils zsh zsh-completions gentoo-zsh-completions vlgothic hack liberation-fonts nano scrot xbindkeys xinput arandr qastools slock xarchiver p7zip gparted squashfs-tools os-prober

echo 'frozen-files="/etc/sudoers"' >> /etc/dispatch-conf.conf
sed -i "s/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
sed -Ei "s@c([2-6]):2345:respawn:/sbin/agetty 38400 tty@#\0@" /etc/inittab
sed -i "s@c1:12345:respawn:/sbin/agetty 38400 tty1 linux@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@" /etc/inittab
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
xdg-settings set default-web-browser firefox.desktop
mkdir Desktop/
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Home\nIcon=user-home\nExec=spacefm ~/" > Desktop/home.desktop
cp /usr/share/applications/{firefox.desktop,smplayer.desktop,emacs.desktop,zzz-gimp.desktop,porthole.desktop,filezilla.desktop,xarchiver.desktop} Desktop/
echo -e "~rows=9\n1=home.desktop\n2=firefox.desktop\n3=smplayer.desktop\n4=emacs.desktop\n5=porthole.desktop\n6=zzz-gimp.desktop\n7=filezilla.desktop\n8=xarchiver.desktop" > .config/spacefm/desktop0
mkdir .config/nitrogen/
wget https://gitgud.io/cloveros/cloveros/raw/master/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
sed -i "s@/home/user/@/home/$user/@" .config/nitrogen/nitrogen.cfg
chown -R $user /home/$user/

sed -i "s@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@c1:12345:respawn:/sbin/agetty -a $user --noclear 38400 tty1 linux@" /etc/inittab
sed -i 's/^/#/' /home/$user/.bash_profile
echo -e 'if [ -z "\$DISPLAY" ]; then
export DISPLAY=:0
X&
sleep 1
fvwm&
nitrogen --set-zoom wallpaper.png
xbindkeys
urxvt -geometry \$(xrandr | awk "NR==1{print \"80x24+\"\\\$8/2-283\"+\"\\\$10/2-191}") -e sudo ./livecd_install.sh
fi' >> /home/$user/.bash_profile
wget https://gitgud.io/cloveros/cloveros/raw/master/livecd_install.sh -O /home/$user/livecd_install.sh
chmod +x /home/$user/livecd_install.sh

emerge --depclean
rm -Rf /usr/portage/packages/* /etc/resolv.conf

exit

EOF

cd ..
umount -l image/*
wget https://gitgud.io/cloveros/cloveros/raw/master/livecd_files.tar.xz
tar xf livecd_files.tar.xz
mv *aufs* image/lib/modules/
mksquashfs image/ image.squashfs -b 1024k -comp xz -Xbcj x86 -Xdict-size 100%
mv image.squashfs files
xorriso -as mkisofs -r -J \
       	-joliet-long -l -cache-inodes \
       	-isohybrid-mbr isohdpfx.bin \
       	-partition_offset 16 -A "Gentoo Live" \
       	-b isolinux/isolinux.bin -c isolinux/boot.cat \
       	-no-emul-boot -boot-load-size 4 -boot-info-table  \
	-o CloverOS-x86_64-$(date +"%Y%m%d").iso files
rm -Rf image/ files/ isohdpfx.bin livecd_files.tar.xz
