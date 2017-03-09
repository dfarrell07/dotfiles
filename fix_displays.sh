#/usr/bin/env sh

# Make sure external dispays are on, may not be after docking w/o reboot
xrandr --output DP2-2 --mode 1920x1200
xrandr --output DP2-3 --mode 1920x1200

# Put the displays in positions that make sense in physical workspace
xrandr --output eDP1 --right-of DP2-2
xrandr --output DP2-3 --left-of DP2-2
xrandr --output DP2-3 --rotate right
xrandr --output DP2-2 --rotate right
