#!/bin/bash
if [ $(id -u) != '0' ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"

while :; do
	echo
	read -erp "Automatic partitioning (a) or manual partitioning? (m) [a/m] " -n 1 partitioning
	if [[ $partitioning = "a" ]]; then
		read -erp "Enter drive for CloverOS installation: " -i "/dev/sda" drive
		partition=${drive}1
	elif [[ $partitioning = "m" ]]; then
		read -erp "Enter partition for CloverOS installation: " -i "/dev/sda1" partition
		read -erp "Enter drive that contains install partition: " -i ${partition%${partition##*[!0-9]}} drive
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
	read -erp "Enter preferred username " username
	newuser=$(echo "$username" | tr A-Z a-z | tr -cd "[:alpha:][:digit:]" | sed "s/^[0-9]\+//" | cut -c -31)
	if [[ "$newuser" != "$username" ]]; then
		username=$newuser
		echo username changed to $username
	fi
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
PORTAGE_BINHOST="https://cloveros.ga" ACCEPT_KEYWORDS="**" emerge -1G aria2 portage python:2.7 python:3.6 openssh iputils wget curl libcap

echo '
CFLAGS="-O3 -march=native -pipe -funroll-loops -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution"
CXXFLAGS="\${CFLAGS}"
CPU_FLAGS_X86="mmx mmxext sse sse2 ssse3 sse3"
MAKEOPTS="-j8"
PORTAGE_NICENESS=19
EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=4 -G"
PORTAGE_BINHOST="https://cloveros.ga"
ACCEPT_LICENSE="*"
ACCEPT_KEYWORDS="**"
binhost_mirrors="\$PORTAGE_BINHOST,https://useast.cloveros.ga,https://uswest.cloveros.ga,https://ca.cloveros.ga,https://fr.cloveros.ga,https://nl.cloveros.ga,https://uk.cloveros.ga,https://au.cloveros.ga,https://sg.cloveros.ga,https://jp.cloveros.ga,"
FETCHCOMMAND_HTTPS="sh -c \"aria2c -x2 -s99 -j99 -k1M -d \"\\\${DISTDIR}\" -o \"\\\${FILE}\" \\\\\\\$(sed -e \"s#,#\\\${DISTDIR}/\\\${FILE}\"\ \"#g\" -e \"s#\$PKGDIR##g\" -e \"s#.partial##g\" <<< \$binhost_mirrors) & aria2c --allow-overwrite -d \"\\\${DISTDIR}\" -o \"\\\${FILE}.asc\" \\\\\\\$(sed -e \"s#,#/s/signatures/\\\${DISTDIR}/\\\${FILE}.asc\"\ \"#g\" -e \"s#\$PKGDIR##g\" -e \"s#.partial##g\" <<< \$binhost_mirrors) && wait && gpg --verify \"\\\${DISTDIR}/\\\${FILE}.asc\" \"\\\${DISTDIR}/\\\${FILE}\" && rm \"\\\${DISTDIR}/\\\${FILE}.asc\"\""' >> /etc/portage/make.conf

gpg --keyserver hkp://pool.sks-keyservers.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"

#emerge gentoo-sources genkernel
#wget http://liquorix.net/sources/4.18/config.amd64
#genkernel --kernel-config=config.amd64 all
wget https://cloveros.ga/s/kernel.tar.xz https://cloveros.ga/s/signatures/s/kernel.tar.xz.asc
gpg --verify kernel.tar.xz.asc kernel.tar.xz
tar xf kernel.tar.xz
rm kernel.tar.xz kernel.tar.xz.asc

emerge grub dhcpcd

grub-install --target=i386-pc /dev/$drive &> /dev/null
grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg

rc-update add dhcpcd default

echo "root:$rootpassword" | chpasswd
useradd $username
echo "$username:$userpassword" | chpasswd
gpasswd -a $username wheel

emerge -eD @world aria2 xorg-server fvwm spacefm rxvt-unicode nitrogen compton nomacs sudo wpa_supplicant porthole firefox emacs gimp mpv smplayer rtorrent weechat linux-firmware alsa-utils zsh zsh-completions gentoo-zsh-completions vlgothic hack liberation-fonts nano scrot xbindkeys xinput arandr qastools slock xarchiver p7zip games-envd gparted squashfs-tools os-prober
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
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8
usermod -aG audio,video,games,input $username
cd /home/$username/
rm .bash_profile
wget $gitprefix/home/user/{.bash_profile,.zprofile,.zshrc,.fvwm2rc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
chmod +x screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh
mkdir -p .emacs.d/backups/ .emacs.d/autosaves/ Downloads/ .rtorrent/ .mpv/ .config/spacefm/ .config/nitrogen/ .local/share/nomacs/ Desktop/
sed -i "s@/home/user/@/home/$username/@" .rtorrent.rc
wget $gitprefix/home/user/.mpv/config -P .mpv/
wget $gitprefix/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
sed -i "s@/home/user/@/home/$username/@" .config/nitrogen/nitrogen.cfg
wget $gitprefix/home/user/.local/share/nomacs/settings.ini -P .local/share/nomacs/
wget $gitprefix/home/user/.config/spacefm/session -P .config/spacefm/
sed -i "s@/home/user/@/home/$username/@" .config/spacefm/session
wget $gitprefix/home/user/.config/mimeapps.list -P .config/
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Home\nIcon=user-home\nExec=spacefm ~/" > Desktop/home.desktop
echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Applications\nIcon=folder\nExec=spacefm /usr/share/applications/" > Desktop/applications.desktop
cp /usr/share/applications/{firefox.desktop,smplayer.desktop,emacs.desktop,zzz-gimp.desktop,porthole.desktop,xarchiver.desktop} Desktop/
echo -e "~rows=0\n1=home.desktop\n2=applications.desktop\n3=firefox.desktop\n4=smplayer.desktop\n5=emacs.desktop\n6=porthole.desktop\n7=zzz-gimp.desktop\n8=xarchiver.desktop" > .config/spacefm/desktop0
chown -R $username /home/$username/

rm -Rf /usr/portage/packages/* /etc/resolv.conf

exit

EOF

reboot
