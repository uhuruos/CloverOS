#!/bin/bash
tput civis
while :
do
mapfile -t toparray <<< "$(top -b -n2 | grep -E '(top - |Tasks: |Cpu\(s\)|KiB Mem|KiB Swap)')"
mapfile -t volume <<< "$(amixer sget Master)"
IFS=' ' read -ra topline1 <<< ${toparray[0]}
IFS=' ' read -ra topline2 <<< ${toparray[1]}
IFS=' ' read -ra topline3 <<< ${toparray[7]}
IFS=' ' read -ra topline4 <<< ${toparray[3]}
IFS=' ' read -ra topline5 <<< ${toparray[4]}
uptime="${topline1[4]} ${topline1[5]}"
uptime=${uptime:0:-1}
uptime=${uptime%, }
cpuidle=${topline3[7]}
cpuidle=${cpuidle%.*}
mapfile -t netdev <<< "$(</proc/net/dev)"
netdev=${netdev[-1]}
IFS=' ' read -ra netdev <<< ${netdev}
volume=${volume[-1]}
IFS=' ' read -ra volume <<< ${volume}
volume=${volume[3]}
volume=${volume:1:${#volume}-2}
mapfile -t signal -ra signal <<< "$(</proc/net/wireless)"
signal=${signal[2]}
IFS=' ' read -ra signal <<< $signal
signal=${signal[2]}
signal=${signal:0:-1}
signal=$((signal*100/70))
clr1="\e[37m"
clr2="\e[32m"
echo -e "
$(uname -sr)
$clr1 Up:$clr2 $uptime
$clr1 Proc:$clr2 ${topline2[1]}
$clr1 Active:$clr2 ${topline2[3]}
$clr1 Cpu:$clr2 $((100-$cpuidle))%
$clr1 Mem:$clr2 $((${topline4[7]}/1024)) MiB / $((${topline4[3]}/1024)) MiB
$clr1 Net in:$clr2 $((${netdev[1]}/1048576)) MiB
$clr1 Net out:$clr2 $((${netdev[9]}/1048576)) MiB
$clr1 Volume:$clr2 $volume
$clr1 Battery:$clr2 $(</sys/class/power_supply/BAT0/capacity)%
$clr1 Brightness:$clr2 $(($(</sys/class/backlight/*/actual_brightness)*100/$(</sys/class/backlight/*/max_brightness)))%
$clr1 Wifi:$clr2 $signal%
$clr1 ${topline1[2]}
       	\r" | tr -d '\n'
done
