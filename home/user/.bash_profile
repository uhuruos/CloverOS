if [ -z "$DISPLAY" ] && ! pgrep X > /dev/null; then
	echo "WM Options: (y) Default (i) i3 (a) Awesome (o) Openbox (e) Enlightenment (k) KDE (m) MATE (x) XFCE (l) LXDE (q) LXQT (f) Fluxbox (d) dwm (c) IceWM (w) Window Maker (t) FVWM Themes (h) xmonad"
	read -erp "Start X? [y/n] " -n 1 choice
	declare -A wms
	declare -A wmspkg
	declare -A wmspost
	wms[y]=fvwm
	wms[Y]=fvwm
	wms[i]=i3
	wms[a]=awesome
	wms[o]=openbox
	wms[e]=enlightenment_start
	wms[k]=startkde
	wms[m]=mate-session
	wms[x]=startxfce4
	wms[l]=startlxde
	wms[q]=startlxqt
	wms[f]=fluxbox
	wms[d]=dwm
	wms[c]=icewm
	wms[w]=wmaker
	wms[t]=fvwm-themes-start
	wms[h]=xmonad
	wmpkgs[y]=fvwm
	wmspkg[Y]=fvwm
	wmspkg[i]="i3-gaps i3status"
	wmspkg[a]=awesome
	wmspkg[o]=openbox
	wmspkg[e]="enlightenment:0.17 terminology"
	wmspkg[k]="kdebase-meta gwenview"
	wmspkg[m]="mate engrampa pluma atril gnome-calculator caja-extensions mate-netbook mate-power-manager mate-screensaver mate-system-monitor mate-utils eom mate-netspeed"
	wmspkg[x]=xfce4-meta
	wmspkg[l]=lxde-meta
	wmspkg[q]=lxqt-meta
	wmspkg[f]=fluxbox
	wmspkg[d]=dwm
	wmspkg[c]=icewm
	wmspkg[w]=windowmaker
	wmspkg[t]=fvwm-themes
	wmspkg[h]=xmonad
	taptoclick=$'tappingid=$(xinput list-props "SynPS/2 Synaptics TouchPad" | grep \'Tapping Enabled (\' | awk \'{print $4}\' | grep -o \'[0-9]\\+\') && xinput set-prop "SynPS/2 Synaptics TouchPad" $tappingid 1'
	wmspost[y]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[Y]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[i]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[a]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[o]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[t]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[h]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[e]=""
	wmspost[k]=""
	wmspost[m]=""
	wmspost[x]=""
	wmspost[l]=""
	wmspost[q]=""
	wmspost[f]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[d]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[c]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"
	wmspost[w]="nitrogen --set-zoom wallpaper.png & xbindkeys & $taptoclick &"

	if [ -v wms[$choice] ]; then
		if [ ! -f /usr/bin/${wms[$choice]} ]; then
			echo
			echo ${wms[$choice]} is not installed. Install it by running:
			echo $ sudo emerge ${wmspkg[$choice]}
			read -erp "Install now? [y/n] " -n 1 installyn
			if [[ "$installyn" == "y" || "$installyn" == "Y" ]]; then
				sudo emerge -v ${wmspkg[$choice]}
				if [ -f /usr/bin/${wms[$choice]} ]; then
					export DISPLAY=:0
					X&
					sleep 1
					${wms[$choice]}&
					eval ${wmspost[$choice]}&
				else
					echo Please connect to the Internet
				fi
			fi
		else
			export DISPLAY=:0
			X&
			sleep 1
			${wms[$choice]}&
			eval ${wmspost[$choice]}&
		fi
	fi
fi
