trap exit SIGINT

emerge --sync
layman -S
emerge -uavDN --buildpkg --exclude=gentoo-sources @world
emerge --buildpkg @preserved-rebuild
emerge --depclean
emerge -1 --buildpkg $(find /var/db/pkg/ -mindepth 2 -maxdepth 2 -name \*-9999 | grep -v MERGING | awk -F \/ '{printf "=%s/%s ", $5, $6}')
eclean-pkg

#mv /usr/portage/packages/s/ .
#rm -Rf /usr/portage/packages/*
#mv s/ /usr/portage/packages/
#quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html | tail -n +1081 | head -n -7 > /usr/portage/packages/s/quickpkg.txt
#emerge --buildpkgonly sudo openssh postfix dcron vixie-cron cronie fcron anacron
#emerge -C hwinfo ntfs3g && emerge --buildpkg ntfs3g && emerge --buildpkg hwinfo

cd /usr/portage/packages/s/
php website.php
EIX_LIMIT=0 eix -IF | grep -v "Available versions" | ansi2html > packages.html

rm -Rf /usr/portage/packages/s/signatures/
mkdir -p /usr/portage/packages/s/signatures/
cd /usr/portage/packages/s/signatures/
find /usr/portage/packages/ -type d | sed 's#/usr/portage/packages/##' | grep -v "^s/signatures$" | xargs mkdir
find /usr/portage/packages/ -type f | sed 's#/usr/portage/packages/##' | pv -qB 1G | xargs -I{} gpg --armor --detach-sign --output {}.asc --sign /usr/portage/packages/{}

chmod -R 755 /usr/portage/packages/

rsync -a --delete /usr/portage/packages/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/
