#/usr/bin/env sh

xrandr --output eDP1 --right-of DP2-2
xrandr --output DP2-3 --left-of DP2-2

xrandr --output DP2-3 --rotate right
xrandr --output DP2-2 --rotate right
