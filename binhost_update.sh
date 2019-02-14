trap exit SIGINT
if [ ! -d '/usr/portage/packages/s/' ]; then
	mkdir -p /usr/portage/packages/s/
fi

#mv /usr/portage/packages/s/ .
#rm -Rf /usr/portage/packages/*
#mv s/ /usr/portage/packages/
#quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html > /usr/portage/packages/s/quickpkg.txt
#emerge -B sudo openssh postfix dcron vixie-cron cronie fcron anacron ungoogled-chromium
#emerge -C hwinfo ntfs3g && emerge -b ntfs3g && emerge -b hwinfo
#PKGDIR="/usr/portage/packages/s/nodbus/" USE="-dbus -webengine -trash-panel-plugin" emerge -B glib qtgui PyQt5 thunar

emerge --sync
layman -S
emerge -uavDNb --exclude=gentoo-sources @world
emerge -b @preserved-rebuild
emerge --depclean
emerge -1b $(find /var/db/pkg/ -mindepth 2 -maxdepth 2 -name \*-9999 | grep -v MERGING | awk -F \/ '{printf "=%s/%s ", $5, $6}')
eclean-pkg

php mirrors/index.php > /usr/portage/packages/index.html
php mirrors/indexalt.php > /usr/portage/packages/indexalt.html
EIX_LIMIT=0 eix -IF | grep -v "Available versions" | ansi2html > /usr/portage/packages/s/packages.html

rm -Rf /usr/portage/packages/s/signatures/
mkdir -p /usr/portage/packages/s/signatures/
cd /usr/portage/packages/s/signatures/
find /usr/portage/packages/ -type d | sed 's#/usr/portage/packages/##' | grep -v "^s/signatures$" | xargs mkdir
find /usr/portage/packages/ -type f | sed 's#/usr/portage/packages/##' | pv -qB 1G | xargs -I{} gpg --armor --detach-sign --output {}.asc --sign /usr/portage/packages/{}

chmod -R 755 /usr/portage/packages/
rsync -a --delete /usr/portage/packages/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/
