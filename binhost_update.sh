#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

trap exit SIGINT

if [ ! -d '/var/cache/binpkgs/s/signatures/' ]; then
	mkdir -p /var/cache/binpkgs/s/signatures/
fi

export BINPKG_COMPRESS="xz" XZ_OPT="--x86 --lzma2=preset=9e,dict=128MB,nice=273,depth=200,lc=4"

if [ "$1" = 'deep' ]; then
	find /var/cache/binpkgs/ -mindepth 1 -maxdepth 1 ! -name s -exec rm -Rf {} \;
	emerge -C hwinfo ntfs3g ; emerge -b ntfs3g ; emerge -b hwinfo ; emerge -C jack-audio-connection-kit audacity ; emerge -b audacity ; emerge -b jack-audio-connection-kit ; emerge -C sys-apps/dbus obs-studio ; emerge -b obs-studio ; emerge -1b sys-apps/dbus
	quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html > /var/cache/binpkgs/s/quickpkg.html
	emerge -B sudo openssh glibc baselayout sysvinit linux-firmware fingerprint-gui dcron cronie fcron anacron chromium torbrowser-launcher mail-mta/postfix acct-user/postfix acct-group/postfix
fi

emerge --sync
emerge -uavDNb --exclude=gentoo-sources @world
emerge -1b $(find /var/db/pkg/ -mindepth 2 -maxdepth 2 -name \*-9999\* | awk -F \/ '{printf "=%s/%s ", $5, $6}')
emerge -b @preserved-rebuild
emerge --depclean

sed -i -n "/^\(RTL\|rtl\|ar\|ath\|brcm\|iwlwifi\|rt\)/p" /etc/portage/savedconfig/sys-kernel/$(ls -1 /etc/portage/savedconfig/sys-kernel/ | tail -n1)
rm -Rf /var/cache/binpkgs/s/nodbus/*
PKGDIR="/var/cache/binpkgs/s/nodbus/" USE="-dbus -qt5 -udisks -trash-panel-plugin -video-thumbnails -video_cards_radeon -video_cards_radeonsi -llvm -opencl savedconfig" emerge -B glib qtgui thunar spacefm wpa_supplicant poppler gpgme gvfs mesa linux-firmware desktop-file-utils freedesktop-icon-theme lcms openjpeg

./mirrors/index.sh > /var/cache/binpkgs/index.html
./mirrors/indexalt.sh > /var/cache/binpkgs/indexalt.html
EIX_LIMIT=0 eix -IF | grep -v "Available versions" | ansi2html > /var/cache/binpkgs/s/packages.html

rm -Rf /var/cache/binpkgs/s/signatures/*
find /var/cache/binpkgs/ -type d -not -path "/var/cache/binpkgs/s/signatures*" | sed "s#/var/cache/binpkgs/##" | xargs -I{} mkdir /var/cache/binpkgs/s/signatures/{}
find /var/cache/binpkgs/ -type f -not -path "/var/cache/binpkgs/s/signatures*" | sed "s#/var/cache/binpkgs/##" | xargs -P 8 -I{} gpg --armor --detach-sign --output /var/cache/binpkgs/s/signatures/{}.asc --sign /var/cache/binpkgs/{}

chmod -R 755 /var/cache/binpkgs/
rsync -a --delete /var/cache/binpkgs/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/
