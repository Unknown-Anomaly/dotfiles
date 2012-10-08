#! /bin/bash

# Author: Walden Riedel
# Title: Cross wallpaper changer for users of awesome wm
# Description: This script uses chron to run every differently alloted time period.
#              Uses feh to work along with the default functions awsetbg of awesome,
#              */5 * * * * /home/molganvk/wallpaperchanger.sh
#              Also I added this file into my xinitrc when I start awesome as to facilitate changing wallpapers with awesome alone.
# 
#              Note: Mainly uses *.png files, all these file directories are used symbolically,
#                    Change how you see fit to use.
# Author Contact: war4756@gmail.com or github.com/Unknown-Anomaly
#

while [ x$DISPLAY != x ]
do
	Local=$HOME/Dropbox/Pictures/Desktop_Pictures/ # This variable for the folder address of the pictures you want to go through.
	LocalDir=$HOME/Dropbox/Pictures/Desktop_Pictures/* # This variable is for all the files inside the folder you want this script to go through.
	DesktopImg=$HOME/Pictures/DesktopImg.png # This is the image that gets over-written to change your background.

<<<<<<< HEAD
	sleep 120 # Number of seconds this script waits until executing again. Set to 2 minutes.
=======
	sleep 300 # Number of seconds this script waits until executing again.
>>>>>>> 2d52161d76b4f1be6691b085e9a3304583f10be1

	cd $Local
	RandInt=$(find . -type f | wc -l)
	FileNum=$[ ( $RANDOM % $RandInt ) ]
	Counter=1
	
	for f in $LocalDir
	do
		if [ $Counter == $FileNum ]; then
			## One could instead of copying the image just use 'awsetbg $DesktopImg'
			# it would work just as well, but when machine reloads it captures where-ever
			# you set your desktop in ~/.config/awesome/theme/default/theme.lua this way
			# so when awesome reloads you get the previous desktop background you had.
			cp $f $DesktopImg
			awsetbg $DesktopImg
		fi
		let "Counter = ${Counter} + 1"
	done
	
	notify-send "Background Changed"
done
