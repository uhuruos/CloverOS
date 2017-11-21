emerge gentoo-sources genkernel
wget https://liquorix.net/sources/4.13/config.amd64
genkernel --kernel-config=config.amd64 all

rm /usr/portage/packages/s/kernel.tar.xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel.tar *-gentoo
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel.tar *-gentoo/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel.tar

emerge -1 --jobs=1 zfs-kmod virtualbox-modules exfat-nofuse
