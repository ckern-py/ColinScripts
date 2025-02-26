#!/bin/bash

todaydate=$(date '+%Y%m%d')
backuplog="/central/location/scripts/logs/JellyfinInventory/${todaydate}_JellyfinInventory.log"

echo "$todaydate $(date +%T) Taking Jellyfin inventory" >> "$backuplog"

#-------------------------------------------------------------
echo "Taking Jellyfin inventory of shows" >> "$backuplog"
readarray -t tv_array < <(ls /NVME_SSD/jellyfin/shows)

readarray -t -O "${#tv_array[@]}" tv_array < <(ls /HDD_1/jellyfin/shows)

printf '%s\n' "${tv_array[@]}" | sort > /central/location/inventory/Jellyfin_Shows.txt
#-------------------------------------------------------------
echo "Taking Jellyfin inventory of movies" >> "$backuplog"
readarray -t movie_array < <(ls /NVME_SSD/jellyfin/movies)

readarray -t -O "${#movie_array[@]}" movie_array < <(ls /HDD_1/jellyfin/movies)

printf '%s\n' "${movie_array[@]}" | sort > /central/location/inventory/Jellyfin_Movies.txt
#-------------------------------------------------------------
echo "Taking Jellyfin inventory of music" >> "$backuplog"
readarray -t music_array < <(tree -d /NVME_SSD/jellyfin/music)

printf '%s\n' "${music_array[@]}" > /central/location/inventory/Jellyfin_Music.txt
#-------------------------------------------------------------
echo "$todaydate $(date +%T) Finished taking Jellyfin inventory" >> "$backuplog"

echo -e "Subject: Inventory Complete.\n\nFinished taking Jellyfin inventory" | ssmtp my.email@mail.com
