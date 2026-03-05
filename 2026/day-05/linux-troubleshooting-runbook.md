**Day 05 – Linux Troubleshooting Drill: CPU, Memory, and Logs** 

**Tagret service: Nginx**

**1. Environment Basics**

uname -a

cat /etc/os-release

**Observation:** Confirmed Linux kernel version and Ubuntu distribution Ensured OS compatibility for systemd and nginx Environment Basics

<img width="1127" height="717" alt="img1" src="https://github.com/user-attachments/assets/4db95416-6ce8-442a-b4ca-98dbf5b230f3" />


**2. Process & CPU / Memory Snapshot**

pgrep -l nginx

ps -o pid,pcpu,pmem,comm -p <pids>

free -h

df -h

vmstat 1 5

**Observation:** nginx master and worker processes running CPU usage stable, no abnormal spikes Memory utilization within safe limits Process

<img width="981" height="648" alt="img2" src="https://github.com/user-attachments/assets/e1649179-1b5d-43e7-b5c9-e5348a49f012" />


**3. Disks & I/O checks**

df -h

du -sh /var/log/nginx

iostat

**Observation:** Root filesystem has sufficient free space Log directory size under control Disk I/O

**4. Network**

ss -tulpn | grep nginx

ss -tulpn

curl -I http://publicip:80

**Observation:** nginx listening on port 80 HTTP 200 response confirms service availability 

<img width="1791" height="972" alt="im3" src="https://github.com/user-attachments/assets/2542d8b5-2592-445e-a0a7-23f56f323591" />


sstulpn

curl

**5. Log Inspection**

tail -n 50 /var/log/nginx/access.log

journalctl -u nginx

**Observation:** No recent errors or warnings Service started cleanly without crashes tail

<img width="1912" height="963" alt="img4" src="https://github.com/user-attachments/assets/e43de07d-126a-4039-96d7-571a1d760012" />


**Key Findings**

--> nginx was healthy and responding correctly

--> No resource exhaustion detected

--> Logs were clean, confirming normal operation 

**If this worsens (next steps)**

**Test nginx configuration** sudo nginx -t

**Restart the service**

sudo systemctl restart

--> **Increase log verbosity for deeper inspection**  

--> **Capture metrics using htop, vmstat, or monitoring tools**

--> **Enable alerts for CPU, memory, and disk thresholds**
