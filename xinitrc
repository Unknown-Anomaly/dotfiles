# ~/.xinitrc

# --{{ Load config files and start background processes

# Fix gui java apps displaying in awesome
_JAVA_AWT_WM_NONREPARENTING=1
export _JAVA_AWT_WM_NONREPARENTING

# Correct urxvt themeing.
xrdb -merge ~/.xresources &

# Font setup
xset +fp /usr/share/fonts/local
xset fp rehash

#Start pulseaudio for x11
start-pulseaudio-x11

xfce4-power-manager & #power
thunar --daemon & #thunar daemon
urxvtd -q -o -f & #urxvt daemon
xscreensaver -no-splash & #screen lock
sleep 8 && dropboxd & #dropbox

# -- }}

# -- {{ Start the GUI programs/daemons

sleep 2 && wicd-gtk -t & #wcid gtk daemon, only tray
sleep 2 && conky -q & #conk
sleep 4 && urxvtc & $starts a terminal

# start programs
sleep 8 && firefox & # Opens firefox web browser
sleep 6 && pidgin & # Pidgin IM client
#sleep 10 && banshee & # Banshee music/media client

# -- }}

# -- {{ Start the WM }} 
exec awesome
