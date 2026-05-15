#!/bin/bash

<< info
Master maintenance script
Runs log rotation and backup
info

LOGFILE="/var/log/maintenance.log"

log_rotate_script="/home/ubuntu/2026/day19/log_rotation.sh"
backup_script="/home/ubuntu/2026/day19/backup.sh"

log_dir="/var/log/nginx"
source_dir="/home/sona/90DaysOfDevOpsChnalange/90DaysOfDevOps/2026/day-19/backend"
backup_dir="/home/sona/90DaysOfDevOpsChnalange/90DaysOfDevOps/2026/day-19/day19backups"

echo "===== Maintenance Started : $(date) =====" >> $LOGFILE

# Run log rotation
echo "Running Log Rotation..." >> $LOGFILE
bash $log_rotate_script $log_dir >> $LOGFILE 2>&1

# Run backup
echo "Running Backup..." >> $LOGFILE
bash $backup_script $source_dir $backup_dir >> $LOGFILE 2>&1

echo "===== Maintenance Finished : $(date) =====" >> $LOGFILE
echo "" >> $LOGFILE
