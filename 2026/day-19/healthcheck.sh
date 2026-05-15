#!/bin/bash

echo "Health Check $(date)"

echo "CPU Load:"
uptime

echo "Check Disk usage:"
df -h

echo "Check Memory usage: "
free -h

echo "Check nginx status: "
sudo systemctl status nginx


