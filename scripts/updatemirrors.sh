#!/bin/sh

[ "$UID" != 0 ] && su=sudo

country='US'
url="http://www.archlinux.org/mirrorlist/?country=$country&protocol=ftp&protocol=http&ip_version=4&use_mirror_status=on"

tmpfile=$(mktemp --suffix=-mirrorlist)

# Get latest mirror list and save to tmpfile
wget -qO- "$url" | sed 's/^#Server/Server/g' > "$tmpfile"

# Backup and replace current mirrorlist file
{ echo " Backing up the original mirrorlist..."
  $su mv -i /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig; } &&
{ echo " Rotating the new list into place..."
  $su mv -i "$tmpfile" /etc/pacman.d/mirrorlist; }

# Run rankmirrors
echo " Backing up mirrorlist..."
$su cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo " Running rankmirrors..."
$su rankmirrors -n 12 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

echo "Please run $ sudo pacman -Syy"
