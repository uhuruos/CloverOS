emerge gentoo-sources genkernel
wget https://liquorix.net/sources/4.12/config.amd64
genkernel --kernel-config=Desktop/config.amd64 all

cd /boot/
tar -cvf /usr/portage/packages/s/kernel.tar initramfs-genkernel-*-gentoo kernel-genkernel-*-gentoo System.map-genkernel-*-gentoo
cd /lib/modules
tar -rvf /usr/portage/packages/s/kernel.tar *-gentoo/
xz -9e --lzma2=dict=256MB /usr/portage/packages/s/kernel.tar

emerge -1 --jobs=1 zfs-kmod virtualbox-modules exfat-nofuse
