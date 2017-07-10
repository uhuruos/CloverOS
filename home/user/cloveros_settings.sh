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
4) Change binary/source"

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
		wget -O - https://raw.githubusercontent.com/chiru-no/cloveros/master/kernel.tar.xz | sudo tar xJ -C /boot/
		wget -O - https://raw.githubusercontent.com/chiru-no/cloveros/master/modules.tar.xz | sudo tar xJ -C /lib/modules/
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		echo "Kernel updated."
		;;

	*)
		echo "Invalid option: '$choice'" >&2
		exit 1
		;;
esac
