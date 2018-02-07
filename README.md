# cloveros
<img src="https://gitgud.io/cloveros/cloveros/raw/master/artwork/logo.png" alt="CloverOS logo" width="800" />

<img src="https://gitgud.io/cloveros/cloveros/raw/master/artwork/desktop.png" alt="CloverOS GNU/Linux Desktop" width="250" />

CloverOS GNU/Linux is scripts that creates a minimal (middleware-free), performance-optimized and out of the box Gentoo image and a packages repo (Binhost)

Mirrors and binary details: https://useast.cloveros.ga https://uswest.cloveros.ga https://fr.cloveros.ga https://fr2.cloveros.ga https://au.cloveros.ga https://uk.cloveros.ga

## Cheat sheet
### Upgrade your profile
```
emerge --sync
eselect profile set "default/linux/amd64/17.0/hardened"
```

### Installing program
`emerge filezilla`

### Upgrading system
```
emerge --sync
emerge -uavD world
emerge --depclean
```

### Updating config files after upgrading system
`dispatch-conf`

After you run it, it will show you the changes it's going to make:

q To exit without making changes

u To update and make the changes

z To disregard the changes

It will ask to modify the sudo settings back to default, just hit z there.

### Controlling fvwm
Open Applications menu: right click on desktop

Move windows: alt + left click

Resize Windows: alt + right click

Open Applications menu anywhere: alt + middle click

fvwm's settings are in `~/.fvwm2rc`

### Keyboard bindings

Take screenshot: Print Screen

Brightness controls: Laptop (software) Brightness up/down keys

Volume control: Laptop (software) Volume up/down keys

Key bindings are in `~/.xbindkeysrc`

### Package isn't available
Make an issue so I can add the package to binhost. In the meantime, edit `/etc/portage/make.conf` and edit the following line:

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"`

to

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"`

This disables the binhost and uses Portage's ebuilds for packages. Now you can emerge from source.

### Listing available packages
https://packages.gentoo.org

or run Porthole

### What programs does the binhost have?
List of programs (no dependencies): https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/var/lib/portage/world

List of all packages: https://cloveros.ga/s/packages.html

### Sound doesn't work
Run `alsamixer` and hit F6 to see your audio devices.

To make 1 the default device, edit `~/.asoundrc` and add this:

```
defaults.pcm.card 1
defaults.ctl.card 1
```

### Changing mirrors
Edit `/etc/portage/make.conf`

The mirror used: `PORTAGE_BINHOST="https://cloveros.ga"`

Available mirrors:

https://useast.cloveros.ga

https://uswest.cloveros.ga

https://fr.cloveros.ga

https://fr2.cloveros.ga

https://au.cloveros.ga

https://uk.cloveros.ga

## FAQ
### What is CloverOS?
It's a default Gentoo install with a binary packages repo. I made it to make my life easier.

### What programs does this come with?
Terminal - urxvt

File manager - xfe

Wifi configuration - wpa_gui

Browser - firefox

Text editor - emacs

Graphic editor - gimp

Video player - smplayer / mpv

FTP client - filezilla

Torrent client - rtorrent-ps

IRC client - weechat

### How do I install systemd/avahi/pulseaudio?
I am proud to announce that CloverOS is 100% Poettering-free.

### It doesn't boot after installation
Take out your boot usb/cd.

### Steam doesn't install
Run `STEAM_PLATFORM=0 steam` for the first run.

### Steam doesn't work anymore
Run `rm -R ~/.steam*` before every time you run `steam`.

### Nvidia card crashes on boot with a green screen
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

### Installing proprietary Nvidia drivers
Make sure your kernel is up to date.
```
sudo emerge nvidia-drivers
sudo depmod -a
sudo nvidia-xconfig
sudo eselect opengl set nvidia
sudo eselect opencl set nvidia
sudo sh -c 'echo \"blacklist nouveau\" >> /etc/modprobe.d/blacklist.conf'
```

### Virtualbox doesn't work
Run

```
depmod -a

for m in vbox{drv,netadp,netflt}; do modprobe $m; done
```

If this doesn't work, upgrade your kernel and world.

### Installing package that has kernel module
`depmod -a`

### Installing another kernel
Example:

```
wget "https://git.kernel.org/torvalds/t/linux-4.15-rc7.tar.gz"

tar xvf linux-4.15-rc7.tar.gz

wget https://liquorix.net/sources/4.14/config.amd64

genkernel --kerneldir=linux-4.15-rc7/ --kernel-config=config.amd64 all

grub-mkconfig -o /boot/grub/grub.cfg
```

