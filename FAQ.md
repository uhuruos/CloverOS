# FAQ
Questions and Answers. This has everything not organized enough for README.

## It doesn't boot
Take out your boot usb/cd.

## Binary details
The mirrors have an index page that details this: https://useast.cloveros.ga https://uswest.cloveros.ga https://fr.cloveros.ga https://uk.cloveros.ga https://nl.cloveros.ga https://au.cloveros.ga

## What is CloverOS Libre?
CloverOS Libre doesn't have the `sys-kernel/linux-firmware` package.

The kernel is the same gentoo-sources with Liquorix config but with https://linux-libre.fsfla.org/pub/linux-libre/releases/4.12.12-gnu/deblob-4.12 ran on it.

You can turn CloverOS into Libre by doing `emerge -C linux-firmware` and using this kernel https://cloveros.ga/s/kernel-libre.tar.xz or building it yourself;

```
emerge gentoo-sources genkernel
cd /usr/src/linux/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/4.12.12-gnu/deblob-4.12
chmod +x deblob-4.12
PYTHON="python2.7" ./deblob-4.12
wget https://liquorix.net/sources/4.12/config.amd64
genkernel --kernel-config=config.amd64 all
```

## Gentoo is a distro that's only good for servers
Gentoo is a meta-distro. You can make any distro you want out of it.

## Does everything build with CFLAGS="-Ofast -mmmx -mssse3 -pipe -funroll-loops -flto=8 -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution" ?
These are all the packages that don't build with the full CFLAGS: https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/etc/portage/package.env

## What if CloverOS dies? Will my install become useless?
Edit `/etc/portage/make.conf` and change
`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"`
to
`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"`

After emerge determines what it needs to install and checks dependencies, the -G switch tells emerge to check the binhost before it starts building source. Removing -G reverts to regular emerge operation. It's exactly the same as running `PORTAGE_BINHOST="https://cloveros.ga" emerge -G package` on any Gentoo install.

CloverOS is a default Gentoo install with programs and with the above defaulted in `/etc/portage/make.conf`. There's also some configuration files and scripts in the user's home directory for making things easier. With those files removed, CloverOS becomes a default Gentoo install.

## Benefits of Gentoo/CloverOS over other distros
No systemd, CFLAGS, lower RAM usage, it's Gentoo, package versions are stable. CloverOS installs in 2 minutes depending on # of cores (unsquashfs) and has infinality installed by default. It saved me a lot of time in OS installs because it's exactly how I would configure my OS.
