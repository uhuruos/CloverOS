emerge --sync
emerge -uvDN --exclude=glibc world
emerge --depclean
mv /usr/portage/packages/s/ .
rm -Rf /usr/portage/packages/*
quickpkg --include-unmodified-config=y "*/*" | ansi2html | tail -n +1081 | head -n -7 > s/quickpkg.txt
EIX_LIMIT=0 eix --installed -F | grep -v "Available versions" | ansi2html > s/packages.html
emerge --buildpkgonly vnstat sudo openssh dnscrypt-proxy
mv s/ /usr/portage/packages/
chmod -R 755 /usr/portage/packages/
cd /usr/portage/packages/s/
php website.php

cd /usr/portage/packages/s/signatures/
rm -Rf *
mkdir -p usr/portage/packages/
cd usr/portage/packages/
ls -1 /usr/portage/packages/ | parallel mkdir
cd ../../../
find /usr/portage/packages/ -type f | parallel gpg --armor --detach-sign --output .{}.asc --sign {}
mv usr/portage/packages/* .
rm -Rf usr

sudo -u gentoo rsync -av --delete-after /usr/portage/packages/ root@useast.cloveros.ga:/var/www/htdocs/useast.cloveros.ga/
sudo -u gentoo rsync -av --delete-after /usr/portage/packages/ root@uswest.cloveros.ga:/var/www/htdocs/uswest.cloveros.ga/
sudo -u gentoo rsync -av --delete-after /usr/portage/packages/ root@fr.cloveros.ga:/var/www/html/
