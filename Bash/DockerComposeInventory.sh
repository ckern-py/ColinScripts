#!/bin/bash

todaydate=$(date '+%Y%m%d')
backuplog="/central/location/scripts/logs/DockerComposeInventory/${todaydate}_DockerComposeInventory.log"

echo "$todaydate $(date +%T) Taking Docker compose inventory" >> "$backuplog"

for file in /central/location/docker/*/docker-compose.yml
do
    new_file=${file#/central/docker/};
    final_location="/central/location/inventory/Docker/${new_file/\//_}"
    echo "Copying $file to $final_location" >> "$backuplog"

    cp "$file" "$final_location";
done;

echo "$todaydate $(date +%T) Finished taking Docker compose inventory" >> "$backuplog"

echo -e "Subject: Inventory Complete.\n\nFinished taking Docker compose inventory" | ssmtp my.email@mail.com
