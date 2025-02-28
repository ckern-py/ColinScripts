#!/bin/bash

todaydate=$(date '+%Y%m%d')
backuplog="/central/location/scripts/logs/LogCleanup/${todaydate}_LogCleanup.log"

echo "$todaydate $(date +%T) Removing old logs" >> "$backuplog"

find /central/location/scripts/logs/ -mindepth 1 -maxdepth 2 -mtime +180 -delete -print >> "$backuplog"

echo "$todaydate $(date +%T) Finished removing old logs" >> "$backuplog"

echo -e "Subject: Log Cleanup Complete.\n\nFinished removing old logs" | ssmtp my.email@mail.com
