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

---

### Task 2: Scheduled Trigger
1. Add a `schedule:` trigger to any workflow using cron syntax
2. Set it to run every day at midnight UTC
3. Write in your notes: What is the cron expression for every Monday at 9 AM?

**Steps to follow:**

-->This task teaches you how to run a GitHub Actions workflow automatically on a schedule using a cron expression.

Step 1: Choose a workflow: Create file schedule.yml

Step 2: Add the scheduled trigger: Create or update the workflow with the following content:
```
name: Daily Scheduled Workflow

on:
  schedule:
    - cron: '0 0 * * *'   # Every day at 00:00 UTC
  workflow_dispatch:       # Optional: lets you run it manually

jobs:
  scheduled-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print message
        run: echo "This workflow runs every day at midnight UTC."
```

Q. Why add workflow_dispatch?

-->Since the schedule only runs at 00:00 UTC, you may not want to wait until then to verify your workflow. Adding:
```workflow_dispatch:```
-->When we add this workflow_dispatch in the code in that case, lets you run it manually from the Actions tab for testing.

Step 3: Understand the cron expression: The expression used is: 0 0 * * *

-->So Cron has five fields:
<img width="720" height="471" alt="image" src="https://github.com/user-attachments/assets/43401b3e-98f1-4ad1-a8c7-b0a661035238" />

Step 4: Commit and push: 

-->git add .github/workflows/scheduled.yml

-->git commit -m "Add scheduled workflow"

-->git push origin main

<img width="1902" height="890" alt="image" src="https://github.com/user-attachments/assets/bf478c91-9461-4dbb-b46d-a29c5bc9792a" />
<img width="1897" height="942" alt="image" src="https://github.com/user-attachments/assets/c2f98cbc-4674-4ff4-a0a2-3e3b0be5a591" />
<img width="1907" height="891" alt="image" src="https://github.com/user-attachments/assets/e7068052-f6c7-42ef-8903-7164fc7613ca" />
<img width="1892" height="962" alt="image" src="https://github.com/user-attachments/assets/adba273d-748c-4bc5-b80e-13c491f1b079" />

Q1. Cron expression to run every day at midnight UTC?

-->0 0 * * *

Q2. What is the cron expression for every Monday at 9 AM?

-->0 9 * * 1

Explanation:
- 0 → minute 0
- 9 → 9 AM
- * → every day of the month
- * → every month
- 1 → Monday

---

### Task 3: Manual Trigger
1. Create `.github/workflows/manual.yml` with a `workflow_dispatch:` trigger
2. Add an **input** that asks for an `environment` name (staging/production)
3. Print the input value in a step
4. Go to the **Actions** tab → find the workflow → click **Run workflow**

**Verify:** Can you trigger it manually and see your input printed?

**Steps to follow:**

-->This task teaches you how to create a manually triggered GitHub Actions workflow that accepts user input.

Step 1: Go to your repository: Make sure you're on the main branch: git checkout main

-->git pull origin main

Step 2: Create the workflow file: vi manual.yml [manual.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/manual.yml)

Step 3: Add the workflow: 
```
name: Manual Deployment

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Choose the deployment environment"
        required: true
        default: "staging"
        type: choice
        options:
          - staging
          - production

jobs:
  manual-job:
    runs-on: ubuntu-latest

    steps:
      - name: Print selected environment
        run: echo "Selected environment: ${{ inputs.environment }}"
```

Step 4: Understand the workflow:
```
Workflow name
name: Manual Deployment

This is the name you'll see in the Actions tab.

Manual trigger
on:
  workflow_dispatch:

This tells GitHub:

Do not run automatically. Only run when someone clicks "Run workflow".

Input field
inputs:
  environment:

This creates a dropdown on GitHub.

Available choices:

staging
production
Print the input
run: echo "Selected environment: ${{ inputs.environment }}"

If you select production, the log will show:

Selected environment: production
```

Step 5: Commit the workflow: 

-->git add .github/workflows/manual.yml

-->git commit -m "Add manual workflow"

-->git push origin main

Step 6: Open the Actions tab: 
- Go to your GitHub repository.
- Click the Actions tab.
- In the left sidebar, click Manual Deployment.

