#! /bin/bash
tt_imdb_id=$1

SEARCH_BASE_URL="https://api.imdbapi.dev/titles/"
TODAY_DATE=$(date '+%Y%m%d')
BACKUP_LOG="/central/location/scripts/logs/IMDB/${TODAY_DATE}_IMDB_Info.log"
SAVE_DIR="/SSD_1/tvshows/"

if [ -z "$tt_imdb_id" ]
then
    read -p "Enter a show ID (tt#######): " tt_imdb_id
fi

trimmed_id=$(echo "$tt_imdb_id" | xargs)

echo "$TODAY_DATE $(date +%T) Getting IMDB info for show $trimmed_id" >> "$BACKUP_LOG"

echo "$TODAY_DATE $(date +%T) Sending IMDB titles/titleID request" >> "$BACKUP_LOG"
show_resp=$(curl -GsS "${SEARCH_BASE_URL}${trimmed_id}" -H 'accept: application/json')
echo "$TODAY_DATE $(date +%T) IMDB titles/titleID request complete" >> "$BACKUP_LOG"

primary_title=$(echo "$show_resp" | jq -r '.primaryTitle')
clean_title=$(echo "$primary_title" | tr -cd '[:alnum:][:space:]')
trimmed_title=$(echo "${clean_title}" | xargs)

show_dir="${SAVE_DIR}${trimmed_title}"
echo "$TODAY_DATE $(date +%T) Show directory is $show_dir" >> "$BACKUP_LOG"

if [ ! -d "$show_dir" ]
then
    echo "$TODAY_DATE $(date +%T) Creating directory $show_dir" >> "$BACKUP_LOG"
    mkdir "$show_dir"
fi

echo "$TODAY_DATE $(date +%T) Saving info to directory" >> "$BACKUP_LOG"
underscore_title="${trimmed_title// /_}"
show_info_file="${show_dir}/${underscore_title}_info.txt"

echo "$show_resp" | jq '.' > "${show_dir}/${trimmed_id}_${underscore_title}.json"

echo "$show_resp" | jq -r '"\(.id)\n\n\(.primaryTitle)\n\n\(.plot)\n\nCreated By\n\(.writers[0].displayName)\n"' > "$show_info_file"
echo "$show_resp" | jq -r '"TV Series • \(.startYear)-\(.endYear) • RATING • \(.runtimeSeconds/60)m"' >> "$show_info_file"

echo "$TODAY_DATE $(date +%T) Sending IMDB ratings request" >> "$BACKUP_LOG"
rating_resp=$(curl -GsS "${SEARCH_BASE_URL}${trimmed_id}/certificates" -H 'accept: application/json')
echo "$TODAY_DATE $(date +%T) IMDB ratings request complete" >> "$BACKUP_LOG"

echo "$TODAY_DATE $(date +%T) Saving IMDB ratings info" >> "$BACKUP_LOG"
echo "$rating_resp" | jq -r '.certificates[] | select( .country.code == "US" ) | .rating' >> "$show_info_file"

picture_url=$(echo "$show_resp" | jq -r '.primaryImage.url')
picture_width=$(echo "$show_resp" | jq -r '.primaryImage.width')
picture_height=$(echo "$show_resp" | jq -r '.primaryImage.height')

echo "$TODAY_DATE $(date +%T) Downloading IMDB primary image" >> "$BACKUP_LOG"
curl -LsS -o "${show_dir}/${underscore_title}_${picture_width}x${picture_height}.${picture_url##*.}" "$picture_url"
echo "$TODAY_DATE $(date +%T) IMDB primary image saved to directory" >> "$BACKUP_LOG"

echo "$TODAY_DATE $(date +%T) Finished getting IMDB info for show $trimmed_id" >> "$BACKUP_LOG"