Don't forget to `emerge genkernel`

### Firefox and Pulseaudio
Firefox 57 still works with ALSA. If this changes, it will be built with apulse.

### What are USE flags?
`/etc/portage/package.use` generally determines what your Gentoo install will look like. The first thing new Gentoo users should do is read the USE flags for their packages.

https://packages.gentoo.org/packages/media-gfx/gimp

There's two types of USE flags that are treated equally: global and local.

Global USE flags are the ones that are in many packages, they generally do the same thing no matter what package uses them.

Local USE flags are the ones that are in a few packages and require you to read https://packages.gentoo.org to read what they do. You can also read the .ebuild to get an even better idea of what it does.

USE flags are basically ./configure parameters made easy.

Examples here:

https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/etc/portage/make.conf

https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/etc/portage/package.use

### What are keywording and unmasking?

https://packages.gentoo.org/packages/media-gfx/gimp

See the green and the yellow? Green means you can just `emerge gimp` and get that version. But what if you want 2.9? It's keyworded, which means it isn't stable.

Gentoo Stable is using packages that aren't keyworded, as in they're tested and guaranteed to work.

Just add media-gfx/gimp to /etc/portage/package.keywords and you'll get the latest keyworded (Yellow) version.

Masked (Red) is just another step forward of keywording and the file is at /etc/portage/package.unmask

You can unmask or unkeyword a specific version by doing =media-gfx/gimp-2.9.6

### Emerge error relating to openssl
Add this to `/etc/portage/package.use`:
```
dev-libs/openssl -bindist
net-misc/openssh -bindist
media-libs/mesa -bindist
```

Mesa needs `-bindist` or OpenGL 3/4 won't work.

### Listing available packages
https://packages.gentoo.org

or run Porthole

### GPU passthrough example
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

### Sound in OBS (Open Broadcaster Software) using ALSA
Run `sudo modprobe snd_aloop` and edit the following file, replacing `device 0` and `hw:0,0` with your sound device:

`~/.asoundrc`

```
    pcm.!default {
      type asym
      playback.pcm "LoopAndReal"
      capture.pcm "looprec"
    }

    pcm.looprec {
        type hw
        card "Loopback"
        device 0
        subdevice 0
    }

    pcm.LoopAndReal {
      type plug
      slave.pcm mdev
      route_policy "duplicate"
    }

    pcm.mdev {
      type multi
      slaves.a.pcm pcm.MixReale
      slaves.a.channels 2
      slaves.b.pcm pcm.MixLoopback
      slaves.b.channels 2
      bindings.0.slave a
      bindings.0.channel 0
      bindings.1.slave a
      bindings.1.channel 1
      bindings.2.slave b
      bindings.2.channel 0
      bindings.3.slave b
      bindings.3.channel 1
    }

    pcm.MixReale {
      type dmix
      ipc_key 1024
      slave {
        pcm "hw:0,0"
        rate 48000
        periods 128
        period_time 0
        period_size 1024
        buffer_size 8192
      }
    }

    pcm.MixLoopback {
      type dmix
      ipc_key 1025
      slave {
        pcm "hw:Loopback,0,0"
        rate 48000
        periods 128
        period_time 0
        period_size 1024
        buffer_size 8192
      }
    }
```

Start playing something, then run `obs`, then add Audio Capture Device (ALSA) to your Sources.

### What is Gentoo?
Gentoo is a meta-distro. You can make any distro you want out of it. You can have a package.use/package.keywords that makes a binary-compatible Debian or Fedora or Arch or whatever. If there's something you don't like about Gentoo, you can just edit /etc/portage/package.use. Using Gentoo is like distro-hopping around the same distro. Also, by building everything yourself, that's one less botnet. If you have a problem with a package or the package doesn't exist, just add an overlay or write an ebuild and put it in your local portage directory and emerge.

### Is this an overlay?
No, this uses regular Gentoo Portage only. Same versions and USE flag options.

### Benefits of Gentoo/CloverOS over other distros
No systemd, maximized CFLAGS, lower RAM usage, it's Gentoo, package versions are stable, it's as default as possible while still being easy, has Infinality, UTF-8 and user groups configured, installs in 2 minutes, saves time by doing all the little things you would've done anyway.

