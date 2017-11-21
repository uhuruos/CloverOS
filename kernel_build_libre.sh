emerge gentoo-sources genkernel
wget https://liquorix.net/sources/4.13/config.amd64
cd /usr/src/linux/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/4.14.1-gnu/deblob-4.14
chmod +x deblob-4.14
PYTHON="python2.7" ./deblob-4.14
genkernel --kernel-config=config.amd64 all

rm /usr/portage/packages/s/kernel-libre.tar.xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel-libre.tar *-gentoo-gnu
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel-libre.tar *-gentoo-gnu/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel-libre.tar

emerge -1 --jobs=1 zfs-kmod virtualbox-modules exfat-nofuse
