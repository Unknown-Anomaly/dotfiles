#!/bin/sh

[ "$UID" != 0 ] && su=sudo

# Load dvorak keylayout
echo "Changing keylayout to en_US-dvorak"
$su loadkeys -q dvorak
sleep 1
# Start program
dvorakng
# After program exits change back layout.
echo "Changing layout back to en_US format"
$su loadkeys -q us
sleep 1
