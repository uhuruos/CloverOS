echo "
$(uname -sr) 
$(uptime -p) 
Proc: $(ps ax | wc -l) 
Cpu: $(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage "%"}') 
Mem: $(cat /proc/meminfo | grep Avail | awk -F ' ' '{print $2 / 1024}') MB 
Battery: $(cat /sys/class/power_supply/BAT0/capacity)% 
Brightness: $(awk "BEGIN{print $(cat /sys/class/backlight/*/actual_brightness)/$(cat /sys/class/backlight/*/max_brightness) * 100}")% 
"| tr -d "\n"
