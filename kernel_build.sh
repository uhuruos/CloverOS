kernelversion=4.14.2
kernelmajversion=4.14

emerge gentoo-sources genkernel
cd /usr/src/linux/
wget https://liquorix.net/sources/4.13/config.amd64
genkernel --kernel-config=config.amd64 all

rm /usr/portage/packages/s/kernel.tar.xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel.tar *$kernelversion-gentoo
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel.tar *$kernelversion-gentoo/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel.tar

cd /usr/src/linux/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-$kernelmajversion
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/$kernelversion-gnu/deblob-check
chmod +x deblob-$kernelmajversion
PYTHON="python2.7" ./deblob-$kernelmajversion
genkernel --kernel-config=config.amd64 all

rm /usr/portage/packages/s/kernel-libre.tar.xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel-libre.tar *$kernelversion-gentoo-gnu
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel-libre.tar *$kernelversion-gentoo-gnu/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel-libre.tar

cd /usr/src/linux/
make prepare
make modules_prepare

emerge --buildpkg @module-rebuild @x11-module-rebuild
