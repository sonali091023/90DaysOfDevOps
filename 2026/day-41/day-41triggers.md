# Day 41 – Triggers & Matrix Builds

## Task
Your pipeline runs on push. Today you learn **every way to trigger a workflow** and how to run jobs across multiple environments at once.

---

## Expected Output
- New workflow files in your `github-actions-practice` repo
- A markdown file: `day-41-triggers.md`

---

## Challenge Tasks

### Task 1: Trigger on Pull Request
1. Create `.github/workflows/pr-check.yml`
2. Trigger it only when a pull request is **opened or updated** against `main`
3. Add a step that prints: `PR check running for branch: <branch name>`
4. Create a new branch, push a commit, and open a PR
5. Watch the workflow run automatically

**Verify:** Does it show up on the PR page?

**Steps to follow:**

Step 1: Go to your repository : github-actions-practice

Step 2: Make sure you're on the main branch: git checkout main && git pull origin main

Step 3: Create the workflow file: Create the following file: .github/workflows/pr-check.yml 

-->Your project should look like:
```
github-actions-demo/
│
├── .github/
│   └── workflows/
│       ├── hello.yml
│       └── pr-check.yml
│
└── README.md
```

Step 4: Add the workflow: Copy this YAML into pr-pull-request-chk.yml: [pr-pull-request-chk.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/pr-pull-request-chk.yml)

```
name: Pull Request Check

on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize

jobs:
  pr-check:
    runs-on: ubuntu-latest

    steps:
      - name: Print PR branch
        run: echo "PR check running for branch: ${{ github.head_ref }}"
```

**Understanding the workflow:** 

- Workflow name: The name shown in the GitHub Actions page
```name: Pull Request Check```

- Trigger: Runs only for Pull Requests.
```
on:
  pull_request:
```

- Target branch:
```
branches:
  - main
```
-->This means: PR into main
- Examples:
  - feature/login  ---> main   ✅ runs
  - bugfix/api ---> main       ✅ runs
  - feature ---> develop       ❌ doesn't run

Event types:
```
types:
  - opened
  - synchronize
```
Meaning:
- opened → workflow runs when a PR is created.
- synchronize → workflow runs whenever new commits are pushed to that PR.

Example: Create PR --> Workflow runs --> Push another commit --> Workflow runs again

- Runner: GitHub creates a temporary Ubuntu VM.
```runs-on: ubuntu-latest```

- Step: 
```run: echo "PR check running for branch: ${{ github.head_ref }}"```

github.head_ref is the source branch of the pull request.

Example: If your PR is feature-login --> main & then output is Output: PR check running for branch: feature-login

Step 5: Commit the workflow to main: 

-->git add .

-->git commit -m "Add PR workflow"

-->git push origin main

Note: The workflow must exist on the target branch (main) before GitHub can run it for future PRs. OR we can say, The workflow must already exist on the main branch before GitHub can use it for pull requests targeting main.

Step 6: Create a new branch: ```git checkout -b feature-pr-test```

-->Verify: 
```
git branch
output is: * feature-pr-test
             main
```

Step 7: Make any change: ```echo "Testing PR workflow" >> README.md```

Step 8: Commit: 

-->git add README.md

-->git commit -m "Test PR workflow"

Step 9: Push the branch: git push -u origin feature-pr-test [Here -u is not mandatory]

Step 10: Create the Pull Request: On GitHub:
- Click Compare & pull request.
- Ensure:
  - Base branch: main
  - Compare branch: feature-pr-test
- Click Create pull request.

Step 11: Watch the workflow: Immediately after creating the PR:
- Open the Actions tab.
- You should see: Pull Request Check Click it.

Step 12: View the logs: 

<img width="635" height="265" alt="image" src="https://github.com/user-attachments/assets/69b7af19-6c5a-4425-be24-e3ded3fe58d3" />

Step 13: Verify it appears on the PR page: 

<img width="710" height="282" alt="image" src="https://github.com/user-attachments/assets/71b01c77-fadd-46a7-96a2-94ed1bb71c8c" />

