if [ -z "$DISPLAY" ] && ! pgrep X > /dev/null; then
	echo "WM Options: (y) Default (i) i3 (a) Awesome (o) Openbox (e) Enlightenment (k) KDE (m) MATE (x) XFCE (l) LXDE (q) LXQT (f) Fluxbox (d) dwm (c) IceWM (w) Window Maker (t) FVWM Themes (p) xmonad (s) Sawfish (b) bspwm (g) goomwwm (h) herbstluftwm (v) evilwm (u) Blackbox !) aewm +) aewm++ @) amiwm #) ctwm $) cwm %) echinus ^) jwm &) larswm *) lumina <) lwm >) matwm2 :) musca ;) notion /) oroborus ?) pagewm \) pekwm |) plwm -) qtile _) ratpoison {) selectwm2 =) sithwm"
	read -erp "Start X? [y/n] " -n 1 choice
	declare -A wms
	declare -A wmspkg
	declare -A wmspost

	defaultpost="nitrogen --set-zoom wallpaper.png & xbindkeys & xinput set-prop \"SynPS/2 Synaptics TouchPad\" \"libinput Tapping Enabled\" 1"

	wms[y]=fvwm
	wmspkg[y]=fvwm
	wmspost[y]=$defaultpost

	wms[Y]=wms[y]
	wmspkg[Y]=wmspkg[y]
	wmspost[Y]=wmspost[y]

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
	wmspkg[d]="dwm dmenu st"
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

	wms[p]=xmonad
	wmspkg[p]=xmonad
	wmspost[p]=$defaultpost

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

	wms[u]=blackbox
	wmspkg[u]=blackbox
	wmspost[u]=$defaultpost

	wms[!]=aewm
	wmspkg[!]=aewm
	wmspost[!]=$defaultpost

	wms[+]=aewm++
	wmspkg[+]=aewm++
	wmspost[+]=$defaultpost

	wms["@"]=amiwm
	wmspkg["@"]=amiwm
	wmspost["@"]=$defaultpost

	wms[#]=ctwm
	wmspkg[#]=ctwm
	wmspost[#]=$defaultpost

	wms[$]=cwm
	wmspkg[$]=cwm
	wmspost[$]=$defaultpost

	wms[%]=echinus
	wmspkg[%]=echinus
	wmspost[%]=$defaultpost

	wms[^]=jwm
	wmspkg[^]=jwm
	wmspost[^]=$defaultpost

	wms[&]=larswm
	wmspkg[&]=larswm
	wmspost[&]=$defaultpost

	wms["*"]=lumina-desktop
	wmspkg["*"]=lumina
	wmspost["*"]=$defaultpost

	wms[<]=lwm
	wmspkg[<]=lwm
	wmspost[<]=$defaultpost

	wms[>]=matwm2
	wmspkg[>]=matwm2
	wmspost[>]=$defaultpost

	wms[:]=musca
	wmspkg[:]=musca
	wmspost[:]=$defaultpost

	wms[;]=notion
	wmspkg[;]=notion
	wmspost[;]=$defaultpost

	wms[/]=oroborus
	wmspkg[/]=oroborus
	wmspost[/]=$defaultpost

	wms["?"]=page
	wmspkg["?"]=pagewm
	wmspost["?"]=$defaultpost

	wms[\]=pekwm
	wmspkg[\]=pekwm
	wmspost[\]=$defaultpost

	wms[|]=plwm
	wmspkg[|]=plwm
	wmspost[|]=$defaultpost

	wms[-]=qtile
	wmspkg[-]=qtile
	wmspost[-]=$defaultpost

	wms[_]=ratpoison
	wmspkg[_]=ratpoison
	wmspost[_]=$defaultpost

	wms[{]=selectwm
	wmspkg[{]=selectwm2
	wmspost[{]=$defaultpost

	wms[=]=sithwm
	wmspkg[=]=sithwm
	wmspost[=]=$defaultpost

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
