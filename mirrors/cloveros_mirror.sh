#apt update && apt -y install gcc make git sudo libpcre3-dev libssl-dev zlib1g-dev
domains='DNS:YourDomain.com,DNS:www.YourDomain.com'
useradd www-data
git clone --depth 1 https://github.com/nginx/nginx
cd nginx/
git clone --depth 1 https://github.com/eustas/ngx_brotli
git clone --depth 1 https://github.com/arut/nginx-rtmp-module
cd ngx_brotli ; git submodule update --init ; cd ..
CFLAGS="-Ofast -march=native -mfpmath=both -pipe -funroll-loops -flto=8 -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution -fgraphite-identity -floop-nest-optimize -malign-data=cacheline -mtls-dialect=gnu2 -Wl,--hash-style=gnu" CXXFLAGS="${CFLAGS}" AR="gcc-ar" NM="gcc-nm" RANLIB="gcc-ranlib" auto/configure --with-http_v2_module --with-http_realip_module --with-http_ssl_module --add-module=ngx_brotli --add-module=nginx-rtmp-module --with-file-aio --with-threads
make -j8
cp -R conf ..
cd ..
wget https://gitgud.io/cloveros/cloveros/raw/master/mirrors/nginxtemplate.conf -O conf/nginx.conf
openssl dhparam -out conf/dhparam.pem 4096
mkdir conf/ssl/
mkdir conf/logs/
sed -ri 's/(ssl_certificate.*;)/#\1/; s/(listen 443 ssl http2;)/#\1/' conf/nginx.conf
sudo nginx/objs/nginx -p conf/ -c nginx.conf
mkdir -p /var/www/html/.well-known/acme-challenge/
openssl genrsa 4096 > conf/ssl/account.key
openssl genrsa 4096 > conf/ssl/certificate.key
#renew certificate start
openssl req -new -sha256 -key conf/ssl/certificate.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$domains")) > conf/ssl/certificate.csr
wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
chmod +x acme_tiny.py
./acme_tiny.py --account-key conf/ssl/account.key --csr conf/ssl/certificate.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > conf/ssl/certificate.crt
rm acme_tiny.py
sudo nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf -s reload
#renew certificate end
sudo pkill nginx
sed -ri 's/#(ssl_certificate.*;)/\1/; s/#(listen 443 ssl http2;)/\1/' conf/nginx.conf
sleep 1
sudo nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf
