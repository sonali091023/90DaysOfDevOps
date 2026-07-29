# Day 12 – Breather & Revision (Days 01–11)

## Goal
Take a **one-day pause** to consolidate everything from Days 01–11 so you don’t forget the fundamentals you just built.

## Expected Output
- A markdown file: `day-12-revision.md`  
  (bullet notes + checkpoints)  
- Optional: screenshots of any re-runs you do

## What to Review (pick at least one per section)
- **Mindset & plan:** revisit your Day 01 learning plan—are your goals still right? any tweaks?
~~~
Day 12 Review

1. Goal:
Become confident in Linux, Docker, Kubernetes, AWS, Terraform, and CI/CD.

2. Progress:
✓ Linux commands
✓ File permissions
✓ Users and Groups
✓ Docker
✓ Kubernetes basics

3. Areas to improve:
- Faster command recall
- Kubernetes troubleshooting
- Bash scripting

4. Next goals:
- Learn Shell Scripting
- Practice Kubernetes daily
- Start CI/CD projects
~~~
- **Processes & services:** rerun 2 commands from Day 04/05 (e.g., `ps`, `systemctl status`, `journalctl -u <service>`); jot what you observed today.

~~~
Step 1: View running processes: ps aux
Observe:
- Which user owns the process?
- What is the PID?
- Which process is using the most CPU?

Step 2: Check a service: For example, check SSH: systemctl status ssh
-->If SSH isn't installed, check Docker: systemctl status docker
-->Or Nginx: systemctl status nginx
Look for:
- Active or inactive status
- Process ID (PID)
- Start time

Step 3: View service logs: Example: journalctl -u docker --no-pager -n 20 OR journalctl -u ssh --no-pager -n 20
-->This displays the last 20 log entries. Document your observations, For example:
Observations:
- Docker service is active.
- Service started successfully.
- No recent errors in logs.
~~~

- **File skills:** practice 3 quick ops from Days 06–11 (e.g., `echo >>`, `chmod`, `chown`, `ls -l`, `cp`, `mkdir`).
~~~
Practice three common operations.

1. Create and append to a file:
-->echo "Linux Review" > review.txt
-->echo "Day 12 Practice" >> review.txt
-->cat review.txt

Expected:
Linux Review
Day 12 Practice

2. Change permissions
-->chmod 644 review.txt
-->Verify:ls -l review.txt
Expected: -rw-r--r--

3. Copy the file: cp review.txt backup-review.txt
-->Verify: ls [Note: You should now have both files.]
~~~
- **Cheat sheet refresh:** skim your Day 03 commands—highlight 5 you’d reach for first in an incident.
<img width="821" height="597" alt="image" src="https://github.com/user-attachments/assets/4da9ebfd-2347-4c55-8f29-a51121fbb8dc" />
- **User/group sanity:** recreate one small scenario from Day 09 or Day 11 (create a user or change ownership) and verify with `id`/`ls -l`.
~~~
Create a practice user: sudo useradd demo-user
Verify: id demo-user
Expected: uid=1005(demo-user) gid=1005(demo-user) groups=1005(demo-user)

Create a file: touch demo.txt
Change its owner: sudo chown demo-user demo.txt
Verify: ls -l demo.txt
Expected: -rw-r--r-- 1 demo-user your-group 0 Jul 29 16:50 demo.txt
~~~

## Mini Self-Check (write short answers in `day-12-revision.md`)
1) Which 3 commands save you the most time right now, and why?  
2) How do you check if a service is healthy? List the exact 2–3 commands you’d run first.  
3) How do you safely change ownership and permissions without breaking access? Give one example command.  
4) What will you focus on improving in the next 3 days?
~~~
# Day 12 Revision - Mini Self-Check

## 1. Which 3 commands save you the most time right now, and why?

### a) `ls -l`
- Helps me quickly check files, permissions, owner, and group information.

### b) `systemctl status <service>`
- Lets me check whether a service is running and if there are any recent errors.

### c) `kubectl get pods -A`
- Since I am learning Kubernetes, it helps me quickly see the status of all pods across namespaces.

---

## 2. How do you check if a service is healthy? List the exact 2–3 commands you'd run first.

```bash
systemctl status docker
journalctl -u docker --no-pager -n 20
ps aux | grep docker
```

These commands help me:
- Check whether the service is active.
- Review recent log messages.
- Verify that the service process is running.

---

## 3. How do you safely change ownership and permissions without breaking access? Give one example command.

I first verify the current owner and permissions using `ls -l`. Then I change only the required owner, group, or permissions and verify the result again.

Example:

```bash
sudo chown professor:planners project-config.yaml
chmod 640 project-config.yaml
ls -l project-config.yaml
```

This ensures the correct user and group own the file while maintaining secure permissions.

---

## 4. What will you focus on improving in the next 3 days?

- Practice Linux commands until I can use them without referring to notes.
- Improve Kubernetes troubleshooting by debugging pods, deployments, and services.
- Learn Bash scripting basics to automate repetitive Linux tasks.
~~~

## Suggested Flow (30–45 minutes)
- 10 min: skim notes from each day, update Day 01 plan if needed.  
- 15–20 min: rerun a tiny hands-on set (process check, service check, file permission change).
~~~
A. Process Check

View running processes:

ps aux

Find a specific process (example: Docker):

ps aux | grep docker
B. Service Check

Check Docker:

systemctl status docker

If Docker isn't available, check another service such as SSH:

systemctl status ssh

View recent logs:

journalctl -u docker --no-pager -n 15

or

journalctl -u ssh --no-pager -n 15
C. File Permission Practice

Create a practice file:

touch revision.txt

Add content:

echo "Linux Revision Day 12" > revision.txt

Check permissions:

ls -l revision.txt

Change permissions:

chmod 640 revision.txt

Verify:

ls -l revision.txt

Expected:

-rw-r----- 1 username username ...
D. Ownership Practice

Create a practice user (only if needed):

sudo useradd -m trainee

Change ownership:

sudo chown trainee revision.txt

Verify:

ls -l revision.txt
~~~
- 5–10 min: write the self-check answers and key takeaways.



## Tips
- Keep it light—this is about retention, not new concepts.  
- If something felt shaky this week (e.g., `chmod` numbers, `journalctl` flags), practice that specifically.  
- Small wins: one screenshot of a command rerun + 5 bullet notes is enough.

## Submission
1. Navigate to `2026/day-12/`  
2. Add `day-12-revision.md` with your bullets and answers  
3. Commit and push to your fork

## Learn in Public
Post 2–3 lines on what you reinforced today and one command you now remember confidently.

Use hashtags:  
#90DaysOfDevOps  
#DevOpsKaJosh  
#TrainWithShubham

Happy Learning  
**TrainWithShubham**
