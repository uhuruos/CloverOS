#!/usr/bin/sudo /bin/bash

# This software is released into the public domain.
# It is provided "as is", without warranties or conditions of any kind.
# Anyone is free to use, modify, redistribute and do anything with this software.

echo "1) Change Mirrors
2) Change default alsa device
3) Upgrade kernel"

read -p "Select option: " -n 1 choice
echo
if [[ $choice = "1" ]]; then
   mirrors=("useast.cloveros.ga" "uswest.cloveros.ga" "fr.cloveros.ga")
    i=1
    while [[ $i -le ${#mirrors[@]} ]]; do
        echo "$i) ${mirrors[$i-1]}"
        let i=i+1
    done
    read -p "Select mirror: " -n 1 choicemirror
    sed -i "s@PORTAGE_BINHOST=\".*\"@PORTAGE_BINHOST=\"https://${mirrors[$choicemirror-1]}\"@" /etc/portage/make.conf
    echo
    echo "Mirror changed to: ${mirrors[$choicemirror-1]}"
    exit 0
elif [[ $choice = "2" ]]; then
echo
elif [[ $choice = "3" ]]; then
    wget -O - https://raw.githubusercontent.com/chiru-no/cloveros/master/kernel.tar.xz | tar xJ -C /boot/
    wget -O - https://raw.githubusercontent.com/chiru-no/cloveros/master/modules.tar.xz | tar xJ -C /lib/modules/
    grub-mkconfig > /boot/grub/grub.cfg
    echo "Kernel updated."
exit 0
else
    echo "Invalid option."
    exit 1
fi

