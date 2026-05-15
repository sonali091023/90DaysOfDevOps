# Day 24 – Advanced Git: Merge, Rebase, Stash & Cherry Pick

## Task

You know how to branch and push to GitHub. Now it's time to learn how branches come back together — and what to do when you're in the middle of something and need to context-switch. These are the Git skills that separate beginners from confident practitioners.

---

## Expected Output
- A markdown file: `day-24-notes.md` with your observations and answers
- Continue updating `git-commands.md` in your `devops-git-practice` repo

---

## Challenge Tasks

### Task 1: Git Merge — Hands-On
1. Create a new branch `feature-login` from `main`, add a couple of commits to it
<img width="967" height="772" alt="image" src="https://github.com/user-attachments/assets/d783653e-f73d-4977-9d7d-9d702fd36c43" />
<img width="955" height="822" alt="image" src="https://github.com/user-attachments/assets/e27d1ac2-ebdf-4a4a-b832-b21463babb8d" />

2. Switch back to `main` and merge `feature-login` into `main`: -->used merge command: **git merge feature-login**

<img width="1101" height="940" alt="image" src="https://github.com/user-attachments/assets/13a98060-1c80-41b2-85c5-e8ef3c988431" />

3. Observe the merge — did Git do a **fast-forward** merge or a **merge commit**?

-->Git did **fast-forward** merge.

4. Now create another branch `feature-signup`, add commits to it — but also add a commit to `main` before merging

<img width="1345" height="927" alt="image" src="https://github.com/user-attachments/assets/c83c8c3e-6c86-4962-9871-05bc2dd36e37" />

<img width="967" height="346" alt="image" src="https://github.com/user-attachments/assets/d36c4f9a-cfc4-4e2d-9120-175a1bac150d" />

5. Merge `feature-signup` into `main` — what happens this time?

<img width="780" height="958" alt="image" src="https://github.com/user-attachments/assets/25714302-9c8a-454d-97c0-642d4db4dbb7" />

6. Answer in your notes:

   **- What is a fast-forward merge?**
   
   -->A fast-forward merge is the simplest type of Git merge where no new commit is created — Git just moves the branch pointer forward.

      Because Git doesn’t need to combine histories — it just moves forward in a straight line.

   **- When does Git create a merge commit instead?**
   
   -->If main and feature-signup both have changes after branching, Git creates a merge commit when it cannot do a fast-forward merge — meaning the branch histories have diverged.

   **- What is a merge conflict? (try creating one intentionally by editing the same line in both branches)**

   -->A merge conflict happens when Git cannot automatically decide which changes to keep while merging two branches, This usually occurs when the same file and same line are modified in both branches.

---

### Task 2: Git Rebase — Hands-On
1. Create a branch `feature-dashboard` from `main`, add 2-3 commits
2. While on `main`, add a new commit (so `main` moves ahead)
3. Switch to `feature-dashboard` and rebase it onto `main`
4. Observe your `git log --oneline --graph --all` — how does the history look compared to a merge?

<img width="1036" height="928" alt="image" src="https://github.com/user-attachments/assets/a3b6ebe4-b23a-46fc-91dc-24254ba4c814" />

<img width="1028" height="877" alt="image" src="https://github.com/user-attachments/assets/15ce1915-369b-4447-a57b-39f12985a2cb" />

<img width="960" height="856" alt="image" src="https://github.com/user-attachments/assets/88e5b944-7f65-49ae-a4eb-1ea530f8e5a2" />

<img width="983" height="605" alt="image" src="https://github.com/user-attachments/assets/f8b7fcee-5920-46ce-918b-e8295f49d760" />

5. Answer in your notes:

**What does rebase actually do to your commits?**

-->rebase "rewrites history" by taking your feature-dashboard branch commits and replaying them one by one on top of the latest version of main.

**How is the history different from a merge?**

-->mergepreserves history exactly as it happened.creates a merge commit. rebase rewrites history.moves your commits on top of feature-dashboard branch,creates a 
linear,clean history.no merge commit.

**Why should you never rebase commits that have been pushed and shared with others?**

-->because rebase changes commit id's,if others pulled the old commits:their history won’t match yours anymore causes conflicts,duplicated commits.

**When would you use rebase vs merge?**

-->**rebase:** keeping history linear

-->**merge:** working on shared branches.you want full history preserved.

---

### Task 3: Squash Commit vs Merge Commit
1. Create a branch `feature-profile`, add 4-5 small commits (typo fix, formatting, etc.)
2. Merge it into `main` using `--squash` — what happens?
3. Check `git log` — how many commits were added to `main`?

-->So Git combines all changes into one, It stages all changes as one big change OR "Take all changes, ignore commit history, create ONE clean commit"

<img width="1172" height="897" alt="image" src="https://github.com/user-attachments/assets/7a7c14d3-d35d-4102-b072-c110a33a5d45" />

<img width="802" height="303" alt="image" src="https://github.com/user-attachments/assets/8b7f7952-07fe-4a4d-8415-3ef7124ff636" />

<img width="1007" height="865" alt="image" src="https://github.com/user-attachments/assets/79fc8d4f-5fbf-4a4a-b5fd-80b5db6decc3" />

