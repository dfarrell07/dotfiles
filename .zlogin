# Prevent displays from sleeping, bug prevents waking properly
xset s 32767
xset -dpms

# Set color scheme
xrdb ~/.Xdefaults

# Connect to my bluetooth keyboard
bluetoothctl << EOF
connect 20:73:16:10:1C:0F
EOF
