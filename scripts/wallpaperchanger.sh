#! /bin/bash

# Author: Walden Riedel
# Title: Cross wallpaper changer for users of awesome ( Window Manager )
# Description: This script uses chron to run every differently alloted time period.
#              Uses feh to work along with the default functions awsetbg of awesome,
#              also I added this file into my xinitrc when I start awesome as to 
#              facilitate changing wallpapers with awesome alone.
#              This program uses 'sleep X' to run and will not stop, the crontab I
#              had used is as such '*/5 * * * * /home/$USER/wallpaperchanger.sh'
# 
#              Note: Mainly uses *.png files, all these file directories are used symbolically,
#                    Change how you see fit to use.
#                    Some errors with *.jpg have not figured out how to fix it in a short line solution.
#
# Author Contact: war4756@gmail.com or github.com/Unknown-Anomaly
#

ShuffleTotal = 0
ShuffleList=()

while [ x$DISPLAY != x ]
do
   # Local=$HOME/Dropbox/Pictures/Desktop_Pictures/
   Local=$HOME/Dropbox/Pictures/Test/
   # This variable for the folder address of the pictures you want to go through.

   #LocalDir=$HOME/Dropbox/Pictures/Desktop_Pictures/*
   LocalDir=$HOME/Dropbox/Pictures/Test/*
   # This variable is for all the files inside the folder you want this script to go through.

   DesktopImg=$HOME/Pictures/DesktopImg.png
   # This is the image that gets over-written to change your background.

   # sleep 180 # Number of seconds this script waits until executing again. Set to 3 minutes.
   # sleep 2

   cd $Local
   NumFiles=$(find . -type f | wc -l)
   let "NumLeft = NumFiles - ShuffleTotal"

   # End of shuffle loop, resets all the variables to loop through the selection process again.
   if [ $NumLeft = 0 ]; then
      NumLeft=$NumFiles
      ShuffleList=()
      ShuffleTotal=0
   fi
   echo -en "Total: ${NumLeft}\n" ##### DEBUG ##### -- prints the total iterated through

   FileNum=$[ ( $RANDOM% $NumLeft ) ]
   Counter=0
   # Find a way to save instead of fully random

   for file in $LocalDir
   do
      if [ $FileNum =~ ${ShuffleList[*]} ]; then
         echo -ne "Repeat element. FileNum=${FileNum}, In list: ${ShuffleList[*]}\n"
      fi
      if [ $Counter == $FileNum ]; then
         #####
         # One could instead of copying the image just use 'awsetbg $DesktopImg'
         # it would work just as well, but when machine reloads it captures where-ever
         # you set your desktop in ~/.config/awesome/theme/default/theme.lua this way
         # so when awesome reloads you get the previous desktop background you had.
         ########
         ShuffleList[$ShuffleTotal]=$Counter
         cp $file $DesktopImg
         awsetbg $DesktopImg
      fi
      let "Counter = Counter + 1"
   done
   echo -en "List: ${ShuffleList[*]}\n Counter: $Counter \t FileNum: $FileNum\n" ##### DEBUG ##### -- listing the currently chosen backgrounds
   let "ShuffleTotal = ShuffleTotal + 1" # Increments the total 
   notify-send "Background Changed" # Notifies the user of a background change. 
done
