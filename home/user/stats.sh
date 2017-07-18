#!/bin/sh
while :
do
topoutput=$(top -b -n2 | grep -E '(load average|Tasks|Cpu|KiB Mem|KiB Swap)' | sed 's/ min//' | tr '\n' ' ')
clr1="\e[97"
clr2="\e[96"
echo -e "
"$clr1"$(uname -sr) 
"$clr1"Up:"$clr2" $(echo $topoutput | awk '{print substr($5, 1, length($5)-1)}') 
"$clr1"Proc:"$clr2" $(echo $topoutput | awk '{print $14 - 3}') 
"$clr1"Active:"$clr2" $(echo $topoutput | awk '{print $16}') 
"$clr1"Cpu:"$clr2" $(echo $topoutput | awk '{print 100 - $93}')% 
"$clr1"Mem:"$clr2" $(echo $topoutput | awk '{print int($48 / 1024)}') MiB / $(echo $topoutput | awk '{printf("%.2f\n", $44 / 1048576)}') GiB 
"$clr1"Net in:"$clr2" $(netstat -ei | grep 'RX packets' | awk '{sum += $5} END {print int(sum / 1048576)}') MiB 
"$clr1"Net out:"$clr2" $(netstat -ei | grep 'TX packets' | awk '{sum += $5} END {print int(sum / 1048576)}') MiB 
"$clr1"Battery: "$clr2"$(cat /sys/class/power_supply/BAT0/capacity)% 
"$clr1"Brightness:"$clr2" $(awk "BEGIN{print $(cat /sys/class/backlight/*/actual_brightness) / $(cat /sys/class/backlight/*/max_brightness) * 100}")% 
"$clr1"Volume:"$clr2" $(amixer | tr '\n' ' ' | awk -F '[][]' '{print $2}') 
"$clr1"$(date) 
    \r" | tr -d '\n'
tput civis
done
