#! /bin/bash

# Author: Walden Riedel
# Title: Cross wallpaper changer for users of awesome wm
# Description: This script uses chron to run every differently alloted time period.
#              Uses feh to work along with the default functions awsetbg of awesome,
#              */5 * * * * /home/molganvk/wallpaperchanger.sh
# 
#              Note: Mainly uses *.png files, all these file directories are used symbolically,
#                    Change how you see fit to use.

Local=$HOME/Dropbox/Pictures/Desktop_Pictures/
LocalDir=$HOME/Dropbox/Pictures/Desktop_Pictures/*
DesktopImg=$HOME/Pictures/DesktopImg.png

cd $Local
RandInt=$(find . -type f | wc -l)
FileNum=$[ ( $RANDOM % $RandInt ) ]
Counter=1

for f in $LocalDir
do
	if [ $Counter == $FileNum ];then
		echo "Picture $f"
		cp $f $DesktopImg
		awsetbg $DesktopImg
	fi
	let "Counter = ${Counter} + 1"
done
