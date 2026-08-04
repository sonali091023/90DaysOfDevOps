# Day 40 – Your First GitHub Actions Workflow

## Task
Today you write your **first GitHub Actions pipeline** and watch it run in the cloud.

This is the moment CI/CD stops being a concept and becomes real.

---

## Expected Output
- A workflow file: `.github/workflows/hello.yml`
- A markdown file: `day-40-first-workflow.md`
- Screenshot of your first green pipeline run

---

## Challenge Tasks

### Task 1: Set Up
1. Create a new **public** GitHub repository called `github-actions-practice`
2. Clone it locally
3. Create the folder structure: `.github/workflows/`

**Steps to follow:**

Step 1: Create a New GitHub Repository: Following is the name of Repo: github-actions practice:** https://github.com/sonali091023/github-actions-practice/tree/main/.github/workflows

Step 2: Clone the Repository: In local create separate directory & inside it run command in gitbash terminal: git clone https://github.com/<your-username>/github-actions-practice.git

-->Then after cloning go inside repo in local machine: cd github-actions-practice

Step 3: Create the Folder Structure: mkdir -p .github/workflows

-->to verify run command: tree OR ls -R OR ls -la

Step 4: Commit the Changes: Git doesn't track empty directories, so create a placeholder file: touch .github/workflows/.gitkeep

-->git status

-->git add .

-->git commit -m "Create GitHub Actions workflow directory"

-->git push origin main

-->verify: find . -type d

**Your repository should now contain:**
```
github-actions-practice/
├── README.md
└── .github
    └── workflows
        └── .gitkeep
```
---

### Task 2: Hello Workflow
Create `.github/workflows/hello.yml` with a workflow that:
1. Triggers on every `push`
2. Has one job called `greet`
3. Runs on `ubuntu-latest`
4. Has two steps:
   - Step 1: Check out the code using `actions/checkout`
   - Step 2: Print `Hello from GitHub Actions!`

Push it. Go to the **Actions** tab on GitHub and watch it run.

**Verify:** Is it green? Click into the job and read every step.

**Steps to follow:**

Step 1: Create the workflow file: vi .github/workflows/hello.yml [hello.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/hello.yml)

Step 2: Add the following YAML
```
name: Hello Workflow

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Print greeting
        run: echo "Hello from GitHub Actions!"
```

Step 3: Check the YAML: 
-->Make sure:
- on: is at the top level.
- jobs: is at the top level.
- greet: is indented under jobs:.
- steps: is indented under greet:.
- Each step begins with -.

Even one extra space can cause the workflow to fail.

Step 4: Commit the workflow: 

-->git status

-->git add .

-->git commit -m "Add hello GitHub Actions workflow"

-->git push origin main

Step 5: Watch the workflow run: 
- Open your GitHub repository.
- Click the Actions tab.
- You should see Hello Workflow.
- Click the latest workflow run.

<img width="1891" height="961" alt="image" src="https://github.com/user-attachments/assets/4cb4cdf6-f040-4a20-a73b-578714e7fc8d" />

Step 6: Verify each step: 
```
Click the greet job.

You should see:

✓ Set up job
✓ Checkout repository
✓ Print greeting
✓ Complete job

Open Print greeting and you should find:

Hello from GitHub Actions!
```
<img width="1882" height="931" alt="image" src="https://github.com/user-attachments/assets/74dd46d5-9881-4cac-8d13-e2c2d7d31070" />
<img width="1910" height="957" alt="image" src="https://github.com/user-attachments/assets/b62ecf87-91ab-426c-818e-b449132c0ef6" />

Step 7: Is it green?: 
```
If everything is correct, you'll see:

🟢 Hello Workflow — Success

That means:

The workflow was triggered by your push.
The runner (ubuntu-latest) started successfully.
The repository was checked out.
The greeting message was printed.
The job completed without errors.
```
---

### Task 3: Understand the Anatomy
Look at your workflow file and write in your notes what each key does:

- on:
- jobs:
- runs-on:
- steps:
- uses:
- run:
- name: (on a step)

**Steps to follow:**

on:
- Defines what event triggers the workflow.
- In our workflow, on: push means the workflow starts whenever code is pushed to the repository.

