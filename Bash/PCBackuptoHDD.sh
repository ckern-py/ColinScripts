#!/bin/bash

destdir=$1
todaydate=$(date '+%Y%m%d')
backuplog="/central/location/scripts/logs/PCBackuptoHDD/${todaydate}_PCBackuptoHDD.log"

echo "$todaydate $(date +%T) Backing up files to ${destdir}" >> "$backuplog"

echo "Moving MyPC_Backup to Backup" >> "$backuplog"
cp -ruv /SSD/Drive/samba/MyPC_Backup "${destdir}/Backup" &>> "$backuplog"

echo "Moving Central location to Backup" >> "$backuplog"
cp -ruv /central/location/scripts "${destdir}/Backup" &>> "$backuplog"
cp -ruv /central/location/docker "${destdir}/Backup" &>> "$backuplog"

echo "Moving VMs to Backup" >> "$backuplog"
cp -ruv /OtherSSD/vms "${destdir}/Backup" &>> "$backuplog"

echo "Moving Jellyfin Media to Backup" >> "$backuplog"
cp -ruv /NVME_SSD/jellyfin/media "${destdir}/Backup" &>> "$backuplog"

echo "Moving Jellyfin Coldstorage to Backup" >> "$backuplog"
cp -ruv /HDD_1/jellyfin/media/coldstorage /HDD_2/jellyfin/media/coldstorage &>> "$backuplog"

echo "$todaydate $(date +%T) Finished backing up files to ${destdir}" >> "$backuplog"

echo -e "Subject: Backup complete.\n\nFinished backup to ${destdir}" | ssmtp my.email@mail.com
