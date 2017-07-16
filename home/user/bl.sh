#!/bin/sh

set -e

if [ -n "$BACKLIGHT" ]; then
	bldir="/sys/class/backlight/$BACKLIGHT"
else
	for f in /sys/class/backlight/*; do
		if [ -n "$bldir" ]; then
			echo "too many backlights found, choose one with \$BACKLIGHT" >&2
			exit 1
		fi
		bldir="$f"
	done
fi
if [ -z "$bldir" ] || ! [ -d "$bldir" ]; then
	echo "no backlight found" >&1
	exit 1
fi
curr=$(($(cat "$bldir/brightness")+0))
max=$(($(cat "$bldir/max_brightness")+0))
mod="$1"
case "$mod" in
	+|-)
		new="$((curr${mod}max/100))"
		;;
	+[1-9]*|-[1-9]*)
		new="$((curr$mod*max/100))"
		;;
	[0-9]*)
		new="$((mod*max/100+1))"
		;;
	=[0-9]*)
		new="${mod#=*}"
		;;
	=)
		echo "$curr"
		exit
		;;
	'')
		echo "$((curr*100/max))"
		exit
		;;
	*)
		echo "usage: $(basename "$0") [ +-=][0-100]" >&2
		exit 2
		;;
esac
[ "$new" -gt "$max" ] && new="$max"
[ "$new" -lt 1 ] && new=1
echo "$new" > "$bldir/brightness"