Step 14: Trigger the workflow again: Since the workflow includes:
```
types:
  - opened
  - synchronize
```
Push another commit to the same branch:

-->echo "Another change" >> README.md

-->git add README.md

-->git commit -m "Update PR"

-->git push

-->The workflow will automatically run again because the PR was updated (synchronize event).

What you should observe:

<img width="742" height="352" alt="image" src="https://github.com/user-attachments/assets/a7ea40ac-5eff-4bac-bb4f-e1fe0b7c7a7f" />
<img width="1665" height="961" alt="image" src="https://github.com/user-attachments/assets/1f02b31b-d1d5-4d34-a4e5-cfdf80468df3" />
<img width="1781" height="532" alt="image" src="https://github.com/user-attachments/assets/a5ce51c0-5ad1-4a8a-a14f-7e9472cfd1a5" />
<img width="1867" height="821" alt="image" src="https://github.com/user-attachments/assets/c6a602cb-6c8b-4e42-a2c0-e0c4cb3d59ca" />
<img width="1897" height="951" alt="image" src="https://github.com/user-attachments/assets/dc863169-e6eb-45b7-a992-c89a4f2520c1" />
<img width="1910" height="847" alt="image" src="https://github.com/user-attachments/assets/e145e9b4-fdb2-463d-96b9-664bbda17eae" />
<img width="1912" height="880" alt="image" src="https://github.com/user-attachments/assets/5bc1572f-7b93-429b-93ca-77e92ba2fac6" />
<img width="1901" height="947" alt="image" src="https://github.com/user-attachments/assets/f276c781-4bd8-44cc-93bc-75c5e271440b" />
<img width="1911" height="715" alt="image" src="https://github.com/user-attachments/assets/aa937247-d14f-4988-9a88-a9877e9dace7" />
<img width="1911" height="417" alt="image" src="https://github.com/user-attachments/assets/7d3cd3d6-552c-4f2b-a5ed-cde5338d1807" />
<img width="1901" height="582" alt="image" src="https://github.com/user-attachments/assets/cd3ca32c-cce2-40e6-a55f-8b0a46f30d55" />
<img width="1916" height="937" alt="image" src="https://github.com/user-attachments/assets/8521c63c-3142-41ff-8b27-93ec628b0a82" />

Q. Does it show up on the PR page?
Yes. GitHub displays the workflow as a status check on the pull request. If the workflow succeeds, you'll see a green check mark. If it fails, you'll see a red cross with a link to inspect the logs.










-->**Create new repository for the github-actions practice:** https://github.com/sonali091023/github-actions-practice/tree/main/.github/workflows

-->Yes, it shows up on the PR page, And the workflow is visible and runs automatically on the PR page when configured correctly

**Steps to perform:**

-->Create Repo-->github-actions-practice-->And now add new file like README.md file and commit the same being in main branch

-->Now create new branch-->for that click branch dropdwon and enter the name-->then we can see create branch option click on it and new branch will get create

-->Now create new workflow in new branch-->Click on Add file-->new file-->.github/workflows/pr-check.yml and add yml file content in the pr-check.yml file and Commit directly to feature/pr-test

**Verify:** Does it show up on the PR page?

<img width="1881" height="901" alt="image" src="https://github.com/user-attachments/assets/0a1f2afb-1199-44e9-a41e-91023a6da59d" />

<img width="1336" height="582" alt="image" src="https://github.com/user-attachments/assets/108148e2-6494-4577-bbf1-216a0bc58371" />

<img width="1815" height="642" alt="image" src="https://github.com/user-attachments/assets/9ccad23b-7c09-470d-992d-60bfd025c514" />

<img width="1903" height="745" alt="image" src="https://github.com/user-attachments/assets/fe26ef65-13fc-457f-9999-ba6984987dc5" />

<img width="1877" height="775" alt="image" src="https://github.com/user-attachments/assets/5522e227-9d8e-41d0-a864-d255eed2ef05" />

---

