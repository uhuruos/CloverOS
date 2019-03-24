#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

trap exit SIGINT

if [ ! -d '/usr/portage/packages/s/signatures/' ]; then
	mkdir -p /usr/portage/packages/s/signatures/
fi

#quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html > /usr/portage/packages/s/quickpkg.html
#emerge -C hwinfo ntfs3g && emerge ntfs3g && emerge hwinfo
#cp -R /etc/portage/package.* /etc/portage/make.conf /etc/portage/env/ binhost_settings/etc/portage/ && cp /var/lib/portage/world binhost_settings/var/lib/portage/ && git add . && git commit -m "binhost_settings: update" && git push

emerge --sync
layman -S
emerge -uavDN --exclude=gentoo-sources @world
emerge -b1 $(find /var/db/pkg/ -mindepth 2 -maxdepth 2 -name \*-9999 | awk -F \/ '{printf "=%s/%s ", $5, $6}')
emerge -b @preserved-rebuild
emerge --depclean
eclean -d distfiles

echo -e "app-admin/sudo\nnet-misc/openssh\nmail-mta/postfix\nwww-client/ungoogled-chromium\nsys-process/anacron\nsys-process/cronie\nsys-process/dcron\nsys-process/fcron\nsys-process/vixie-cron" | eclean -d -e /dev/stdin packages
#emerge -B sudo openssh postfix dcron vixie-cron cronie fcron anacron ungoogled-chromium
#PKGDIR="/usr/portage/packages/s/nodbus/" USE="-dbus -webengine -trash-panel-plugin" emerge -B glib qtgui PyQt5 thunar

EIX_LIMIT=0 eix -IF | grep -v "Available versions" | ansi2html > /usr/portage/packages/s/packages.html
php mirrors/index.php > /usr/portage/packages/index.html
./mirrors/indexalt.sh > /usr/portage/packages/indexalt.html

rm -Rf /usr/portage/packages/s/signatures/*
find /usr/portage/packages/ -type d | sed "s#/usr/portage/packages/##" | grep -v "^s/signatures$" | xargs -I{} mkdir /usr/portage/packages/s/signatures/{}
find /usr/portage/packages/ -type f | sed "s#/usr/portage/packages/##" | pv -qB 1G | xargs -I{} gpg --armor --detach-sign --output /usr/portage/packages/s/signatures/{}.asc --sign /usr/portage/packages/{}

chmod -R 755 /usr/portage/packages/
rsync -a --delete /usr/portage/packages/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/
