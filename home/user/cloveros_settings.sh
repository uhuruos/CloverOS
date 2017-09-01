#!/bin/bash

mirrors=(
	"useast.cloveros.ga"
	"uswest.cloveros.ga"
	"fr.cloveros.ga"
	"uk.cloveros.ga"
	"nl.cloveros.ga"
)

gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"

echo "1) Enable/disable package signing validation
2) Change mirrors
3) Change default alsa device
4) Upgrade kernel
5) Change binary/source
6) Update dotfiles
7) Sync time
8) Set timezone
9) Clean binary cache
0) Update cloveros_settings.sh
t) Enable tap to click on touchpad
b) Install bluetooth manager
n) Install proprietary Nvidia drivers
v) Install Virtualbox/VMWare drivers"

read -erp "Select option: " -n 1 choice
echo

case "$choice" in
	1)
		if ! grep -Fq 'FETCHCOMMAND_HTTPS="/home/'$USER'/gpgvalidate.sh \"\${URI}\" \"\${DISTDIR}/\${FILE}\""' /etc/portage/make.conf; then
			if ! type /usr/bin/gpg > /dev/null; then
				sudo emerge gnupg
			fi
			if ! sudo gpg --list-keys "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"; then
				sudo gpg --keyserver keys.gnupg.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"
			fi
			echo 'FETCHCOMMAND_HTTPS="/home/'$USER'/gpgvalidate.sh \"\${URI}\" \"\${DISTDIR}/\${FILE}\""' | sudo tee -a /etc/portage/make.conf
			sudo wget "$gitprefix"/home/user/gpgvalidate.sh -O /home/$USER/gpgvalidate.sh
			sudo chmod +x /home/$USER/gpgvalidate.sh
			echo -e "\nPackage validation enabled. (/etc/portage/make.conf)"
		else
			sudo sed -i '/FETCHCOMMAND_HTTPS/d' /etc/portage/make.conf
			echo -e "\nPackage validation disabled. (/etc/portage/make.conf)"
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
		wget https://cloveros.ga/s/kernel.tar.xz
		wget https://cloveros.ga/s/signatures/s/kernel.tar.xz.asc
		sudo gpg --verify kernel.tar.xz.asc kernel.tar.xz
		tar xf kernel.tar.xz
		sudo mv initramfs-genkernel-*-gentoo kernel-genkernel-*-gentoo System.map-genkernel-*-gentoo /boot/
		sudo mv *-gentoo/ /lib/modules/
		rm kernel.tar.xz kernel.tar.xz.asc
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		sudo sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
		rm kernel.tar.xz kernel.tar.xz.asc modules.tar.xz modules.tar.xz.asc
		echo -e "\nKernel upgraded. (/boot/)"
		;;

	5)
		if grep -q 'EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"' /etc/portage/make.conf; then
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/' /etc/portage/make.conf
			echo -e "\nemerge will now install from source. (/etc/portage/make.conf)\n"
			read -erp "Copy over binhost build settings? (USE flags: /etc/portage/make.conf, /etc/portage/package.use/package.use) [y/n] " -n 1 binhostyn
			if [[ $binhostyn == "y" || $binhostyn == "Y" ]]; then
				sudo wget $gitprefix/binhost_settings/etc/portage/package.use -O /etc/portage/package.use/package.use
				sudo sh -c "curl -s $gitprefix/binhost_settings/etc/portage/make.conf | grep '^USE=' >> /etc/portage/make.conf"
				sudo sed -i 's/^ACCEPT_KEYWORDS="~amd64"/#ACCEPT_KEYWORDS="~amd64"/' /etc/portage/make.conf
			fi
		else
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/' /etc/portage/make.conf
			sudo sed -i 's/^#ACCEPT_KEYWORDS="~amd64"/ACCEPT_KEYWORDS="~amd64"/' /etc/portage/make.conf
			echo -e "\nemerge will now install from binary. (/etc/portage/make.conf)"
		fi
		;;

	6)
		cd ~
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 5)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .twmrc .Xdefaults wallpaper.png .xbindkeysrc screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh .emacs .emacs.d .twm .rtorrent.rc .mpv .config/xfe/ $backupdir/
		wget -q "$gitprefix"/home/user/{.bash_profile,.zprofile,.zshrc,.twmrc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev bl.sh cloveros_settings.sh stats.sh rotate_screen.sh
		mkdir -p .emacs.d/backups
		mkdir .emacs.d/autosaves
		mkdir .twm
		wget -q "$gitprefix"/home/user/.twm/{minimize.xbm,maximize.xbm,close.xbm} -P .twm
		mkdir -p .config/xfe/
		wget -q "$gitprefix"/home/user/.config/xfe/xferc -P .config/xfe
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		mkdir .mpv
		wget -q "$gitprefix"/home/user/.mpv/config -P .mpv
		echo -e "\nConfiguration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/ (~)"
		;;

	7)
		if ! type /usr/sbin/ntpdate > /dev/null; then
			sudo emerge ntp
		fi
		sudo ntpdate pool.ntp.org
		echo -e "\nTime synced."
		;;

	8)
		echo -e "Available timezones: $(ls -1 /usr/share/zoneinfo/ | tr "\n" " ") \n"
		read -erp "Select a timezone: " timezone
		sudo cp /usr/share/zoneinfo/${timezone} /etc/localtime
		echo -e "\nTimezone set to ${timezone}. (/etc/localtime)"
		;;

	9)
		sudo rm -Rf /usr/portage/packages/* /tmp/curlcache/* /usr/portage/distfiles/* /var/tmp/portage/*
		echo -e "\nPackage cache cleared. (/usr/portage/packages/, /tmp/curlcache/, /usr/portage/distfiles/, /var/tmp/portage/)"
		;;

	0)
		cd ~
		wget "$gitprefix"/home/user/cloveros_settings.sh -O cloveros_settings.new.sh
		if [ -f cloveros_settings.new.sh ]; then
			rm cloveros_settings.sh
			mv cloveros_settings.new.sh cloveros_settings.sh
			chmod +x cloveros_settings.sh
			echo -e "\ncloveros_settings.sh is now updated. (~/cloveros_settings.sh)"
		else
			echo -e "\nCould not retrieve file."
		fi
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
		echo "Running the following:"
		echo "emerge nvidia-drivers"
		echo "eselect opengl set nvidia"
		echo 'echo " Section "Device"
   Identifier  "nvidia"
   Driver      "nvidia"
 EndSection" > /etc/X11/xorg.conf.d/nvidia.conf'
		echo "echo blacklist nouveau >> /etc/modprobe.d/blacklist.conf"
		sudo emerge nvidia-drivers
		sudo eselect opengl set nvidia
		echo " Section "Device"
   Identifier  "nvidia"
   Driver      "nvidia"
 EndSection" | sudo tee -a /etc/X11/xorg.conf.d/nvidia.conf
		echo blacklist nouveau | sudo tee -a /etc/modprobe.d/blacklist.conf
		echo -e "\nNvidia drivers installed, restart X.\nCheck https://wiki.gentoo.org/wiki/NVidia/nvidia-drivers for more info"
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

	v)
		echo "Running the following:"
		echo "emerge xf86-video-vmware virtualbox-guest-additions"
		sudo emerge xf86-video-vmware virtualbox-guest-additions
		echo -e "\nRestart X to load driver."
		;;

	*)
		echo "Invalid option: '$choice'" >&2
		exit 1
		;;
esac
