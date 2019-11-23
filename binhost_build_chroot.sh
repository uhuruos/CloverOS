#!/bin/bash
if [ $(id -u) != '0' ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"

mkdir gentoo/

cd gentoo/
builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr 's/.*href="stage3-amd64-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-"$builddate".tar.xz
tar pxf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << HEREDOC | chroot .
emerge-webrsync
eselect profile set "default/linux/amd64/17.0/hardened"

rm -R /var/lib/portage/world /etc/portage/package.* /etc/portage/make.conf
wget $gitprefix/binhost_settings/etc/portage/{make.conf,package.use,package.keywords,package.env,package.mask,package.unmask} -P /etc/portage/
mkdir /etc/portage/env/
wget $gitprefix/binhost_settings/etc/portage/env/{gold,no-gnu2,no-gold,no-hashgnu,no-lto,no-lto-graphite,no-lto-o3,no-lto-ofast,no-ofast,pcsx2,size} -P /etc/portage/env/
wget $gitprefix/binhost_settings/var/lib/portage/world -O /var/lib/portage/world

emerge genkernel gentoo-sources app-arch/lz4
eselect kernel set 1
wget https://raw.githubusercontent.com/damentz/liquorix-package/master/linux-liquorix/debian/config/kernelarch-x86/config-arch-64
sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/; s/CONFIG_I2C_NVIDIA_GPU=/#CONFIG_I2C_NVIDIA_GPU=/" config-arch-64
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config-arch-64
genkernel --kernel-config=config-arch-64 --luks --lvm all
(cd /usr/src/linux/ ; make clean ; make prepare ; make modules_prepare)
binutils-config --linker ld.gold

emerge eselect-repository
mkdir /etc/portage/repos.conf
xargs eselect repository enable <<< $(grep -Po "(?<=\*/\*::).*" /etc/portage/package.mask)
echo -e "\n[cloveros]\nlocation = /var/db/repos/cloveros\nsync-type = git\nsync-uri = https://gitgud.io/cloveros/cloveros-overlay.git\n\n\n[flatpak-overlay]\nlocation = /var/db/repos/flatpak-overlay\nsync-type = git\nsync-uri = https://github.com/fosero/flatpak-overlay.git\n\n\n[tlp]\nlocation = /var/db/repos/tlp\nsync-type = git\nsync-uri = https://github.com/dywisor/tlp-portage.git\n" >> /etc/portage/repos.conf/eselect-repo.conf

USE="-vaapi binary -color-management -opengl" emerge -1av gcc mesa scala netcat6 opencolorio openimageio
emerge --depclean
emerge -veD @world
emerge @preserved-rebuild
emerge --depclean

emerge -C hwinfo ntfs3g ; emerge ntfs3g ; emerge hwinfo ; emerge -C sys-apps/dbus obs-studio ; emerge obs-studio ; emerge -1 sys-apps/dbus ; emerge -C jack-audio-connection-kit audacity ; emerge audacity ; emerge jack-audio-connection-kit

BINPKG_COMPRESS="xz" XZ_OPT="--x86 --lzma2=preset=9e,dict=1024MB,nice=273,depth=200,lc=4" quickpkg --include-unmodified-config=y "*/*"

exit
HEREDOC

umount -l gentoo/*

echo "Build finished. Packages are in gentoo/usr/portage/packages/"
