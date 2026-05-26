# Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs

## Task
Today’s goal is to **run a focused troubleshooting drill**.

You will pick a running process/service on your system and:
- Capture a quick health snapshot (CPU, memory, disk, network)
- Trace logs for that service
- Write a **mini runbook** describing what you did and what you’d do next if things were worse

This turns yesterday’s practice into a repeatable troubleshooting routine.

### What’s a runbook?
A **runbook** is a short, repeatable checklist you follow during an incident: the exact commands you run, what you observed, and the next actions if the issue persists. Keep it concise so you can reuse it under pressure.

---

## Expected Output
By the end of today, you should have:

- A markdown file named:  
  `linux-troubleshooting-runbook.md`

or

- A hand written runbook (Recommended)

Your runbook should include both the commands you ran and brief interpretations.

---

## Guidelines
Follow these rules while creating your runbook:

- Run and record output for **at least 8 commands** (save snippets in your runbook)  
  - **Environment basics (2):** `uname -a`, `lsb_release -a` (or `cat /etc/os-release`)
 
Observation: Confirmed Linux kernel version and Ubuntu distribution Ensured OS compatibility for systemd and nginx Environment Basics
<img width="1777" height="663" alt="image" src="https://github.com/user-attachments/assets/c897689d-1230-40da-931b-3add5c482db9" />

  - **Filesystem sanity (2):** create a throwaway folder and file, e.g., `mkdir /tmp/runbook-demo`, `cp /etc/hosts /tmp/runbook-demo/hosts-copy && ls -l /tmp/runbook-demo`  

**Note:** This is called a filesystem sanity check because it confirms: directory creation works, file copying works, file listing works, filesystem permissions are okay etc.
<img width="1602" height="136" alt="image" src="https://github.com/user-attachments/assets/627d4493-9326-43ec-95f3-f1e9339e22a4" />

  - **CPU / Memory (2):** `top`/`htop`/`ps -o pid,pcpu,pmem,comm -p <pid>`, `free -h`, `vm_stat` (mac)

-->Shows live system usage: CPU usage, Memory usage, Running processes, Updates continuously in real time etc.
<img width="1220" height="976" alt="image" src="https://github.com/user-attachments/assets/a3100f1e-4369-4225-8590-c60466634ac9" />

-->Improved and colorful version of top, Easier to read and interact with, Shows CPU, RAM, process list, etc. May need installation first.
<img width="1917" height="980" alt="image" src="https://github.com/user-attachments/assets/08291b03-d21d-4585-817a-468145d37817" />

-->Shows details for a specific process ID (PID) Output columns: pid → process ID, pcpu → CPU usage %, pmem → memory usage %, comm → command/process name etc.
<img width="1050" height="70" alt="image" src="https://github.com/user-attachments/assets/63a4aa71-3617-42a7-92e0-ccee4c2a7492" />

-->Displays RAM and swap memory usage, -h = human-readable format (MB/GB), Shows: total memory, used memory, free memory etc.
<img width="1008" height="87" alt="image" src="https://github.com/user-attachments/assets/8a47fa78-89fb-4558-9dc7-864141eef0cd" />


  - **Disk / IO (2):** `df -h`, `du -sh /var/log`, `iostat`/`vmstat`/`dstat`

-->**df -h:** df = disk filesystem usage: Shows: total disk space, used space, free space & -h = human-readable (GB/MB)
<img width="1343" height="383" alt="image" src="https://github.com/user-attachments/assets/03e2bb7a-2042-4960-8df3-329661d0b8bc" />

-->**du -sh /var/log:** du = disk usage Checks size of a directory, Options: -s = summary only, -h = human-readable, This command shows total size of /var/log.
<img width="927" height="47" alt="image" src="https://github.com/user-attachments/assets/3d603a87-42d6-4cc9-95d2-d5f906dd37f2" />

-->**iostat:** Shows CPU and disk I/O statistics, Useful for checking: disk read/write activity, IO bottlenecks, device utilization etc.
<img width="1198" height="278" alt="image" src="https://github.com/user-attachments/assets/2687ff65-30f2-419b-ae08-b772c1edce7f" />

-->**vmstat Displays:** memory usage, CPU activity,processes, swap, IO statistics & Useful for overall system performance troubleshooting.
<img width="1052" height="92" alt="image" src="https://github.com/user-attachments/assets/0afae259-8fea-4cca-a33a-4beaefa61f3a" />

-->**dstat:** is Combined monitoring tool it Shows: CPU, disk, network, memory, IO, processes etc. & installation is needed here.More user-friendly than using multiple tools separately.
<img width="867" height="287" alt="image" src="https://github.com/user-attachments/assets/ba631ac0-c911-48e7-9d31-9591a9dcbf1b" />

  - **Network (2):** `ss -tulpn`/`netstat -tulpn`, `curl -I <service-endpoint>`/`ping`

-->**ss -tulpn:** Shows: open ports, listening services, protocol details, process using the port etc.

-->Options: -t → TCP, -u → UDP, -l → listening ports, -p → process name/PID, -n → numeric output (no DNS resolution) etc.
<img width="1905" height="447" alt="image" src="https://github.com/user-attachments/assets/6f2af0f2-7d8f-4cb2-a928-7c685bd7cb07" />

-->netstat -tulpn: Older alternative to ssShows: netstat is a command-line utility used to display network connections, routing tables, interface statistics, masquerade connections, and listening ports.

-->netstat -l [Show listening ports]

-->netstat -t [Show TCP connections]

-->netstat -u [Show UDP connections]

