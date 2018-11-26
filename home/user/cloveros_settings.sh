#!/bin/bash
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
2) Update system
3) Change default sound device
4) Update kernel
5) Change emerge to source/binary
6) Revert to default dot files
7) Sync time
8) Set timezone
9) Clean emerge cache
a) ALSA settings configuration
l) Update libre kernel
k) Delete all kernels except for $(uname -r)
t) Enable tap to click on touchpad
d) Disable mouse acceleration
c) Update Portage config from binhost
m) Revert to default /etc/portage/make.conf
b) Install Bluetooth manager
i) Install VirtualBox
v) Install Virtualbox/VMWare drivers
s) Install and add dnscrypt-proxy to startup
n) Install proprietary Nvidia drivers"
	read -erp "Select option: " -n 1 choice
	echo
fi

case "$choice" in
	1)
		wget $gitprefix/home/user/cloveros_settings.sh -O cloveros_settings.new.sh
		if [[ -s cloveros_settings.new.sh ]]; then
			mv cloveros_settings.new.sh cloveros_settings.sh
			chmod +x cloveros_settings.sh
			echo -e "\ncloveros_settings.sh is now updated. (~/cloveros_settings.sh)"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			exit 1
		fi
		;;

	2|u)
		echo "Running the following:"
		echo "./cloveros_settings.sh 1"
		echo "./cloveros_settings.sh 4"
		echo "sudo emerge --sync"
		echo "sudo emerge -uvD @world"
		echo "sudo emerge --depclean"
		echo "./cloveros_settings.sh 9"
		sleep 2
		./cloveros_settings.sh 1 || exit 1;
		./cloveros_settings.sh zz
		;;

	zz)
		if ! grep -q 'EMERGE_DEFAULT_OPTS=".* -G"' /etc/portage/make.conf; then
			echo "Please enable binaries."
			exit 1
		fi

		if [ -d /var/db/pkg/net-p2p/rtorrent-ps-9999/ ]; then
			sudo emerge -C rtorrent-ps
			sudo emerge rtorrent
			sudo emerge -1 portage
		fi
		if [ -d /var/db/pkg/net-wireless/rfkill-*/ ]; then
			sudo emerge -C rfkill
			sudo emerge -1 portage
		fi

		sudo rm /usr/portage/packages/Packages &> /dev/null

		kernel=$(uname -r)
		if [[ ${kernel: -3} == "gnu" ]]; then
			./cloveros_settings.sh l
		else
			./cloveros_settings.sh 4
		fi

		sudo emerge --sync
		sudo emerge -uvD @world
		sudo emerge --depclean
		./cloveros_settings.sh 9

		sudo sh -c 'PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1 glib && emerge --depclean' &> /dev/null &
		sudo sh -c 'PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1 qtgui && emerge --depclean' &> /dev/null &
		sudo sh -c 'PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1 PyQt5 && emerge --depclean' &> /dev/null &
		sudo sh -c 'PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1 thunar && emerge --depclean' &> /dev/null &
		wait

		echo -e "\nSystem updated."
		;;

	3)
		grep " \[" /proc/asound/cards
		read -erp "Select the audio device to become default: " -n 1 choiceaudio
		echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
		echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs. (~/.asoundrc)"
		;;

	4)
		kernelversion=$(curl -sr 0-100 https://cloveros.ga/s/kernel.tar.xz | grep -aoP "(?<=x86_64-).*(?=-gentoo)")
		if ls /boot/ | grep -q $kernelversion; then
			echo "Kernel up to date."
		else
			rm kernel.tar.xz kernel.tar.xz.asc &> /dev/null
			wget https://cloveros.ga/s/kernel.tar.xz https://cloveros.ga/s/signatures/s/kernel.tar.xz.asc
			if sudo gpg --verify kernel.tar.xz.asc kernel.tar.xz; then
				sudo tar -C / -xf kernel.tar.xz
				sudo grub-mkconfig -o /boot/grub/grub.cfg
				sudo emerge @module-rebuild
				sudo depmod -a $kernelversion-gentoo
				echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
			else
				echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			fi
			rm kernel.tar.xz kernel.tar.xz.asc &> /dev/null
		fi
		;;

	5)
		if ! grep -q '#EMERGE_DEFAULT_OPTS=".* -G"' /etc/portage/make.conf; then
			sudo sed -ri 's/(EMERGE_DEFAULT_OPTS|PORTAGE_BINHOST|ACCEPT_LICENSE|ACCEPT_KEYWORDS|binhost_mirrors|FETCHCOMMAND_HTTPS.*)/#\1/' /etc/portage/make.conf
			echo -e "\nemerge will now install from source. (/etc/portage/make.conf)\nUse ./cloveros_settings.sh c to copy binhost Portage configuration"
		else
			sudo sed -ri 's/#(EMERGE_DEFAULT_OPTS|PORTAGE_BINHOST|ACCEPT_LICENSE|ACCEPT_KEYWORDS|binhost_mirrors|FETCHCOMMAND_HTTPS.*)/\1/' /etc/portage/make.conf
			echo -e "\nemerge will now install from binary. (/etc/portage/make.conf)"
		fi
		;;

	6)
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 8)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .fvwm2rc .Xdefaults wallpaper.png .xbindkeysrc screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh .emacs .emacs.d/ .rtorrent.rc .mpv .config/nitrogen/ .config/spacefm/ .config/mimeapps.list .local/share/nomacs/ $backupdir/
		wget $gitprefix/home/user/{.bash_profile,.zprofile,.zshrc,.fvwm2rc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh
		mkdir -p .emacs.d/backups/ .emacs.d/autosaves/ Downloads/ .rtorrent/ .mpv/ .config/spacefm/ .config/nitrogen/ .local/share/nomacs/ Desktop/
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		wget $gitprefix/home/user/.mpv/config -P .mpv/
		wget $gitprefix/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
		sed -i "s@/home/user/@/home/$USER/@" .config/nitrogen/nitrogen.cfg
		wget $gitprefix/home/user/.local/share/nomacs/settings.ini -P .local/share/nomacs/
		wget $gitprefix/home/user/.config/spacefm/session -P .config/spacefm/
		sed -i "s@/home/user/@/home/$USER/@" .config/spacefm/session
		wget $gitprefix/home/user/.config/mimeapps.list -P .config/
		echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Home\nIcon=user-home\nExec=spacefm ~/" > Desktop/home.desktop
		echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Applications\nIcon=folder\nExec=spacefm /usr/share/applications/" > Desktop/applications.desktop
		cp /usr/share/applications/{firefox.desktop,smplayer.desktop,emacs.desktop,zzz-gimp.desktop,porthole.desktop,xarchiver.desktop} Desktop/
		echo -e "~rows=0\n1=home.desktop\n2=applications.desktop\n3=firefox.desktop\n4=smplayer.desktop\n5=emacs.desktop\n6=porthole.desktop\n7=zzz-gimp.desktop\n8=xarchiver.desktop" > .config/spacefm/desktop0
		echo -e "\nConfiguration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/ (~)"
		./cloveros_settings.sh 1
		;;

	7)
		sudo date +%s -s @$(curl -s http://www.4webhelp.net/us/timestamp.php | grep -oP '(?<=p" value=").*(?=" s)')
		echo -e "\nTime set."
		;;

	8)
		echo -e "Available timezones: $(find /usr/share/zoneinfo/ -type f | sed s@/usr/share/zoneinfo/@@ | sort | tr "\n" " ") \n"
		read -erp "Select a timezone: " timezone
		sudo cp /usr/share/zoneinfo/${timezone} /etc/localtime
		echo -e "\nTimezone set to ${timezone}. (/etc/localtime)"
		;;

	9)
		sudo rm -Rf /usr/portage/packages/* /usr/portage/distfiles/* /var/tmp/portage/*
		echo -e "\nPackage cache cleared. (/usr/portage/packages/, /usr/portage/distfiles/, /var/tmp/portage/)"
		;;

	a)
		echo "1) Change default ALSA playback device
2) Change default ALSA capture device
3) Change default ALSA playback device to a Bluetooth device
4) Set sample rate
5) Bypass dmix and use hw (DSD, high sample rate)
6) Configure ALSA for OBS
7) GUI volume control
8) CLI volume control"
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
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device to become default for playback: " -n 1 choiceaudio
				read -erp "Select the audio device to become default for capture: " -n 1 choicecapture
				echo -e "pcm.!default {\n    type asym\n    playback.pcm \"plughw:${choiceaudio}\"\n    capture.pcm  \"plughw:${choicecapture}\"\n}" > ~/.asoundrc
				echo -e "\nPlayback device ${choiceaudio} and capture device ${choicecapture} are now default for ALSA programs. (~/.asoundrc)"
				;;

			3)
				echo "First pair the Bluetooth device with blueman-manager."
				read -erp "Specify the Bluetooth address: " -i 00:00:00:00:00:00 bluetoothaddress
				echo -e "pcm.!default {\n	type bluealsa\n	device \"${bluetoothaddress}\"\n	profile "a2dp"\n}" > ~/.asoundrc
				echo -e "\nAudio device ${bluetoothaddress} is now the default for ALSA programs. (~/.asoundrc)"
				;;

			4)
				echo "Sample rate examples: 44100 48000 96000 192000"
				read -erp "Select sample rate: " choicesamplerate
				if grep -q "defaults.pcm.dmix.rate" ~/.asoundrc; then
					sed -i "s/defaults.pcm.dmix.rate .*/defaults.pcm.dmix.rate $choicesamplerate/" ~/.asoundrc
				else
					echo "defaults.pcm.dmix.rate $choicesamplerate" >> ~/.asoundrc
				fi
				echo -e "\nSample rate set to $choicesamplerate (~/.asoundrc)"
				;;

			5)
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device (hw) to become default: " -n 1 choiceaudio
				echo -e "pcm.!default {\n  type hw\n  card ${choiceaudio}\n}" > ~/.asoundrc
				echo -e "\nAudio device ${choiceaudio} (hw) is now the default for ALSA programs. Only one program will output audio. (~/.asoundrc)"
				;;
			6)
				echo -e "\nIn progress."
				;;

			7)
				qasmixer&
				;;

			8)
				alsamixer
				;;

			*)
				echo "Invalid option: $choicealsa"
				;;
		esac
		;;

	l)
		kernelversion=$(curl -sr 0-100 https://cloveros.ga/s/kernel-libre.tar.xz | grep -aoP "(?<=x86_64-).*(?=-gentoo)")
		if ls /boot/ | grep -q $kernelversion-gentoo-gnu; then
			echo "Kernel up to date."
		else
			rm kernel-libre.tar.xz kernel-libre.tar.xz.asc &> /dev/null
			wget https://cloveros.ga/s/kernel-libre.tar.xz https://cloveros.ga/s/signatures/s/kernel-libre.tar.xz.asc
			if sudo gpg --verify kernel-libre.tar.xz.asc kernel-libre.tar.xz; then
				sudo tar -C / -xf kernel-libre.tar.xz
				sudo grub-mkconfig -o /boot/grub/grub.cfg
				sudo emerge @module-rebuild
				sudo depmod -a $kernelversion-gentoo-gnu
				echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
			else
				echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			fi
			rm kernel-libre.tar.xz kernel-libre.tar.xz.asc &> /dev/null
		fi
		;;

	k)
		sudo find /boot/ /lib/modules/ -mindepth 1 -maxdepth 1 -name \*gentoo\* ! -name \*$(uname -r) -exec rm -R {} \;
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo "All kernels except for $(uname -r) deleted."
		;;

	t)
		xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1
		echo "Tap to click enabled. (xinput set-prop \"SynPS/2 Synaptics TouchPad\" \"libinput Tapping Enabled\" 0)"
		;;

	d)
		for i in {0..99}; do
			xinput set-prop $i "libinput Accel Profile Enabled" 0 1 &> /dev/null
		done
		echo -e "\nMouse acceleration disabled. (xinput set-prop \"Your Device\" \"libinput Accel Profile Enabled\" 0 1)"
		;;

	c)
		portageworkdir=portageworkdir$(< /dev/urandom tr -dc 0-9 | head -c 8)
		mkdir -p $portageworkdir/env/
		wget $gitprefix/binhost_settings/etc/portage/{package.use,package.keywords,package.env,package.mask,package.unmask} -P $portageworkdir/
		wget $gitprefix/binhost_settings/etc/portage/env/{no-lto,no-lto-graphite,no-lto-graphite-ofast,no-lto-o3,no-lto-ofast,no-o3,no-ofast,no-gold,size,pcsx2} -P $portageworkdir/env/
		if [[ $(find $portageworkdir -type f | wc -l) == "15" ]]; then
			backupportagedir=backupportage$(< /dev/urandom tr -dc 0-9 | head -c 8)
			mkdir $backupportagedir
			sudo mv /etc/portage/package.use /etc/portage/package.mask /etc/portage/package.keywords /etc/portage/package.env /etc/portage/package.unmask /etc/portage/env/ $backupportagedir
			sudo mv $portageworkdir/* /etc/portage/
			useflags=$(curl -s $gitprefix/binhost_settings/etc/portage/make.conf | grep "^USE=")
			if ! grep -q "$useflags" /etc/portage/make.conf; then
				echo $useflags | sudo tee --append /etc/portage/make.conf > /dev/null
			fi
			echo -e "\nPortage configuration now mirrors binhost Portage configuration. Previous Portage config stored in ~/$backupportagedir"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
		fi
		rm -R $portageworkdir
		;;

	m)
		sudo wget -q $gitprefix/home/user/make.conf -O make.conf.new
		if [[ -s make.conf.new ]]; then
			backupmakeconf="make.conf.bak"$(< /dev/urandom tr -dc 0-9 | head -c 8)
			sudo mv /etc/portage/make.conf $backupmakeconf
			sudo mv make.conf.new /etc/portage/make.conf
			echo "/etc/portage/make.conf is now default Previous make.conf saved to $backupmakeconf"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
		fi
		;;

	b)
		echo "Running the following:"
		echo "sudo emerge blueman bluez-alsa"
		echo 'sudo usermod -aG plugdev $USER'
		echo "sudo /etc/init.d/bluetooth start"
		echo "sudo /etc/init.d/bluealsa start"
		echo "blueman-manager &"
		sleep 2
		sudo emerge blueman bluez-alsa
		sudo usermod -aG plugdev $USER
		sudo /etc/init.d/bluetooth start
		sudo /etc/init.d/bluealsa start
		blueman-manager &
		echo "blueman installed. To have it automatically start on boot, run: sudo rc-config add bluetooth & sudo rc-config add bluealsa"
		;;

	i)
		echo "Running the following:"
		echo "sudo emerge virtualbox"
		echo "./cloveros_settings.sh 4"
		echo "sudo useradd -a $USER vboxusers"
		echo "sudo modprobe -a vboxdrv vboxnetadp vboxnetflt"
		sleep 2
		sudo emerge virtualbox
		./cloveros_settings.sh 4
		sudo useradd -g $USER vboxusers
		sudo modprobe -a vboxdrv vboxnetadp vboxnetflt
		echo "Virtualbox installed, please reboot to update kernel."
		;;

	v)
		echo "Running the following:"
		echo "sudo emerge xf86-video-vmware virtualbox-guest-additions"
		sleep 2
		sudo emerge xf86-video-vmware virtualbox-guest-additions
		echo -e "\nRestart X to load driver."
		;;

	s)
		echo "Running the following:"
		echo "sudo emerge dnscrypt-proxy"
		echo "sudo /etc/init.d/dnscrypt-proxy start"
		echo "sudo rc-config add dnscrypt-proxy"
		echo "sudo sh -c 'echo \"static domain_name_servers=127.0.0.1\" >> /etc/dhcpcd.conf'"
		echo "sudo /etc/init.d/dhcpcd restart"
		sleep 2
		sudo emerge dnscrypt-proxy
		sudo /etc/init.d/dnscrypt-proxy start
		sudo rc-config add dnscrypt-proxy
		sudo sh -c 'echo "static domain_name_servers=127.0.0.1" >> /etc/dhcpcd.conf'
		sudo /etc/init.d/dhcpcd restart
		;;

	n)
		echo "Running the following:"
		echo "sudo emerge nvidia-drivers"
		echo "./cloveros_settings.sh 4"
		echo "sudo eselect opengl set nvidia"
		echo "sudo eselect opencl set nvidia"
		echo "sudo sh -c 'echo -e \"blacklist nouveau\nblacklist vga16fb\nblacklist rivafb\nblacklist nvidiafb\nblacklist rivatv\" >> /etc/modprobe.d/blacklist.conf'"
		sleep 2
		sudo emerge nvidia-drivers
		./cloveros_settings.sh 4
		sudo eselect opengl set nvidia
		sudo eselect opencl set nvidia
		sudo sh -c 'echo -e "blacklist nouveau\nblacklist vga16fb\nblacklist rivafb\nblacklist nvidiafb\nblacklist rivatv" >> /etc/modprobe.d/blacklist.conf'
		echo -e "\nNvidia drivers installed, please reboot.\nCheck https://wiki.gentoo.org/wiki/NVidia/nvidia-drivers for more info"
		;;

	*)
		echo "Invalid option: $choice"
		;;
esac
