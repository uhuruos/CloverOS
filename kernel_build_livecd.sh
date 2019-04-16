#!/bin/bash
if [ $(id -u) != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi

kernelversion=4.20.7
kernelmajversion=4.20

binutils-config --linker ld.bfd

ACCEPT_KEYWORDS="~amd64" emerge -1O \=sys-kernel/aufs-sources-$kernelversion
wget https://raw.githubusercontent.com/damentz/liquorix-package/$kernelmajversion/linux-liquorix/debian/config/kernelarch-x86/config-arch-64 -O config-aufs
sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/; s/CONFIG_I2C_NVIDIA_GPU=/#CONFIG_I2C_NVIDIA_GPU=/" config-aufs
echo -e "CONFIG_SND_HDA_INPUT_BEEP=y\nCONFIG_SND_HDA_INPUT_BEEP_MODE=0" >> config-aufs
echo -e "CONFIG_AUFS_FS=y\nCONFIG_AUFS_BRANCH_MAX_127=y\nCONFIG_AUFS_BRANCH_MAX_511=n\nCONFIG_AUFS_BRANCH_MAX_1023=n\nCONFIG_AUFS_BRANCH_MAX_32767=n\nCONFIG_AUFS_HNOTIFY=y\nCONFIG_AUFS_EXPORT=n\nCONFIG_AUFS_XATTR=y\nCONFIG_AUFS_FHSM=y\nCONFIG_AUFS_RDU=n\nCONFIG_AUFS_DIRREN=n\nCONFIG_AUFS_SHWH=n\nCONFIG_AUFS_BR_RAMFS=y\nCONFIG_AUFS_BR_FUSE=n\nCONFIG_AUFS_BR_HFSPLUS=n\nCONFIG_AUFS_DEBUG=n" >> config-aufs
echo -e "CONFIG_NUMA_BALANCING=y\nCONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y\nCONFIG_FAIR_GROUP_SCHED=y\nCONFIG_CFS_BANDWIDTH=n\nCONFIG_RT_GROUP_SCHED=n\nCONFIG_CGROUP_CPUACCT=n\nCONFIG_SCHED_AUTOGROUP=n\nCONFIG_SCSI_MQ_DEFAULT=y\nCONFIG_GENTOO_LINUX=y\nCONFIG_GENTOO_LINUX_UDEV=y\nCONFIG_GENTOO_LINUX_PORTAGE=y\nCONFIG_GENTOO_LINUX_INIT_SCRIPT=y\nCONFIG_GENTOO_LINUX_INIT_SYSTEMD=n" >> config-aufs
sed -i "s/CONFIG_ISO9660_FS=m/CONFIG_ISO9660_FS=y/" config-aufs
mkdir -p /usr/src/linux-$kernelversion-aufs/build/kernel/ /usr/src/linux-$kernelversion-aufs/build/modules/
genkernel --kernel-config=config-aufs --kerneldir=/usr/src/linux-$kernelversion-aufs/ --bootdir=/usr/src/linux-$kernelversion-aufs/build/kernel/ --module-prefix=/usr/src/linux-$kernelversion-aufs/build/modules/ all
XZ_OPT="--lzma1=preset=9e,dict=256MB,nice=273,depth=200,lc=4" tar --lzma -cf /usr/portage/packages/s/kernel-livecd.tar.lzma -C /usr/src/linux-$kernelversion-aufs/build/kernel/ . -C /usr/src/linux-$kernelversion-aufs/build/modules/lib/modules/ .
sudo emerge -C aufs-sources
sudo rm -Rf /usr/src/linux-$kernelversion-aufs/ config-aufs

binutils-config --linker ld.gold
