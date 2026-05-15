# Day 28 – Revision Day: Everything from Day 1 to Day 27

## Task

You've covered a lot of ground in 27 days — DevOps fundamentals, Linux deep dives, Shell scripting, Python basics, Git & GitHub, and even your developer branding. Today, **stop and revise**. No new concepts. Just solidify what you've learned.

The goal is to identify gaps, revisit topics you struggled with, and make sure you can confidently explain and use everything covered so far.

---

## What You've Covered So Far

| Days | Topic | Key Concepts |
|------|-------|-------------|
| 1 | DevOps & Cloud Intro | What is DevOps, SDLC, Cloud basics |
| 2–7 | Linux Fundamentals | Architecture, commands, processes, systemd, file system hierarchy, troubleshooting, text files |
| 8 | Cloud Server Setup | Docker, Nginx, web deployment |
| 9–11 | Users, Permissions & Ownership | User/group management, file permissions, chown/chgrp |
| 12 | Revision Day 1 | Days 1–11 recap |
| 13 | Volume Management | LVM — physical volumes, volume groups, logical volumes |
| 14–15 | Networking | Fundamentals, DNS, IP, subnets, ports, hands-on checks |
| 16–18 | Shell Scripting | Basics, loops, arguments, error handling, functions |
| 19–20 | Shell Scripting Projects | Log rotation, backup, crontab, log analyzer |
| 21 | Shell Scripting Cheat Sheet | Personal reference guide |
| 22–25 | Git & GitHub | Init, branching, merge, rebase, stash, cherry pick, reset, revert, branching strategies |
| 26 | GitHub CLI | Managing GitHub from the terminal |
| 27 | GitHub Profile | Profile README, repo organization, developer branding |

---

## Challenge Tasks

### Task 1: Self-Assessment Checklist
Go through the checklist below. For each item, mark yourself honestly:
- **Can do confidently**
- **Need to revisit**
- **Haven't done yet**

#### Linux
- [ ] Navigate the file system, create/move/delete files and directories     -->Can do confidently
- [ ] Manage processes — list, kill, background/foreground                   -->Can do confidently
- [ ] Work with systemd — start, stop, enable, check status of services      -->Can do confidently
- [ ] Read and edit text files using vi/vim or nano                          -->Can do confidently
- [ ] Troubleshoot CPU, memory, and disk issues using top, free, df, du      -->Can do confidently
- [ ] Explain the Linux file system hierarchy (/, /etc, /var, /home, /tmp, etc.)   -->Can do confidently
- [ ] Create users and groups, manage passwords     -->Can do confidently
- [ ] Set file permissions using chmod (numeric and symbolic)    -->Can do confidently
- [ ] Change file ownership with chown and chgrp     -->Can do confidently
- [ ] Create and manage LVM volumes     -->Can do confidently
- [ ] Check network connectivity — ping, curl, netstat, ss, dig, nslookup    -->Can do confidently
- [ ] Explain DNS resolution, IP addressing, subnets, and common ports   -->Can do confidently

#### Shell Scripting
- [ ] Write a script with variables, arguments, and user input    -->Need to revisit
- [ ] Use if/elif/else and case statements                        -->Need to revisit
- [ ] Write for, while, and until loops                           -->Need to revisit
- [ ] Define and call functions with arguments and return values  -->Need to revisit
- [ ] Use grep, awk, sed, sort, uniq for text processing          -->Need to revisit
- [ ] Handle errors with set -e, set -u, set -o pipefail, trap    -->Need to revisit
- [ ] Schedule scripts with crontab                               -->Can do this confidently

