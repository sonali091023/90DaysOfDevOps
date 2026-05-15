**Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab**

Task 1: Log Rotation Script
Create log_rotate.sh that:

1. Takes a log directory as an argument (e.g., /var/log/myapp)
2. Compresses .log files older than 7 days using gzip
3. Deletes .gz files older than 30 days
4. Prints how many files were compressed and deleted
5. Exits with an error if the directory doesn't exist

<img width="1891" height="715" alt="1" src="https://github.com/user-attachments/assets/466925f1-b6db-4c10-b561-6a0b83b2cd21" />

<img width="1891" height="163" alt="1-2" src="https://github.com/user-attachments/assets/e49c588a-5d6c-4c6e-8b43-13a5edd3ea6b" />

Task 2: Server Backup Script
Create backup.sh that:

1. Takes a source directory and backup destination as arguments
2. Creates a timestamped .tar.gz archive (e.g., backup-2026-02-08.tar.gz)
3. Verifies the archive was created successfully
4. Prints archive name and size
5. Deletes backups older than 14 days from the destination
6. Handles errors — exit if source doesn't exist

<img width="1916" height="946" alt="2" src="https://github.com/user-attachments/assets/d0d62e5d-2af1-4bfa-9038-a2e1baceb289" />

Task 3: Crontab
1. Read: crontab -l — what's currently scheduled?
2. Understand cron syntax:
* * * * *  command
│ │ │ │ │
│ │ │ │ └── Day of week (0-7)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
3. Write cron entries (in your markdown, don't apply if unsure) for:
4. Run log_rotate.sh every day at 2 AM
5. Run backup.sh every Sunday at 3 AM
6. Run a health check script every 5 minutes

<img width="1902" height="552" alt="3" src="https://github.com/user-attachments/assets/02c8c7c2-2c85-433a-9de7-416be0410740" />

<img width="848" height="72" alt="3-2" src="https://github.com/user-attachments/assets/c137c0be-bb3b-470a-b5d9-e242c337ed1b" />

<img width="997" height="975" alt="3-3" src="https://github.com/user-attachments/assets/16a51b39-1668-4321-9c98-8cb9db3d769e" />

<img width="1585" height="165" alt="3-4" src="https://github.com/user-attachments/assets/1a71a3ab-f4e4-4fb4-820b-d3dc405af9e6" />

Task 4: Combine — Scheduled Maintenance Script

Create maintenance.sh that:

1. Calls your log rotation function

2. Calls your backup function
3. Logs all output to /var/log/maintenance.log with timestamps
4. Write the cron entry to run it daily at 1 AM
