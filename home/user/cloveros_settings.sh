#!/bin/bash

mirrors=(
	"https://useast.cloveros.ga"
	"https://uswest.cloveros.ga"
	"https://ca.cloveros.ga"
	"https://fr.cloveros.ga"
	"https://nl.cloveros.ga"
	"https://uk.cloveros.ga"
	"https://au.cloveros.ga"
	"https://sea.cloveros.ga"
)

kernelversion="4.16.3"

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"

cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ -n "$1" ]]; then
	if [[ -z "$2" ]]; then
		choice=$1
	else
		exit 1
	fi
else
	echo "1) Update cloveros_settings.sh
2) Change mirror
3) Change default sound device
4) Update/install kernel $kernelversion
5) Change emerge to source or binary
6) Update default dot files
7) Sync time
8) Set timezone
9) Clean emerge cache
u) Update system, kernel, cloveros_settings.sh, clean emerge cache
l) Update/install kernel $kernelversion-gnu
a) ALSA settings configurator
t) Enable tap to click on touchpad
b) Install bluetooth manager
i) Install VirtualBox
v) Install Virtualbox/VMWare drivers
c) Update Portage config from binhost
m) Revert to default /etc/portage/make.conf
n) Install proprietary Nvidia drivers
g) Fix Nvidia doesn't boot problem
q) Exit"
	read -erp "Select option: " -n 1 choice
	echo
fi

