# Day 22 – Introduction to Git: Your First Repository

## Task

Today marks the beginning of your Git journey. Git is the backbone of modern DevOps — every tool, pipeline, and workflow revolves around version control. Before diving into advanced concepts, you need to get comfortable with the basics by doing.

You will:
- Understand what Git is and why it matters
- Set up your first Git repository from scratch
- Start building a living document of Git commands

---

## Expected Output
- A local Git repository with a clean commit history
- A file called `git-commands.md` that you will keep updating in future days
- A file called `day-22-notes.md` with your answers

---

## Challenge Tasks

Task 1: Install and Configure Git
1. Verify Git is installed on your machine
2. Set up your Git identity — name and email
3. Verify your configuration

**Steps to follow:**

Step 1: Verify Git is Installed: git --version

Note: If you see a version number, Git is already installed. & if it not install we will get git: command not found, then to install git run command: sudo apt update && sudo apt install git -y

-->Then verify the version again: git --version

Step 2: Configure Your Git Identity: Git stores your name and email in every commit.

-->Set your name: git config --global user.name "Your Name" Example: git config --global user.name "Sonali"

-->Set your email: git config --global user.email "your-email@example.com" Example: git config --global user.email "sonali@example.com"

Note: Replace the example email with the email associated with your GitHub account if you want your commits to be linked to your GitHub profile.

Step 3: Verify Your Configuration: Display your configured name: git config --global user.name

-->Display your configured email: git config --global user.email

-->You can also view all global Git settings: git config --global --list

Optional: Check Where the Configuration Is Stored: 

-->To see the file containing your global Git configuration: git config --global --edit

-->Or print the path: git config --global --show-origin --list

---

Task 2: Create Your Git Project
1. Create a new folder called devops-git-practice
2. Initialize it as a Git repository
3. Check the status — read and understand what Git is telling you
4. Explore the hidden .git/ directory — look at what's inside

**Steps to follow:**

Step 1: Create a New Project Folder: mkdir devops-git-practice && cd devops-git-practice

-->Verify Your Location: pwd

-->Step 2: Initialize the Git Repository: git init [Note: This creates a hidden .git directory that Git uses to track your project's history.]

Step 3: Check the Repository Status: git status
```
Expected Output:
On branch main
No commits yet
nothing to commit (create/copy files and use "git add" to track)

Understanding the Output:
On branch main →                              You're currently on the main branch.
No commits yet →                              The repository is new and has no commit history.
Nothing to commit →                           There are no files to track yet.
Create/copy files and use git add →           Git is telling you the next step.
```

Step 4: View Hidden Files: By default, .git is hidden, List all files, including hidden ones: ls -la

Step 5: Explore the .git Directory: Move inside the Git metadata directory: 

-->Move inside the Git metadata directory: cd .git

-->List its contents: ls -la

What Each Item Does: 

```
Item	                        Purpose
HEAD -->	              Points to the current branch.
config -->	           Repository-specific Git configuration.
description	-->        Used mainly by Git web interfaces.
hooks/ -->	           Stores Git hook scripts that run before or after Git actions.
info/	Contains -->     repository information such as exclude rules.
objects/ -->	        Stores commits, files (blobs), and other Git objects.
refs/	Stores -->       references to branches and tags.
branches/ -->	        Legacy directory for branch references (often empty in modern Git).
```





---

### Task 3: Create Your Git Commands Reference
1. Create a file called `git-commands.md` inside the repo
2. Add the Git commands you've used so far, organized by category:
   - **Setup & Config**
   - **Basic Workflow**
   - **Viewing Changes**
3. For each command, write:
   - What it does (1 line)
   - An example of how to use it
  
**git-command.md URL:** https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-22/git-commands.md

---

### Task 4: Stage and Commit
1. Stage your file
2. Check what's staged
3. Commit with a meaningful message
4. View your commit history

<img width="1036" height="250" alt="image" src="https://github.com/user-attachments/assets/3eb8ae84-0cfc-49df-ba41-147272186763" />

<img width="942" height="465" alt="image" src="https://github.com/user-attachments/assets/0797693d-0915-4cd4-8866-3676c6f5dbe3" />

<img width="717" height="162" alt="image" src="https://github.com/user-attachments/assets/b89ce7c5-c6e2-401e-8734-8602c17f8d7b" />

<img width="1460" height="308" alt="image" src="https://github.com/user-attachments/assets/3c5dfea4-292a-4528-9d83-5d8da79faa4b" />

---

### Task 5: Make More Changes and Build History
1. Edit `git-commands.md` — add more commands as you discover them
2. Check what changed since your last commit
3. Stage and commit again with a different, descriptive message
4. Repeat this process at least **3 times** so you have multiple commits in your history
5. View the full history in a compact format

<img width="926" height="551" alt="image" src="https://github.com/user-attachments/assets/0bee4de7-5325-4899-a028-262fafe839af" />

<img width="823" height="120" alt="image" src="https://github.com/user-attachments/assets/e0e3fb23-697d-4bf8-a65d-55bc701aff22" />

---

### Task 6: Understand the Git Workflow

Answer these questions in your own words (add them to a `day-22-notes.md` file):

1. What is the difference between `git add` and `git commit`?

-->**git add:** is used to stage changes by moving them from the working directory to the staging area. 

-->**git commit:** is used to save those staged changes into the local repository as a snapshot, To send changes to a remote repository like GitHub.

2. What does the **staging area** do? Why doesn't Git just commit directly?

-->**staging area**: The staging area in Git allows to review and select specific changes before committing them. It acts as an intermediate step between the 
   
   working directory and the repository, enabling clean, organized, and meaningful commits instead of committing everything at once.

5. What information does `git log` show you?

-->shows the commit history of a repository, including details like commit ID, author, date, and commit message. It helps track changes and understand the 

   project history. 

7. What is the `.git/` folder and what happens if you delete it?

--> The .git/ folder is the internal directory where Git stores all repository data, including commit history, branches, and configuration. If it is deleted,

    the project loses version control completely and becomes a normal directory, with no way to track previous changes.

9. What is the difference between a **working directory**, **staging area**, and **repository**?

-->The working directory is where files are created and modified. The staging area is an intermediate space where changes are prepared before committing. 

The repository is where Git permanently stores committed changes as version history. Together, they form the workflow of how changes move in Git.

**Flow Diagram**:

**Working Directory → Staging Area → Repository → Remote (GitHub)**
      
    (edit)           (git add)      (git commit)     (git push)

---

## Ongoing Task

**Keep updating `git-commands.md` every day** as you learn new Git commands in the upcoming days. This will become your personal Git reference. Maintain a clean commit history — one commit per update with a clear message.

---

## Hints
- All you need today are about 8-10 Git commands — Google them, try them, break things
- Read what `git status` tells you — it's your best friend
- Use `man git-<command>` or `git <command> --help` to explore

---

## Submission
1. Share a screenshot of your `git log --oneline` output showing multiple commits
2. Add your `day-22-notes.md` to `2026/day-22/`
3. Commit and push to your fork
4. Add your submission for Community Builder of the week on discord

---

## Learn in Public

Share your first Git repo and commit history on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
