# Prevent displays from sleeping, bug prevents waking properly
xset s 32767
xset -dpms

# Set color scheme
# NB: Must uncomment this for custom shell colors
# NB: May not be desired on all systems
xrdb ~/.Xdefaults

# Connect to my bluetooth keyboard
# Disable by default, not desired on all systems
#bluetoothctl << EOF
#connect 20:73:16:10:1C:0F
#EOF

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
