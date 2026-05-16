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

-->**Create new repository for the github-actions practice:** https://github.com/sonali091023/github-actions-practice/tree/main/.github/workflows

<img width="1906" height="788" alt="image" src="https://github.com/user-attachments/assets/514b86e6-5c77-4817-95c7-ec8d5c89ad38" />

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

<img width="1446" height="388" alt="image" src="https://github.com/user-attachments/assets/130acedb-d345-425b-861e-ddb09231bc7b" />

<img width="1878" height="912" alt="image" src="https://github.com/user-attachments/assets/10549bd2-04f1-4f36-9293-c4529e9b0544" />

---

### Task 3: Understand the Anatomy
Look at your workflow file and write in your notes what each key does:

-->These are the fundamental building blocks of a GitHub Actions workflow file

- **`on:`** Defines what events start the workflow.
<img width="507" height="205" alt="image" src="https://github.com/user-attachments/assets/bb23cb1b-493d-4e7d-b086-3da1ab7d98af" />

-->**Following are the Common triggers:** push, pull_request, release, schedule, workflow_dispatch, workflow_call

- **`jobs:`** A workflow contains one or more jobs. By default, jobs run in parallel
<img width="502" height="150" alt="image" src="https://github.com/user-attachments/assets/61c3becf-545b-4172-9347-66af835b3656" />

**Note:** Each job gets its own fresh runner, That is VM. They don't share filesystem unless you use artifacts.

- **`runs-on:`** The Runner (Execution Environment), Specifies which machine/OS the job runs on.
<img width="443" height="115" alt="image" src="https://github.com/user-attachments/assets/8fed87b2-1635-4d7e-9e15-1a789b606c50" />

**Note:** 

-->**GitHub-hosted runner** is managed by GitHub, It is availble Free with limits (minutes/month based on plan), No setup needed, Limited control (you can’t access underlying VM deeply), And Github hosted runner Scales automatically.

-->**Self-hosted runner** Not truly free — we have to pay for: Server/VM (cloud or physical), Electricity / infra / maintenance, Full control (install anything, debug deeply), No GitHub minute limits, You manage scaling, security, uptime etc.

**`steps:`** Ordered List of Tasks, A sequential list of actions within a job. Steps share the same runner and filesystem.
<img width="355" height="155" alt="image" src="https://github.com/user-attachments/assets/5aa8bf33-28f7-4c39-856f-bb36e8838668" />

**Note:** Unlike jobs, steps are always sequential within a job

**- `uses:** Reusable Action, Calls a pre-built action from the Marketplace or your own repository. 
<img width="562" height="201" alt="image" src="https://github.com/user-attachments/assets/1b7b3698-647b-4ed6-9801-86900abf5018" />

**Note:** Always pin to a version tag (@v4) or SHA for security and stability.

**run:** Shell Command, Executes a raw shell command directly on the runner.
<img width="533" height="246" alt="image" src="https://github.com/user-attachments/assets/c84436d4-f7de-4094-88db-46e20a899494" />

**Note:** Default shell is bash on Linux/macOS, pwsh on Windows.

**name:` (on a step)** Step Label, A human-readable label shown in the GitHub Actions UI log. Optional but highly recommended.
<img width="593" height="221" alt="image" src="https://github.com/user-attachments/assets/8ec759f7-267e-4450-b793-7adf9fe7e0b9" />

**Note:** Without name, GitHub shows the run command or action path — harder to read at a glance. 

---

### Task 4: Add More Steps
Update `hello.yml` to also:
1. Print the current date and time
2. Print the name of the branch that triggered the run (hint: GitHub provides this as a variable)
3. List the files in the repo
4. Print the runner's operating system

Push again — watch the new run.

<img width="1908" height="708" alt="image" src="https://github.com/user-attachments/assets/88bc7bb3-36ef-4d5f-a469-3b5bdd2df69b" />

<img width="1891" height="902" alt="image" src="https://github.com/user-attachments/assets/d1749d0b-1dd0-478c-a267-fac4580971ae" />

---

### Task 5: Break It On Purpose
1. Add a step that runs a command that will **fail** (e.g., `exit 1` or a misspelled command)
2. Push and observe what happens in the Actions tab
3. Fix it and push again

Write in your notes: What does a failed pipeline look like? How do you read the error?

<img width="1860" height="598" alt="image" src="https://github.com/user-attachments/assets/7eb07b13-5df7-4c1f-bfe1-43127ba6e72d" />

<img width="892" height="167" alt="image" src="https://github.com/user-attachments/assets/e1286c56-84ea-49d3-bf0e-a8dff155d04c" />

-->Fizxed the intentional failure:
<img width="897" height="160" alt="image" src="https://github.com/user-attachments/assets/224f6ed6-9831-4330-a278-b1c702c3897a" />

-->So The workflow shows a red ❌ status, The job is marked as failed, Some steps may pass (✅), but one step fails (❌), Execution stops at the failed step
Logs are available for each step.

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
