#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

mkdir gentoo

cd gentoo
builddate=$(curl -s http://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686/ | sed -nr 's/.*href="stage3-i686-([0-9].*).tar.xz">.*/\1/p')
wget http://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686/stage3-i686-$builddate.tar.xz
tar pxf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << EOF | chroot .

emerge-webrsync
eselect profile set "default/linux/amd64/17.0"

rm /var/lib/portage/world
rm -R /etc/portage/package.use
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.use -O /etc/portage/package.use
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.env -O /etc/portage/package.env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.keywords -O /etc/portage/package.keywords
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.license -O /etc/portage/package.license
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.mask -O /etc/portage/package.mask
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/make.conf -O /etc/portage/make.conf
mkdir /etc/portage/env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/env/{no-lto,no-lto-graphite,no-lto-graphite-ofast,no-lto-o3,no-lto-ofast,no-o3,no-ofast,size} -P /etc/portage/env/
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/var/lib/portage/world -O /var/lib/portage/world

sed -i 's/-mssse3/-msse2/' /etc/portage/make.conf
sed -i 's/CPU_FLAGS_X86="mmx mmxext sse sse2 sse3 ssse3"/CPU_FLAGS_X86="mmx mmxext sse sse2"/' /etc/portage/make.conf

CFLAGS="-Ofast -mmmx -msse2 -pipe -flto=8 -funroll-loops" emerge gcc
binutils-config --linker ld.gold
emerge openssl openssh
USE="-vaapi" emerge mesa
emerge -1 netcat6
emerge genkernel gentoo-sources
wget https://liquorix.net/sources/4.14/config.i386-pae
binutils-config --linker ld.bfd
genkernel --kernel-config=config.i386-pae all
binutils-config --linker ld.gold
emerge layman
layman -S
yes | layman -a 0x4d4c abendbrot audio-overlay causelay cg das-labor deadbeef-overlay dotnet DuPol eclipse elementary eroen farmboy0 fkmclane flatpak-overlay jm-overlay jorgicio palemoon pg_overlay pinkpieea raiagent rasdark science steam-overlay tlp torbrowser vapoursynth voyageur

emerge -uvDN @world

emerge -C hwinfo ntfs3g && emerge ntfs3g && emerge hwinfo

quickpkg --include-unmodified-config=y "*/*"

exit

EOF

umount -l gentoo/*

echo "Build finished. Packages are in gentoo/usr/portage/packages/"