case "$choice" in
	1)
		wget "$gitprefix"/home/user/cloveros_settings.sh -O cloveros_settings.new.sh
		if [[ -s cloveros_settings.new.sh ]]; then
			chmod +x cloveros_settings.new.sh
			mv cloveros_settings.new.sh cloveros_settings.sh
			echo -e "\ncloveros_settings.sh is now updated. (~/cloveros_settings.sh)"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			exit 1
		fi
		;;

	2)
		for i in "${!mirrors[@]}"; do
			echo "$((i+1))) ${mirrors[i]}"
		done
		read -erp "Select mirror: " -n 1 choicemirror
		sudo sed -i "s@PORTAGE_BINHOST=\".*\"@PORTAGE_BINHOST=\"${mirrors[$choicemirror-1]}\"@" /etc/portage/make.conf
		echo -e "\nMirror changed to: ${mirrors[choicemirror-1]}. (/etc/portage/make.conf)"
		;;

	3)
		grep " \[" /proc/asound/cards
		read -erp "Select the audio device to become default: " -n 1 choiceaudio
		echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
		echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs. (~/.asoundrc)"
		;;

	4)
		if [[ $(find /boot/ -iname \*$kernelversion\*-gentoo | wc -l) -gt 0 ]]; then
			echo "Kernel up to date."
		else
			tempdir=kernel$(< /dev/urandom tr -dc 0-9 | head -c 8)
			mkdir $tempdir
			cd $tempdir
			wget https://cloveros.ga/s/kernel.tar.xz
			wget https://cloveros.ga/s/signatures/s/kernel.tar.xz.asc
			if sudo gpg --verify kernel.tar.xz.asc kernel.tar.xz; then
				tar xf kernel.tar.xz
				sudo mv initramfs-genkernel-*-gentoo* kernel-genkernel-*-gentoo* System.map-genkernel-*-gentoo* /boot/
				sudo cp -R *-gentoo*/ /lib/modules/
				sudo grub-mkconfig -o /boot/grub/grub.cfg
				echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
			else
				echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			fi
			cd ..
			rm -R $tempdir
		fi
		;;

	5)
		if grep -q 'EMERGE_DEFAULT_OPTS=".* -G"' /etc/portage/make.conf; then
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="\(.*\) -G"/EMERGE_DEFAULT_OPTS="\1"/' /etc/portage/make.conf
			sudo sed -i 's/^ACCEPT_KEYWORDS="\*\*"/#ACCEPT_KEYWORDS="\*\*"/' /etc/portage/make.conf
			sudo sed -i 's/^FETCHCOMMAND_HTTPS=/#FETCHCOMMAND_HTTPS=/' /etc/portage/make.conf
			echo -e "\nemerge will now install from source. (/etc/portage/make.conf)\nUse ./cloveros_settings.sh c to copy binhost Portage configuration"
		else
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="\(.*\)"/EMERGE_DEFAULT_OPTS="\1 -G"/' /etc/portage/make.conf
			sudo sed -i 's/^#ACCEPT_KEYWORDS="\*\*"/ACCEPT_KEYWORDS="\*\*"/' /etc/portage/make.conf
			sudo sed -i 's/^#FETCHCOMMAND_HTTPS=/FETCHCOMMAND_HTTPS=/' /etc/portage/make.conf
			echo -e "\nemerge will now install from binary. (/etc/portage/make.conf)"
		fi
		;;

	6)
                wget "$gitprefix"/home/user/cloveros_settings.sh -O cloveros_settings.new.sh
		if [[ -s cloveros_settings.new.sh ]]; then
			chmod +x cloveros_settings.new.sh
			mv cloveros_settings.new.sh cloveros_settings.sh
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			exit 1
		fi
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 8)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .fvwm2rc .Xdefaults wallpaper.png .xbindkeysrc screenfetch-dev bl.sh stats.sh rotate_screen.sh .emacs .emacs.d .rtorrent.rc .mpv .config/nitrogen/ .config/spacefm .config/nomacs $backupdir/
		wget -q "$gitprefix"/home/user/{.bash_profile,.zprofile,.zshrc,.fvwm2rc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev bl.sh stats.sh rotate_screen.sh
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		mkdir -p .emacs.d/backups/ .emacs.d/autosaves/
		mkdir -p .config/nitrogen/
		wget -q "$gitprefix"/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
		sed -i "s@/home/user/@/home/$USER/@" .config/nitrogen/nitrogen.cfg
		mkdir -p .config/spacefm/
		wget -q "$gitprefix"/home/user/.config/spacefm/session -P .config/spacefm/
		sed -i "s@/home/user/@/home/$USER/@" .config/spacefm/session
		mkdir .config/nomacs/
		wget -q "$gitprefix/home/user/.config/nomacs/Image%20Lounge.conf"
		mkdir .mpv
		wget -q "$gitprefix"/home/user/.mpv/config -P .mpv/
		echo -e "\nConfiguration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/ (~)"
		;;

	7)
		sudo date +%s -s @$(curl -s http://www.convert-unix-time.com/ | grep "Seconds since" | sed -r 's/.*t=(.*)" id.*/\1/') > /dev/null
		echo -e "\nTime set."
		;;

	8)
		echo -e "Available timezones: $(find /usr/share/zoneinfo/ -type f | sed s@/usr/share/zoneinfo/@@ | sort | tr '\n' ' ') \n"
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
		echo "./cloveros_settings.sh 4"
		echo "sudo emerge --sync"
		echo "sudo emerge -uvD world"
		echo "sudo emerge @preserved-rebuild"
		echo "sudo emerge --depclean"
		echo 'sudo depmod "$kernelversion-gentoo"'
		echo "./cloveros_settings.sh 9"
		sleep 1
		./cloveros_settings.sh 1
		./cloveros_settings.sh zz
		;;

	zz)
		if ! grep -q 'EMERGE_DEFAULT_OPTS=".* -G"' /etc/portage/make.conf; then
			echo "Please enable binaries."
			exit 1
		fi

		sudo eselect profile set "default/linux/amd64/17.0/hardened"
		if [ -d /var/db/pkg/net-p2p/rtorrent-0.9.6-r1/ ]; then
			sudo emerge -C rtorrent
			sudo emerge rtorrent-ps
		fi

		binhostmirrors='binhost_mirrors="$PORTAGE_BINHOST,'
		for i in "${mirrors[@]}"
		do
		binhostmirrors+="$i,"
		done
		binhostmirrors+='"'
		if ! grep -q "^$binhostmirrors$" /etc/portage/make.conf; then
			sudo sed -i "s@^binhost_mirrors=.*@$binhostmirrors@" /etc/portage/make.conf
		fi

		./cloveros_settings.sh 4
		sudo emerge --sync
		sudo emerge -uvD world
		sudo emerge @preserved-rebuild
		sudo emerge --depclean
		sudo depmod "$kernelversion-gentoo"
		./cloveros_settings.sh 9
		;;

	l)
		if [[ $(find /boot/ -iname \*$kernelversion\*-gnu | wc -l) -gt 0 ]]; then
			echo "Kernel up to date."
		else
			tempdir=kernel$(< /dev/urandom tr -dc 0-9 | head -c 8)
			mkdir $tempdir
			cd $tempdir
			wget https://cloveros.ga/s/kernel-libre.tar.xz
			wget https://cloveros.ga/s/signatures/s/kernel-libre.tar.xz.asc
			if sudo gpg --verify kernel-libre.tar.xz.asc kernel-libre.tar.xz; then
				tar xf kernel-libre.tar.xz
				sudo mv initramfs-genkernel-*-gentoo*-gnu kernel-genkernel-*-gentoo*-gnu System.map-genkernel-*-gentoo*-gnu /boot/
				sudo cp -R *-gentoo*-gnu/ /lib/modules/
				sudo grub-mkconfig -o /boot/grub/grub.cfg
				echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
			else
				echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			fi
			cd ..
			rm -R $tempdir
		fi
		;;

	a)
		echo "1) Change default ALSA device
