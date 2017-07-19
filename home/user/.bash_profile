if [ -z "$DISPLAY" ]; then
    echo "WM Options: (y) Default (i) i3 (a) Awesome (o) Openbox (e) Enlightenment (k) KDE (m) MATE (x) XFCE (l) LXDE (f) Fluxbox (d) dwm (w) icewm"
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
    wms[f]=fluxbox
    wms[d]=dwm
    wms[w]=icewm
    wmpkgs[y]=twm
    wmspkg[Y]=twm
    wmspkg[i]=i3-gaps
    wmspkg[a]=awesome
    wmspkg[o]=openbox
    wmspkg[e]="enlightenment:0.17 terminology"
    wmspkg[k]="plasma-meta kde-apps/dolphin dolphin-plugins konsole gwenview"
    wmspkg[m]="mate engrampa pluma atril gnome-calculator caja-extensions mate-netbook mate-power-manager mate-screensaver mate-system-monitor mate-utils eom mate-netspeed"
    wmspkg[x]=xfce4-meta
    wmspkg[l]=lxde-meta
    wmspkg[f]=fluxbox
    wmspkg[d]=dwm
    wmspkg[w]=icewm
    wmspost[y]="feh --bg-max wallpaper.png & xbindkeys &"
    wmspost[Y]="feh --bg-max wallpaper.png & xbindkeys &"
    wmspost[i]="feh --bg-max wallpaper.png & xbindkeys"
    wmspost[a]=""
    wmspost[o]="feh --bg-max wallpaper.png & xbindkeys"
    wmspost[e]=""
    wmspost[k]=""
    wmspost[m]=""
    wmspost[x]=""
    wmspost[l]=""
    wmspost[f]="feh --bg-max wallpaper.png & xbindkeys"
    wmspost[d]=""
    wmspost[w]=""
    if [ -n "${wms[$choice] + 1}" ]; then
        if [ ! -f /usr/bin/${wms[$choice]} ]; then
            echo
            echo ${wms[$choice]} is not installed. Install it by running:
            echo $ sudo emerge ${wmspkg[$choice]}
            read -erp "Install now? [y/n] " -n 1 installyn
            if [[ "$installyn" == "y" || "$installyn" == "Y" ]]; then
                sudo emerge -v ${wmspkg[$choice]}
                export DISPLAY=:0
                X&
                sleep 1
                ${wms[$choice]}&
                eval ${wmspost[$choice]}&
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
