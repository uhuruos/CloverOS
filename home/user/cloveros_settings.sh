#!/usr/bin/sudo /bin/bash

# This software is released into the public domain.
# It is provided "as is", without warranties or conditions of any kind.
# Anyone is free to use, modify, redistribute and do anything with this software.

echo "1) Change Mirrors
2) Change default alsa device
3) Upgrade kernel"

read -erp "Select option: " -n 1 choice
echo
if [[ $choice = "1" ]]; then
   mirrors=("useast.cloveros.ga" "uswest.cloveros.ga" "fr.cloveros.ga")
    i=0
    for i in "${!mirrors[@]}"; do
        echo "$((i+1))) ${mirrors[$i]}"
    done
    read -erp "Select mirror: " -n 1 choicemirror
    choicemirror=$((choicemirror-1))
    sed -i "s@PORTAGE_BINHOST=\".*\"@PORTAGE_BINHOST=\"https://${mirrors[$choicemirror]}\"@" /etc/portage/make.conf
    echo
    echo "Mirror changed to: ${mirrors[$choicemirror]}"
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
