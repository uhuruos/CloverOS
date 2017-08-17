#emerge gentoo-sources genkernel
wget https://liquorix.net/sources/4.12/config.amd64
genkernel --kernel-config=config.amd64 all
dracut --xz
cd /boot/
tar -cvf /usr/portage/packages/s/kernel.tar.xz *4.12.5*
cd /lib/modules/
tar -cvf /usr/portage/packages/s/modules.tar.xz *4.12.5*
emerge -1 --jobs=1 zfs-kmod virtualbox-modules exfat-nofuse
