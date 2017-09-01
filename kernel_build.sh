emerge gentoo-sources genkernel
wget https://liquorix.net/sources/4.12/config.amd64
genkernel --btrfs --zfs --lvm --mdadm --dmraid --iscsi --luks --kernel-config=Desktop/config.amd64 all

tar -cvf /usr/portage/packages/s/kernel.tar.xz /boot/initramfs-genkernel-*-gentoo /boot/kernel-genkernel-*-gentoo /boot/System.map-genkernel-*-gentoo /lib/modules/*-gentoo/

emerge -1 --jobs=1 zfs-kmod virtualbox-modules exfat-nofuse
