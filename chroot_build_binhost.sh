#!/bin/bash
# untested rough draft

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

wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.use -O /etc/portage/package.use
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.env -O /etc/portage/package.env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/package.keywords -O /etc/portage/package.keywords
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/make.conf -O /etc/portage/make.conf
mkdir /etc/portage/env
wget https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/etc/portage/env/{no-lto,no-lto-graphite,no-lto-o3,no-lto-ofast,no-o3,no-ofast,size} -P /etc/portage/env/

CFLAGS="-Ofast -mssse3 -pipe -flto=8 -funroll-loops" emerge gcc

emerge -uvDN world $(curl https://gitgud.io/cloveros/cloveros/raw/master/binhost_settings/var/lib/portage/world)

quickpkg --include-unmodified-config=y "*/*"

exit

EOF

umount -l gentoo/*

echo "Build finished. Packages are in gentoo/usr/portage/packages/"
