# FAQ
Questions and Answers. This has everything not organized enough for README.

## It doesn't boot
Take out your boot usb/cd.

## How do I open a terminal
Right click desktop.

## Nvidia card crashes on boot with a green screen
/etc/modprobe.d/blacklist.conf:

```
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
```

/boot/grub/grub.cfg:

```
linux   /boot/kernel-genkernel-x86_64-[ver]-gentoo root=UUID=[id] ro nomodeset nouveau.modeset=0
```

## Known issues
- Initramfs (genkernel) doesn't boot btrfs

- I can't figure out how to change the port in rtorrent-ps

- Firefox and twm aren't 100% compatible, switch to fvwm needed

## Steam doesn't work anymore
Run `rm -Rf ~/.steam*` before every time you run `steam`.

## Starting X automatically after login
Edit `~/.bash_profile`

Comment out

`read -erp "Start X? [y/n] " -n 1 choice`

And add in

`choice=y`

## is there anyone here using this as a daily? seriously and unironically considering to install this on my laptop
Yes

## Does it have binaries?
It's a pre-setup Gentoo image with `PORTAGE_BINHOST="https://cloveors.ga" emerge -G package` preset in /etc/portage/make.conf. It uses Gentoo for everything (versions, ebuilds, etc.) and gets it from cloveros.ga instead of building

## Binary details
The mirrors have an index page that details this: https://useast.cloveros.ga https://uswest.cloveros.ga https://fr.cloveros.ga https://uk.cloveros.ga https://nl.cloveros.ga https://au.cloveros.ga

## I want to host a mirror
Run `rsync -av --delete rsync://fr.cloveros.ga/cloveros /your/webserver/location/` and tell me the domain (or IP) so I can give you a cloveros.ga subdomain

## Firefox and Pulseaudio
Firefox 57 on CloverOS works with ALSA. If this changes, it will be built with apulse.

## How often is this updated?
It's stable rolling release, I update the binhost about once a week. (If emerging doesn't work, then I'm probably rsyncing, so wait a few minutes.)

## Gentoo is a distro that's only good for servers
Gentoo is a meta-distro. You can make any distro you want out of it.

## Does everything build with CFLAGS="-Ofast -mmmx -mssse3 -pipe -funroll-loops -flto=8 -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution" ?
These are all the packages that don't build with the full CFLAGS: https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/etc/portage/package.env

## Benefits of Gentoo/CloverOS over other distros
No systemd, CFLAGS, lower RAM usage, it's Gentoo, package versions are stable, it's as default as possible while still being easy, has infinality, installs in 2 minutes depending on # of cores (unsquashfs), saves time by doing all the little things you would've done anyway, while still being default enough for you to change.

## The default shell is bash but twm launches urxvt -e zsh?
This is done to keep it as default as possible.

## What programs does the binhost have?
List of programs without dependencies: https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/var/lib/portage/world

List of all packages: https://cloveros.ga/s/packages.html

## Which DE does this come with?
None, it comes with twm and a `~/.bash_profile` that can select/install a DE for you:

![bash profile](https://i.imgur.com/YD4IPRf.png)

## What is CloverOS Libre?
CloverOS Libre doesn't have the `sys-kernel/linux-firmware` package.

The kernel is the same gentoo-sources with Liquorix config but with https://linux-libre.fsfla.org/pub/linux-libre/releases/4.12.12-gnu/deblob-4.12 ran on it.

```
emerge -C linux-firmware
emerge gentoo-sources genkernel
cd /usr/src/linux/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/4.14.1-gnu/deblob-4.14
chmod +x deblob-4.14
PYTHON="python2.7" ./deblob-4.14
wget https://liquorix.net/sources/4.13/config.amd64
genkernel --kernel-config=config.amd64 all
grub-mkconfig -o /boot/grub/grub.cfg
```

## Turning CloverOS into CloverOS Libre
`emerge -C linux-firmware`

`./cloveros_settings.sh` l) Update/Install Libre kernel

Reboot; Advanced options, select -gnu kernel

## Turning CloverOS Libre into CloverOS
`emerge linux-firmware`

`./cloveros_settings.sh` 4) Update kernel

Reboot; Advanced options, select non -gnu kernel

## Things preventing CloverOS Libre from being 100% free software:
- LiveCD kernel is taken from Gentoo, it needs to be made from scratch

- /usr/portage/ needs to be filtered to not include the .ebuilds of proprietary software, also requiring a separate Portage mirror

- It needs a cloveros.ga mirror that doesn't host the non-free software packages

## How many users does CloverOS have?
This is the only data I record:

![CloverOS bandwidth](https://cloveros.ga/s/bandwidth.png)

Each mirror has /s/bandwidth.txt. ie: https://uswest.cloveros.ga/s/bandwidth.txt

`while :; do netstat -i | grep -m1 eth0 | awk '{print $7}' > /var/www/html/s/bandwidth.txt; sleep 60; done &`

## What if CloverOS dies? Will my install become useless?
Edit `/etc/portage/make.conf` and change

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"`

to

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"`

Your system is now Gentoo Linux.

After emerge determines what it needs to install and checks dependencies, the -G switch tells emerge to check the binhost before it starts building source. Removing -G reverts to regular emerge operation. It's exactly the same as running `PORTAGE_BINHOST="https://cloveros.ga" emerge -G package` on any Gentoo install. Because it still uses Gentoo repo (versions, ebuilds), and only uses CloverOS as a binhost, you still need to run `emerge --sync`.

CloverOS is a default Gentoo install with programs and with the above defaulted in `/etc/portage/make.conf`. There's also some configuration files and scripts in the user's home directory for making things easier. With those files removed, CloverOS becomes a default Gentoo install.

You can see exactly what's done here: https://gitgud.io/cloveros/cloveros/blob/master/livecd_build.sh
