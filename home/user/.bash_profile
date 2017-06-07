if [ -z "$DISPLAY" ]; then
    read -p "Start X?" yn
    if [[ $yn == "Y" || $yn == "y" ]]; then
       export DISPLAY=:0
       X&
       sleep 1
       twm&
       feh --bg-scale wall.png
    fi
fi
