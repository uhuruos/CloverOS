#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

mkdir gentoo

cd gentoo
builddate=$(curl -s http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/ | sed -nr 's/.*href="stage3-amd64-([0-9]+).tar.bz2">.*/\1/p')
wget http://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64/stage3-amd64-$builddate.tar.bz2
tar pxf stage3*
rm stage3*

cp /etc/resolv.conf etc
mount -t proc none proc
mount --rbind /dev dev
mount --rbind /sys sys

cat << EOF | chroot .

emerge-webrsync

rm /var/lib/portage/world
rm -R /etc/portage/package.use
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.use -O /etc/portage/package.use
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.env -O /etc/portage/package.env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.keywords -O /etc/portage/package.keywords
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.license -O /etc/portage/package.license
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/make.conf -O /etc/portage/make.conf
mkdir /etc/portage/env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/env/{no-lto,no-lto-graphite,no-lto-o3,no-lto-ofast,no-o3,no-ofast,size} -P /etc/portage/env/
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/var/lib/portage/world -O /var/lib/portage/world

sed -i '/pantheon-base\/plank/d' /var/lib/portage/world
sed -i '/sys-apps\/flatpak/d' /var/lib/portage/world
sed -i '/x11-terms\/termite/d' /var/lib/portage/world

CFLAGS="-Ofast -mmmx -mssse3 -pipe -flto=8 -funroll-loops" emerge gcc
binutils-config --linker ld.gold
emerge openssl openssh
USE="-vaapi" emerge mesa
emerge -1 netcat6
emerge genkernel gentoo-sources
wget https://liquorix.net/sources/4.9/config.amd64
binutils-config --linker ld.bfd
genkernel --kernel-config=config.amd64 all
binutils-config --linker ld.gold
emerge layman
layman -S
yes | layman -a 0x4d4c deadbeef-overlay palemoon steam-overlay torbrowser vapoursynth das-labor voyageur

emerge -uvDN @world

quickpkg --include-unmodified-config=y "*/*"

exit

EOF

umount -l gentoo/*

echo "Build finished. Packages are in gentoo/usr/portage/packages/"
