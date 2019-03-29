#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

trap exit SIGINT

if [ ! -d '/usr/portage/packages/s/signatures/' ]; then
	mkdir -p /usr/portage/packages/s/signatures/
fi

if [ "$1" = 'deep' ]; then
	find /usr/portage/packages/ -mindepth 1 -maxdepth 1 ! -name s -exec rm -Rf {} \; ; rm -Rf /usr/portage/packages/s/nodbus/
	emerge -C hwinfo ntfs3g ; emerge ntfs3g ; emerge hwinfo; emerge -C sys-apps/dbus obs-studio ; emerge obs ; emerge -1 sys-apps/dbus; emerge -C jack-audio-connection-kit audacity ; emerge audacity ; emerge jack-audio-connection-kit
	XZ_OPT="-T0" BINPKG_COMPRESS="xz" quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html > /usr/portage/packages/s/quickpkg.html
	emerge -B sudo openssh postfix dcron vixie-cron cronie fcron anacron ungoogled-chromium
	PKGDIR="/usr/portage/packages/s/nodbus/" USE="-dbus -webengine -trash-panel-plugin" emerge -B glib qtgui PyQt5 thunar
fi

emerge --sync
layman -S
emerge -uavDN --exclude=gentoo-sources @world
emerge -b1 $(find /var/db/pkg/ -mindepth 2 -maxdepth 2 -name \*-9999 | awk -F \/ '{printf "=%s/%s ", $5, $6}')
emerge -b @preserved-rebuild
emerge --depclean

php mirrors/index.php > /usr/portage/packages/index.html
./mirrors/indexalt.sh > /usr/portage/packages/indexalt.html
EIX_LIMIT=0 eix -IF | grep -v "Available versions" | ansi2html > /usr/portage/packages/s/packages.html &

rm -Rf /usr/portage/packages/s/signatures/*
find /usr/portage/packages/ -type d | sed "s#/usr/portage/packages/##" | grep -v "^s/signatures$" | xargs -I{} mkdir /usr/portage/packages/s/signatures/{}
find /usr/portage/packages/ -type f | sed "s#/usr/portage/packages/##" | pv -qB 1G | xargs -I{} gpg --armor --detach-sign --output /usr/portage/packages/s/signatures/{}.asc --sign /usr/portage/packages/{}

chmod -R 755 /usr/portage/packages/
rsync -a --delete /usr/portage/packages/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/

cp -R /etc/portage/package.* /etc/portage/make.conf /etc/portage/env/ binhost_settings/etc/portage/ && cp /var/lib/portage/world binhost_settings/var/lib/portage/ && git add . && git commit -m "binhost_settings: update" && git push