-->netstat -n [Show numeric addresses instead of resolving hostnames]

-->sudo netstat -tulpn [Show processes using ports (Linux)]

-->netstat -r [Show routing table]

-->netstat -c [Continuously monitor connections]
<img width="1446" height="923" alt="image" src="https://github.com/user-attachments/assets/135625cd-1b19-4e7c-a761-755c22db2642" />

- **Logs (2):** `journalctl -u <service> -n 50`, `tail -n 50 /var/log/<file>.log` [Note: These commands are used to check logs in Linux systems.]

-->journalctl -u nginx -n 50: Used to view logs of a specific systemd service. Meaning of options -u → unit/service name & -n 50 → show last 50 log entries

-->Useful variations:

1. journalctl -u nginx -f: Follow logs live

2. journalctl -u docker --since today: Show logs since boot

3. journalctl -p err: Show errors only
<img width="1706" height="981" alt="image" src="https://github.com/user-attachments/assets/011834db-1ea3-4416-9241-4abfab00b588" />

-->tail -n 50 /var/log/<file>.log: Used to read the last lines of a normal log file. Meaning: tail → display end of file & -n 50 → show last 50 lines

--> tail -f /var/log/syslog [Follow logs live] 

Eg: 

1. docker logs: journalctl -u docker -n 50

2. SSH logs: tail -n 50 /var/log/auth.log

3. Kubernetes kubelet logs: journalctl -u kubelet -f

4. tail -f /var/log/nginx/access.log : Nginx access logs
<img width="1777" height="978" alt="image" src="https://github.com/user-attachments/assets/80dbca92-0cc8-462d-ab39-d0539dc6ed2b" />

- Choose **one target service/process** (e.g., `ssh`, `cron`, `docker`, your web app) and stick to it for the drill.

1. systemctl status docker: Check Docker service

2. journalctl -u docker -n 50: View Docker logs

3. journalctl -u docker -f: Follow logs live

4. ps aux | grep docker: Check Docker process

5. sudo netstat -tulpn | grep docker OR ss -tulpn | grep docker: Check Docker listening ports

6. docker ps: Check running containers

7. sudo systemctl restart docker: Restart service

-->Other services are also there: ssh, cron, nginx, apache2, kubelet etc.

<img width="616" height="392" alt="image" src="https://github.com/user-attachments/assets/d9376a45-9d58-40d6-9fe0-8560193a296e" />

- For each command, add a 1–2 line note on what you observed (e.g., “CPU spikes to 80% when restarting”, “No recent errors in last 50 lines”).
- End with a **“If this worsens”** section listing 3 next steps you would take (ex: restart strategy, increase log verbosity, collect `strace`).
- Keep it concise and actionable (aim for ~1 page).

Suggested structure for `linux-troubleshooting-runbook.md`:
- Target service / process

-->Target Service / Process Service: Docker

-->Commands used:

1. systemctl status docker: This command is used to check the docker status

2. ps aux | grep docker: This command is used to find Docker-related running processes. [Here | is used to Takes output from the left command and sends it to the right command. & grep commands Filters lines containing the word docker.]
<img width="827" height="641" alt="image" src="https://github.com/user-attachments/assets/299e4043-94e6-4381-8c63-4da01e87df3b" />

3. docker ps: To check the running dockers list
<img width="1891" height="778" alt="image" src="https://github.com/user-attachments/assets/d34bacfc-a0b9-4f8b-b92f-9567683f6f84" />

- Snapshot: CPU & Memory

1. top: It shows CPU utilization, Memory usage, Running processes, Load average etc. Alternetive is htop

2. free -h: It shows Memory usage: used → actively used RAM, free → completely unused RAM, buff/cache → Linux cache, available → actually usable memory etc.

3. ps -o pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head: 
<img width="1597" height="956" alt="image" src="https://github.com/user-attachments/assets/c949ce3d-0a6f-4398-850c-293906e77a5d" />

-->ps aux --sort=-%cpu | head: Find top CPU-consuming processes

-->ps aux --sort=-%mem | head: Find top Memory-consuming processes

-->mpstat -P ALL 2: Monitor CPU usage continuously [install if missing: sudo apt install sysstat -y]

-->uptime: Check system load average

-->lscpu: Check per-core CPU stats

- Snapshot: Disk & IO
- Snapshot: Network
- Logs reviewed
- Quick findings
- If this worsens (next steps)

---

## Resources
You may refer to:

- Notes from Day 02–04
- Linux `man` pages (`top`, `ps`, `df`, `journalctl`, `ss/netstat`)
- Your class notes

Avoid generic copy/paste. Use outputs from **your** machine.

---

## Why This Matters for DevOps
Incidents rarely come with perfect clues. A fast, repeatable checklist saves minutes when services misbehave.

This drill builds:
- Habit of capturing evidence before acting
- Confidence reading resource signals (CPU, memory, disk, network)
- Log-first mindset before restarts or escalations

These habits reduce downtime and prevent guesswork in production.

---

## Submission
1. Fork this `90DaysOfDevOps` repository  
2. Navigate to the `2026/day-05/` folder  
3. Add your `linux-troubleshooting-runbook.md` file  
4. Commit and push your changes to your fork  

---

## Learn in Public
Share your Day 05 progress on LinkedIn:

- Post 2–3 lines on the checks you ran and one insight
- Share the service you inspected and one “next step” from your runbook
- Optional: screenshot of your runbook

Use hashtags:  
#90DaysOfDevOps  
#DevOpsKaJosh  
#TrainWithShubham

Happy Learning  
**TrainWithShubham**
