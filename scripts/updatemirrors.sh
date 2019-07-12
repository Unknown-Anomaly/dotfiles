#!/bin/sh

# url="https://www.archlinux.org/mirrorlist/?country=$country&protocol=http&use_mirror_status=on"

# Only run if privledged.
if [[ $(id -u) != 0 ]]; then
   echo -e "Error: Permission Denied."
   exit 1
fi

# Assign defaults.
charCountry="US" # Assign the default country code.
numMirrors=5 # Assign the default number.

if [[ ${#1} == "2" ]]; then
   if [[ $1 =~ ^[A-Z]+$ ]]; then
      echo -e "Using provided country code: $1."
      charCountry=$1
   else
      echo -e "Using default country code: $charCountry."
   fi
else
   echo -e "Using default country code: $charCountry."
fi

if [[ ${#2} == "1" || ${#2} == "2" ]]; then
   if [[ $2 =~ ^[0-9]+$ ]]; then
      echo -e "Using provided number of mirrors: $2."
      numMirrors=$2
   else
      echo -e "Using default number of mirrors: $numMirrors."
   fi
else
   echo -e "Using default number of mirrors: $numMirrors."
fi

echo -e "\n"

# Get latest mirror list and save to a tmpfile
$su curl -o /etc/pacman.d/mirrorlist.orig "https://www.archlinux.org/mirrorlist/?country=$charCountry&protocol=http&use_mirror_status=on"

echo -e "\nProcessing and backing up downloaded server list.\n"
$su sed '/^#\S/ s|#||' -i /etc/pacman.d/mirrorlist.orig
$su cp /etc/pacman.d/mirrorlist.orig /etc/pacman.d/mirrorlist.backup
$su rm /etc/pacman.d/mirrorlist.orig

echo -e "Running rankmirrors."
$su rankmirrors -n $numMirrors /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist
echo -e "Done.\n"

# Display servers used.
echo -e "These servers will be used."
$su tail -n$numMirrors /etc/pacman.d/mirrorlist
echo -e "\nPlease run $ sudo pacman -Syy"
