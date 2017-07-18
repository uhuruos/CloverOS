#!/bin/sh
while :
do
topoutput=$(top -b -n2 | grep -v '    ' | tr '\n' ' ')
ifoutput=$(ifconfig wlp1s0 | tr '\n' ' ')
clr1="\033[0;37m"
clr2="\033[0;34m"
echo -e "
"$clr1"$(uname -sr) 
"$clr1"Up:"$clr2" $(echo $topoutput | awk -O '{print $3}') 
"$clr1"Proc:"$clr2" $(echo $topoutput | awk -O '{print $14 - 3}') 
"$clr1"Active:"$clr2" $(echo $topoutput | awk -O '{print $16}') 
"$clr1"Cpu:"$clr2" $(echo $topoutput | awk -O '{print 100 - $82}')% 
"$clr1"Mem:"$clr2" $(echo $topoutput | awk -O '{print $48}') MiB / $(echo $topoutput | awk -O '{print substr($44 / 1048576, 1, 4)}') GiB 
"$clr1"Net in:"$clr2" $(echo $ifoutput | awk -O '{print $26 / 1048576}') MiB 
"$clr1"Net out:"$clr2" $(echo $ifoutput | awk -O '{print $42 / 1048576}') MiB 
"$clr1"Battery: "$clr2"$(cat /sys/class/power_supply/BAT0/capacity)% 
"$clr1"Brightness:"$clr2" $(awk "BEGIN{print $(cat /sys/class/backlight/*/actual_brightness) / $(cat /sys/class/backlight/*/max_brightness) * 100}")% 
"$clr1"Volume:"$clr2" $(amixer | tr '\n' ' ' | awk -F '[][]' '{print $2}') 
"$clr1"$(date) 
\r" | tr -d '\n'
done
