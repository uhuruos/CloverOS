# cloveros
![CloverOS GNU/Linux](https://raw.githubusercontent.com/chiru-no/cloveros/master/artwork/logo.png "CloverOS GNU/Linux")

CloverOS GNU/Linux is scripts that creates a Gentoo image and a packages repo (Binhost) that contains unique USE flags and CFLAGS. It aims to be a fast, poetterfrei, lightweight out of the box desktop.

You can download CloverOS GNU/Linux here: https://github.com/chiru-no/cloveros/releases

Video demonstration: https://my.mixtape.moe/qsmcje.mp4

## Cheat sheet
### Installing program
`emerge filezilla`

### Upgrading system
`emerge --sync`

`emerge -uavD world`

### Package isn't available
Make an issue so I can add the package. In the meantime, edit `/etc/portage/make.conf` and edit the following line:

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"`

to

`EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"`

This disables the binhost and uses Portage's ebuilds for packages.

### Controlling twm
Open Applications menu: rightclick on desktop

Move windows: alt + leftclick

Resize Windows: alt + rightclick

Close windows: ctrl + alt + rightclick

The taskbar minimizes and restores windows.

twm's settings are in `~/.twmrc`

### Listing available packages
https://packages.gentoo.org

or run Porthole

### Installing a DE
First, connect to wifi using wpa_gui ('wifi' in twm)

Kill X and relog. After you log in and the "Start X?" dialog pops up, instead of y/n, type one of the WM options and hit y when it asks to install.

### Sound doesn't work
Run `alsamixer` and hit F6 to see your audio devices.

To make 1 the default device, edit `~/.asoundrc` and add this:

```
defaults.pcm.card 1
defaults.ctl.card 1
```

## FAQ
### Is this an overlay?
No, this uses regular Gentoo Portage only. Same versions and USE flag options.

### What makes CloverOS different?
CloverOS is a pre-riced, out-of-the-box Gentoo that's by /g/, for /g/. It focuses on speed and low ram usage, doesn't have systemd or other service bloat, and includes commonly used software.

It's as close to default Gentoo as possible, with all of the configuration made in `/etc/portage/make.conf`, unlike other Gentoo-based distros. The scripts can be used to install it to hard drive, generate a LiveCD and create the CloverOS repo. It's very easy to modify the bash script to make your own Gentoo livecd. In short: CloverOS is Gentoo.

The CloverOS repo is built with custom CFLAGS for optimum performance, and the USE flags are configured for desktop use. There's some dotfiles in the home directory by default to save time. Packages are built with the newest GCC features such as Ofast, Graphite and LTO. I don't see any other distro putting in the effort of utilizing them, so I took it upon myself to ensure the latest breakthroughs in compiler tech doesn't go unused.

If you use Gentoo, you'll probably come to a similar conclusion as CloverOS (package.use, installed packages). The original goal was to be similar to CrunchBang, but with Gentoo.

### What programs does this come with?
Terminal - urxvt

File manager - xfe

Wifi configuration - wpa_gui

Browser - firefox

Text editor - emacs

Graphic editor - gimp

Video player - smplayer / mpv

FTP client - filezilla

Torrent client - rtorrent

IRC client - weechat

### How do I install systemd/avahi/pulseaudio?
I am proud to announce that CloverOS is 100% Poettering-free.

### Dual booting with Windows
I personally did this:

Boot CloverOS liveCD, partition drive like this:


GPT

/dev/sda1 1mb unformatted

/dev/sda2 50gb ext4

/dev/sda3 50gb unformatted

/dev/sda4 rest ext4 or ntfs


Install Windows in /dev/sda3 (or more accurately, the space between /dev/sda2 and /dev/sda4)

Use laptop settings to switch between BIOS and UEFI for Linux or Windows respectively