Example:
```
on:
  push:
```

jobs:
- Contains one or more jobs that the workflow will execute.
- Each job performs a specific set of tasks.

Example:
```
jobs:
  greet:
```

runs-on:
- Specifies which runner (virtual machine) will execute the job.
- ubuntu-latest means GitHub provides the latest Ubuntu Linux machine.

Example:
```
runs-on: ubuntu-latest
```

steps:
- Lists the individual actions or commands that make up a job.
- Steps are executed one after another in the order they appear.

Example:
```
steps:
  - name: Checkout repository
    uses: actions/checkout@v4
```

uses:
- Uses a pre-built GitHub Action created by GitHub or the community.
- In this workflow, actions/checkout@v4 downloads your repository code onto the runner.

Example:
```
uses: actions/checkout@v4
```

run:
- Executes a shell command or script directly on the runner.
- Useful for running commands like echo, npm install, pytest, or docker build.

Example:
```
run: echo "Hello from GitHub Actions!"
```

name: (on a step):
- Gives a human-readable name to a step.
- This name appears in the GitHub Actions logs, making it easier to understand what each step is doing.

Example:
```
- name: Print greeting
  run: echo "Hello from GitHub Actions!"
```

**Summary Table:**
<img width="772" height="350" alt="image" src="https://github.com/user-attachments/assets/fc7ad805-c8a1-43e5-a027-248b61e7552c" />

---

### Task 4: Add More Steps
Update `hello.yml` to also: [hello.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/hello.yml)
1. Print the current date and time
2. Print the name of the branch that triggered the run (hint: GitHub provides this as a variable)
3. List the files in the repo
4. Print the runner's operating system

Push again — watch the new run.

**Steps to follow:**

Step 1: Update .github/workflows/hello.yml: vi .github/workflows/hello.yml
```
name: Hello Workflow

on:
  push:

jobs:
  greet:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Print greeting
        run: echo "Hello from GitHub Actions!"

      - name: Print current date and time
        run: date

      - name: Print branch name
        run: echo "Branch: ${{ github.ref_name }}"

      - name: List repository files
        run: ls -la

      - name: Print runner operating system
        run: echo "Runner OS: $RUNNER_OS"
```

Step 2: What each new step does: 

1. Print current date and time:
```
- name: Print current date and time
  run: date
```
- Executes the Linux date command.
- Displays the current date and time on the GitHub runner.

Example output: Mon Aug 4 09:45:21 UTC 2026

2. Print branch name
```
- name: Print branch name
  run: echo "Branch: ${{ github.ref_name }}"
```
- github.ref_name is a GitHub Actions context variable.
- It contains the name of the branch that triggered the workflow.

Example output: Branch: main

If you push from another branch: Branch: feature/login

3. List repository files:
```
- name: List repository files
  run: ls -la
```
- Lists all files and folders in the checked-out repository.
- The -l option shows details, and -a includes hidden files (like .github).

Example output:
- README.md
- .github
- .gitignore

4. Print runner operating system
```
- name: Print runner operating system
  run: echo "Runner OS: $RUNNER_OS"
```
- $RUNNER_OS is an environment variable automatically provided by GitHub Actions.
- It shows the operating system of the runner.

Example output: Runner OS: Linux

Step 3: Commit and Push: Run the following commands:

-->git add .github/workflows/hello.yml

-->git commit -m "Add more workflow steps"

-->git push origin main

Step 4: Watch the workflow: 
- Open your GitHub repository.
- Click the Actions tab.
- Open the latest Hello Workflow run.
- Click the greet job.

You should see something like:
```
✓ Set up job
✓ Checkout repository
✓ Print greeting
✓ Print current date and time
✓ Print branch name
✓ List repository files
✓ Print runner operating system
✓ Complete job
```

<img width="1905" height="492" alt="image" src="https://github.com/user-attachments/assets/268352d3-d4b6-43c4-8fe4-bde86c412ee9" />
<img width="1887" height="950" alt="image" src="https://github.com/user-attachments/assets/09affdd0-5c30-46b8-95a6-c0b0144b2179" />
<img width="1877" height="972" alt="image" src="https://github.com/user-attachments/assets/82030281-2322-4810-b684-7386bd64a467" />

