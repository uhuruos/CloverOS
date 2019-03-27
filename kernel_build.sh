#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

kernelversion=5.0.4
kernelmajversion=5.0

if [ ! -d '/usr/portage/packages/s/' ]; then
	mkdir -p /usr/portage/packages/s/
fi

binutils-config --linker ld.bfd

emerge -C gentoo-sources
rm -Rf /usr/src/*-gentoo*
find /boot/ /lib/modules/ -mindepth 1 -maxdepth 1 -name \*gentoo\* ! -name \*$(uname -r) -exec rm -R {} \;

emerge =gentoo-sources-$kernelversion
eselect kernel set linux-$kernelversion-gentoo
wget https://raw.githubusercontent.com/damentz/liquorix-package/master/linux-liquorix/debian/config/kernelarch-x86/config-arch-64 -O config
sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/; s/CONFIG_I2C_NVIDIA_GPU=/#CONFIG_I2C_NVIDIA_GPU=/" config
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config
genkernel --kernel-config=config --luks --lvm all
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel.tar.lzma /boot/*$kernelversion-gentoo /lib/modules/$kernelversion-gentoo &

cp -R /usr/src/linux-$kernelversion-gentoo/ /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion -P /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check -P /usr/src/linux-$kernelversion-gentoo-gnu/
chmod +x /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion /usr/src/linux-$kernelversion-gentoo-gnu/deblob-check
cd /usr/src/linux-$kernelversion-gentoo-gnu/ ; PYTHON="python2.7" /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion ; cd -
genkernel --kernel-config=config --kerneldir=/usr/src/linux-$kernelversion-gentoo-gnu/ --luks --lvm all
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel-libre.tar.lzma /boot/*$kernelversion-gentoo-gnu /lib/modules/$kernelversion-gentoo-gnu &

rm config
cd /usr/src/linux/
make clean
make prepare
make modules_prepare
cd /usr/src/linux-$kernelversion-gentoo-gnu/
make clean
wait
emerge -b @module-rebuild

binutils-config --linker ld.gold
