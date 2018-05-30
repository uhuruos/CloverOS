emerge --sync
layman -S
emerge -uvDN --buildpkg --exclude=gentoo-sources @world
emerge --buildpkg @preserved-rebuild
emerge --depclean
emerge -1 --buildpkg $(find /var/db/pkg/ -mindepth 2 -maxdepth 2 -name \*-9999 | grep -v MERGING | awk -F \/ '{printf "=%s/%s ", $5, $6}')

#mv /usr/portage/packages/s/ .
#rm -Rf /usr/portage/packages/*
#quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html | tail -n +1081 | head -n -7 > s/quickpkg.txt
#mv s/ /usr/portage/packages/
#emerge --buildpkgonly vnstat sudo openssh firefox-kde-opensuse postfix
#emerge -C hwinfo ntfs3g && emerge --buildpkg ntfs3g && emerge --buildpkg hwinfo

cd /usr/portage/packages/s/
php website.php
EIX_LIMIT=0 eix --installed -F | grep -v "Available versions" | ansi2html > packages.html

rm -Rf /usr/portage/packages/s/signatures/
mkdir -p /usr/portage/packages/s/signatures/
cd /usr/portage/packages/s/signatures/
find /usr/portage/packages/ -type d | sed 's#/usr/portage/packages/##' | grep -v "^s/signatures$" | xargs mkdir
find /usr/portage/packages/ -type f | sed 's#/usr/portage/packages/##' | pv -qB 1G | xargs -I{} gpg --armor --detach-sign --output {}.asc --sign /usr/portage/packages/{}

chmod -R 755 /usr/portage/packages/

rsync -a --delete /usr/portage/packages/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/
