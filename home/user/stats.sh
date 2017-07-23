#!/bin/bash
tput civis
enable -f sleep sleep
cpulasttotal=0
cpulastidle=0
if [ -f ~/.asoundrc ]; then
    read -r alsadevice < ~/.asoundrc
    alsadevice=${alsadevice/defaults.pcm.card /}
    if [ $alsadevice -eq $alsadevice ] 2>/dev/null; then
        :
    else
        alsadevice=0
    fi
else
    alsadevice=0
fi
i=0
while read line; do
    if [[ $line == "Amp-Out vals:  "* ]]; then
        alsaline=$i
        break
    fi
((i++))
done < /proc/asound/card$alsadevice/codec#0

while :
do
system=$(</proc/version)
system=${system%% (*}
system=${system/ version/}

uptime=$(</proc/uptime)
uptime=${uptime%%.*}
hrs=$((uptime/3600))
min=$((uptime/60%60))
if [ ${#min} -eq 1 ]; then
    min=0$min
fi
uptime="$hrs:$min"

processes=()
for line in /proc/*[0-9]; do
    processes+=($line)
done
processes=${#processes[@]}

mapfile -t procstat < /proc/stat
activeprocesses=${procstat[-3]}
activeprocesses=${activeprocesses:13}

IFS=' ' read -ra cpustats <<< ${procstat[0]}
cpustats=("${cpustats[@]:1}")
cpuidle=${cpustats[3]}
cputotal=0
for i in "${cpustats[@]}"; do
    cputotal=$(($cputotal+$i))
done
cpuusage=$(((1000*(($cputotal-$cpulasttotal)-($cpuidle-$cpulastidle))/($cputotal-$cpulasttotal)+5)/10))%
cpulasttotal=$cputotal
cpulastidle=$cpuidle

mapfile -t meminfo < /proc/meminfo
memtotal=${meminfo[0]}
memtotal=${memtotal#* }
memtotal=${memtotal/ kB/}
memory[0]=${meminfo[1]} #memfree
memory[1]=${meminfo[3]} #buffers
memory[2]=${meminfo[4]} #cached
memory[3]=${meminfo[20]} #shmem
memory[4]=${meminfo[22]} #sreclaimable
memused=$memtotal
for line in "${memory[@]}"; do
    line=${line#* }
    line=${line/ kB/}
    memused=$(($memused-$line))
done
meminfo=$(($memused/1024))\ MiB\ \/\ $(($memtotal/1024))\ MiB

mapfile -t netdev < /proc/net/dev
netdev=${netdev[-1]}
IFS=' ' read -ra netdev <<< ${netdev}
netin=$((${netdev[1]}/1048576))\ MiB
netout=$((${netdev[9]}/1048576))\ MiB

mapfile -t asound < /proc/asound/card$alsadevice/codec#0
volume=${asound[$alsaline]}
volume=${volume:20:2}
volume=$((16#$volume))%

battery=$(</sys/class/power_supply/BAT0/capacity)%

brightness=$(($(</sys/class/backlight/*/actual_brightness)*100/$(</sys/class/backlight/*/max_brightness)))%

mapfile -t signal -ra signal < /proc/net/wireless
signal=${signal[2]}
IFS=' ' read -ra signal <<< $signal
signal=${signal[2]}
signal=${signal:0:-1}
signal=$((signal*100/70))%

date=$(printf '%(%c)T')

clr1="\e[37m"
clr2="\e[32m"

echo -e "
$clr1 $system
$clr1 Up:$clr2 $uptime
$clr1 Proc:$clr2 $processes
$clr1 Active:$clr2 $activeprocesses
$clr1 Cpu:$clr2 $cpuusage
$clr1 Mem:$clr2 $meminfo
$clr1 Net in:$clr2 $netin
$clr1 Net out:$clr2 $netout
$clr1 Battery:$clr2 $battery
$clr1 Brightness:$clr2 $brightness
$clr1 Volume:$clr2 $volume
$clr1 Wifi:$clr2 $signal
$clr1 $date
       	\r" | tr -d '\n'
sleep 2
done
