kernelversion=4.19.17
kernelmajversion=4.19

binutils-config --linker ld.bfd

emerge -C gentoo-sources
rm -Rf /usr/src/*-gentoo*
find /boot/ /lib/modules/ -mindepth 1 -maxdepth 1 -name \*gentoo\* ! -name \*$(uname -r) -exec rm -R {} \;
mkdir -p /usr/portage/packages/s/

emerge =gentoo-sources-$kernelversion
eselect kernel set linux-$kernelversion-gentoo
wget https://liquorix.net/sources/$kernelmajversion/config.amd64
sed -i "s/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=n/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/; s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/" config.amd64
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config.amd64
genkernel --kernel-config=config.amd64 --luks --lvm all &

cp -R /usr/src/linux-$kernelversion-gentoo/ /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion -P /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check -P /usr/src/linux-$kernelversion-gentoo-gnu/
chmod +x /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion /usr/src/linux-$kernelversion-gentoo-gnu/deblob-check
cd /usr/src/linux-$kernelversion-gentoo-gnu/ ; PYTHON="python2.7" /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion ; cd -
genkernel --kernel-config=config.amd64 --kerneldir=/usr/src/linux-$kernelversion-gentoo-gnu/ --luks --lvm all

wait
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel.tar.lzma /boot/*$kernelversion-gentoo /lib/modules/$kernelversion-gentoo &
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel-libre.tar.lzma /boot/*$kernelversion-gentoo-gnu /lib/modules/$kernelversion-gentoo-gnu &
wait

rm config.amd64
cd /usr/src/linux/
make clean
make prepare
make modules_prepare
cd /usr/src/linux-$kernelversion-gentoo-gnu/
make clean
emerge --buildpkg @module-rebuild

binutils-config --linker ld.gold
