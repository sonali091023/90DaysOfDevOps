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

Step 6: View the Current Branch Reference: cat HEAD

Example output: ref: refs/heads/main [Note: This means HEAD points to the main branch.]

Step 7: Return to Your Project Directory: cd .. && pwd

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

**Steps to follow:**
  
**git-command.md URL:** https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-22/git-commands.md

Step 1: Make Sure You're Inside Your Repository: cd ~/devops-git-practice

-->verify: pwd

Step 2: Create the Markdown File: Create a new file named git-commands.md: touch git-commands.md

-->then to verify: ls

Step 3: Open the File: vi git-commands.md & add the content into it.

[git-commands.md](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-22/git-commands.md)

Step 6: View the File: cat git-commands.md OR less git-commands.md

---

### Task 4: Stage and Commit
1. Stage your file
2. Check what's staged
3. Commit with a meaningful message
4. View your commit history

Step 1: Make Sure You're Inside the Repository: cd ~/devops-git-practice

-->verify: pwd

Step 2: Check the Current Status: git status
```
Expected Output:
On branch main
No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
  git-commands.md
  nothing added to commit but untracked files present

What It Means:
git-commands.md exists but Git is not tracking it yet.
The file must be staged before it can be committed.
```

Step 3: Stage the File: Stage your Markdown file: git add git-commands.md

-->To stage all files in the current directory, you could also use: git add .

Step 4: Verify What's Staged: git status
```
Expected Output:
On branch main
No commits yet
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
    new file:   git-commands.md

What It Means:
The file is now in the staging area.
It is ready to be committed.
```

Step 5: Create Your First Commit: Commit the staged file with a meaningful message: git commit -m "Add Git commands reference documentation"
```
Expected Output
[main (root-commit) abc1234] Add Git commands reference documentation
 1 file changed, 80 insertions(+)
 create mode 100644 git-commands.md

The commit ID (abc1234) will be different on your system.
```

Step 6: Verify the Working Tree: git status
```
Expected Output
On branch main
nothing to commit, working tree clean

What It Means:
All changes have been committed.
Your repository is clean.
```

Step 7: View Commit History: Show the commit history: git log
```
Example Output
commit a1b2c3d4e5f678901234567890abcdef12345678
Author: Sonali <sonali@example.com>
Date:   Sat Aug 1 12:45:00 2026 +0530

    Add Git commands reference documentation

Press Q to exit the log viewer.
```

-->View a Shorter Commit History: A compact view: git log --oneline

Git Workflow Summary:
```
Create/Edit File
        │
        ▼
git status
        │
        ▼
git add git-commands.md
        │
        ▼
git status
        │
        ▼
git commit -m "Add Git commands reference documentation"
        │
        ▼
git log
```

Expected Deliverables: By the end of this task, you should have:
- Staged git-commands.md using git add
- Verified the staged file with git status
- Created your first commit with a meaningful message
- Confirmed the repository is clean using git status
- Viewed your commit history using git log and git log --oneline

Key Concepts Learned:

Command	                                           Purpose
git status -->                                Shows the current state of your repository
git add -->	                                  Moves changes to the staging area
git commit -m "message" -->      	          Saves staged changes as a snapshot
git log -->	                                  Displays detailed commit history
git log -->                                   oneline	Shows a concise commit history

---

### Task 5: Make More Changes and Build History
1. Edit `git-commands.md` — add more commands as you discover them
2. Check what changed since your last commit
3. Stage and commit again with a different, descriptive message
4. Repeat this process at least **3 times** so you have multiple commits in your history
5. View the full history in a compact format

**Steps to follow:**

-->The goal of this task is to understand that Git records your project's history as a series of commits. Each commit should represent one logical change with a clear commit message.

Step 1: Go to Your Repository: cd ~/devops-git-practice

-->then to verify: pwd

Step 2: Edit git-commands.md: vi git-commands.md & add new commands into it

[git-commands.md](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-22/git-commands.md)

Step 3: Check What Changed:

-->verify: git status

-->Now see the actual changes: git diff

Note: This command displays every line you've added, removed, or modified since the last commit.

Step 4: Stage the Changes: git add git-commands.md

-->Verify the staged changes: git status

-->Optionally, view the staged differences: git diff --staged

Step 6: Make Another Update: Open the file again: vi git-commands.md After addition save then chnages

[git-commands.md](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-22/git-commands.md)

-->verify: git status

-->Now see the actual changes: git diff

-->git add git-commands.md

-->Verify the staged changes: git status

-->git commit -m "Document Git log commands"

Step 7: Make a Third Update: Open the file again: vi git-commands.md After addition save then changes

-->view the changes: git diff

-->stage the chnages: git add git-commands.md

-->commit the chnages: git commit -m "Add basic branch management commands"

Step 8: View Your Complete History: Compact history: git log --oneline
```
Example:

d82f9f1 Add basic branch management commands
8c3f721 Document Git log commands
7b21f4c Add Git diff commands to reference
5a8d2c0 Add Git commands reference documentation

Newest commit appears at the top.
```

Optional: View History as a Graph: git log --oneline --graph
```
Example:

* d82f9f1 Add basic branch management commands
* 8c3f721 Document Git log commands
* 7b21f4c Add Git diff commands to reference
* 5a8d2c0 Add Git commands reference documentation
```

Expected Repository Progress:
```
devops-git-practice/
├── .git/
└── git-commands.md

Commit history:

Commit 4 → Add basic branch management commands
Commit 3 → Document Git log commands
Commit 2 → Add Git diff commands to reference
Commit 1 → Add Git commands reference documentation
```
---

Task 6: Understand the Git Workflow
Answer these questions in your own words (add them to a day-22-notes.md file):

1. What is the difference between git add and git commit?
2. What does the staging area do? Why doesn't Git just commit directly?
3. What information does git log show you?
4. What is the .git/ folder and what happens if you delete it?
5. What is the difference between a working directory, staging area, and repository?

**Steps to follow:**

Answer these questions in your own words (add them to a `day-22-notes.md` file):

1. What is the difference between `git add` and `git commit`?

-->**git add:** is used to stage changes by moving them from the working directory to the staging area. 

-->**git commit:** is used to save those staged changes into the local repository as a snapshot, To send changes to a remote repository like GitHub.

-->OR simply we can say, `git add` moves new or modified files to the staging area, preparing them to be included in the next commit. `git commit` saves the staged changes as a permanent snapshot in the Git repository with a commit message.


2. What does the **staging area** do? Why doesn't Git just commit directly?

-->**staging area**: The staging area in Git allows to review and select specific changes before committing them. It acts as an intermediate step between the working directory and the repository, enabling clean, organized, and meaningful commits instead of committing everything at once. OR we can say The staging area lets you review and choose exactly which changes should be included in the next commit. This gives you control to organize related changes into meaningful commits instead of committing everything at once.


3. What information does `git log` show you?

-->shows the commit history of a repository, including details like commit ID, author, date, and commit message. It helps track changes and understand the project history. 

4. What is the `.git/` folder and what happens if you delete it?

--> The .git/ folder is the internal directory where Git stores all repository data, including commit history, branches, and configuration. If it is deleted, the project loses version control completely and becomes a normal directory, with no way to track previous changes.

5. What is the difference between a **working directory**, **staging area**, and **repository**?

- **Working Directory:** The files and folders you are currently editing.

- **Staging Area (Index):** A temporary area where changes are prepared before being committed.

- **Repository:** The Git database that permanently stores all commits, branches, and project history.

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
