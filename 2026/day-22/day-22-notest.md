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

### Task 1: Install and Configure Git

1. Verify Git is installed on your machine--> In case git is not installed  then if we run comand git --status then we see following output,

<img width="967" height="165" alt="image" src="https://github.com/user-attachments/assets/49e1bdb3-8aec-4d8e-9efd-71698b6df3aa" />

2. Set up your Git identity — name and email

3. Verify your configuration

<img width="1075" height="472" alt="image" src="https://github.com/user-attachments/assets/04de5a7a-8db2-401d-b19d-e2feaa754880" />

---

### Task 2: Create Your Git Project
1. Create a new folder called `devops-git-practice`

2. Initialize it as a Git repository

<img width="1022" height="352" alt="image" src="https://github.com/user-attachments/assets/b3bf115c-9481-4801-a6a9-dd8a815dfede" />

3. Check the status — read and understand what Git is telling you

4. Explore the hidden `.git/` directory — look at what's inside

<img width="808" height="322" alt="image" src="https://github.com/user-attachments/assets/6d8b0d43-6434-4936-98bd-4022b94b1daf" />

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