<img width="1880" height="950" alt="image" src="https://github.com/user-attachments/assets/e24469e2-41de-46cf-a00e-1cbeb066abc6" />

-->You should see something like: Manual Deployment

Step 7: Run the workflow: 

<img width="702" height="547" alt="image" src="https://github.com/user-attachments/assets/761fc1c4-60d9-4405-82f2-f8692a92de74" />

Step 8: Check the logs

<img width="671" height="392" alt="image" src="https://github.com/user-attachments/assets/0161932d-c9ff-4d57-851b-984b11abeadd" />

Step 10: Verify the task

Q. Can you trigger it manually and see your input printed?

-->Yes. The workflow can be started manually from the Actions tab using the Run workflow button. After selecting an environment (staging or production), the workflow runs and prints the selected value in the job logs.

<img width="675" height="501" alt="image" src="https://github.com/user-attachments/assets/87ac2b30-51bb-4495-8330-910cfa47041f" />

---

### Task 4: Matrix Builds
Create `.github/workflows/matrix.yml` that:
1. Uses a matrix strategy to run the same job across:
   - Python versions: `3.10`, `3.11`, `3.12`
2. Each job installs Python and prints the version
3. Watch all 3 run in parallel

Then extend the matrix to also include 2 operating systems — how many total jobs run now?

**Steps to follow:**

-->This task introduces Matrix Builds, one of the most useful features in GitHub Actions. A matrix strategy lets you run the same job multiple times with different configurations (such as Python versions, operating systems, or Node.js versions) in parallel.

Create a workflow that:
- Runs on Python 3.10
- Runs on Python 3.11
- Runs on Python 3.12
- Prints the Python version
- All jobs run in parallel
- Then extend it to run on 2 operating systems

 Step 1: Create the workflow file: vi matrix.yml [vi exclude-and-fail-fast.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/exclude-and-fail-fast.yml)

Step 2: Add the workflow:
```
name: Matrix Build Demo

on:
  workflow_dispatch:

jobs:
  python-matrix:
    runs-on: ubuntu-latest

    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Python Version
        run: python --version
```

Step 3: Understand the workflow: 
```
Manual trigger
on:
  workflow_dispatch:

You'll start this workflow manually from the Actions tab.

Matrix strategy
strategy:
  matrix:
    python-version: ["3.10", "3.11", "3.12"]

GitHub creates one job for each Python version.

Equivalent to:

Job 1 → Python 3.10
Job 2 → Python 3.11
Job 3 → Python 3.12

These jobs run at the same time (parallel), if runners are available.

Setup Python
uses: actions/setup-python@v5

This action installs the requested Python version.

The version comes from:

${{ matrix.python-version }}

For each job, GitHub replaces it with:

3.10
3.11
3.12
Print the version
run: python --version

Example output:

Python 3.10.x

Another job:

Python 3.11.x

Another:

Python 3.12.x
```

Step 4: Commit and push: 

-->git add .github/workflows/matrix.yml

-->git commit -m "Add matrix workflow"

-->git push origin main

Step 5: Run the workflow: 
- Go to your GitHub repository.
- Click Actions.
- Select Matrix Build Demo.
- Click Run workflow.
- Select the main branch.
- Click Run workflow.

<img width="1912" height="846" alt="image" src="https://github.com/user-attachments/assets/2db0379c-5b05-47de-8e88-60ddfdd77f7a" />
<img width="1896" height="866" alt="image" src="https://github.com/user-attachments/assets/622d7c42-e2b1-465e-b01a-79efbb3733c6" />
<img width="1875" height="965" alt="image" src="https://github.com/user-attachments/assets/85406767-8d81-4fbf-99ae-1b95b7b3b6a5" />

Step 6: Observe the workflow: 
<img width="701" height="492" alt="image" src="https://github.com/user-attachments/assets/e2bbef79-94cd-4919-b030-d566f1aa738b" />

Step 7: Extend the matrix with Operating Systems: 
```
name: Matrix Build Demo

on:
  workflow_dispatch:

jobs:
  python-matrix:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
        python-version: ["3.10", "3.11", "3.12"]

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Python Version
        run: python --version
```
-->Notice that: runs-on: ${{ matrix.os }} [Uses the operating system from the matrix.]

