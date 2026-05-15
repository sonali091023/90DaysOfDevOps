# Day 25 – Git Reset vs Revert & Branching Strategies

## Task

You'll learn how to **undo mistakes** safely — one of the most important skills in Git. You'll also explore **branching strategies** used by real engineering teams to manage code at scale.

---

## Expected Output
- A markdown file: `day-25-notes.md` with your observations and answers
- Continue updating `git-commands.md` in your `devops-git-practice` repo

---

## Challenge Tasks

### Task 1: Git Reset — Hands-On
1. Make 3 commits in your practice repo (commit A, B, C)
2. Use `git reset --soft` to go back one commit — what happens to the changes? 
3. Re-commit, then use `git reset --mixed` to go back one commit — what happens now?
4. Re-commit, then use `git reset --hard` to go back one commit — what happens this time?

<img width="917" height="913" alt="image" src="https://github.com/user-attachments/assets/ef61a62a-d0fa-4a2b-b2f9-63a0134a631a" />

<img width="987" height="847" alt="image" src="https://github.com/user-attachments/assets/28854b47-6851-44af-bc4e-d95eec854f3b" />

<img width="897" height="735" alt="image" src="https://github.com/user-attachments/assets/1577143b-ce96-484f-8aaa-8843b1c0b2da" />

<img width="867" height="393" alt="image" src="https://github.com/user-attachments/assets/41dce4e9-e966-48d8-bd0a-ccb06e46d479" />

6. Answer in your notes:

**What is the difference between `--soft`, `--mixed`, and `--hard`?**

--> **--soft:** With the help --soft only the last commit is undone, but keeps everything ready/staged for new commit, Best for: fixing commit messages or 

regrouping commits **eg:** **git reset --soft HEAD~1**

--> **--mixed:** Undo commit, unstage everything, Keeps changes in files but unstaged, Best for reworking what to stage **eg:** **git reset --mixed HEAD~1**
   
--> **--hard:** Undo everything — like it never happened, Removes commit, Deletes changes from staging AND files, Dangerous data loss. 

**eg:** **git reset --hard HEAD~1**

**Which one is destructive and why?**

--> **--hard** is destructive because it permanently discards all uncommitted changes in your staging area and working directory.

**When would you use each one?**

--> **--soft:** when you want to undo a commit but keep changes staged,for example to edit the commit message.

--> **--mixed:** when you want to undo a commit and unstage changes,so you can modify them before recommitting.

--> **--reset:** when you want to completely remove commits and all changes.

**Should you ever use `git reset` on commits that are already pushed?**

-->No,once commits are pushed,others may have already pulled and worked on them,so resetting them can cause confusion and conflicts.

---

### Task 2: Git Revert — Hands-On

1. Make 3 commits (commit X, Y, Z)

<img width="881" height="982" alt="image" src="https://github.com/user-attachments/assets/7094271b-43a1-45b5-afc4-77e8c33ec56b" />

2. Revert commit Y (the middle one) — what happens?

<img width="767" height="371" alt="image" src="https://github.com/user-attachments/assets/0c34c7fe-01dc-4b79-8721-53c8fcb79190" />

3. Check `git log` — is commit Y still in the history?

-->Commit Y is still in the history.A new commit was added.

<img width="767" height="371" alt="image" src="https://github.com/user-attachments/assets/a4040cf2-836e-47a9-aa00-596103cea6c0" />

6. Answer in your notes:

**How is git revert different from git reset?**

-->**git revert:** Creates a new commit that undoes changes from a previous commit.Keeps original commit in history

-->**git reset:** Can rewrite history.Moves the branch pointer to an earlier commit

**Why is revert considered safer than reset for shared branches?**

-->git revert does not rewrite history.

**When would you use revert vs reset?**

-->**git revert:** On branches that are already pushed/shared.To undo a commit without breaking history.

-->**git reset:** When you want to rewrite history or completely remove commits

---

### Task 3: Reset vs Revert — Summary
Create a comparison in your notes:

| | `git reset` | `git revert` |
|---|---|---|
| What it does | Can rewrite history.Moves the branch pointer to an earlier commit | Creates a new commit that undoes changes from a previous commit.Keeps original commit in history |
| Removes commit from history? | Yes | No |
| Safe for shared/pushed branches? | No | Yes |
| When to use | When you want to rewrite history or completely remove commits | On branches that are already pushed/shared.To undo a commit without breaking history |

---

### Task 4: Branching Strategies

Research the following branching strategies and document each in your notes with:

### Task 4: Branching Strategies