2) Change default sample rate
3) Bypass dmix (DSD, high sample rate)
4) Configure ALSA for OBS
5) GUI volume control
6) CLI volume control"
		read -erp "Select option: " -n 1 choicealsa
		echo
		case "$choicealsa" in
			1)
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device to become default: " -n 1 choiceaudio
				echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
				echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs. (~/.asoundrc)"
				;;

			2)
				echo "Sample rate examples: 44100 48000 96000 192000"
				read -erp "Select sample rate: " choicesamplerate
				if grep -q 'defaults.pcm.dmix.rate' ~/.asoundrc; then
					sed -i "s/defaults.pcm.dmix.rate .*/defaults.pcm.dmix.rate $choicesamplerate/" ~/.asoundrc
				else
					echo "defaults.pcm.dmix.rate $choicesamplerate" >> ~/.asoundrc
				fi
				echo -e "\nSample rate set to $choicesamplerate (~/.asoundrc)"
				;;

			3)
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device to become (hw) default: " -n 1 choiceaudio
				echo -e "pcm.!default {\n  type hw\n  card ${choiceaudio}\n}" > ~/.asoundrc
				echo -e "\nAudio device ${choiceaudio} is now the default (hw) for ALSA programs. Only one program will output audio. (~/.asoundrc)"
				;;
			4)
				echo -e "\nIn progress."
				;;

			5)
				qasmixer&
				;;

			6)
				alsamixer
				;;

			*)
				echo "Invalid option: '$choicealsa'" >&2
				exit 1
				;;
		esac
		;;

	t)
		if [ ! -s /usr/bin/xinput ]; then
			sudo emerge xinput
		fi
		tappingid=$(xinput list-props "SynPS/2 Synaptics TouchPad" | grep 'Tapping Enabled (' | awk '{print $4}' | grep -o "[0-9]\+")
		xinput set-prop "SynPS/2 Synaptics TouchPad" $tappingid 1
		echo -e "\nEnable Tap to Click: xinput set-prop \"SynPS/2 Synaptics TouchPad\" $tappingid 1"
		echo "Disable Tap to Click: xinput set-prop \"SynPS/2 Synaptics TouchPad\" $tappingid 0"
		;;

	b)
		echo "Running the following:"
		echo "sudo emerge blueman"
		echo "sudo /etc/init.d/bluetooth start"
		echo "sudo blueman-applet&"
		echo "sudo blueman-browse&"
		sleep 1
		sudo emerge blueman
		sudo /etc/init.d/bluetooth start
		sudo blueman-applet&
		sudo blueman-browse&
		;;

	i)
		echo "Running the following:"
		echo "./cloveros_settings.sh u"
		echo "sudo emerge virtualbox"
		echo "sudo depmod"
		echo 'sudo useradd -a $USER vboxusers'
		sleep 1
		./cloveros_settings.sh u
		sudo emerge virtualbox
		sudo depmod
		sudo useradd -g $USER vboxusers
		echo "Virtualbox installed, please reboot to update kernel."
		;;

	v)
		echo "Running the following:"
		echo "sudo emerge xf86-video-vmware virtualbox-guest-additions"
		sleep 1
		sudo emerge xf86-video-vmware virtualbox-guest-additions
		echo -e "\nRestart X to load driver."
		;;

	c)
		backupportagedir=backupportage$(< /dev/urandom tr -dc 0-9 | head -c 8)
		sudo mkdir ~/$backupportagedir
		sudo mv /etc/portage/package.use /etc/portage/package.mask /etc/portage/package.keywords /etc/portage/package.env /etc/portage/package.mask /etc/portage/package.license ~/$backupportagedir
		sudo wget $gitprefix/binhost_settings/etc/portage/package.use $gitprefix/binhost_settings/etc/portage/package.keywords $gitprefix/binhost_settings/etc/portage/package.env $gitprefix/binhost_settings/etc/portage/package.mask $gitprefix/binhost_settings/etc/portage/package.license -P /etc/portage/
		sudo rm -R /etc/portage/env/
		sudo mkdir /etc/portage/env/
		sudo wget $gitprefix/binhost_settings/etc/portage/env/no-lto $gitprefix/binhost_settings/etc/portage/env/no-lto-graphite $gitprefix/binhost_settings/etc/portage/env/no-lto-graphite-ofast $gitprefix/binhost_settings/etc/portage/env/no-lto-o3 $gitprefix/binhost_settings/etc/portage/env/no-lto-ofast $gitprefix/binhost_settings/etc/portage/env/no-o3 $gitprefix/binhost_settings/etc/portage/env/no-ofast $gitprefix/binhost_settings/etc/portage/env/size -P /etc/portage/env/
		useflags=$(curl -s $gitprefix/binhost_settings/etc/portage/make.conf | grep '^USE=')
		if ! grep -q "$useflags" /etc/portage/make.conf; then
			echo $useflags >> /etc/portage/make.conf
		fi
		echo -e "\nPortage configuration now mirrors binhost Portage configuration. Previous Portage config stored in ~/$backupportagedir"
		;;

	m)
		backupmakeconf="make.conf.bak"$(< /dev/urandom tr -dc 0-9 | head -c 8)
		sudo mv /etc/portage/make.conf $backupmakeconf
		sudo wget -q "$gitprefix"/home/user/make.conf -P /etc/portage/
		echo "/etc/portage/make.conf is now default Previous make.conf saved to $backupmakeconf"
		;;

	n)
		echo "Running the following:"
		echo "./cloveros_settings.sh 4"
		echo "sudo emerge nvidia-drivers"
		echo 'sudo depmod "$kernelversion-gentoo"'
		echo "sudo nvidia-xconfig"
		echo "sudo eselect opengl set nvidia"
		echo "sudo eselect opencl set nvidia"
		echo "sudo sh -c 'echo \"blacklist nouveau\" >> /etc/modprobe.d/blacklist.conf'"
		sleep 1
		./cloveros_settings.sh 4
		sudo emerge nvidia-drivers
		sudo depmod "$kernelversion-gentoo"
		sudo nvidia-xconfig
		sudo eselect opengl set nvidia
		sudo eselect opencl set nvidia
		sudo sh -c 'echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf'
		echo -e "\nNvidia drivers installed, please reboot.\nCheck https://wiki.gentoo.org/wiki/NVidia/nvidia-drivers for more info"
		;;

	g)
		echo "In progress. See https://gitgud.io/cloveros/cloveros/#nvidia-card-crashes-on-boot-with-a-green-screen"
		;;

	q)
		;;

	*)
		echo "Invalid option: '$choice'" >&2
		exit 1
		;;
esac