#### Git & GitHub
- [ ] Initialize a repo, stage, commit, and view history          -->Can do this confidently
- [ ] Create and switch branches                                  -->Can do this confidently
- [ ] Push to and pull from GitHub                                -->Can do this confidently
- [ ] Explain clone vs fork                                       -->Can do this confidently
- [ ] Merge branches — understand fast-forward vs merge commit    -->Can do this confidently
- [ ] Rebase a branch and explain when to use it vs merge         -->Can do this confidently
- [ ] Use git stash and git stash pop                             -->Can do this confidently
- [ ] Cherry-pick a commit from another branch                    -->Can do this confidently
- [ ] Explain squash merge vs regular merge                       -->Can do this confidently
- [ ] Use git reset (soft, mixed, hard) and git revert            -->Can do this confidently
- [ ] Explain GitFlow, GitHub Flow, and Trunk-Based Development   -->Need to revisit
- [ ] Use GitHub CLI to create repos, PRs, and issues             -->Need to revisit

---

### Task 2: Revisit Your Weak Spots
1. Pick **3 topics** from the checklist where you marked "Need to revisit"
2. Go back to that day's challenge and redo the hands-on tasks
3. Document what you re-learned in `day-28-notes.md`

---

### Task 3: Quick-Fire Questions
Answer these from memory (no Googling). Then verify your answers:

1. What does `chmod 755 script.sh` do?

-->Change the file permission

2. What is the difference between a process and a service?

-->**Process** is any running program

-->**Service** is a special type of process that runs in the background (usually long-running)

3. How do you find which process is using port 8080?

-->Jenkins/apache tomxcat/Node.js servers/Sprint boot apps are using port 8080

4. What does `set -euo pipefail` do in a shell script?  

-->set -euo pipefail is a defensive setting in Bash that makes your script fail fast instead of silently continuing on errors. It combines 3 options as below:

  1. set -e (exit on error): The script stops immediately if any command exits with a non-zero status.

  2. set -u (undefined variables = error): Treats unset variables as errors and exits.

  3. set -o pipefail (catch pipeline failures): Makes a pipeline fail if any command in it fails, not just the last one.

5. What is the difference between `git reset --hard` and `git revert`?

-->rewrites history and removes commits, while git revert safely undoes changes by creating a new commit. Reset is used locally, whereas revert is preferred in shared repositories.

6. What branching strategy would you recommend for a team of 5 developers shipping weekly?

-->A better fit is a lightweight, trunk-based workflow with short-lived branches.

7. What does `git stash` do and when would you use it?

-->git stash is used to hide the current working directory task and inbetween we can switch to other branch and start work overthere.

8. How do you schedule a script to run every day at 3 AM?

--> 0.3.0.0.0

9. What is the difference between `git fetch` and `git pull`?

-->git fetch only downloads changes and lets me review them, while git pull fetches and automatically merges them into my current branch. Fetch is safer because it avoids unintended merges.

10. What is LVM and why would you use it instead of regular partitions?

-->LVM (Logical Volume Manager) is a storage management layer in Linux that lets you create flexible, resizable “virtual partitions” instead of being stuck with fixed disk partitions. Instead of carving a disk into rigid chunks up front, LVM lets you pool storage and allocate it dynamically.

---

### Task 4: Organize Your Work
1. Make sure all your daily submissions (day-1 through day-27) are committed and pushed
2. Check that your `git-commands.md` is up to date
3. Check that your shell scripting cheat sheet is complete
4. Verify your GitHub profile and repos are clean (from Day 27)

---

### Task 5: Teach It Back
Pick **one topic** you've learned and write a short explanation (5-10 lines) as if you're teaching it to someone who has never heard of it. Add it to your `day-28-notes.md`.

Examples:
- Explain Git branching to a non-developer
- Explain file permissions to a new Linux user
- Explain what a crontab is and why sysadmins use it

Teaching is the best test of understanding.

---

## Submission
1. Add your `day-28-notes.md` to `2026/day-28/`
2. Push to your fork
3. Make sure all previous days are pushed and up to date

---

## Learn in Public

Share your self-assessment results or your "teach it back" explanation on LinkedIn. Be honest about what you found easy and what you need to work on.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
