kernelversion=4.15.0
kernelmajversion=4.15
revision=

#emerge gentoo-sources genkernel
#eselect kernel set 1

binutils-config --linker ld.bfd

cd /usr/src/linux/
wget https://liquorix.net/sources/4.14/config.amd64
genkernel --kernel-config=config.amd64 --luks --lvm all
make clean

rm /usr/portage/packages/s/kernel.tar.xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel.tar *$kernelversion-gentoo$revision
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel.tar *$kernelversion-gentoo$revision/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel.tar

cd /usr/src/
cp -R linux-$kernelversion-gentoo$revision linux-$kernelversion-gentoo-gnu$revision
cd linux-$kernelversion-gentoo-gnu$revision
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check
chmod +x deblob-$kernelmajversion deblob-check
PYTHON="python2.7" ./deblob-$kernelmajversion
genkernel --kernel-config=config.amd64 --kerneldir=/usr/src/linux-$kernelversion-gentoo-gnu$revision --luks --lvm all
make clean

rm /usr/portage/packages/s/kernel-libre.tar.xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel-libre.tar *$kernelversion-gentoo$revision-gnu
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel-libre.tar *$kernelversion-gentoo$revision-gnu/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel-libre.tar

cd /usr/src/linux/
make prepare
make modules_prepare
emerge --buildpkg @module-rebuild

binutils-config --linker ld.gold
