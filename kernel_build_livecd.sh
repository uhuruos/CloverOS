#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

ACCEPT_KEYWORDS="~amd64" emerge -1O \=sys-kernel/aufs-sources-4.20.7
cd /usr/src/linux-4.20.7-aufs
wget https://raw.githubusercontent.com/damentz/liquorix-package/4.20/linux-liquorix/debian/config/kernelarch-x86/config-arch-64 -O .config
make -j$(nproc)
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel.tar.lzma /boot/*$kernelversion-gentoo /lib/modules/$kernelversion-gentoo &
sudo emerge -C aufs-sources