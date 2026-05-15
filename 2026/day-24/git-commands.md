**Git Commands Used:**

**git reflog:** This shows all recent actions

git init

git status

git config --global user.name "Mention name"

git config --global user.email "mention email"

**Note:** If we remove --global from the above command we can set the configuration locally as well **Eg:** git config user.name "sonali"

**To verify the Configuratopn details used command:**

git config --global user.name

git config --global user.email OR git config --list

**Note:** **Global config is stored in: ~/.gitconfig** And **Local config is stored in: .git/config inside your repo**

Git Commands organized by category:
- **Setup & Config**

1. git config: Sets username, email, and other Git configurations.

2. git init: Initializes a new Git repository

3. git clone: Copies an existing repository from remote to local

- **Basic Workflow**

1. **git status:** Shows current state of files (staged, unstaged, untracked)

2. **git add:** Adds files to staging area Eg: git add . [To add all the files and directories etc] Also we can mention specif file name to add

3. **git commit:** Saves staged changes with a message

4. **git push:** Uploads local commits to remote repository

5. **git pull:** Fetches and merges changes from remote repo

- **Viewing Changes**

6. **git log:** Shows commit history

7. **git diff:** Shows differences between file versions

8. **git show:** Displays details of a specific commit

10. **git branch:** Lists or creates branches

11. **git checkout:** Switches between branches

**To push the code to the new repository for the first time/New repository use below commands:**

1. git init

2. git add README.md

3. git commit -m "first commit"

4. git branch -M main

5. git remote add origin https://github.com/sonali091023/gitcommands.git

6. git push -u origin main

**To push the code to existing repository use commands:**

1. git remote add origin https://github.com/sonali091023/gitcommands.git

2. git branch -M main

3. git push -u origin main

**Viewing Changes/To Check the commit logs use commands:**

1. **git log:** View History in detail

2. **git log --oneline:** view history in oneline

3. **git status:** Check file status

4. **git diff:** Se changes

**Branching git commands:**

1. **git branch:** List branches	

2. **git branch feature:** Create branch	

3. **git checkout feature:** Switch branch	

4. **git checkout -b feature:** Create + switch	

5. **git merge feature:** Merge branch

6. **git merge --abort:** To abort the merge and restore everything

7. **git rebase --abort**: This restores your repo to exactly how it was before rebase started

8. **git merge --squash feature-branch**: Take multiple commits → merge them into a single commit, Used to keep history clean

9. **git cherry-pick <commit-id>:** git cherry-pick is used when you want to take a specific commit from one branch and apply it to another branch

**To Undo Changes**

1. **git restore file.txt:** Discard changes

**Note:** Git moves the current branch pointer (HEAD) to a previous commit, Commits after that point are removed from branch history, Depending on the option, 

your files may also change. reset rewrite the history thasts why it is dengours for the shared branches. reset Pretends this commit never happened

2. **git reset file.txt:** Unstage file

3. **git reset --hard:** Go back to last commit state, but don’t touch history, Resets your working directory & staging area to the current HEAD, Does NOT move

HEAD, Just discards uncommitted changes
  
4. **git reset --hard HEAD~1:** Delete last commit completely like it never happened/If merge completed but files are missing due to that want to undo/

5. **git reset --hard HEAD@{1}:** It Means: Where HEAD was previously, This is the safest and most powerful recovery method, This brings you back to previous

state (before reset)

**Note:** --hard always deletes changes, But reflog (HEAD@{1}) can save you if used quickly

7. **git reset --mixed HEAD~1:** Undo commit, unstage everything, Keeps changes in files but unstaged, Best for reworking what to stage

8. **git reset --soft HEAD~1:** With the help --soft only the last commit is undone, but keeps everything ready/staged for new commit, Best for: fixing commit

messages or regrouping commits

8. **git reset HEAD~1:** Use when: You want to edit before committing again, Removes last commit, Keeps changes in working directory, Unstages files

**Remote Repository**

1. **git remote -v:** Show remotes

2. **git remote add origin:** Add remote

3. **git push -u origin main**: First push

**Git stash and Git stash pop:**

**git stash:** git stash is used to temporarily save uncommitted changes without committing them, allowing you to work on something else.

**git stash pop:** git stash pop restores the most recent stashed changes and removes them from the stash list.

**git stash list:** To show all the stashes

**git stash apply:** Restores stash without deleting it

**git stash drop:** Deletes a stash manually

**To remove an unwanted branch in Git**

1. **Delete a local branch:** git branch -d branch-name [Deletes the branch safely only if its already merged]

2. **Force delete the branch:** git branch -D branch-name [Use carefully — this permanently deletes the branch]

3. **Delete a remote branch:** git push origin --delete branch-name

**Note:** You cannot delete the branch you're currently on.

-->Use git status before doing anything to understand your current state.

-->Avoid --hard and --force unless you're sure.

1. Discard changes before staging (not added yet): This will remove all local changes and bring the file back to the last committed state

--> **git restore <file-name>**

2.Discard changes after staging (after git add): If you already added the file by using git add .

-->**git restore --staged <file-name>**

3. Discard all local changes: This will remove everything you changed

-->**git restore .**

4. Undo last commit (but keep code): If you already committed but want to undo

-->**git reset --soft HEAD~1**

5. "Undo my last commit… but keep everything ready to commit again. OR Undo last commit and delete code: This permanently deletes the changes

-->**git reset --hard HEAD~1**

6. If code is already pushed to GitHub: If you've pushed and want to remove it

**Revert Note:** Add a new commit to cancel previous changes, Git creates a new commit, This commit reverses changes of a previous commit, No history is deleted

-->git revert <commit-id> **[Safe way (recommended)]**

-->**git revert HEAD:** Original commit stays, New commit added that cancels it

-->git reset --hard HEAD~1 OR git push --force **[Force way (dangerous)]**

