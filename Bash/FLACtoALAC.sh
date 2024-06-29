#!/bin/bash

#vars
shopt -s nullglob
todaydate=$(date '+%Y%m%d')
todayslog="/central/location/scripts/logs/FLACtoALAC/${todaydate}_FLACtoALAC.log"
convertlog="/central/location/scripts/logs/FLACtoALAC/${todaydate}_FLACtoALAC_convert.log"
backupdir="/SSD/Drive/samba/Backup/Music/Albums"
albumregex="(.*) \[.*\] \["

cd /SSD/Drive/samba

echo "$todaydate $(date +%T) Checking for new files" >> "$todayslog"

for m in ./FLAC_In/**/*
do
 echo "$todaydate $(date +%T) Found $m" >> "$todayslog"

 readarray -d '/' sambaarray <<< "$m"
 last=$(echo "${sambaarray[-1]}" | xargs -0 echo -n)
 sambaarray[-1]="$last"
 alacdir=$(echo "${sambaarray[-1]/FLAC/ALAC}")
 sambaarray+=("$alacdir")
 fullalacdir="./ALAC_Out/${sambaarray[-1]}"

 albumartist=''
 albumname=''
 if [[ "${sambaarray[3]}" =~ $albumregex ]]
 then
   albumartist=$(echo "${sambaarray[2]}" | cut -d '-' -f 1 | awk '{$1=$1};1')
   albumname="${BASH_REMATCH[1]}"
 fi

 mkdir "$fullalacdir"

 for f in "${m}/"*
 do
  echo "$todaydate $(date +%T) Found $f" >> "$todayslog"
  echo "$todaydate $(date +%T) Converting to ALAC" >> "$todayslog"
  songname=$(echo "${f//flac/m4a}" | grep -oE "[^/]+$")
  outputloc="${fullalacdir}/${songname}"
  ffmpeg -i "$f" -c:v copy -c:a alac "$outputloc" &>> "$convertlog"
 done

 echo "$todaydate $(date +%T) Moving ./FLAC_In/${sambaarray[2]} to $backupdir." >> "$todayslog"
 cp -r "./FLAC_In/${sambaarray[2]}"  "$backupdir"
 echo "$todaydate $(date +%T) Moving $fullalacdir to $backupdir/${sambaarray[-3]}." >> "$todayslog"
 cp -r "$fullalacdir" "$backupdir/${sambaarray[-3]}"

 if [ ! -z "$albumname" ]
 then
   musicsaveloc="/Other/SSD/Location/music/${albumartist}/${albumname}/"
   echo "$todaydate $(date +%T) Moving ./FLAC_In/${sambaarray[2]} to $musicsaveloc." >> "$todayslog"
   mkdir -p "$musicsaveloc"
   cp "$m"/* "$musicsaveloc"
 fi

done

if [ ${#sambaarray[@]} -gt 0 ]
then
 echo "$todaydate $(date +%T) Cleaning up FLAC folder" >> "$todayslog"
 rm -r ./FLAC_In/*
else
 echo "$todaydate $(date +%T) Did not find any files" >> "$todayslog"
fi

echo "$todaydate $(date +%T) Script finished" >> "$todayslog"