### Task 2: Scheduled Trigger
1. Add a `schedule:` trigger to any workflow using cron syntax
2. Set it to run every day at midnight UTC

<img width="455" height="242" alt="image" src="https://github.com/user-attachments/assets/435fc829-d5c4-4196-8ed6-6148dbeac4a7" />

3. Write in your notes: What is the cron expression for every Monday at 9 AM?
-->Cron expression for every monday at 9 am is **0 9 * * 1**, So here meaning of

0 → minute (00), 

9 → hour (9 AM), 

(astric*) → every day of month,

(astric*) → every month,

1 → Monday etc.

---

### Task 3: Manual Trigger
1. Create `.github/workflows/manual.yml` with a `workflow_dispatch:` trigger
2. Add an **input** that asks for an `environment` name (staging/production)
3. Print the input value in a step
4. Go to the **Actions** tab → find the workflow → click **Run workflow**

**Verify:** Can you trigger it manually and see your input printed?

<img width="1886" height="757" alt="image" src="https://github.com/user-attachments/assets/74d4f2aa-9c62-44dd-a1e1-e73eb31d5667" />

<img width="1906" height="821" alt="image" src="https://github.com/user-attachments/assets/f06fa576-e570-4085-b761-b2c5ab3741e0" />

---

### Task 4: Matrix Builds
Create `.github/workflows/matrix.yml` that:
1. Uses a matrix strategy to run the same job across:
   - Python versions: `3.10`, `3.11`, `3.12`
2. Each job installs Python and prints the version
3. Watch all 3 run in parallel

<img width="1897" height="778" alt="image" src="https://github.com/user-attachments/assets/5a74638e-f3d8-4297-8304-35d1a0a196d5" />

Then extend the matrix to also include 2 operating systems — how many total jobs run now?

-->Total 6 jobs executed, Matrix creates combinations (Cartesian product), not separate groups.

<img width="1886" height="837" alt="image" src="https://github.com/user-attachments/assets/80ad3f92-23ae-4698-8df0-8b737c2a9ea8" />

---

### Task 5: Exclude & Fail-Fast
1. In your matrix, **exclude** one specific combination (e.g., Python 3.10 on Windows)

-->As we have excluded python-version: 3.10 for windows-latest os we can see 5 jobs running as below,

<img width="1883" height="852" alt="image" src="https://github.com/user-attachments/assets/0b1da0aa-0d54-4ed3-931f-ae2f4dfbb33e" />

2. Set `fail-fast: false` — trigger a failure in one job and observe what happens to the rest

-->For Python version 3.11 job gets failed because of exit code 1 in both os ubuntu-latest & windows-latest as you can see below,

<img width="1918" height="907" alt="image" src="https://github.com/user-attachments/assets/13264baa-38d2-4607-bae0-6ec2650f351e" />

3. Write in your notes: What does `fail-fast: true` (the default) do vs `false`?

-->**fail-fast: true (default):** As soon as one job fails, GitHub cancels all other running/pending jobs

-->This fail-fast: true condition is kind of Faster feedback which saves resources, **Simple way to remember is stop everything on first failure**

-->**fail-fast: false:** Even if one job fails, All other jobs continue running

-->This fail-fast false is useful when you want to test all environments 7 You need full results not partial result, **Simple way to remember is let all jobs finish no matter what**

---

## Hints
- PR trigger: `on: pull_request: branches: [main]`
- Cron trigger: `on: schedule: - cron: '0 0 * * *'`
- Manual trigger: `on: workflow_dispatch: inputs:`
- Matrix: `strategy: matrix: python-version: [...]`
- Exclude: `exclude: - os: windows-latest python-version: "3.10"`

---

## Documentation
Create `day-41-triggers.md` with:
- Each workflow YAML
- Screenshots of runs
- The cron expression answer from Task 2

---

## Submission
1. Add `day-41-triggers.md` to `2026/day-41/`
2. Commit and push to your fork

---

## Learn in Public
Share your matrix build screenshot — seeing multiple jobs run in parallel for the first time is a great moment.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
