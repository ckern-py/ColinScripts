#!/bin/bash

todaydate=$(date '+%Y%m%d')
backuplog="/central/location/scripts/logs/DockerInventory/${todaydate}_DockerInventory.log"

echo "$todaydate $(date +%T) Taking Docker inventory" >> "$backuplog"

docker container ls --all --format "table {{.Image}}\t{{.State}}\t{{.Names}}\t{{.Networks}}" > /central/location/inventory/Docker_Containers.txt

echo "$todaydate $(date +%T) Finished taking Docker inventory" >> "$backuplog"

echo -e "Subject: Inventory Complete.\n\nFinished taking Docker inventory" | ssmtp my.email@mail.com
