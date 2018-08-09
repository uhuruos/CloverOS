kernelversion=4.17.13
kernelmajversion=4.17

emerge -C gentoo-sources
rm -Rf /usr/src/*-gentoo*
emerge =gentoo-sources-$kernelversion
eselect kernel set linux-$kernelversion-gentoo

binutils-config --linker ld.bfd

cd /usr/src/linux/
wget https://liquorix.net/sources/$kernelmajversion/config.amd64
sed -i "s/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y/CONFIG_FW_LOADER_USER_HELPER_FALLBACK=n/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/" config.amd64
sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/" config.amd64
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config.amd64
genkernel --kernel-config=config.amd64 --luks --lvm all
make clean

mkdir -p /usr/portage/packages/s/
rm /usr/portage/packages/s/kernel.tar.xz
cd /boot/
tar -cf /usr/portage/packages/s/kernel.tar *$kernelversion-gentoo
cd /lib/modules
tar -rf /usr/portage/packages/s/kernel.tar *$kernelversion-gentoo/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel.tar

cd /usr/src/
cp -R linux-$kernelversion-gentoo linux-$kernelversion-gentoo-gnu
cd linux-$kernelversion-gentoo-gnu
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check
chmod +x deblob-$kernelmajversion deblob-check
PYTHON="python2.7" ./deblob-$kernelmajversion
genkernel --kernel-config=config.amd64 --kerneldir=/usr/src/linux-$kernelversion-gentoo-gnu --luks --lvm all
make clean

rm /usr/portage/packages/s/kernel-libre.tar.xz
cd /boot/
tar -cf /usr/portage/packages/s/kernel-libre.tar *$kernelversion-gentoo-gnu
cd /lib/modules
tar -rf /usr/portage/packages/s/kernel-libre.tar *$kernelversion-gentoo-gnu/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel-libre.tar

cd /usr/src/linux/
make prepare
make modules_prepare
emerge --buildpkg @module-rebuild

binutils-config --linker ld.gold
