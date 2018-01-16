#!/bin/bash

mirrors=(
	"useast.cloveros.ga"
	"fr.cloveros.ga"
	"au.cloveros.ga"
	"ca.cloveros.ga"
	"uswest.cloveros.ga"
	"uk.cloveros.ga"
)

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"

echo "1) Update cloveros_settings.sh
2) Change mirrors
3) Change default ALSA (sound) device
4) Upgrade kernel (Current version: 4.14.13)
5) Change binary/source
6) Update dot files
7) Sync time
8) Set timezone
9) Clean emerge cache
u) Update system
a) ALSA settings
t) Enable tap to click on touchpad
l) Upgrade/Install Libre kernel
c) Update Portage config from binhost
g) Fix Nvidia doesn't boot problem
b) Install bluetooth manager
i) Install VirtualBox
n) Install proprietary Nvidia drivers
v) Install Virtualbox/VMWare drivers
q) Exit"

if [[ -n "$1" ]]; then
	choice=$1
else
	read -erp "Select option: " -n 1 choice
fi

echo

case "$choice" in
	1)
		cd ~
		wget "$gitprefix"/home/user/cloveros_settings.sh -O cloveros_settings.new.sh
		if [[ -f cloveros_settings.new.sh ]]; then
			rm cloveros_settings.sh
			mv cloveros_settings.new.sh cloveros_settings.sh
			chmod +x cloveros_settings.sh
			echo -e "\ncloveros_settings.sh is now updated. (~/cloveros_settings.sh)"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
		fi
		;;

	2)
		for i in "${!mirrors[@]}"; do
			echo "$((i+1))) ${mirrors[i]}"
		done
		read -erp "Select mirror: " -n 1 choicemirror
		sudo sed -i "s@PORTAGE_BINHOST=\".*\"@PORTAGE_BINHOST=\"https://${mirrors[$choicemirror-1]}\"@" /etc/portage/make.conf
		echo -e "\nMirror changed to: ${mirrors[choicemirror-1]}. (/etc/portage/make.conf)"
		;;

	3)
		grep " \[" /proc/asound/cards
		read -erp "Select the audio device to become default: " -n 1 choiceaudio
		echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
		echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs. (~/.asoundrc)"
		;;

	4)
		cd ~
		tempdir=kernel$(< /dev/urandom tr -dc 0-9 | head -c 5)
		mkdir $tempdir
		cd $tempdir
		wget https://cloveros.ga/s/kernel.tar.xz
		wget https://cloveros.ga/s/signatures/s/kernel.tar.xz.asc
		sudo gpg --verify kernel.tar.xz.asc kernel.tar.xz
		tar xf kernel.tar.xz
		sudo mv initramfs-genkernel-*-gentoo* kernel-genkernel-*-gentoo* System.map-genkernel-*-gentoo* /boot/
		sudo cp -R *-gentoo*/ /lib/modules/
		cd ..
		rm -R $tempdir
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
		;;

	5)
		if grep -q 'EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"' /etc/portage/make.conf; then
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/' /etc/portage/make.conf
			sudo sed -i 's/^ACCEPT_KEYWORDS="\*\*"/#ACCEPT_KEYWORDS="\*\*"/' /etc/portage/make.conf
			sudo sed -i 's/^FETCHCOMMAND_HTTPS=/#FETCHCOMMAND_HTTPS=/' /etc/portage/make.conf
			echo -e "\nemerge will now install from source. (/etc/portage/make.conf)\n"
			read -erp "Copy over binhost Portage config? (/etc/portage/package.use, /etc/portage/package.env, /etc/portage/package.keywords, /etc/portage/package.license, /etc/portage/package.mask) [y/n] " -n 1 binhostyn
			if [[ $binhostyn == "y" || $binhostyn == "Y" ]]; then
				backupportagedir=backupportage$(< /dev/urandom tr -dc 0-9 | head -c 5)
				sudo mkdir ~/$backupportagedir
				sudo mv /etc/portage/package.use /etc/portage/package.mask /etc/portage/package.keywords /etc/portage/package.env /etc/portage/package.mask /etc/portage/package.license ~/$backupportagedir
				sudo wget $gitprefix/binhost_settings/etc/portage/package.use $gitprefix/binhost_settings/etc/portage/package.keywords $gitprefix/binhost_settings/etc/portage/package.env $gitprefix/binhost_settings/etc/portage/package.mask $gitprefix/binhost_settings/etc/portage/package.license -P /etc/portage/
				sudo rm -R /etc/portage/env/
				sudo mkdir /etc/portage/env/
				sudo wget $gitprefix/binhost_settings/etc/portage/env/no-lto $gitprefix/binhost_settings/etc/portage/env/no-lto-graphite $gitprefix/binhost_settings/etc/portage/env/no-lto-graphite-ofast $gitprefix/binhost_settings/etc/portage/env/no-lto-o3 $gitprefix/binhost_settings/etc/portage/env/no-lto-ofast $gitprefix/binhost_settings/etc/portage/env/no-o3 $gitprefix/binhost_settings/etc/portage/env/no-ofast $gitprefix/binhost_settings/etc/portage/env/size -P /etc/portage/env/
				sudo sh -c "curl -s $gitprefix/binhost_settings/etc/portage/make.conf | grep '^USE=' >> /etc/portage/make.conf"
				echo -e "\nPortage configuration now mirrors binhost Portage configuration. Previous Portage config stored in ~/$backupportagedir"
			fi
		else
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/' /etc/portage/make.conf
			sudo sed -i 's/^#ACCEPT_KEYWORDS="\*\*"/ACCEPT_KEYWORDS="\*\*"/' /etc/portage/make.conf
			sudo sed -i 's/^#FETCHCOMMAND_HTTPS=/FETCHCOMMAND_HTTPS=/' /etc/portage/make.conf
			echo -e "\nemerge will now install from binary. (/etc/portage/make.conf)"
		fi
		;;

	6)
		cd ~
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 5)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .twmrc .Xdefaults wallpaper.png .xbindkeysrc screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh .emacs .emacs.d .twm .rtorrent.rc .mpv .config/xfe/ .config/nitrogen/ $backupdir/
		wget -q "$gitprefix"/home/user/{.bash_profile,.zprofile,.zshrc,.twmrc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh
		mkdir -p .emacs.d/backups
		mkdir .emacs.d/autosaves
		mkdir .twm
		wget -q "$gitprefix"/home/user/.twm/{minimize.xbm,maximize.xbm,close.xbm} -P .twm
		mkdir -p .config/xfe/
		wget -q "$gitprefix"/home/user/.config/xfe/xferc -P .config/xfe
		mkdir -p .config/nitrogen/
		wget -q "$gitprefix"/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen
		sed -i "s@/home/user/@/home/$USER/@" .config/nitrogen/nitrogen.cfg
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		mkdir .mpv
		wget -q "$gitprefix"/home/user/.mpv/config -P .mpv
		echo -e "\nConfiguration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/ (~)"
		;;

	7)
		sudo date +%s -s @$(curl -s http://www.convert-unix-time.com/ | grep "Seconds since" | sed -r 's/.*t=(.*)" id.*/\1/')
		echo -e "\nTime set."
		;;

	8)
		echo -e "Available timezones: $(find /usr/share/zoneinfo/ -type f | sed s#/usr/share/zoneinfo/## | sort | tr '\n' ' ') \n"
		read -erp "Select a timezone: " timezone
		sudo cp /usr/share/zoneinfo/${timezone} /etc/localtime
		echo -e "\nTimezone set to ${timezone}. (/etc/localtime)"
		;;

	9)
		sudo rm -Rf /usr/portage/packages/* /usr/portage/distfiles/* /var/tmp/portage/*
		echo -e "\nPackage cache cleared. (/usr/portage/packages/, /usr/portage/distfiles/, /var/tmp/portage/)"
		;;

	u)
		echo "Running the following:"
		echo "sudo emerge --sync"
		echo "sudo emerge -uvD world"
		echo "sudo emerge --depclean"
		sudo emerge --sync
		sudo emerge -uvD world
		sudo emerge --depclean
		;;

	a)
		echo "In Progress.
1) Change default ALSA device
2) Configure ALSA for OBS
3) GUI volume control
4) CLI volume control"
		read -erp "Select option: " -n 1 choice
		echo "Choice: $choice"
		;;

	l)
		cd ~
		tempdir=kernel$(< /dev/urandom tr -dc 0-9 | head -c 5)
		mkdir $tempdir
		cd $tempdir
		wget https://cloveros.ga/s/kernel-libre.tar.xz
		wget https://cloveros.ga/s/signatures/s/kernel-libre.tar.xz.asc
		sudo gpg --verify kernel-libre.tar.xz.asc kernel-libre.tar.xz
		tar xf kernel-libre.tar.xz
		sudo mv initramfs-genkernel-*-gentoo*-gnu kernel-genkernel-*-gentoo*-gnu System.map-genkernel-*-gentoo*-gnu /boot/
		sudo mv *-gentoo*-gnu/ /lib/modules/
		cd ..
		rm -R $tempdir
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
		;;

	t)
		if ! type /usr/bin/xinput > /dev/null; then
			sudo emerge xinput
		fi
		tappingid=$(xinput list-props "SynPS/2 Synaptics TouchPad" | grep 'Tapping Enabled (' | awk '{print $4}' | grep -o "[0-9]\+")
		xinput set-prop "SynPS/2 Synaptics TouchPad" $tappingid 1
		echo -e "\nEnable Tap to Click: xinput set-prop \"SynPS/2 Synaptics TouchPad\" $tappingid 1"
		echo "Disable Tap to Click: xinput set-prop \"SynPS/2 Synaptics TouchPad\" $tappingid 0"
		;;

	n)
		echo "Updating kernel..."
		echo "Running the following:"
		echo "./cloveros_settings.sh 4"
		./cloveros_settings.sh 4
		echo "Installling Nvidia drivers..."
		echo "Running the following:"
		echo "sudo emerge nvidia-drivers"
		echo "sudo depmod -a"
		echo "sudo nvidia-xconfig"
		echo "sudo eselect opengl set nvidia"
		echo "sudo eselect opencl set nvidia"
		echo "sudo sh -c 'echo \"blacklist nouveau\" >> /etc/modprobe.d/blacklist.conf'"
		sudo emerge nvidia-drivers
		sudo depmod -a
		sudo nvidia-xconfig
		sudo eselect opengl set nvidia
		sudo eselect opencl set nvidia
		sudo sh -c 'echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf'
		echo -e "\nNvidia drivers installed, restart X.\nCheck https://wiki.gentoo.org/wiki/NVidia/nvidia-drivers for more info"
		;;

	c)
		backupportagedir=backupportage$(< /dev/urandom tr -dc 0-9 | head -c 5)
		sudo mkdir ~/$backupportagedir
		sudo mv /etc/portage/package.use /etc/portage/package.mask /etc/portage/package.keywords /etc/portage/package.env /etc/portage/package.mask /etc/portage/package.license ~/$backupportagedir
		sudo wget $gitprefix/binhost_settings/etc/portage/package.use $gitprefix/binhost_settings/etc/portage/package.keywords $gitprefix/binhost_settings/etc/portage/package.env $gitprefix/binhost_settings/etc/portage/package.mask $gitprefix/binhost_settings/etc/portage/package.license -P /etc/portage/
		sudo rm -R /etc/portage/env/
		sudo mkdir /etc/portage/env/
		sudo wget $gitprefix/binhost_settings/etc/portage/env/no-lto $gitprefix/binhost_settings/etc/portage/env/no-lto-graphite $gitprefix/binhost_settings/etc/portage/env/no-lto-graphite-ofast $gitprefix/binhost_settings/etc/portage/env/no-lto-o3 $gitprefix/binhost_settings/etc/portage/env/no-lto-ofast $gitprefix/binhost_settings/etc/portage/env/no-o3 $gitprefix/binhost_settings/etc/portage/env/no-ofast $gitprefix/binhost_settings/etc/portage/env/size -P /etc/portage/env/
		sudo sh -c "curl -s $gitprefix/binhost_settings/etc/portage/make.conf | grep '^USE=' >> /etc/portage/make.conf"
		echo -e "\nPortage configuration now mirrors binhost Portage configuration. Previous Portage config stored in ~/$backupportagedir"
		;;

	g)
		echo "In progress, check README."
		;;

	b)
		echo "Running the following:"
		echo "sudo emerge blueman"
		echo "sudo /etc/init.d/bluetooth start"
		echo "sudo blueman-applet&"
		echo "sudo blueman-browse&"
		sudo emerge blueman
		sudo /etc/init.d/bluetooth start
		sudo blueman-applet&
		sudo blueman-browse&
		;;

	i)
		echo "Running the following:"
		echo "sudo emerge virtualbox"
		echo "depclean -a"
		;;

	v)
		echo "Running the following:"
		echo "sudo emerge xf86-video-vmware virtualbox-guest-additions"
		sudo emerge xf86-video-vmware virtualbox-guest-additions
		echo -e "\nRestart X to load driver."
		;;

	q)
		;;

	*)
		echo "Invalid option: '$choice'" >&2
		exit 1
		;;
esac
