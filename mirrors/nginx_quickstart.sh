#apt update && apt -y install gcc make git sudo libpcre3-dev libssl-dev zlib1g-dev
domains='DNS:YourDomain.com,DNS:www.YourDomain.com'
useradd www-data
wget http://nginx.org/download/nginx-1.15.7.tar.gz
tar xvf nginx-*.tar.gz
rm nginx-*.tar.gz
cd nginx-*/
git clone https://github.com/google/ngx_brotli
git clone https://github.com/arut/nginx-rtmp-module
cd ngx_brotli && git submodule update --init && cd ..
CFLAGS="-Ofast -march=native -flto=4 -pipe -funroll-loops -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution" CXXFLAGS="${CFLAGS}" AR="gcc-ar" NM="gcc-nm" RANLIB="gcc-ranlib" ./configure --with-http_v2_module --with-http_realip_module --with-http_ssl_module --add-module=ngx_brotli --add-module=nginx-rtmp-module --with-file-aio --with-threads
make -j8
cp -R conf ../nginx/
cd ..
wget https://gitgud.io/cloveros/cloveros/raw/master/mirrors/nginxtemplate.conf -O nginx/nginx.conf
openssl dhparam -out nginx/dhparam.pem 4096
mkdir nginx/ssl/
mkdir nginx/logs/
sed -ri 's/(ssl_certificate.*;)/#\1/; s/(listen 443 ssl http2;)/#\1/' nginx/nginx.conf
sudo nginx-*/objs/nginx -p nginx -c nginx.conf
mkdir -p /var/www/html/.well-known/acme-challenge/
openssl genrsa 4096 > nginx/ssl/account.key
openssl genrsa 4096 > nginx/ssl/certificate.key
#renew certificate start
openssl req -new -sha256 -key nginx/ssl/certificate.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$domains")) > nginx/ssl/certificate.csr
wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
chmod +x acme_tiny.py
./acme_tiny.py --account-key nginx/ssl/account.key --csr nginx/ssl/certificate.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > nginx/ssl/certificate.crt
rm acme_tiny.py
sudo nginx-*/objs/nginx -p $(pwd)/nginx -c nginx.conf -s reload
#renew certificate end
sudo pkill nginx
sed -ri 's/#(ssl_certificate.*;)/\1/; s/#(listen 443 ssl http2;)/\1/' nginx/nginx.conf
sudo nginx-*/objs/nginx -p $(pwd)/nginx -c nginx.conf
