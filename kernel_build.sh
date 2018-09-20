kernelversion=4.17.19
kernelmajversion=4.17

emerge -C gentoo-sources
rm -Rf /usr/src/*-gentoo*
find /boot/ /lib/modules/ -mindepth 1 -maxdepth 1 -name \*gentoo\* ! -name \*$(uname -r) -exec rm -R {} \;
mkdir -p /usr/portage/packages/s/
binutils-config --linker ld.bfd

emerge =gentoo-sources-$kernelversion
eselect kernel set linux-$kernelversion-gentoo
wget https://liquorix.net/sources/$kernelmajversion/config.amd64
sed -i "s/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=n/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/" config.amd64
sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/" config.amd64
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config.amd64
genkernel --kernel-config=config.amd64 --luks --lvm all
grub-mkconfig -o /boot/grub/grub.cfg

cp -R /usr/src/linux-$kernelversion-gentoo/ /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion -P /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check -P /usr/src/linux-$kernelversion-gentoo-gnu/
chmod +x /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion /usr/src/linux-$kernelversion-gentoo-gnu/deblob-check
cd /usr/src/linux-$kernelversion-gentoo-gnu/ ; PYTHON="python2.7" /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion ; cd -
genkernel --kernel-config=config.amd64 --kerneldir=/usr/src/linux-$kernelversion-gentoo-gnu/ --luks --lvm all

XZ_OPT="-9e --lzma2=dict=256MB" tar -cJf /usr/portage/packages/s/kernel.tar.xz /boot/*$kernelversion-gentoo /lib/modules/$kernelversion-gentoo
XZ_OPT="-9e --lzma2=dict=256MB" tar -cJf /usr/portage/packages/s/kernel-libre.tar.xz /boot/*$kernelversion-gentoo-gnu /lib/modules/$kernelversion-gentoo-gnu

binutils-config --linker ld.gold
rm config.amd64
cd /usr/src/linux/
make clean
make prepare
make modules_prepare
cd /usr/src/linux-$kernelversion-gentoo-gnu/
make clean
emerge --buildpkg @module-rebuild
