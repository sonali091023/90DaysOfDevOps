# Day 12 – Breather & Revision (Days 01–11)

## 1. Mindset & Plan Review
- **Mindset & plan:** revisit your Day 01 learning plan—are your goals still right? any tweaks?  
-> Goals still aligned, committed to the journey

## 2. Processes & Services Review (Days 04–05)
- **Processes & services:** rerun 2 commands from Day 04/05 (e.g., `ps`, `systemctl status`, `journalctl -u <service>`);

<img width="1898" height="971" alt="12-1" src="https://github.com/user-attachments/assets/2bd05d03-7940-44db-a7bc-3693c58fbdba" />

## 3. File Skills Practice (Days 06–11)

- **File skills:** practice 3 quick ops from Days 06–11 (e.g., `echo >>`, `chmod`, `chown`, `ls -l`, `cp`, `mkdir`).

<img width="1132" height="950" alt="12-2" src="https://github.com/user-attachments/assets/149b4834-cab6-4576-b3fc-207e0636871a" />

## 4. Cheat Sheet Refresh (Day 03)
Top 5 Commands for Incidents
- ls -l → permissions & ownership
- df -h → disk space issues
- free -m → memory check
- ps -ef → running processes
- systemctl status <service> → service health

## 5. User / Group Sanity Check (Days 09 & 11)

- **User/group sanity:** recreate one small scenario from Day 09 or Day 11 (create a user or change ownership) and verify with `id`/`ls -l`.

observation : adduser & useradd are two different commands for adding user, while running adduser it asks you to provide password for the user

<img width="821" height="483" alt="12-3" src="https://github.com/user-attachments/assets/0df2774a-18fb-46e6-af39-ab47528594d5" />

<img width="1012" height="957" alt="12-4" src="https://github.com/user-attachments/assets/35e7b13f-9354-4538-9524-d6edd5f0f77f" />

<img width="620" height="952" alt="image" src="https://github.com/user-attachments/assets/6862dd8d-f13a-48a0-8161-2847d9e89b6a" />

## 6. Mini Self-Check

**- Q1. Which 3 commands save you the most time right now?**
- ls -l → instant permission clarity
  - systemctl status → fastest service health check
  - journalctl -u → quick root cause analysis

**- Q2. How do you check if a service is healthy?**
  - systemctl status <service>
  - ps -ef | grep <service>
  - journalctl -u <service>

**- Q3. How do you safely change ownership and permissions?**
  - sudo chown appuser:appgroup app.log
  - chmod 640 app.log

**- Q4. Focus for the next 3 days**
  - Practice advanced shell scripting along with linux commands

