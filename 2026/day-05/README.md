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

-->df = disk filesystem usage: Shows: total disk space, used space, free space & -h = human-readable (GB/MB)
<img width="1343" height="383" alt="image" src="https://github.com/user-attachments/assets/03e2bb7a-2042-4960-8df3-329661d0b8bc" />

-->du = disk usage Checks size of a directory, Options: -s = summary only, -h = human-readable, This command shows total size of /var/log.
<img width="927" height="47" alt="image" src="https://github.com/user-attachments/assets/3d603a87-42d6-4cc9-95d2-d5f906dd37f2" />

-->Shows CPU and disk I/O statistics, Useful for checking: disk read/write activity, IO bottlenecks, device utilization etc.
<img width="1198" height="278" alt="image" src="https://github.com/user-attachments/assets/2687ff65-30f2-419b-ae08-b772c1edce7f" />

-->vmstat Displays: memory usage, CPU activity,processes, swap, IO statistics & Useful for overall system performance troubleshooting.
<img width="1052" height="92" alt="image" src="https://github.com/user-attachments/assets/0afae259-8fea-4cca-a33a-4beaefa61f3a" />

-->dstat is Combined monitoring tool it Shows: CPU, disk, network, memory, IO, processes etc. & installation is needed here.More user-friendly than using multiple tools separately.
<img width="867" height="287" alt="image" src="https://github.com/user-attachments/assets/ba631ac0-c911-48e7-9d31-9591a9dcbf1b" />


  - **Network (2):** `ss -tulpn`/`netstat -tulpn`, `curl -I <service-endpoint>`/`ping`  
  - **Logs (2):** `journalctl -u <service> -n 50`, `tail -n 50 /var/log/<file>.log`
- Choose **one target service/process** (e.g., `ssh`, `cron`, `docker`, your web app) and stick to it for the drill.
- For each command, add a 1–2 line note on what you observed (e.g., “CPU spikes to 80% when restarting”, “No recent errors in last 50 lines”).
- End with a **“If this worsens”** section listing 3 next steps you would take (ex: restart strategy, increase log verbosity, collect `strace`).
- Keep it concise and actionable (aim for ~1 page).

Suggested structure for `linux-troubleshooting-runbook.md`:
- Target service / process
- Snapshot: CPU & Memory
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
