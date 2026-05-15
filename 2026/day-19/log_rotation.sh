#!/bin/bash

<<comment
To check the logs older than 7 days and 30 days later compress then and delete as well
comment

function rotate_logs() {

    # Validate input
    if [ -z "$1" ]; then
        echo "Usage: $0 <log_directory>"
        exit 1
    fi

    if [ ! -d "$1" ]; then
        echo "Directory not found: $1"
        exit 1
    fi

    echo "Directory found: $1"

    # Count and compress .log files older than 7 days
    echo "Checking logs older than 7 days..."

    old_logs=$(find "$1" -type f -name "*.log" -mtime +7)
    log_count=$(echo "$old_logs" | grep -c .)

    if [ "$log_count" -eq 0 ]; then
        echo "No log files older than 7 days found"
    else
        echo "Compressing $log_count files..."
        find "$1" -type f -name "*.log" -mtime +7 -exec gzip {} +
    fi

    # Count and delete .gz files older than 30 days
    echo "Checking compressed logs older than 30 days..."

    old_gz=$(find "$1" -type f -name "*.gz" -mtime +30)
    gz_count=$(echo "$old_gz" | grep -c .)

    if [ "$gz_count" -eq 0 ]; then
        echo "No compressed logs older than 30 days found"
    else
        echo "Deleting $gz_count files..."
        find "$1" -type f -name "*.gz" -mtime +30 -delete
    fi

    echo "Log rotation complete"
}

rotate_logs "$1"

<<comment 
if [ ! -d "$1" ]; then #“Is the provided argument NOT a directory? If yes → true, if no → false” echo "Directory not found" exit 1 else echo "directory found" fi echo "Checking logs older than 7 days..." old_logs=$(find "$1" -type f -name "*.log" -mtime +7) if [ -z "$old_logs" ]; then echo "No log files older than 7 days found" else echo "Compressing logs..." echo "$old_logs" | xargs gzip fi echo "Checking compressed logs older than 30 days..." old_gz=$(find "$1" -type f -name "*.gz" -mtime +30) if [ -z "$old_gz" ]; then echo "No compressed logs older than 30 days found" else echo "Deleting old compressed logs..." echo "$old_gz" | xargs rm -f fi echo "Log rotation complete" } rotate_logs "$1" 
comment
