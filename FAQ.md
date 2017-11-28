# FAQ
Full Questions and Answers.

### Installing program
`emerge filezilla`

### Upgrading system
```
emerge --sync
emerge -uavD world
emerge --depclean
```

## Updating config files after upgrading system
`dispatch-conf`

After you run it, it will show you the changes it's going to make:

q To exit without making changes

u To update and make the changes

z To disregard the changes

It will ask to modify the sudo settings back to default, just hit z there.

## Sound doesn't work
Run `alsamixer` and hit F6 to see your audio devices.

To make 1 the default device, edit `~/.asoundrc` and add this:

```
defaults.pcm.card 1
defaults.ctl.card 1
```

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

## Installing proprietary Nvidia drivers
Make sure your kernel is up to date.
```
sudo emerge nvidia-drivers
sudo depmod -a
sudo nvidia-xconfig
sudo eselect opengl set nvidia
sudo eselect opencl set nvidia
sudo sh -c 'echo \"blacklist nouveau\" >> /etc/modprobe.d/blacklist.conf'
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

## Is Gentoo a meme?
Gentoo is a meta-distro. You can make any distro you want out of it. You can have a package.use/package.keywords that makes a binary-compatible Debian or Fedora or Arch or whatever. If 
there's something you don't like about Gentoo, you can just edit /etc/portage/package.use. Using Gentoo is like distro-hopping around the same distro. Also, by building everything 
yourself, that's one less botnet.

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
List of programs (no dependencies): https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/var/lib/portage/world

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

## What are keywording and unmasking?

https://packages.gentoo.org/packages/media-gfx/gimp

See the green and the yellow? Green means you can just `emerge gimp` and get that version. But what if you want 2.9? It's keyworded, which means it isn't stable.

Gentoo Stable is using packages that aren't keyworded, as in they're tested and guaranteed to work.

Just add media-gfx/gimp to /etc/portage/package.keywords and you'll get the latest keyworded (Yellow) version.

Masked (Red) is just another step forward of keywording and the file is at /etc/portage/package.unmask

You can unmask or unkeyword a specific version by doing =media-gfx/gimp-2.9.6

## GPU passthrough example
```
./vfio-bind.sh 0000:01:00.0 0000:01:00.1 0000:00:12.0 0000:00:12.2

qemu-system-x86_64 -enable-kvm -m 4G -cpu host -smp cores=8,threads=1 -vga none -display none \
-drive if=pflash,format=raw,readonly,file=OVMF_CODE-pure-efi.fd \
-drive if=pflash,format=raw,file=OVMF_VARS-pure-efi.fd \
-drive file=windows,format=raw \
-device vfio-pci,host=01:00.0,romfile=XFX.R9390.8192.150603.rom \
-device vfio-pci,host=01:00.1 \
-device vfio-pci,host=00:12.0 \
-device vfio-pci,host=00:12.2
```

## What if CloverOS dies? Will my install become useless?
Edit `/etc/portage/make.conf` and change

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"`

to

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"`

Your system is now Gentoo Linux.

After emerge determines what it needs to install and checks dependencies, the -G switch tells emerge to check the binhost before it starts building source. Removing -G reverts to regular emerge operation. It's exactly the same as running `PORTAGE_BINHOST="https://cloveros.ga" emerge -G package` on any Gentoo install. Because it still uses Gentoo repo (versions, ebuilds), and only uses CloverOS as a binhost, you still need to run `emerge --sync`.

CloverOS is a default Gentoo install with programs and with the above defaulted in `/etc/portage/make.conf`. There's also some configuration files and scripts in the user's home directory for making things easier. With those files removed, CloverOS becomes a default Gentoo install.

You can see exactly what's done here: https://gitgud.io/cloveros/cloveros/blob/master/livecd_build.sh
