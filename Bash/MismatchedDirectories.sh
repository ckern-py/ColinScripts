#! /bin/bash
#---------
orphan_array=()

TODAY_DATE=$(date '+%Y%m%d')
LOG_FILE="/central/location/scripts/logs/DirectoryOrphans/${TODAY_DATE}_DirectoryOrphans.log"

JELLYFIN_TV="/HDD_1/jellyfin/tvshows/"
JELLYFIN_TV_BACKUP="/HDD_2/jellyfin/tvshows/"

JELLYFIN_MOVIES="/HDD_1/jellyfin/movies/"
JELLYFIN_MOVIES_BACKUP="/HDD_2/jellyfin/movies/"

BLURAY_REG_MOVIES="/HDD_3/bluray/regularhd/movies/"
BLURAY_REG_MOVIES_BACKUP="/HDD_4/bluray/regularhd/movies/"

BLURAY_UHD_MOVIES="/HDD_3/bluray/ultrahd/movies/"
BLURAY_UHD_MOVIES_BACKUP="/HDD_4/bluray/ultrahd/movies/"

MORE_BLURAY_REG_MOVIES="/HDD_5/bluray/regularhd/movies/"
MORE_BLURAY_REG_MOVIES_BACKUP="/HDD_6/bluray/regularhd/movies/"

MORE_BLURAY_UHD_MOVIES="/HDD_5/bluray/ultrahd/movies/"
MORE_BLURAY_UHD_MOVIES_BACKUP="/HDD_6/bluray/ultrahd/movies/"
#---------
compare_dir() {
    echo "-Comparing-" >> "$LOG_FILE"
    echo "--1: $1" >> "$LOG_FILE"
    echo "--2: $2" >> "$LOG_FILE"

    backup_dir=$(echo "$2" | cut -d '/' -f1-2)
    readarray -t diff_array < <(diff "$1" "$2" | grep "^Only in $backup_dir" | cut -d ':' -f2)

    if [ ${#diff_array[@]} -ne 0 ]
    then
        curr_drive="Only in $backup_dir"
        echo "---$curr_drive" >> "$LOG_FILE"
        orphan_array+="$curr_drive\n"
        for o in "${diff_array[@]}"
        do
            echo "$o" >> "$LOG_FILE"
            orphan_array+="$o\n"
        done
    fi
}
#---------
echo "$TODAY_DATE $(date +%T) Finding directory orphans" >> "$LOG_FILE"

compare_dir "$JELLYFIN_TV" "$JELLYFIN_TV_BACKUP"
compare_dir "$JELLYFIN_MOVIES" "$JELLYFIN_MOVIES_BACKUP"
compare_dir "$BLURAY_REG_MOVIES" "$BLURAY_REG_MOVIES_BACKUP"
compare_dir "$BLURAY_UHD_MOVIES" "$BLURAY_UHD_MOVIES_BACKUP"
compare_dir "$MORE_BLURAY_REG_MOVIES" "$MORE_BLURAY_REG_MOVIES_BACKUP"
compare_dir "$MORE_BLURAY_UHD_MOVIES" "$MORE_BLURAY_UHD_MOVIES_BACKUP"

if [ ${#orphan_array[@]} -gt 0 ]
then
    echo "$TODAY_DATE $(date +%T) Sending email" >> "$LOG_FILE"
    echo -e "Subject: Directory Mismatch.\n\nFound the following orphan directories:\n\n${orphan_array[@]}" | ssmtp my.email@mail.com
fi

echo "$TODAY_DATE $(date +%T) Finished finding directory orphans" >> "$LOG_FILE"
