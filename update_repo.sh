emerge --sync
emerge -uvDN --buildpkg world
emerge --depclean
#mv /usr/portage/packages/s/ .
#rm -Rf /usr/portage/packages/*
#quickpkg --include-unmodified-config=y "*/*" | ansi2html | tail -n +1081 | head -n -7 > s/quickpkg.txt
#emerge --buildpkgonly vnstat sudo openssh dnscrypt-proxy
#mv s/ /usr/portage/packages/
cd /usr/portage/packages/s/
EIX_LIMIT=0 eix --installed -F | grep -v "Available versions" | ansi2html > packages.html
php website.php

rm -Rf signatures
mkdir -p signatures/usr/portage/packages/
cd signatures/usr/portage/packages/
ls -1 /usr/portage/packages/ | parallel mkdir
cd ../../../
find /usr/portage/packages/ -type f | pv -qB 1G | parallel gpg --armor --detach-sign --output .{}.asc --sign {}
mv usr/portage/packages/* .
rm -Rf usr
rmdir * */* &> /dev/null
cd ..

chmod -R 755 /usr/portage/packages/
rsync -av --delete-after /usr/portage/packages/ root@useast.cloveros.ga:/var/www/htdocs/useast.cloveros.ga/
rsync -av --delete-after /usr/portage/packages/ root@uswest.cloveros.ga:/var/www/htdocs/uswest.cloveros.ga/
rsync -av --delete-after /usr/portage/packages/ root@fr.cloveros.ga:/var/www/html/