Step 5: Verify the outputs: Open each step and confirm you can see:
<img width="702" height="261" alt="image" src="https://github.com/user-attachments/assets/e3f6a302-23ef-4404-9517-6a7e7f27145e" />

---

### Task 5: Break It On Purpose
1. Add a step that runs a command that will **fail** (e.g., `exit 1` or a misspelled command)
2. Push and observe what happens in the Actions tab
3. Fix it and push again

Write in your notes: What does a failed pipeline look like? How do you read the error?

**Steps to follow:**

Step 1: Add a failing step: 

-->Open your .github/workflows/hello.yml and add this step at the end of the steps: list: [hello.yml](https://github.com/sonali091023/github-actions-practice/blob/main/.github/workflows/hello.yml)
```
- name: Intentionally fail
        run: exit 1
```
-->Your workflow will now look similar to this:
```
steps:
  - name: Checkout repository
    uses: actions/checkout@v4

  - name: Print greeting
    run: echo "Hello from GitHub Actions!"

  - name: Print current date and time
    run: date

  - name: Print branch name
    run: echo "Branch: ${{ github.ref_name }}"

  - name: List repository files
    run: ls -la

  - name: Print runner operating system
    run: echo "Runner OS: $RUNNER_OS"

  - name: Intentionally fail
    run: exit 1
```

Step 2: Commit and push: 

-->git add .github/workflows/hello.yml

-->git commit -m "Add failing step for testing"

-->git push origin main

Step 3: Observe the workflow: 
- Open your GitHub repository.
- Click the Actions tab.
- Open the latest workflow run.

-->Instead of a green checkmark, you'll see a red indicating the workflow failed.

-->Click the greet job and then click Intentionally fail.

You should see output similar to:
```
Run exit 1
Error: Process completed with exit code 1.
```

<img width="1877" height="947" alt="image" src="https://github.com/user-attachments/assets/e7c334e7-bb0c-474e-83e4-fbf6a9f0ce54" />
<img width="1877" height="932" alt="image" src="https://github.com/user-attachments/assets/67788c39-1460-4327-a71a-1fd0621d7a26" />


Step 4: How to read the error: 
When a workflow fails:
- The failed step is marked with a red X.
- Steps before it have green check marks because they completed successfully.
- Steps after the failed step (if any) are not executed.

The error log tells you:
- Which step failed.
- Which command was run.
- The exit code or error message.

For example:
```
Run exit 1
Error: Process completed with exit code 1.
```
-->This means the command exit 1 returned a non-zero exit code, which GitHub Actions treats as a failure.

Step 5: Fix the workflow: 

-->Remove the failing step:
```
- name: Intentionally fail
  run: exit 1
```

-->Or replace it with a successful command:
```
- name: Successful step
  run: echo "Workflow fixed!"
```

Step 6: Commit and push again:

-->git add .github/workflows/hello.yml

-->git commit -m "Fix failing workflow"

-->git push origin main

-->Go back to the Actions tab and verify the latest run is green.

<img width="1880" height="575" alt="image" src="https://github.com/user-attachments/assets/ba12028f-8276-4069-a9b1-348706fbec2c" />
<img width="1877" height="972" alt="image" src="https://github.com/user-attachments/assets/67eb935c-caa4-46f6-975f-53ba4a59b842" />

---

## Hints
- Workflow files live in `.github/workflows/` and must end in `.yml`
- `uses: actions/checkout@v4` checks out your code onto the runner
- `run:` executes shell commands
- GitHub provides built-in variables like `${{ github.ref_name }}` for branch name
- Every push triggers a new run — check the Actions tab

---

## Documentation
Create `day-40-first-workflow.md` with:
- Your workflow YAML
- Screenshot of the green run
- What each `on:`, `jobs:`, `steps:` key does (your own words)

---

## Submission
1. Add `day-40-first-workflow.md` to `2026/day-40/`
2. Commit and push to your fork

---

## Learn in Public
Share your first green pipeline screenshot on LinkedIn. That green checkmark hits different.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
