#!/bin/bash

# -------------------------
# 1. Input & Validation
# -------------------------

if [ -z "$1" ]; then
    echo "Usage: ./log_analyzer.sh <logfile>"
    exit 1
fi

logfile="$1"

if [ ! -f "$logfile" ]; then
    echo "Error: File does not exist!"
    exit 1
fi

if [ ! -r "$logfile" ]; then
    echo "Error: File is not readable!"
    exit 1
fi

echo "Log file accepted: $logfile"
echo

today=$(date +%Y-%m-%d)


# -------------------------
# 2. Count Authentication Failures
# -------------------------

error_count=$(grep -c "authentication failure" "$logfile")

echo "Total authentication failures: $error_count"
echo


# -------------------------
# 3. Find Critical Events
# -------------------------

echo "----- Critical Events -----"

critical_events=$(grep -n "connection from 210.245.165.136" "$logfile")

if [ -z "connection from 210.245.165.136" ]; then
    echo "No connection from 210.245.165.136 found"
else
    echo "$critical_events"
fi

echo


# -------------------------
# 4. Top 5 ERROR Messages
# -------------------------

echo "----- Top 5 ERROR Messages -----"

top_errors=$(grep "ERROR" "$logfile" \
            | sed 's/.*ERROR[: ]*//' \
            | sort \
            | uniq -c \
            | sort -nr \
            | head -5)

if [ -z "$top_errors" ]; then
    echo "No ERROR messages found"
else
    echo "$top_errors"
fi

echo


# -------------------------
# 5. Create Summary Report
# -------------------------

report="logreport_$today.txt"

echo "Creating report..."

{
echo "===== Log Analysis Report ====="
echo "Date: $today"
echo "File: $logfile"
echo "Total lines: $(wc -l < "$logfile")"
echo "Authentication failures: $error_count"
echo
echo "--- Top Errors ---"
echo "$top_errors"
echo
echo "--- Critical Events ---"
echo "$critical_events"
} > "$report"

echo "Report saved as: $report"
echo


# -------------------------
# 6. Archive the Log
# -------------------------

mkdir -p archive
mv "$logfile" archive/

echo "Log moved to archive/ folder"
