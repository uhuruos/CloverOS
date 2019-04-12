#unfinished
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi
if [ ! -d "nginx/" ] || [ ! -d "conf/" ]; then
	if [ -z "$1" ]; then
		echo "Domain name missing"
	fi
	if [ ! -z "$1" ] && [[ "$(dig +short $1)" != "$(curl ifconfig.co)" ]]; then
		echo "Domain $1 is not pointed to $(curl ifconfig.co)"
		errors=true
	fi
	if [ ! -f "/usr/bin/git" ]; then
		echo "git not found"
		errors=true
	fi
	if [ ! -f "/usr/bin/gcc" ]; then
		echo "gcc not found"
		errors=true
	fi
	if [ ! -f "/usr/bin/make" ]; then
		echo "make not found"
		errors=true
	fi
	if [ ! -f "/usr/include/pcre.h" ]; then
		echo "/usr/include/pcre.h not found"
		errors=true
	fi
	if [ ! -f "/usr/include/zlib.h" ]; then
		echo "/usr/include/zlib.h not found"
		errors=true
	fi
	if [ ! -d "/usr/include/openssl/" ]; then
		echo "/usr/include/openssl/ not found"
		errors=true
	fi
	if [ "$errors" = true ]; then
		if [ -f "/usr/bin/dpkg" ]; then
			apt update && apt -y install gcc make git libpcre3-dev libssl-dev zlib1g-dev
			exec cloveros_mirror.sh
		fi
		if [ -f "/usr/bin/emerge" ]; then
			emerge --sync && emerge git
			exec cloveros_mirror.sh
		fi
		if [ -f "/usr/bin/yum" ]; then
			yum update && yum install gcc make git libpcre-devel openssl-devel zlib-devel
			exec cloveros_mirror.sh
		fi
		echo "Usage: cloveros_mirror.sh domain.com"
		echo "Domain name is required and must point to current IP."
		echo "Required dependencies: gcc make, git, pcre/zlib/openssl includes"
		echo "Debian: apt update && apt -y install gcc make git libpcre3-dev libssl-dev zlib1g-dev"
		echo "Gentoo: emerge --sync && emerge git"
		echo "CentOS/Fedora: yum update && yum install gcc make git libpcre-devel openssl-devel zlib-devel"
		exit 1
	fi
	domains="DNS:$1"
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
	wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
	chmod +x acme_tiny.py
	./acme_tiny.py --account-key conf/ssl/account.key --csr conf/ssl/certificate.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > conf/ssl/certificate.crt
	rm acme_tiny.py
	pkill nginx
	sed -ri "s/#(ssl_certificate.*;)/\1/; s/#(listen 443 ssl http2;)/\1/" conf/nginx.conf
	sleep 1
	nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf
fi

while sleep 3600; do
	if ! $(pidof nginx); then
		nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf
	fi
	if [ $(($(date -d "$(echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -enddate | sed "s/notAfter=//")" +%s) - $(date +%s))) -lt "2592000" ]; then
		openssl req -new -sha256 -key conf/ssl/certificate.key -subj "/" -reqexts SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=$domains")) > conf/ssl/certificate.csr
		wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
		chmod +x acme_tiny.py
		./acme_tiny.py --account-key conf/ssl/account.key --csr conf/ssl/certificate.csr --acme-dir /var/www/html/.well-known/acme-challenge/ > conf/ssl/certificate.crt
		rm acme_tiny.py
		nginx/objs/nginx -p $(pwd)/conf/ -c nginx.conf -s reload
	fi
done
