#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"
rootpassword=password
username=livecd
userpassword=password

mkdir image/
cd image/

builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr 's/.*href="stage3-amd64-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.xz
tar pxf stage3*
rm -f stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat <<HEREDOC | chroot .
emerge-webrsync
eselect profile set "default/linux/amd64/17.0/hardened"
echo '
CFLAGS="-O3 -march=native -mfpmath=both -pipe -funroll-loops -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution"
CXXFLAGS="\${CFLAGS}"
CPU_FLAGS_X86="mmx mmxext sse sse2 ssse3 sse3"
MAKEOPTS="-j8"
PORTAGE_NICENESS=19
PORTAGE_BINHOST="https://cloveros.ga"
EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=4 -G"
ACCEPT_KEYWORDS="**"
ACCEPT_LICENSE="*"
binhost_mirrors="\$PORTAGE_BINHOST,https://useast.cloveros.ga,https://uswest.cloveros.ga,https://ca.cloveros.ga,https://fr.cloveros.ga,https://nl.cloveros.ga,https://uk.cloveros.ga,https://au.cloveros.ga,https://sg.cloveros.ga,https://jp.cloveros.ga,"
FETCHCOMMAND_HTTPS="sh -c \"aria2c -x2 -s99 -j99 -k1M -d \"\\\${DISTDIR}\" -o \"\\\${FILE}\" \\\\\\\$(sed -e \"s#,#\\\${DISTDIR}/\\\${FILE}\"\ \"#g\" -e \"s#\$PKGDIR##g\" -e \"s#.partial##g\" <<< \$binhost_mirrors) & aria2c --allow-overwrite -d \"\\\${DISTDIR}\" -o \"\\\${FILE}.asc\" \\\\\\\$(sed -e \"s#,#/s/signatures/\\\${DISTDIR}/\\\${FILE}.asc\"\ \"#g\" -e \"s#\$PKGDIR##g\" -e \"s#.partial##g\" <<< \$binhost_mirrors) && wait && gpg --verify \"\\\${DISTDIR}/\\\${FILE}.asc\" \"\\\${DISTDIR}/\\\${FILE}\" && rm \"\\\${DISTDIR}/\\\${FILE}.asc\"\""' >> /etc/portage/make.conf
while ! gpg --list-keys "CloverOS GNU/Linux (Package signing)"; do gpg --keyserver hkp://pool.sks-keyservers.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"; done
FETCHCOMMAND_HTTPS="wget -O \"\\\${DISTDIR}/\\\${FILE}\" \"\\\${URI}\"" emerge aria2

#emerge gentoo-sources genkernel
#wget http://liquorix.net/sources/4.19/config.amd64
#genkernel --kernel-config=config.amd64 all
wget https://cloveros.ga/s/kernel.tar.lzma https://cloveros.ga/s/signatures/s/kernel.tar.lzma.asc
gpg --verify kernel.tar.lzma.asc kernel.tar.lzma && tar xf kernel.tar.lzma
rm kernel.tar.lzma kernel.tar.lzma.asc

emerge grub dhcpcd
rc-update add dhcpcd default

echo "root:$rootpassword" | chpasswd
useradd $username
echo "$username:$userpassword" | chpasswd
gpasswd -a $username wheel

