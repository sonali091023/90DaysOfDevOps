# Day 04 – Linux Practice: Processes and Services

## Task
Today’s goal is to **practice Linux fundamentals with real commands**.

You will create a short practice note by actually running basic commands and capturing what you see:
- Check running processes
- Inspect one systemd service
- Capture a small troubleshooting flow

This is hands-on. Keep it simple and focused on fundamentals.

---

## Expected Output
By the end of today, you should have:

- A markdown file named:  
  `linux-practice.md`

or

- A hand written practice log (Recommended)

Your note should show what you actually ran on your system.

---

## Guidelines
Follow these rules while creating your practice note:

- Run and record output for **at least 6 commands**
- Include **2 process commands** (`ps`, `top`, `pgrep`, etc.)
-->ps[View Running Processes]: The ps command shows a snapshot of currently running processes.

Command: ps

<img width="838" height="106" alt="image" src="https://github.com/user-attachments/assets/d26db292-a01e-41ef-b62d-9954a3afcd04" />
<img width="850" height="297" alt="image" src="https://github.com/user-attachments/assets/b137d2c6-9dc3-4dff-8019-42fa4aadc5d5" />

Eg: ps aux
<img width="1905" height="601" alt="image" src="https://github.com/user-attachments/assets/55b7688d-a8f5-4a79-a83f-8930287f64ab" />

-->Common usage is to find a specific process: ps aux | grep nginx
<img width="1767" height="378" alt="image" src="https://github.com/user-attachments/assets/a5c6fb2c-537a-47a3-8344-a616f34f0ecc" />
-->This helps identify: process ID (PID), CPU usage, memory usage, running command

Command: top [Real-Time Process Monitoring]: The top command displays live system and process activity.
<img width="1522" height="953" alt="image" src="https://github.com/user-attachments/assets/5ab5de8e-b110-4fb3-9915-aa8887a74ffb" />
-->It Shows CPU usage, Memory usage, Running processes, System load & Process states etc.
<img width="792" height="352" alt="image" src="https://github.com/user-attachments/assets/5300a117-9afd-4f0b-aab8-1402ea34d158" />
<img width="806" height="781" alt="image" src="https://github.com/user-attachments/assets/da421286-8cd2-4ba5-b4e5-ad3f8a997c20" />

Command: pgrep nginx: to get the process id of any process use pgrep command.
<img width="1262" height="398" alt="image" src="https://github.com/user-attachments/assets/14a29922-a00e-4e26-8545-f4ef4991e7bb" />

Command: pgrep -l nginx: To know bothe process id and name we use this command [Another common command to get pid: ps aux | grep nginx]
<img width="1103" height="137" alt="image" src="https://github.com/user-attachments/assets/11b815e9-d76a-411d-a1cf-997395f25c56" />

Commond: Match Full Command: pgrep -af nginx
<img width="1180" height="322" alt="image" src="https://github.com/user-attachments/assets/a004204c-6339-4fa3-9453-e9c91dbef7ab" />
<img width="776" height="367" alt="image" src="https://github.com/user-attachments/assets/3db6e2b0-1699-4cfe-9526-a577cdaa2e65" />

Command: pgrep -u ubuntu: To know the Processes of a Specific User
<img width="1066" height="113" alt="image" src="https://github.com/user-attachments/assets/a17bd084-2b6f-497d-923c-c11cb5f16023" />
<img width="853" height="255" alt="image" src="https://github.com/user-attachments/assets/a6850cf7-caae-435e-a4d7-992f62f05441" />

- Include **2 service commands** (`systemctl status`, `systemctl list-units`, etc.)
1. sudo systemctl status nginx: Used to check: whether a service is running, stopped, enabled, or failed.
-->It Helps With Verify service health, Check uptime, View recent logs/errors, Confirm if service is active etc.

2. sudo systemctl list-units: Lists currently loaded systemd units &  systemctl list-units --type=service Lists currently loaded systemd services.
<img width="1918" height="746" alt="image" src="https://github.com/user-attachments/assets/9fda324d-d2fa-4ab2-9891-4f67d62f942e" />
<img width="1856" height="721" alt="image" src="https://github.com/user-attachments/assets/455ebce4-13c3-4721-996b-c9e7921c8585" />

Command: systemctl list-units --type=service --state=running: Show only running services, This helps during: troubleshooting, monitoring, deployment validation,server health checks etc.
<img width="1505" height="738" alt="image" src="https://github.com/user-attachments/assets/420dcbfe-3ae6-4e57-8aa2-0e10985a6a3c" />

Command: systemctl --failed: To check the failed services
<img width="881" height="250" alt="image" src="https://github.com/user-attachments/assets/8e604507-7326-45fc-845c-3868a1660bdc" />

- Include **2 log commands** (`journalctl -u <service>`, `tail -n 50`, etc.)

