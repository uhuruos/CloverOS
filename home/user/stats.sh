#!/bin/bash
while :
do
IFS=$'\n' read -d '' -ra toparray <<< "$(top -b -n2 | grep -E '(top - |Tasks: |Cpu\(s\)|KiB Mem|KiB Swap)')"
IFS=' ' read -ra topline1 <<< ${toparray[0]}
IFS=' ' read -ra topline2 <<< ${toparray[1]}
IFS=' ' read -ra topline3 <<< ${toparray[7]}
IFS=' ' read -ra topline4 <<< ${toparray[3]}
IFS=' ' read -ra topline5 <<< ${toparray[4]}
uptime=${topline1[4]}
brightness=$(bc -l <<< $(cat /sys/class/backlight/*/actual_brightness)/$(cat /sys/class/backlight/*/max_brightness)*100)
IFS=' ' read -d '' -r -a alsasound <<< $(amixer sget Master | grep 'Mono: ')
clr1="\e[37m"
clr2="\e[32m"
echo -e "
$(uname -sr)
$clr1 Up:$clr2 ${uptime:0:-1}
$clr1 Proc:$clr2 ${topline2[1]}
$clr1 Active:$clr2 ${topline2[3]}
$clr1 Cpu:$clr2 $(bc <<< 100-${topline3[7]})%
$clr1 Mem:$clr2 $((${topline4[7]} / 1024)) MiB / $((${topline4[3]} / 1024)) MiB
$clr1 Net in:$clr2 $(netstat -ei | grep 'RX packets' | awk '{sum += $5} END {print int(sum / 1048576)}') MiB
$clr1 Net out:$clr2 $(netstat -ei | grep 'TX packets' | awk '{sum += $5} END {print int(sum / 1048576)}') MiB
$clr1 Battery:$clr2 $(</sys/class/power_supply/BAT0/capacity)%
$clr1 Brightness:$clr2 ${brightness:0:5}%
$clr1 Volume:$clr2 ${alsasound[2]}
$clr1 Wifi:$clr2 $(tail -n1 /proc/net/wireless  | awk '{ print int($3 * 100 / 70) }')%
$clr1 $(date '+%c')
        \r" | tr -d '\n'
tput civis
done
