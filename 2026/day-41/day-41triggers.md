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

Step 1: Go to your repository: github-actions-practice

Step 2: Create the workflow file: Create the following file: .github/workflows/pr-check.yml 

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

Step 3: Add the workflow: Copy this YAML into pr-check.yml: [pr-lifecycle.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/pr-lifecycle.yml)
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
