if [ -z "$DISPLAY" ]; then
    read -p "Start X? y/n" -n 1 yn
    if [[ $yn == "Y" || $yn == "y" ]]; then
       export DISPLAY=:0
       X&
       sleep 1
       twm&
       feh --bg-fill wallpaper.png
    fi
fi
