emerge --sync
layman -S
emerge -uvDN --with-bdeps=y --buildpkg @world
emerge -1 --buildpkg $(eix -Jc | grep 9999 | cut -d" " -f2 | tr "\n" " ")
emerge -C hwinfo ntfs3g && emerge -1O --jobs=1 ntfs3g hwinfo
emerge --buildpkg @preserved-rebuild
emerge --depclean

#mv /usr/portage/packages/s/ .
#rm -Rf /usr/portage/packages/*
#quickpkg --include-unmodified-config=y "*/*" 2>&1 | ansi2html | tail -n +1081 | head -n -7 > s/quickpkg.txt
#emerge --buildpkgonly vnstat sudo openssh
#mv s/ /usr/portage/packages/

cd /usr/portage/packages/s/
EIX_LIMIT=0 eix --installed -F | grep -v "Available versions" | ansi2html > packages.html
php website.php

rm -Rf /usr/portage/packages/s/signatures/*
cd /usr/portage/packages/s/signatures/
find /usr/portage/packages/ -type d | sed 's#/usr/portage/packages/##' | parallel mkdir
find /usr/portage/packages/ -type f | sed 's#/usr/portage/packages/##' | pv -qB 1G | parallel gpg --armor --detach-sign --output {}.asc --sign /usr/portage/packages/{}

chmod -R 755 /usr/portage/packages/
rmdir /usr/portage/packages/s/signatures/s/signatures/

rsync -a --delete-before /usr/portage/packages/ root@fr.cloveros.ga:/var/www/html/ &
wait
