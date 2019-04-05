#!/bin/bash
if [ $(id -u) != '0' ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

mkdir gentoo/

cd gentoo/
builddate=$(curl -s http://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686/ | sed -nr 's/.*href="stage3-i686-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686/stage3-i686-$builddate.tar.xz
tar pxf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << HEREDOC | chroot .

emerge-webrsync
eselect profile set "default/linux/x86/17.0/hardened"

rm /var/lib/portage/world
rm -R /etc/portage/package.*
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/{make.conf,package.use,package.keywords,package.env,package.mask,package.unmask} -P /etc/portage/
mkdir /etc/portage/env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/env/{no-lto,no-lto-graphite,no-lto-graphite-ofast,no-lto-o3,no-lto-ofast,no-ofast,no-gold,no-mfpmath,size,pcsx2,gold,no-gnu2,rethinkdb} -P /etc/portage/env/
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/var/lib/portage/world -O /var/lib/portage/world

sed -i 's/-mssse3/-msse2/' /etc/portage/make.conf
sed -i 's/CPU_FLAGS_X86="mmx mmxext sse sse2 sse3 ssse3"/CPU_FLAGS_X86="mmx mmxext sse sse2"/' /etc/portage/make.conf

CFLAGS="-Ofast -mmmx -mssse3 -pipe -flto=8 -funroll-loops" emerge gcc
binutils-config --linker ld.gold
USE="-vaapi" emerge -1 mesa
USE="binary" emerge -1 scala
emerge -1 netcat6
emerge genkernel gentoo-sources
wget https://liquorix.net/sources/4.19/config.i386-pae
binutils-config --linker ld.bfd ; genkernel --kernel-config=config.i386-pae all ; binutils-config --linker ld.gold
emerge layman
layman -S
yes | layman -a $(grep -Po "(?<=\*/\*::).*" /etc/portage/package.mask | tr "\n" " ")

emerge -uvDN @world

emerge -C hwinfo ntfs3g && emerge ntfs3g && emerge hwinfo

quickpkg --include-unmodified-config=y "*/*"

exit
HEREDOC

umount -l gentoo/*

echo "Build finished. Packages are in gentoo/usr/portage/packages/"
