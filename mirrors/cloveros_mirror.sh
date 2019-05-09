if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi
if [ "$(ping -c1 $1 2> /dev/null | awk -F "[()]" "NR==1 {print \$2}")" != "$(wget -qO - ifconfig.co)" ]; then
	echo "Usage: cloveros_mirror.sh YourDomain.com www.YourDomain.com YourOtherDomain.com
Domain name is required and must point to current IP. Only the first domain will be configured in nginx.

Required dependencies for nginx build: gcc, make, git, wget, includes for pcre/zlib/openssl
Debian: apt update && apt -y install gcc make git libpcre3-dev libssl-dev zlib1g-dev
Gentoo: emerge --sync && emerge git
CentOS/Fedora: yum update && yum install gcc make git wget libpcre-devel openssl-devel zlib-devel"
	exit 1
fi
for domain in "$@"; do
	domains+="DNS:$domain,"
done
domains=${domains%?}
if [ ! -d "nginx/" ] || [ ! -d "conf/" ]; then
	echo "nginx build not found. building..."
	if [ ! -f "/usr/bin/gcc" ] || [ ! -f "/usr/bin/make" ] || [ ! -f "/usr/bin/git" ] || [ ! -f "/usr/bin/wget" ] || [ ! -f "/usr/include/pcre.h" ] || [ ! -f "/usr/include/zlib.h" ] || [ ! -d "/usr/include/openssl/" ]; then
		if [ -f "/usr/bin/dpkg" ]; then
			apt update && apt -y install gcc make git libpcre3-dev libssl-dev zlib1g-dev
		fi
		if [ -f "/usr/bin/emerge" ]; then
			emerge --sync && emerge git
		fi
		if [ -f "/usr/bin/yum" ]; then
			yum update && yum install gcc make git wget libpcre-devel openssl-devel zlib-devel
		fi
	fi
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
	sed -ri "s/(ssl_certificate.*;)/#\1/; s/(listen 443 ssl http2;)/#\1/" conf/nginx.conf
	nginx/objs/nginx -p conf/ -c nginx.conf
	mkdir -p /var/www/html/.well-known/acme-challenge/
	openssl genrsa 4096 > conf/ssl/account.key
	openssl genrsa 4096 > conf/ssl/certificate.key
	openssl req -new -sha256 -key conf/ssl/certificate.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$domains")) > conf/ssl/certificate.csr
	wget -qO - https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py | python - --account-key conf/ssl/account.key --csr conf/ssl/certificate.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > conf/ssl/certificate.crt
	pkill nginx
	sed -ri "s/#(ssl_certificate.*;)/\1/; s/#(listen 443 ssl http2;)/\1/" conf/nginx.conf
	sed -i 's@^}$@\
	server {\
		server_name '"$1"';\
		listen 443 ssl http2;\
		add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";\
		add_header X-Content-Type-Options nosniff;\
		root /var/www/html/cloveros.ga/;\
	}\
}@' conf/nginx.conf
	mkdir /var/www/html/cloveros.ga/
	sleep 1
	nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf
fi

while :; do
	if ! $(pidof nginx); then
		nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf
	fi
	if [ $(($(date -d "$(echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -enddate | sed \"s/notAfter=//\")" +%s) - $(date +%s)))" -lt "2592000" ]; then
		openssl req -new -sha256 -key conf/ssl/certificate.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$domains")) > conf/ssl/certificate.csr
		wget -qO - https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py | python - --account-key conf/ssl/account.key --csr conf/ssl/certificate.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > conf/ssl/certificate.crt
		nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf -s reload
	fi
	rsync -a --delete rsync://nl.cloveros.ga/cloveros /var/www/html/cloveros.ga/;
	sleep 600
done
