php mirrors/index.php > /var/cache/binpkgs/index.html
./mirrors/indexalt.sh > /var/cache/binpkgs/indexalt.html
EIX_LIMIT=0 eix -IF | grep -v "Available versions" | ansi2html > /var/cache/binpkgs/s/packages.html &

rm -Rf /var/cache/binpkgs/s/signatures/*
find /var/cache/binpkgs/ -type d -not -path "/var/cache/binpkgs/s/signatures*" | sed "s#/var/cache/binpkgs/##" | xargs -I{} mkdir /var/cache/binpkgs/s/signatures/{}
find /var/cache/binpkgs/ -type f -not -path "/var/cache/binpkgs/s/signatures*" | sed "s#/var/cache/binpkgs/##" | xargs -P 8 -I{} gpg --armor --detach-sign --output /var/cache/binpkgs/s/signatures/{}.asc --sign /var/cache/binpkgs/{}

chmod -R 755 /var/cache/binpkgs/
rsync -a --delete /var/cache/binpkgs/ root@nl.cloveros.ga:/var/www/html/cloveros.ga/
