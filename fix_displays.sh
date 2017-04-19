#/usr/bin/env sh

# Make sure external dispays are on, may not be after docking w/o reboot
xrandr --output DP-2-2 --mode 1920x1200
xrandr --output DP-2-3 --mode 1920x1200

# Put the displays in positions that make sense in physical workspace
xrandr --output eDP-1 --right-of DP-2-2
xrandr --output DP-2-3 --left-of DP-2-2
xrandr --output DP-2-3 --rotate right
xrandr --output DP-2-2 --rotate right
