if [ -z "$DISPLAY" ] && ! pgrep X > /dev/null; then
	echo "WM Options: (y) Default (i) i3 (a) Awesome (o) Openbox (e) Enlightenment (k) KDE (m) MATE (x) XFCE (l) LXDE (q) LXQT (f) Fluxbox (d) dwm (c) IceWM (w) Window Maker (t) FVWM Themes (n) xmonad (s) Sawfish (b) bspwm (g) goomwwm (h) herbstluftwm (v) evilwm"
	read -erp "Start X? [y/n] " -n 1 choice
	declare -A wms
	declare -A wmspkg
	declare -A wmspost

	defaultpost="nitrogen --set-zoom wallpaper.png & xbindkeys & xinput set-prop \"SynPS/2 Synaptics TouchPad\" \"libinput Tapping Enabled\" 1"

	wms[y]=fvwm
	wmspkg[y]=fvwm
	wmspost[y]=$defaultpost

	wms[Y]=fvwm
	wmspkg[Y]=fvwm
	wmspost[Y]=$defaultpost

	wms[i]=i3
	wmspkg[i]="i3-gaps i3status"
	wmspost[i]=$defaultpost

	wms[a]=awesome
	wmspkg[a]=awesome
	wmspost[a]=$defaultpost

	wms[o]=openbox
	wmspkg[o]=openbox
	wmspost[o]=$defaultpost

	wms[e]=enlightenment_start
	wmspkg[e]="enlightenment:0.17 terminology"
	wmspost[e]=""

	wms[k]=startkde
	wmspkg[k]="kdebase-meta gwenview"
	wmspost[k]=""

	wms[m]=mate-session
	wmspkg[m]="mate engrampa pluma atril gnome-calculator caja-extensions mate-netbook mate-power-manager mate-screensaver mate-system-monitor mate-utils eom mate-netspeed"
	wmspost[m]=""

	wms[x]=startxfce4
	wmspkg[x]=xfce4-meta
	wmspost[x]=""

	wms[l]=startlxde
	wmspkg[l]=lxde-meta
	wmspost[l]=""

	wms[q]=startlxqt
	wmspkg[q]=lxqt-meta
	wmspost[q]=""

	wms[f]=fluxbox
	wmspkg[f]=fluxbox
	wmspost[f]=$defaultpost

	wms[d]=dwm
	wmspkg[d]=dwm
	wmspost[d]=$defaultpost

	wms[c]=icewm
	wmspkg[c]=icewm
	wmspost[c]=$defaultpost

	wms[w]=wmaker
	wmspkg[w]=windowmaker
	wmspost[w]=$defaultpost

	wms[t]=fvwm-themes-start
	wmspkg[t]=fvwm-themes
	wmspost[t]=$defaultpost

	wms[n]=xmonad
	wmspkg[n]=xmonad
	wmspost[n]=$defaultpost

	wms[s]=sawfish
	wmspkg[s]=sawfish
	wmspost[s]=$defaultpost

	wms[b]=bspwm
	wmspkg[b]=bspwm
	wmspost[b]=$defaultpost

	wms[g]=goomwwm
	wmspkg[g]=goomwwm
	wmspost[g]=$defaultpost

	wms[h]=herbstluftwm
	wmspkg[h]=herbstluftwm
	wmspost[h]=$defaultpost

	wms[v]=evilwm
	wmspkg[v]=evilwm
	wmspost[v]=$defaultpost

	wms[null]=aewm++
	wmspkg[null]=aewm++
	wmspost[null]=$defaultpost

	wms[null]=amiwm
	wmspkg[null]=amiwm
	wmspost[null]=$defaultpost

	wms[null]=blackbox
	wmspkg[null]=blackbox
	wmspost[null]=$defaultpost

	wms[null]=ctwm
	wmspkg[null]=ctwm
	wmspost[null]=$defaultpost

	wms[null]=cwm
	wmspkg[null]=cwm
	wmspost[null]=$defaultpost

	wms[null]=echinus
	wmspkg[null]=echinus
	wmspost[null]=$defaultpost

	wms[null]=jwm
	wmspkg[null]=jwm
	wmspost[null]=$defaultpost

	wms[null]=larswm
	wmspkg[null]=larswm
	wmspost[null]=$defaultpost

	wms[null]=lumina
	wmspkg[null]=""
	wmspost[null]=$defaultpost

	wms[null]=lwm
	wmspkg[null]=lwm
	wmspost[null]=$defaultpost

	wms[null]=matwm2
	wmspkg[null]=matwm2
	wmspost[null]=$defaultpost

	wms[null]=musca
	wmspkg[null]=musca
	wmspost[null]=$defaultpost

	wms[null]=notion
	wmspkg[null]=notion
	wmspost[null]=$defaultpost

	wms[null]=oroborus
	wmspkg[null]=oroborus
	wmspost[null]=$defaultpost

	wms[null]=page
	wmspkg[null]=pagewm
	wmspost[null]=$defaultpost

	wms[null]=pekwm
	wmspkg[null]=pekwm
	wmspost[null]=$defaultpost

	wms[null]=plwm
	wmspkg[null]=plwm
	wmspost[null]=$defaultpost

	wms[null]=qtile
	wmspkg[null]=qtile
	wmspost[null]=$defaultpost

	wms[null]=ratpoison
	wmspkg[null]=ratpoison
	wmspost[null]=$defaultpost

	wms[null]=selectwm
	wmspkg[null]=selectwm2
	wmspost[null]=$defaultpost

	wms[null]=sithwm
	wmspkg[null]=sithwm
	wmspost[null]=$defaultpost

	wms[null]=spectrwm
	wmspkg[null]=spectrwm
	wmspost[null]=$defaultpost

	wms[null]=subtle
	wmspkg[null]=subtle
	wmspost[null]=$defaultpost

	wms[null]=treewm
	wmspkg[null]=treewm
	wmspost[null]=$defaultpost

	wms[null]=twm
	wmspkg[null]=twm
	wmspost[null]=$defaultpost

	wms[null]=windowlab
	wmspkg[null]=windowlab
	wmspost[null]=$defaultpost

	wms[null]=wm2
	wmspkg[null]=wm2
	wmspost[null]=$defaultpost

	wms[null]=wmfs
	wmspkg[null]=wmfs
	wmspost[null]=$defaultpost

	wms[null]=wmii
	wmspkg[null]=wmii
	wmspost[null]=$defaultpost

	wms[null]=xoat
	wmspkg[null]=xoat
	wmspost[null]=$defaultpost

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