emerge -eD @world xorg-server fvwm spacefm rxvt-unicode nitrogen compton nomacs sudo wpa_supplicant porthole firefox emacs gimp mpv smplayer rtorrent weechat linux-firmware alsa-utils zsh zsh-completions gentoo-zsh-completions vlgothic hack liberation-fonts nano scrot xbindkeys xinput arandr qastools slock xarchiver p7zip games-envd gparted squashfs-tools os-prober exfat-nofuse sshfs curlftpfs
PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\\\${DISTDIR}/\\\${FILE}\" \"\\\${URI}\"" emerge -1 glib qtgui
emerge --depclean
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
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
usermod -aG audio,video,games,input $username
binutils-config --linker ld.gold
cd /home/$username/
rm .bash_profile
wget $gitprefix/home/user/{.bash_profile,.zprofile,.zshrc,.fvwm2rc,.Xdefaults,wallpaper.png,wallpaper43.png,wallpaper1610.png,.xbindkeysrc,screenfetch-dev,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
chmod +x screenfetch-dev cloveros_settings.sh stats.sh rotate_screen.sh
mkdir -p .emacs.d/backups/ .emacs.d/autosaves/ Downloads/ .rtorrent/ .mpv/ .config/spacefm/ .config/nitrogen/ .config/nomacs/ Desktop/
sed -i "s@/home/user/@/home/$username/@" .rtorrent.rc
wget $gitprefix/home/user/.mpv/config -P .mpv/
wget $gitprefix/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
sed -i "s@/home/user/@/home/$username/@" .config/nitrogen/nitrogen.cfg
wget $gitprefix/home/user/.config/nomacs/Image\ Lounge.conf -P .config/nomacs/
wget $gitprefix/home/user/.config/spacefm/session -P .config/spacefm/
sed -i "s@/home/user/@/home/$username/@" .config/spacefm/session
wget $gitprefix/home/user/.config/mimeapps.list -P .config/
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Home\nIcon=user-home\nExec=spacefm ~/" > Desktop/home.desktop
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Applications\nIcon=folder\nExec=spacefm /usr/share/applications/" > Desktop/applications.desktop
cp /usr/share/applications/{firefox.desktop,smplayer.desktop,emacs.desktop,zzz-gimp.desktop,porthole.desktop,xarchiver.desktop} Desktop/
echo -e "~rows=0\n1=home.desktop\n2=applications.desktop\n3=firefox.desktop\n4=smplayer.desktop\n5=emacs.desktop\n6=porthole.desktop\n7=zzz-gimp.desktop\n8=xarchiver.desktop" > .config/spacefm/desktop0
chown -R $username /home/$username/

wget $gitprefix/livecd_install.sh -P /home/$username/
chmod +x /home/$username/livecd_install.sh
sed -i "s@c1:12345:respawn:/sbin/agetty --noclear 38400 tty1 linux@c1:12345:respawn:/sbin/agetty -a $username --noclear 38400 tty1 linux@" /etc/inittab
sed -i 's/^/#/' /home/$username/.bash_profile
echo -e 'if [ -z "$DISPLAY" ] && [ -z "$SSH_CLIENT" ] && ! pgrep X > /dev/null; then
X &
sleep 1
fvwm &
export DISPLAY=:0
sleep 2 && xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1 & xinput list --name-only | sed "/Virtual core pointer/,/Virtual core keyboard/\"\!\"d;//d" | xargs -I{} xinput set-prop {} "libinput Accel Profile Enabled" 0 1 &> /dev/null &
urxvt -geometry 80x24+\$(xrandr | awk "NR==1{print \\\$8/2-283\"+\"\\\$10/2-191}") -e sudo ./livecd_install.sh &
cp wallpaper.png wallpaper169.png && ratio=\$(xrandr | awk "NR==1{print substr(\\\$8/\\\$10, 0, 4)}"); [ \$ratio == 1.6 ] && cp wallpaper1610.png wallpaper.png; [ \$ratio == 1.33 ] && cp wallpaper43.png wallpaper.png;
nitrogen --set-zoom wallpaper.png
fi' >> /home/$username/.bash_profile

rm -Rf /usr/portage/packages/* /etc/resolv.conf
exit
HEREDOC

cd ..
umount -l image/*
[ ! -f livecd_files.tar.xz ] && wget $gitprefix/livecd_files.tar.xz
tar -C image/lib/modules/ -xf livecd_files.tar.xz 4.5.2-aufs-r1/
tar -C image/ -xf livecd_files.tar.xz files/
mv image/files/ iso/
mksquashfs image/ iso/image.squashfs -b 1024k -comp xz -Xbcj x86 -Xdict-size 100%
xorriso -as mkisofs -r -J \
	-joliet-long -l -cache-inodes \
	-isohybrid-mbr /usr/share/syslinux/isohdpfx.bin \
	-partition_offset 16 -A "Gentoo Live" \
	-b isolinux/isolinux.bin -c isolinux/boot.cat \
	-no-emul-boot -boot-load-size 4 -boot-info-table  \
	-o CloverOS-x86_64-$(date +"%Y%m%d").iso iso/
rm -Rf image/ iso/
