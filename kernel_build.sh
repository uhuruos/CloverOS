emerge -C gentoo-sources
rm -Rf /usr/src/*-gentoo*
rm /usr/portage/packages/s/kernel*.tar.xz
find /boot/ /lib/modules/ -mindepth 1 -maxdepth 1 -name \*gentoo\* ! -name \*$(uname -r) -exec rm -R {} \;
mkdir -p /usr/portage/packages/s/
binutils-config --linker ld.bfd

kernelversion=4.17.19
kernelmajversion=4.17

emerge =gentoo-sources-$kernelversion
eselect kernel set linux-$kernelversion-gentoo
wget https://liquorix.net/sources/$kernelmajversion/config.amd64
sed -i "s/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=n/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/" config.amd64
sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/" config.amd64
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config.amd64
genkernel --kernel-config=config.amd64 --luks --lvm all
grub-mkconfig -o /boot/grub/grub.cfg

tar -cf /usr/portage/packages/s/kernel.tar -C /boot/ *$kernelversion-gentoo
tar -rf /usr/portage/packages/s/kernel.tar -C /lib/modules/ *$kernelversion-gentoo/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel.tar

cp -R /usr/src/linux-$kernelversion-gentoo/ /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion -P /usr/src/linux-$kernelversion-gentoo-gnu/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check -P /usr/src/linux-$kernelversion-gentoo-gnu/
chmod +x /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion /usr/src/linux-$kernelversion-gentoo-gnu/deblob-check
cd /usr/src/linux-$kernelversion-gentoo-gnu/ && PYTHON="python2.7" /usr/src/linux-$kernelversion-gentoo-gnu/deblob-$kernelmajversion && cd -
genkernel --kernel-config=config.amd64 --kerneldir=/usr/src/linux-$kernelversion-gentoo-gnu/ --luks --lvm all

tar -cf /usr/portage/packages/s/kernel-libre.tar -C /boot/ *$kernelversion-gentoo-gnu
tar -rf /usr/portage/packages/s/kernel-libre.tar -C /lib/modules/ *$kernelversion-gentoo-gnu/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel-libre.tar

cd /usr/src/linux/
make clean
make prepare
make modules_prepare
emerge --buildpkg @module-rebuild
binutils-config --linker ld.gold