Step 8: How many jobs run?: 
<img width="717" height="747" alt="image" src="https://github.com/user-attachments/assets/ff8bff64-b277-42d6-8cd2-8d9e033fc005" />

---

### Task 5: Exclude & Fail-Fast
1. In your matrix, exclude one specific combination (e.g., Python 3.10 on Windows)
2. Set fail-fast: false — trigger a failure in one job and observe what happens to the rest
3. Write in your notes: What does fail-fast: true (the default) do vs false?

**Steps to follow:**
This task teaches two important matrix features:
- exclude – Skip specific matrix combinations.
- fail-fast – Control what happens when one matrix job fails.

Step 1: Open your existing matrix workflow: vi matrix.yml [matrix.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/matrix.yml)

Step 2: Update the workflow: Replace the previous matrix with the following:
```
name: Matrix Build Demo

on:
  workflow_dispatch:

jobs:
  python-matrix:
    strategy:
      fail-fast: false

      matrix:
        os:
          - ubuntu-latest
          - windows-latest

        python-version:
          - "3.10"
          - "3.11"
          - "3.12"

        exclude:
          - os: windows-latest
            python-version: "3.10"

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}

      - name: Print Python Version
        run: python --version
```
-->Commit and push to github:

-->git add .

-->git commit -m "Update matrix with exclude"

-->git push origin main

<img width="1917" height="936" alt="image" src="https://github.com/user-attachments/assets/22ff93dd-eba2-4f47-9fa3-7a78eedb1a20" />
<img width="1897" height="930" alt="image" src="https://github.com/user-attachments/assets/9b691708-653c-4ced-99b7-36c027671e9e" />
<img width="1781" height="957" alt="image" src="https://github.com/user-attachments/assets/8f7da8bc-489b-4434-9c3e-0ea243ea2f5a" />


Step 3: Understand exclude: 

<img width="677" height="447" alt="image" src="https://github.com/user-attachments/assets/c02f5be7-0810-4acb-9c2c-5a73ce4170db" />
<img width="697" height="647" alt="image" src="https://github.com/user-attachments/assets/ddc5bf63-08db-48cf-948c-5c1f0f3477f0" />

Step 4: Trigger a failure: Add following line of code at last:
```
- name: Force Failure on Python 3.11
        if: matrix.python-version == '3.11'
        run: exit 1
```

-->This causes both Python 3.11 jobs (Ubuntu and Windows) to fail.

Note: exit 1 works on Ubuntu runners. On Windows runners, the default shell is PowerShell, where exit 1 also exits with a failure status.

Step 5: Commit and push:

-->git add .github/workflows/matrix.yml

-->git commit -m "Test fail-fast false"

-->git push origin main

<img width="1885" height="966" alt="image" src="https://github.com/user-attachments/assets/81c31b61-7490-4d9c-aab6-2caa0d09d004" />

Step 6: Run the workflow: GitHub Repository --> Actions --> Matrix Build Demo --> Run workflow

Step 7: Observe the results: 
<img width="695" height="421" alt="image" src="https://github.com/user-attachments/assets/957daff0-94c9-43ed-a120-e4527887c816" />

Step 8: Try the default behavior:

<img width="715" height="300" alt="image" src="https://github.com/user-attachments/assets/71bacaca-792e-42a1-85d2-9d74f8156fb5" />

-->Commit and push again:

-->git add .github/workflows/matrix.yml

-->git commit -m "Test fail-fast true"

-->git push origin main

Run the workflow again, This time, once a matrix job fails, GitHub cancels any other matrix jobs that are still queued or running.

<img width="1901" height="967" alt="image" src="https://github.com/user-attachments/assets/8ae5c9b9-8147-4bea-93db-bf0fbfd9ebc2" />

<img width="742" height="326" alt="image" src="https://github.com/user-attachments/assets/7e835dfb-8d49-4174-8b6e-37e3626bd54b" />

Note:

fail-fast: false:
- All matrix jobs continue running even if one or more jobs fail.
- Useful for seeing the results of every configuration in a single workflow run.
fail-fast: true (default):
- When one matrix job fails, GitHub cancels the remaining in-progress or queued matrix jobs.
- Saves runner time but may hide additional failures in other configurations.

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
