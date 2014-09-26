#!/bin/sh

[ "$UID" != 0 ] && su=sudo

country='US'
url="http://www.archlinux.org/mirrorlist/?country=$country&protocol=ftp&protocol=http&ip_version=4&use_mirror_status=on"

# Get latest mirror list and save to tmpfile
$su wget -O /etc/pacman.d/mirrorlist.orig https://www.archlinux.org/mirrorlist/all/http
$su sed '/^#\S/ s|#||' -i /etc/pacman.d/mirrorlist.orig

$su cp /etc/pacman.d/mirrorlist.orig /etc/pacman.d/mirrorlist

# Run rankmirrors
echo " Backing up mirrorlist..."
$su cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo " Running rankmirrors..."
$su rankmirrors -n 5 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

$su cat /etc/pacman.d/mirrorlist

echo "Please run $ sudo pacman -Syy"
