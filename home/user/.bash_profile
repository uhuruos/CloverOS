if [ -z "$DISPLAY" ]; then
    echo "WM Options: (y) Default (i) i3 (a) Awesome (o) Openbox (e) Enlightenment (k) KDE (m) MATE (x) XFCE (l) LXDE (q) LXQT (f) Fluxbox (d) dwm (c) icewm (w) windowmaker (z) Compiz"
    read -erp "Start X? [y/n] " -n 1 choice
    declare -A wms
    declare -A wmspkg
    declare -A wmspost
    wms[y]=twm
    wms[Y]=twm
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
    wms[z]=compiz-manager
    wmpkgs[y]=twm
    wmspkg[Y]=twm
    wmspkg[i]="i3-gaps i3status"
    wmspkg[a]=awesome
    wmspkg[o]=openbox
    wmspkg[e]="enlightenment:0.17 terminology"
    wmspkg[k]="plasma-meta kde-apps/dolphin dolphin-plugins konsole gwenview"
    wmspkg[m]="mate engrampa pluma atril gnome-calculator caja-extensions mate-netbook mate-power-manager mate-screensaver mate-system-monitor mate-utils eom mate-netspeed"
    wmspkg[x]=xfce4-meta
    wmspkg[l]=lxde-meta
    wmspkg[q]=lxqt-meta
    wmspkg[f]=fluxbox
    wmspkg[d]=dwm
    wmspkg[c]=icewm
    wmspkg[w]=windowmaker
    wmspkg[z]="compiz-fusion emerald"
    taptoclick=$'tappingid=$(xinput list-props "SynPS/2 Synaptics TouchPad" | grep \'Tapping Enabled (\' | awk \'{print $4}\' | grep -o \'[0-9]\\+\') && xinput set-prop "SynPS/2 Synaptics TouchPad" $tappingid 1'
    wmspost[y]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[Y]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[i]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[a]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[o]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[e]=""
    wmspost[k]=""
    wmspost[m]=""
    wmspost[x]=""
    wmspost[l]=""
    wmspost[q]=""
    wmspost[f]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[d]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[c]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[w]="feh --bg-max wallpaper.png & xbindkeys & $taptoclick &"
    wmspost[z]="ccsm &"
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
