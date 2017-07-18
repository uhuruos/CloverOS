#!/bin/bash

mirrors=(
	"useast.cloveros.ga"
	"uswest.cloveros.ga"
	"fr.cloveros.ga"
	"uk.cloveros.ga"
)

fileprefix="https://raw.githubusercontent.com/chiru-no/cloveros/master/home/user"

echo "1) Change mirrors
2) Change default alsa device
3) Upgrade kernel
4) Change binary/source
5) Update dotfiles
6) Sync time
7) Set timezone
8) Clean binary cache
9) Disable/enable package signing validation
0) Update cloveros_settings.sh"

read -erp "Select option: " -n 1 choice
echo
case "$choice" in
	1)
		for i in "${!mirrors[@]}"; do
			echo "$((i+1))) ${mirrors[i]}"
		done
		read -erp "Select mirror: " -n 1 choicemirror
		sudo sed -i "s@PORTAGE_BINHOST=\".*\"@PORTAGE_BINHOST=\"https://${mirrors[$choicemirror-1]}\"@" /etc/portage/make.conf
		echo -e "\nMirror changed to: ${mirrors[choicemirror-1]}."
		;;

	2)
		grep " \[" /proc/asound/cards
		read -erp "Select the audio device to become default: " -n 1 choiceaudio
		echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
		echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs."
		;;

	3)
		wget -O - https://cloveros.ga/s/kernel.tar.xz | sudo tar xJ -C /boot/
		wget -O - https://cloveros.ga/s/modules.tar.xz | sudo tar xJ -C /lib/modules/
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo -e "\nKernel upgraded."
		;;

	4)
		if grep -q 'EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"' /etc/portage/make.conf; then
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/' /etc/portage/make.conf
			echo -e "\nemerge will now install from source."
		else
			sudo sed -i 's/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2"/EMERGE_DEFAULT_OPTS="--keep-going=y --autounmask-write=y --jobs=2 -G"/' /etc/portage/make.conf
			echo -e "\nemerge will now install from binary."
		fi
		;;

	5)
		cd ~
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 5)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .twmrc .Xdefaults wallpaper.png .xbindkeysrc screenfetch-dev bl.sh cloveros_settings.sh stats.sh .emacs .emacs.d .twm .rtorrent.rc .mpv .config/xfe/ $backupdir/
		wget -q "$fileprefix"/{.bash_profile,.zprofile,.zshrc,.twmrc,.Xdefaults,wallpaper.png,.xbindkeysrc,screenfetch-dev,bl.sh,cloveros_settings.sh,stats.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev bl.sh cloveros_settings.sh stats.sh
		mkdir -p .emacs.d/backups
		mkdir .emacs.d/autosaves
		mkdir .twm
		wget -q "$fileprefix"/.twm/{minimize.xbm,maximize.xbm,close.xbm} -P .twm
		mkdir -p .config/xfe/
		wget -q "$fileprefix"/.config/xfe/xferc -P .config/xfe
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		mkdir .mpv
		wget -q "$fileprefix"/.mpv/config -P .mpv
		echo -e "\nConfiguration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/"
		;;

	6)
		if ! type /usr/sbin/ntpdate > /dev/null; then
			sudo emerge ntp
		fi
		sudo ntpdate pool.ntp.org
		echo -e "\nTime synced."
		;;

	7)
		echo -e "Available timezones: $(ls -1 /usr/share/zoneinfo/ | tr "\n" " ") \n"
		read -erp "Select a timezone: " timezone
		sudo cp /usr/share/zoneinfo/${timezone} /etc/localtime
		echo -e "\nTimezone set to ${timezone}."
		;;

	8)
		sudo rm -Rf /usr/portage/packages/* /tmp/curlcache/*
		echo -e "\nPackage cache cleared."
		;;

	9)
		if ! grep -Fq 'FETCHCOMMAND_HTTPS="/home/'$USER'/curlcache.sh \"\${URI}\" \"\${DISTDIR}/\${FILE}\""' /etc/portage/make.conf; then
			if ! type /usr/bin/gpg > /dev/null; then
				sudo emerge gnupg
			fi
			if ! sudo gpg --list-keys "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"; then
				sudo gpg --keyserver keys.gnupg.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"
			fi
			echo 'FETCHCOMMAND_HTTPS="/home/'$USER'/curlcache.sh \"\${URI}\" \"\${DISTDIR}/\${FILE}\""' | sudo tee -a /etc/portage/make.conf
			wget "$fileprefix"/curlcache.sh -O ~/curlcache.sh
			chmod +x ~/curlcache.sh
			echo -e "\nPackage validation enabled."
		else
			sudo sed -i '/FETCHCOMMAND_HTTPS/d' /etc/portage/make.conf
			echo -e "\nPackage validation disabled."
		fi
		;;

	0)
		cd ~
		rm cloveros_settings.sh
		wget "$fileprefix"/cloveros_settings.sh
		chmod +x cloveros_settings.sh
		echo -e "\ncloveros_settings.sh is now updated."
		;;

	*)
		echo "Invalid option: '$choice'" >&2
		exit 1
		;;
esac
