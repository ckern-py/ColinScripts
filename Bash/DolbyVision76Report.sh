#!/bin/bash
#----- Vars -----
todaydate=$(date '+%Y%m%d')
backuplog="/central/location/scripts/logs/DolbyVision76Report/${todaydate}_DolbyVision76Report.log"
movie_array=()

#----- Functions -----
ScanDir () {
    cd "$1"
    echo "Scanning $(pwd)" >> "$backuplog"
    echo -e "-----\n" >> "$backuplog"

    for d in *
    do
	if [ -d "$d" ]
	then
        cd "$d"
        for m in *.mkv
        do
        if mediainfo "$m" | grep -q "dvhe.07.06"
        then
            w_line="$d\n$m\n-----\n"
            echo -e "$w_line" >> "$backuplog"
            movie_array+="$w_line"
        fi
        done
        cd ..
	fi
    done
}

#----- Code -----
echo "$todaydate $(date +%T) Scanning for Dolby Vision 7.6 movies" >> "$backuplog"

ScanDir "/HDD_1/bluray/ultrahd/movies"
ScanDir "/HDD_3/bluray/ultrahd/movies"

if [ ${#movie_array[@]} -gt 0 ]
then
    echo -e "Subject: Dolby Vision 7.6 movies found.\n\nFound the following movies:\n\n${movie_array[@]}" | ssmtp my.email@mail.com
fi

echo "$todaydate $(date +%T) Finished scanning for Dolby Vision 7.6 movies" >> "$backuplog"
