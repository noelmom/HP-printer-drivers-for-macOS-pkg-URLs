#!/bin/bash
# HP macOS printer drivers repo
driversBaseURL="ftp://ftp.hp.com/pub/softlib/software12/HP_Quick_Start/osx/Installations/Essentials"
# Obtain .pkg path for each driver from repo
driversPath="$(curl -s "$driversBaseURL/" | awk '{print $9}' | grep hp-printer-essentials)"
# Backup IFS
bIFS=$IFS
# Add each path to an array
declare -a driversPathArray="( $driversPath )";
# For loop to download/parse drivers within .pkg files to text files
for i in "${driversPathArray[@]}"
do
  IFS=$bIFS
  pkgsTemp="/private/tmp/hpdrivers/pkgs"
  txtFiles="/private/tmp/hpdrivers"
  drvLocalPath="/Library/Printers/PPDs/Contents/Resources/"
  mkdir -p "$pkgsTemp"
  downloadURL="$driversBaseURL/$i"
  NAME="$(basename $downloadURL)"
  printf "\nDownloading: $downloadURL"
  curl -# -o "$pkgsTemp/$NAME" "$downloadURL"
  pathsList="$(lsbom $(pkgutil --bom "$pkgsTemp/$NAME") | grep "$drvLocalPath" | awk -F.gz '{ print $1".gz" }' | cut -c2- | sed 's/["\]/\\&/g; s/.*/"&"/')"
  IFS=$'\n'
  declare -a pathsArray="( "$pathsList" )";
  printf "| "$downloadURL" |\n| :--- |" > "$txtFiles/$NAME.md"
  for j in "${pathsArray[@]}"
  do
    printf "\n| "$j" |" >> "$txtFiles/$NAME.md"
  done
  IFS=$bIFS
done
# Clean-up
rm -rf /tmp/hp-printer*.boms.*
rm -rf "$pkgsTemp"
printf "\nAll done! Text files location: $txtFiles"