Note: Here are 2 commonly used log-related commands for troubleshooting services and applications.
Command: journalctl -u docker [Used to view logs for a specific systemd service.] So -u is unit & In systemd, a unit usually refers to a service.
<img width="1902" height="741" alt="image" src="https://github.com/user-attachments/assets/3f4db669-cbcc-4fb7-b814-aac4b25bcf7d" />
-->It Shows Service startup logs, Errors and warnings, Crashes/restarts, Recent activity etc.

Command: journalctl -u nginx -n 50 [To check the latest logs]
<img width="1492" height="795" alt="image" src="https://github.com/user-attachments/assets/65c4c500-337c-4505-b250-3cd50e880e7e" />

Command: journalctl -u nginx -f: To see the live logs 
<img width="1555" height="82" alt="image" src="https://github.com/user-attachments/assets/fab3d7b5-81bd-4b50-95e2-71695ca529e2" />

Command: tail -n 50 /var/log/syslog  
<img width="1918" height="766" alt="image" src="https://github.com/user-attachments/assets/00b8f06a-e48e-4a3d-b7c4-95c9ebaf0958" />
<img width="822" height="282" alt="image" src="https://github.com/user-attachments/assets/b3c4472a-f02f-41de-9c8c-f82778d92cf8" />
-->So this command shows the latest 50 log entries from the system log. This is useful for: checking recent errors, debugging services, viewing latest system events,
troubleshooting crashes.

Command: tail -f /var/log/syslog: To see the live logs of the syslog, Here -f means “follow” the log in real time.
<img width="1906" height="362" alt="image" src="https://github.com/user-attachments/assets/e507e344-cc90-4d2f-9c33-720f0ea81c58" />

Common examples: journalctl -u ssh, journalctl -u nginx, journalctl -u docker, journalctl -u kubelet

- Pick **one service on your system** (example: `ssh`, `cron`, `docker`) and inspect it

-->Service inspection commands: for now use service: cron

Command to Check service status: **sudo systemctl status cron**: This shows: whether the service is running, PID, uptime, logs summary etc.
<img width="1751" height="453" alt="image" src="https://github.com/user-attachments/assets/77b7b70b-665e-46bc-a9a5-80a4331c686a" />

Command to check service is enabled at boot: **sudo systemctl is-enabled cron:** 
<img width="962" height="82" alt="image" src="https://github.com/user-attachments/assets/26564321-ab6b-4d56-9b90-429f8c60de22" />

Command to check the detail logs of the any service: **journalctl -u cron**: journalctl → system logs viewer & -u docker → logs only for the cron service unit, & id wanred to see live logs just add -f after service name in command

journalctl -u cron
<img width="1431" height="961" alt="image" src="https://github.com/user-attachments/assets/2e9b3bbc-6d46-4145-addf-4a0dd49b810b" />
journalctl -u cron -n 50
<img width="1897" height="921" alt="image" src="https://github.com/user-attachments/assets/2a17e471-7e92-4103-ad4b-57f449706dc2" />
journalctl -u cron -f
<img width="1915" height="427" alt="image" src="https://github.com/user-attachments/assets/92c198fe-d8e6-4dc5-b641-d2255c8895f7" />

Command: ps aux | grep cron [pgrep gives only the process ID (PID).]
<img width="1461" height="112" alt="image" src="https://github.com/user-attachments/assets/ee1faf34-82d3-4de0-ba99-09270f7b00bd" />

Command: ss -tulpn | grep cron & netstat -tulpn | grep docker [This gives output when particualr service is in running state]

Command: docker ps: To check the docker process & docker info: Both command are uesd to check is docker demon is responding or not
<img width="1637" height="972" alt="image" src="https://github.com/user-attachments/assets/5896aa1e-a84b-4774-8991-7dc25fa7dc48" />

- Keep it **simple and actionable**

Suggested structure for `linux-practice.md`:
- Process checks
- Service checks
- Log checks
- Mini troubleshooting steps

---

## Resources
You may refer to:

- Your notes from Day 02 and Day 03
- Linux `man` pages
- Your class notes

---

## Why This Matters for DevOps
Hands‑on practice builds speed and confidence.

When issues happen in production, you won’t have time to search for basic commands.  
This day helps you build muscle memory with Linux fundamentals.

---

## Submission
1. Fork this `90DaysOfDevOps` repository  
2. Navigate to the `2026/day-04/` folder  
3. Add your `linux-practice.md` file  
4. Commit and push your changes to your fork  

---

## Learn in Public
Share your Day 04 progress on LinkedIn:

- Post 2–3 lines on the Linux commands you practiced
- Share one service you inspected and what you learned
- Optional: screenshot of your practice note

Use hashtags:
#90DaysOfDevOps
#DevOpsKaJosh
#TrainWithShubham

Happy Learning
**TrainWithShubham**
