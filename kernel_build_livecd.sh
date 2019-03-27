#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

ACCEPT_KEYWORDS="~amd64" emerge -1O \=sys-kernel/aufs-sources-4.20.7
cd /usr/src/linux-4.20.7-aufs
wget https://raw.githubusercontent.com/damentz/liquorix-package/4.20/linux-liquorix/debian/config/kernelarch-x86/config-arch-64 -O .config
echo -e "CONFIG_NUMA_BALANCING=y\nCONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y\nCONFIG_FAIR_GROUP_SCHED=y\nCONFIG_CFS_BANDWIDTH=n\nCONFIG_RT_GROUP_SCHED=n\nCONFIG_CGROUP_CPUACCT=n\nCONFIG_SCHED_AUTOGROUP=n\nCONFIG_SCSI_MQ_DEFAULT=y\nCONFIG_AUFS_FS=y\nCONFIG_AUFS_BRANCH_MAX_127=y\nCONFIG_AUFS_BRANCH_MAX_511=n\nCONFIG_AUFS_BRANCH_MAX_1023=n\nCONFIG_AUFS_BRANCH_MAX_32767=n\nCONFIG_AUFS_HNOTIFY=y\nCONFIG_AUFS_EXPORT=n\nCONFIG_AUFS_XATTR=y\nCONFIG_AUFS_FHSM=y\nCONFIG_AUFS_RDU=n\nCONFIG_AUFS_DIRREN=n\nCONFIG_AUFS_SHWH=n\nCONFIG_AUFS_BR_RAMFS=y\nCONFIG_AUFS_BR_FUSE=n\nCONFIG_AUFS_BR_HFSPLUS=n\nCONFIG_AUFS_DEBUG=n\nCONFIG_GENTOO_LINUX=y\nCONFIG_GENTOO_LINUX_UDEV=y\nCONFIG_GENTOO_LINUX_PORTAGE=y\nCONFIG_GENTOO_LINUX_INIT_SCRIPT=y\nCONFIG_GENTOO_LINUX_INIT_SYSTEMD=n" >> .config
make -j$(nproc)
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel.tar.lzma /boot/*$kernelversion-gentoo /lib/modules/$kernelversion-gentoo &
sudo emerge -C aufs-sources
