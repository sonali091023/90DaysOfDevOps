#!/bin/bash

LOGFILE="/home/sona/90DaysOfDevOpsChnalange/90DaysOfDevOps/2026/day-20/archive/logfile"

echo "===== LOG SUMMARY ====="
echo

echo "Total Failed Login Attempts:"
grep "Failed password" $LOGFILE | wc -l

echo

echo "Top 5 IPs Attempting Login:"
grep "Failed password" $LOGFILE | awk '{print $11}' | sort | uniq -c | sort -nr | head -5

echo

echo "Number of Errors:"
grep -i "error" $LOGFILE | wc -l

echo

echo "Number of Warnings:"
grep -i "warning" $LOGFILE | wc -l
