# Day 23 – Git Branching & Working with GitHub

## Task

Now that you know how to create repos, stage, and commit — it's time to learn the most powerful concept in Git: **branching**. Branches let you work on features, fixes, and experiments in isolation without breaking your main code. You'll also push your work to GitHub for the first time.

---

## Expected Output
- A markdown file: `day-23-notes.md` with your answers
- Continue updating `git-commands.md` in your `devops-git-practice` repo
- Your practice repo pushed to GitHub

---

## Challenge Tasks

### Task 1: Understanding Branches
Answer these in your `day-23-notes.md`:
1. What is a branch in Git?

-->When you create a new branch, you make a copy of the current code, that allows us to work on features or fixes independently without affecting the main codebase.

   Once the changes are complete, the branch can be merged back into the main branch. Bydefault main Master branch is available in the github we can rename it to main.
   
   **Eg:** git branch feature-login -->To create new branch
      
           git checkout feature-login -->To switch to that created branch

2. Why do we use branches instead of committing everything to `main`?

-->By using branches we can Work in teams without conflicts, Keep project history clean, Fix bugs without breaking main code, Develop features independently etc

3. What is `HEAD` in Git?
-->in Git is a pointer that refers to the current commit or the latest commit on the active branch. It represents the current working position in the repository.

4. What happens to your files when you switch branches?

-->When switching branches in Git, the working directory is updated to reflect the files and commits of the target branch. Files may be added, removed, or

   modified based on the branch. If there are uncommitted changes that conflict, Git prevents the switch to avoid data loss.

---

### Task 2: Branching Commands — Hands-On
In your `devops-git-practice` repo, perform the following:
1. List all branches in your repo
2. Create a new branch called `feature-1`
3. Switch to `feature-1`
4. Create a new branch and switch to it in a single command — call it `feature-2`
5. Try using `git switch` to move between branches — how is it different from `git checkout`?
6. Make a commit on `feature-1` that does **not** exist on `main`
7. Switch back to `main` — verify that the commit from `feature-1` is not there
8. Delete a branch you no longer need
9. Add all branching commands to your `git-commands.md`

<img width="942" height="687" alt="image" src="https://github.com/user-attachments/assets/7dcd365d-877a-450b-9568-ca07edb2d285" />

<img width="1192" height="830" alt="image" src="https://github.com/user-attachments/assets/62c154bf-93d7-43f3-8b47-94fbba690b87" />

<img width="1158" height="890" alt="image" src="https://github.com/user-attachments/assets/1544b946-dd33-4070-b7d1-1a6bc5dda47d" />

---

### Task 3: Push to GitHub
1. Create a **new repository** on GitHub (do NOT initialize it with a README)
2. Connect your local `devops-git-practice` repo to the GitHub remote
3. Push your `main` branch to GitHub
4. Push `feature-1` branch to GitHub
5. Verify both branches are visible on GitHub

<img width="1056" height="688" alt="image" src="https://github.com/user-attachments/assets/86cc87ad-1afc-410e-ace7-10dd63be1f4e" />

<img width="1202" height="653" alt="image" src="https://github.com/user-attachments/assets/1934f27f-5eff-45b8-b8fa-bbaadc063742" />

6. Answer in your notes: What is the difference between `origin` and `upstream`?

-->**origin** refers to the default remote repository that points to your fork or cloned repository, while **upstream** refers to the original repository from which 

   the fork was created. **origin** is used for pushing your changes, and **upstream** is used to fetch updates from the main project.

---

### Task 4: Pull from GitHub
1. Make a change to a file **directly on GitHub** (use the GitHub editor)

2. Pull that change to your local repo

3. Answer in your notes: What is the difference between `git fetch` and `git pull`?

-->**git fetch** retrieves the latest changes from the remote repository without merging them into the current branch, allowing us to review updates.

   **git pull** fetches the changes and automatically merges them into the current branch.

   <img width="841" height="332" alt="image" src="https://github.com/user-attachments/assets/c4aa24dd-e27f-47ae-9175-cf6aee8fca7c" />

---

### Task 5: Clone vs Fork

1. **Clone** any public repository from GitHub to your local machine

2. **Fork** the same repository on GitHub, then clone your fork

3. Answer in your notes:

   **- What is the difference between clone and fork?**

   -->**git clone** creates a local copy of a repository on your system, while a fork creates a copy of a repository on your GitHub account. **Cloning** is used

      for local development, whereas **forking** is typically used to contribute to external projects without modifying the original repository.

   **- When would you clone vs fork?**
   
   -->Use git clone when you have direct access to a repository and want to work on it locally. Use fork when you don’t have write access and need to create your

      own copy of the repository to make changes and contribute via pull requests.

   **- After forking, how do you keep your fork in sync with the original repo?**
   
   -->To keep a fork in sync with the original repository, we add the original repo as an upstream remote, fetch the latest changes, merge or rebase them into our

    local branch, and then push the updates to our fork. 

---

## Hints
- When you create a branch, it starts from the commit you're currently on
- `git switch` is the modern alternative to `git checkout` for switching branches
- To push a new branch: `git push -u origin <branch-name>`
- A fork is a GitHub concept, not a Git concept

---

## Submission
1. Add your `day-23-notes.md` to `2026/day-23/`
2. Update `git-commands.md` with all new commands and commit
3. Push to your fork

---

## Learn in Public

Share your branching workflow and first GitHub push on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