1. **GitFlow**
    
    **How it works:**

    - `main`      : Contains production-ready code.Every commit here is a stable release.
        
    - `develop`   : The integration branch where new features are merged before they’re ready to go live.
    
    - `feature`   : For building out new functionality.Created from develop and merged back when complete.
        
    - `release`   : Used to prep a new version for production.Created from develop and merged into both main and develop.

    - `hotfix`   : For urgent fixes on production.Created from main,then merged back into both main and develop.

    **Text Diagram:**
    ```text
    [main] (Production-ready)
    |
    o <----------------------------------------- (Start)
    | \
    |  \ [develop] (Integration)
    |   |
    |   o <------------------------------------- (Develop Start)
    |   | \
    |   |  \ [feature/login] (New functionality)
    |   |   |
    |   |   o (Feature Commit)
    |   |   |
    |   |   o (Feature Complete)
    |   |  /
    |   o / (Merge feature to develop)
    |   |
    |   | \
    |   |  \ [release/1.0] (Prep for production)
    |   |   |
    |   |   o (Release Prep/Bug Fix)
    |   |   |
    |   |   o (Release Ready)
    |   |  / \
    |   o /   o (Merge release to develop)
    |  /
    o / (Merge release to main & tag v1.0)
    |
    | \
    |  \ [hotfix/1.0.1] (Urgent fix)
    |   |
    |   o (Apply Fix)
    |  / \
    o /   o (Merge hotfix to develop)
    |
    V
    ```

    **When/where it's used:**

    - Team follows scheduled release cycles

    - Need to maintain multiple versions

    **Pros:** 
    - Clear separation of concerns across features,releases,and hotfixes.

    **Cons:** 
    - Can result in long-lived branches,increasing the risk of merge conflicts.



2. **GitHub Flow**

    **How it works:**

    - Create a `feature branch` from `main`
    - Push commits to the `feature branch`
    - Open a pull request for code review and automated tests.
    - Once approved, merge back to `main`.
    - Deploy immediately.
    - Everything in main should always be production-ready.

    **Text Diagram:**
    ```text  
   
      [main] (Always Production-Ready)
        |
        o (Start)
        |
        |\_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ 
        |                               \
        |                                \ [feature/login]
        |                                 |
        |                                 o (Commit 1)
        |                                 |
        |                                 o (Commit 2)
        |                                 |
        |                                 o (Pull Request & Review)
        |<_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _/
        |                               
        o (Merge & Auto-Deploy)
        |
        v
    ```

    **When/where it's used:**
    - ship frequent,small releases

     **Pros:**
    - Fast merge & deploy
    
     **Cons:**
     - In large teams,it can result in frequent merge conflicts

3. **Trunk-Based Development**

    **How it works:**

    - There’s one `main` branch, often called main or trunk. All development happens here
    - Developers commit directly to `main`, often multiple times per day
    - Changes are small,incremental

     **Text Diagram:**
     ```text
      [main] (The Trunk)
        |
        o (Start)
        |
        |\_ _ _ _ _ _ _ 
        |             \
        |              o (Dev A: Small Change)
        |<_ _ _ _ _ _ /
        |             /
        o (Merge & Test)
        |
        |\_ _ _ _ _ _ _ 
        |             \
        |              o (Dev B: Small Change)
        |<_ _ _ _ _ _ /
        |             /
        o (Merge & Test)
        |
        v
    ```

    **When/where it's used:**
    - building SaaS products or anything that updates frequently


    **Pros:**
    - Delivers the fastest feedback from dev to prod

    **Cons:**
    - Can be risky without tests

4. Answer:

   - Which strategy would you use for a startup shipping fast?
        - Trunk-Based Development
        
   - Which strategy would you use for a large team with scheduled releases?

        - GitFlow

   - Which one does your favorite open-source project use?

        - https://github.com/aws-containers/retail-store-sample-app.git (GitHub Flow)


---

### Task 5: Git Commands Reference Update
Update your `git-commands.md` to cover everything from Days 22–25:
- Setup & Config
- Basic Workflow (add, commit, status, log, diff)
- Branching (branch, checkout, switch)
- Remote (push, pull, fetch, clone, fork)
- Merging & Rebasing
- Stash & Cherry Pick
- Reset & Revert

---

## Hints
- `git reflog` is your safety net — it shows everything Git has done, even after a hard reset
- For branching strategies, look at how projects like Kubernetes, React, or Linux kernel manage branches

---

## Submission
1. Add your `day-25-notes.md` to `2026/day-25/`
2. Update `git-commands.md` — commit and push
3. Push to your fork

---

## Learn in Public

Share your Reset vs Revert comparison or your branching strategy notes on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
