#!/bin/bash

<<comment
This script is regarding backup and delete the older data
comment
 

function display_usage {
    echo "Usage: $0 <source_directory> <backup_directory>"
    exit 1
}

# Validate arguments
if [ $# -ne 2 ]; then
    display_usage
fi

source_dir=$1
backup_dir=$2
timestamp=$(date '+%Y-%m-%d')
backup_file="${backup_dir}/backup-${timestamp}.tar.gz"

# Check if source exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory does not exist: $source_dir"
    exit 1
fi

# Check if backup directory exists
if [ ! -d "$backup_dir" ]; then
    echo "Error: Backup directory does not exist: $backup_dir"
    exit 1
fi

# Create backup
function create_backup {
    echo "Creating backup..."

    tar -czf "$backup_file" "$source_dir" 2>/dev/null

    if [ $? -ne 0 ]; then
        echo "Backup failed!"
        exit 1
    fi

    echo "Backup created: $backup_file"

    # Print size
    size=$(du -h "$backup_file" | cut -f1)
    echo "Backup size: $size"
}

# Delete backups older than 14 days
function cleanup_old_backups {
    echo "Cleaning backups older than 14 days..."

    deleted_count=$(find "$backup_dir" -type f -name "backup-*.tar.gz" -mtime +14 -print -delete | wc -l)

    echo "Deleted $deleted_count old backups"
}

create_backup
cleanup_old_backups