<img width="1112" height="648" alt="image" src="https://github.com/user-attachments/assets/86e9f3d0-67f1-450b-a107-0ef187967b6b" />

4. Now create another branch `feature-settings`, add a few commits
5. Merge it into `main` **without** `--squash` (regular merge) — compare the history

<img width="1162" height="881" alt="image" src="https://github.com/user-attachments/assets/0b0a4e78-2dee-46f3-9ed2-64ce965a0a19" />

<img width="953" height="927" alt="image" src="https://github.com/user-attachments/assets/6cedbdf2-a488-4a3c-8c94-2a7a0692e1fd" />

<img width="842" height="943" alt="image" src="https://github.com/user-attachments/assets/cea64c18-96d0-44a7-807a-dd35ca836325" />

<img width="907" height="638" alt="image" src="https://github.com/user-attachments/assets/940f6548-0a9f-4706-95f5-6a99d9269d70" />

6. Answer in your notes:

**What does squash merging do?**
Combines all commits from a feature branch into one single commit on main.
Does not preserve individual commit history.

**When would you use squash merge vs regular merge?**
squash merge: Feature branch has many commits.You want clean main branch history.
regular merge: You want to preserve full commit history.

**What is the trade-off of squashing?**
The trade-off of squashing is that while it keeps the main branch history clean and linear,it removes the detailed commit history of the feature branch by combining everything into a single commit.

---

### Task 4: Git Stash — Hands-On
1. Start making changes to a file but **do not commit**
2. Now imagine you need to urgently switch to another branch — try switching. What happens?
3. Use `git stash` to save your work-in-progress
4. Switch to another branch, do some work, switch back
5. Apply your stashed changes using `git stash pop`
6. Try stashing multiple times and list all stashes
7. Try applying a specific stash from the list

<img width="1165" height="967" alt="image" src="https://github.com/user-attachments/assets/00ae45d2-f266-41c1-b4c9-b0b66c6bd236" />

<img width="1097" height="962" alt="image" src="https://github.com/user-attachments/assets/62846bc1-d1cd-4e93-aef0-1538fe7f3840" />

<img width="1290" height="883" alt="image" src="https://github.com/user-attachments/assets/b66dea5f-c30d-4c07-b22f-9b2a1ab2d59f" />

<img width="951" height="920" alt="image" src="https://github.com/user-attachments/assets/07ef9600-61a2-487b-b33f-2d079a3c2978" />

8. Answer in your notes:
**What is the difference between git stash pop and git stash apply?**

-->**git stash pop:** brings your stashed changes back to your working directory.deletes that entry from your stash list immediately.

-->**git stash apply:** brings the stashed changes back to your working directory.keeps the entry in your stash list.

**When would you use stash in a real-world workflow?**

-->If I’m working on a feature and need to urgently switch branches to fix a production bug, I would use git stash to temporarily save my unfinished changes before switching.

---

### Task 5: Cherry Picking
1. Create a branch `feature-hotfix`, make 3 commits with different changes
2. Switch to `main`
3. Cherry-pick **only the second commit** from `feature-hotfix` onto `main`
4. Verify with `git log` that only that one commit was applied

<img width="1137" height="337" alt="image" src="https://github.com/user-attachments/assets/1c31c748-9758-4690-b55b-7ca4e5da0db2" />

<img width="1062" height="916" alt="image" src="https://github.com/user-attachments/assets/01a52367-5cef-46c2-96ff-10384cbeb12c" />

<img width="1038" height="392" alt="image" src="https://github.com/user-attachments/assets/86a95bbd-9ce2-4fd2-aa36-e9828e60eb8e" />

<img width="862" height="597" alt="image" src="https://github.com/user-attachments/assets/8b5d7209-e102-4873-a0bd-c943c18d1e1e" />

<img width="853" height="476" alt="image" src="https://github.com/user-attachments/assets/bb94c8cd-dfda-48ef-a89c-e1ac68ecf1af" />

<img width="952" height="573" alt="image" src="https://github.com/user-attachments/assets/15744e71-f51f-4f8c-91b3-e087243d61ac" />

6. Answer in your notes:

**What does cherry-pick do?**

-->Applies a specific commit from one branch to another and creates a new commit with a new ID.

**When would you use cherry-pick in a real project?**

-->When I need only specific changes, like applying a hotfix from a feature branch to main,without merging the entire branch 

**What can go wrong with cherry-picking?**

-->merge conflicts if same file was modified.

-->Commit history confusion because it creates new commit ids.

---

## Hints
- Visualize history: `git log --oneline --graph --all`
- To intentionally create a merge conflict: edit the **same line** of the **same file** on two branches
- Stash with a message: `git stash push -m "description"`
- Cherry-pick needs a commit hash — find it with `git log --oneline`

---

## Submission
1. Add your `day-24-notes.md` to `2026/day-24/`
2. Update `git-commands.md` with all new commands and commit
3. Push to your fork

---

## Learn in Public

Share your merge vs rebase comparison on LinkedIn — a diagram or screenshot of `git log --graph` goes a long way!

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
