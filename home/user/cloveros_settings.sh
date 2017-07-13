#!/bin/bash

# This software is released into the public domain.
# It is provided "as is", without warranties or conditions of any kind.
# Anyone is free to use, modify, redistribute and do anything with this software.

mirrors=(
	"useast.cloveros.ga"
	"uswest.cloveros.ga"
	"fr.cloveros.ga"
)

echo "1) Change Mirrors
2) Change default alsa device
3) Upgrade kernel
4) Change binary/source
5) Update dotfiles
6) Sync time
7) Set timezone
8) Clean binary cache"

read -erp "Select option: " -n 1 choice
echo
case "$choice" in
	1)
		for i in "${!mirrors[@]}"; do
			echo "$((i+1))) ${mirrors[i]}"
		done
		read -erp "Select mirror: " -n 1 choicemirror
		sudo sed -i "s@PORTAGE_BINHOST=\".*\"@PORTAGE_BINHOST=\"https://${mirrors[$choicemirror-1]}\"@" /etc/portage/make.conf
		echo
		echo "Mirror changed to: ${mirrors[choicemirror-1]}"
		;;

	2)
		grep " \[" /proc/asound/cards
		read -erp "Select the audio device to become default: " -n 1 choiceaudio
		echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
		;;

	3)
		wget -O - https://cloveros.ga/s/kernel.tar.xz | sudo tar xJ -C /boot/
		wget -O - https://cloveros.ga/s/modules.tar.xz | sudo tar xJ -C /lib/modules/
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo "Kernel upgraded."
		;;

	4)
		if grep -q 'EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"' /etc/portage/make.conf; then
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/' /etc/portage/make.conf
			echo "emerge will now install from source."
		else
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/' /etc/portage/make.conf
			echo "emerge will now install from binary."
		fi
		;;

	5)
		cd ~
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 5)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .twmrc .Xdefaults wallpaper.png .xbindkeysrc screenfetch-dev bl.sh cloveros_settings.sh .emacs .emacs.d .twm .rtorrent.rc .mpv .config/xfe/xferc backup/
		wget -q https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/{.bash_profile,.zprofile,.zshrc,.twmrc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,cloveros_settings.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev bl.sh cloveros_settings.sh
		mkdir -p .emacs.d/backups
		mkdir .emacs.d/autosaves
		mkdir .twm
		wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.twm/{minimize.xbm,maximize.xbm,close.xbm} -P .twm
		mkdir -p .config/xfe/
		wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.config/xfe/xferc -P .config/xfe
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		mkdir .mpv
		wget https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user/.mpv/config -P .mpv
		echo "Configuration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/"
		;;

	6)
		sudo ntpdate pool.ntp.org
		echo "Time synced."
		;;

	7)
		echo -e "Available timezones: $(ls -1 /usr/share/zoneinfo/ | tr "\n" " ") \n"
		read -erp "Select a timezone: " timezone
		sudo cp /usr/share/zoneinfo/${timezone} /etc/localtime
		echo "Timezone set to ${timezone}."
		;;

	8)
		rm -Rf /usr/portage/packages/*
		echo "Package cache cleared."
		;;

	*)
		echo "Invalid option: '$choice'" >&2
		exit 1
		;;
esac