### What is CloverOS Libre?
CloverOS Libre doesn't have the `sys-kernel/linux-firmware` package.

The kernel is the same gentoo-sources with Liquorix config but with https://linux-libre.fsfla.org/pub/linux-libre/releases/4.12.12-gnu/deblob-4.12 ran on it.

```
emerge -C linux-firmware
emerge gentoo-sources genkernel
cd /usr/src/linux/
wget https://linux-libre.fsfla.org/pub/linux-libre/releases/4.14.1-gnu/deblob-4.14
chmod +x deblob-4.14
PYTHON="python2.7" ./deblob-4.14
wget https://liquorix.net/sources/4.14/config.amd64
genkernel --kernel-config=config.amd64 all
grub-mkconfig -o /boot/grub/grub.cfg
```

### Turning CloverOS into CloverOS Libre
`emerge -C linux-firmware`

`./cloveros_settings.sh` l) Update/Install Libre kernel

Reboot; Advanced options, select -gnu kernel

### Turning CloverOS Libre into CloverOS
`emerge linux-firmware`

`./cloveros_settings.sh` 4) Update kernel

Reboot; Advanced options, select non -gnu kernel

### Starting X automatically after login
Edit `~/.bash_profile`

Comment out

`read -erp "Start X? [y/n] " -n 1 choice`

And add in

`choice=y`

### I want to bypass the mixer to play >48KHz audio / DSD
Edit ~/.asoundrc:

```
pcm.!default {
  type hw
  card 0
}
```

Replace card 0 with your device number

### Wayland howto
```
emerge weston
useradd weston-launch
gpasswd -a youruser weston-launch
echo '[core]
modules=xwayland.so' >> ~/.config/weston.ini
XDG_RUNTIME_DIR=. weston-launch
```

### Things preventing CloverOS Libre from being 100% free software:
- LiveCD kernel is taken from Gentoo, it needs to be made from scratch

- /usr/portage/ needs to be filtered to not include the .ebuilds of proprietary software, also requiring a separate Portage mirror

- It needs a cloveros.ga mirror that doesn't host the non-free software packages

### Does CloverOS have binaries?
It's a pre-setup Gentoo image with `PORTAGE_BINHOST="https://cloveors.ga" emerge -G package` preset in /etc/portage/make.conf. It uses Gentoo for everything (versions, ebuilds, etc.) and gets it from cloveros.ga instead of building

### How often is this updated?
It's stable rolling release (Gentoo Stable). It's updated about once a week: http://twitter.com/cloveros_ga

### Does everything build with CFLAGS="-Ofast -mmmx -mssse3 -pipe -funroll-loops -flto=8 -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution" ?
These are all the packages that don't build with the full CFLAGS: https://gitgud.io/cloveros/cloveros/blob/master/binhost_settings/etc/portage/package.env

### The default shell is bash but fvwm launches urxvt -e zsh?
This is done to keep it as default as possible.

### Which DE does this come with?
None, it comes with fvwm and a `~/.bash_profile` that can select/install a DE for you:

![bash profile](https://i.imgur.com/YD4IPRf.png)

### Installing a DE
First, connect to wifi using wpa_gui ('wifi' in fvwm)

Kill X and relog. After you log in and the "Start X?" dialog pops up, instead of y/n, type one of the WM options and hit y when it asks to install.

### I want to host a mirror
Run `rsync -av --delete rsync://fr.cloveros.ga/cloveros /your/webserver/location/` and tell me the domain (or IP) so I can give you a cloveros.ga subdomain

### What if CloverOS dies? Will my install become useless?
Edit `/etc/portage/make.conf` and change

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=4 -G"`

to

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=4"`

Your system is now Gentoo Linux.

After emerge determines what it needs to install and checks dependencies, the -G switch tells emerge to check the binhost before it starts building source. Removing -G reverts to regular emerge operation. It's exactly the same as running `PORTAGE_BINHOST="https://cloveros.ga" emerge -G package` on any Gentoo install. Because it still uses Gentoo repo (versions, ebuilds), and only uses CloverOS as a binhost, you still need to run `emerge --sync`.

CloverOS is a default Gentoo install with programs and with the above defaulted in `/etc/portage/make.conf`. There's also some configuration files and scripts in the user's home directory for making things easier. With those files removed, CloverOS becomes a default Gentoo install.

You can see exactly what's done here: https://gitgud.io/cloveros/cloveros/blob/master/livecd_build.sh
