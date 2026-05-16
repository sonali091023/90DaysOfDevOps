# Day 47 – Advanced Triggers: PR Events, Cron Schedules & Event-Driven Pipelines

## Task
You've used `push` and basic `pull_request` triggers. But GitHub Actions supports **dozens of event types** — today you go deep into PR lifecycle events, scheduled cron jobs, and chaining workflows together.

---

## Expected Output
- Multiple workflow files demonstrating advanced triggers
- A markdown file: `day-47-advanced-triggers.md`
- At least one scheduled workflow running on your repo

---

## Challenge Tasks

### Task 1: Pull Request Event Types
Create `.github/workflows/pr-lifecycle.yml` that triggers on `pull_request` with **specific activity types**:
1. Trigger on: `opened`, `synchronize`, `reopened`, `closed`
2. Add steps that:
   - Print which event type fired: `${{ github.event.action }}`
   - Print the PR title: `${{ github.event.pull_request.title }}`
   - Print the PR author: `${{ github.event.pull_request.user.login }}`
   - Print the source branch and target branch
3. Add a conditional step that only runs when the PR is **merged** (closed + merged = true)

Test it: create a PR, push an update to it, then merge it. Watch the workflow fire each time with a different event type.

**Steps followed:**

-->Created new branch

-->git fetch --all

-->git checkout -n int origin/int     #switch to remote url locally

-->git branch

-->echo "adding new file" >> file1.txt

-->git status

-->git add .

-->git commit -m "added new file"

-->git push origin int -->Status is open

-->Then edit the file and push again -->Status is Synchronsize

-->Close the PR -->Status is closed

-->Reopen the PR -->Status is reopen

-->Merge the PR --> Status is Closed  [**To merge the PR:** Open your Pull Request-->Click "Merge pull request"-->Click "Confirm merge"]

<img width="997" height="912" alt="image" src="https://github.com/user-attachments/assets/7caa2667-dae1-4683-a3a3-d5fb9ff7ccde" />
<img width="1866" height="700" alt="image" src="https://github.com/user-attachments/assets/b47544a1-afdd-45d2-9cf0-bce875700061" />
<img width="1685" height="893" alt="image" src="https://github.com/user-attachments/assets/5cd2a8ec-6894-4104-89dd-5ab0153ec6cc" />
<img width="1676" height="758" alt="image" src="https://github.com/user-attachments/assets/271690e8-645a-47b9-9503-990b85308de4" />
<img width="1863" height="377" alt="image" src="https://github.com/user-attachments/assets/d9a3c74d-ca85-47b9-b54f-b17d85d932ca" />
<img width="1865" height="841" alt="image" src="https://github.com/user-attachments/assets/174a725e-057f-4016-9a22-17ae4dbba215" />
<img width="1820" height="815" alt="image" src="https://github.com/user-attachments/assets/84510f53-a1d1-4ca7-9add-1f42b8d841f7" />
<img width="1893" height="645" alt="image" src="https://github.com/user-attachments/assets/3ca8e548-02c6-4afc-b047-af652a39b4e4" />
<img width="1401" height="622" alt="image" src="https://github.com/user-attachments/assets/c1a1be32-8215-4dec-8385-efb2ea5b3d06" />
<img width="1650" height="890" alt="image" src="https://github.com/user-attachments/assets/e9f00f2e-1739-4074-bdf5-a2081d5830e5" />
<img width="1872" height="287" alt="image" src="https://github.com/user-attachments/assets/efe65e4b-9520-47ad-8dfd-ac7d9fa62d2d" />

---

### Task 2: PR Validation Workflow
Create `.github/workflows/pr-checks.yml` — a real-world PR gate:
1. Trigger on `pull_request` to `main`
2. Add a job `file-size-check` that:
   - Checks out the code
   - Fails if any file in the PR is larger than 1 MB
3. Add a job `branch-name-check` that:
   - Reads the branch name from `${{ github.head_ref }}`
   - Fails if it doesn't follow the pattern `feature/*`, `fix/*`, or `docs/*`
4. Add a job `pr-body-check` that:
   - Reads the PR body: `${{ github.event.pull_request.body }}`
   - Warns (but doesn't fail) if the PR description is empty

**Verify:** Open a PR from a badly named branch — does the check fail?

**Steps followed:**

-->Create new branch in the github

-->then go to terminal and run --> git fetch --all

-->git bhranch -r

-->git checkout -b feature-test origin/feature-test

-->git branch

-->echo "adding new file" >> file1.txt

-->git add .

-->git commit -m "added new file"

-->git push origin feature-test

-->Now go to github-->Go to PR section -->there compare and create PR option will be available click it --> Then on the next page add description and create pr, 

after this job will get trigger and execution will get start automatically.

<img width="958" height="958" alt="image" src="https://github.com/user-attachments/assets/235997bc-3193-4307-936a-3db214966377" />
<img width="1867" height="677" alt="image" src="https://github.com/user-attachments/assets/2330d899-9116-4bb5-98f5-91db31bdd23f" />
<img width="1663" height="872" alt="image" src="https://github.com/user-attachments/assets/111a2c7b-84ce-4600-a6ac-597f5d721523" />
<img width="1910" height="403" alt="image" src="https://github.com/user-attachments/assets/f3929a63-d95b-4bd3-b726-c362045deb21" />
<img width="1862" height="673" alt="image" src="https://github.com/user-attachments/assets/6de6c05b-7187-4d9b-be92-92bad147acdb" />
<img width="1886" height="882" alt="image" src="https://github.com/user-attachments/assets/052e13e1-6ac7-49eb-8d38-ff8ab8e0cd67" />
<img width="1895" height="827" alt="image" src="https://github.com/user-attachments/assets/2fbbddd0-8362-4f68-bd98-4c81f7a4e064" />
<img width="1897" height="737" alt="image" src="https://github.com/user-attachments/assets/e30c8241-756b-4070-a471-b6eb1cd861cc" />

---

### Task 3: Scheduled Workflows (Cron Deep Dive)
Create `.github/workflows/scheduled-tasks.yml`:
1. Add a `schedule` trigger with cron: `'30 2 * * 1'` (every Monday at 2:30 AM UTC)
2. Add **another** cron entry: `'0 */6 * * *'` (every 6 hours)
3. In the job, print which schedule triggered using `${{ github.event.schedule }}`
4. Add a step that acts as a **health check** — curl a URL and check the response code

Write in your notes:
- The cron expression for: every weekday at 9 AM IST

-->Every weekday at 9 AM IST: IST = UTC + 5:30 --> 9:00 AM IST → 3:30 AM UTC --> 30 3 * * 1-5

**Meaning:**

30 → minute

3 → hour (UTC)

* → every day of month

* → every month

1-5 → Monday to Friday

- The cron expression for: first day of every month at midnight
-->0 0 1 * *

**Meaning:**

0 → minute

0 → hour

1 → first day of month

* → every month

* → any day of week

- Why GitHub says scheduled workflows may be delayed or skipped on inactive repos
**1. Inactive repositories**
-->If no recent activity (commits, PRs, etc.), GitHub may pause schedules, Helps reduce unnecessary compute usage

**2. Shared infrastructure (best-effort execution)**
-->GitHub runs millions of scheduled jobs, Cron timing is not guaranteed exact, Jobs may run slightly later than scheduled

**3. Queue delays during high load**
-->Peak usage → workflows may be queued, This can cause delays or, rarely, skipped runs

**4. No strict SLA for cron jobs**
-->GitHub does not guarantee execution timing, It’s designed for automation, not real-time systems

**Important:** Also add `workflow_dispatch` so you can test it manually without waiting for the schedule.

<img width="1873" height="890" alt="image" src="https://github.com/user-attachments/assets/274852d4-6a8e-4917-bf2c-33b3bb434860" />

**Note:** GitHub cron is “best-effort”, not real-time—delays and skips can happen, especially on inactive repos or under heavy load.

---

### Task 4: Path & Branch Filters
Create `.github/workflows/smart-triggers.yml`:
1. Trigger on push but **only** when files in `src/` or `app/` change:
   ```yaml
   on:
     push:
       paths:
         - 'src/**'
         - 'app/**'
   ```
2. Add `paths-ignore` in a second workflow that skips runs when only docs change:
   ```yaml
   paths-ignore:
     - '*.md'
     - 'docs/**' 
   ```
3. Add branch filters to only trigger on `main` and `release/*` branches
4. Test it: push a change to a `.md` file — does the workflow skip?

Write in your notes: When would you use `paths` vs `paths-ignore`?

-->when you want workflow to run ONLY for specific files/folders

-->**For Example:** Run CI only when backend changes, Trigger build only when Docker files change etc.

-->**Think**: "ONLY these changes should trigger"

When to use path-ignore?

-->when you want workflow to run for everything EXCEPT some files

-->**For Example:** Ignore docs updates, Skip CI for README changes

-->**Think:** "Ignore these changes, run for everything else"

-->Edited the README.md file but both smart-triggers.yml, docs-ignore.yml workflows not executed
   <img width="1877" height="773" alt="image" src="https://github.com/user-attachments/assets/1bcd17c7-1500-445c-a390-6f18ee468597" />

-->make chnages on src/ or app/ and triggger the both workflows, smart-triggers.yml & ignore-docs.yml
<img width="1905" height="547" alt="image" src="https://github.com/user-attachments/assets/b667ffc6-f5a0-4078-86bc-eb48f1831cf6" />
<img width="1885" height="587" alt="image" src="https://github.com/user-attachments/assets/a62d973c-f861-4aed-9786-214df5e85ab8" />

**Easy to remember difference:** 

-->paths → allow list (strict trigger)[Used for heavy workflows (build, deploy)] & 

-->paths-ignore → block list (skip certain changes) [for general workflows (lint, checks)]

---

### Task 5: `workflow_run` — Chain Workflows Together
Create two workflows:
1. `.github/workflows/tests.yml` — runs tests on every push
2. `.github/workflows/deploy-after-tests.yml` — triggers **only after** `tests.yml` completes successfully:
   ```yaml
   on:
     workflow_run:
       workflows: ["Run Tests"]
       types: [completed]
   ```
3. In the deploy workflow, add a conditional:
   - Only proceed if the triggering workflow **succeeded** (`${{ github.event.workflow_run.conclusion == 'success' }}`)
   - Print a warning and exit if it failed

**Verify:** Push a commit — does the test workflow run first, then trigger the deploy workflow?
-->To verify we have to make some chnages to the file and the commit the same and after that first run tests.yml file and then deploy after test yml file

<img width="1886" height="872" alt="image" src="https://github.com/user-attachments/assets/34c587b7-90c6-4f68-9304-7323a40bef37" />
<img width="1902" height="746" alt="image" src="https://github.com/user-attachments/assets/fbab5885-271d-4f51-808c-f58df56f537b" /> 


---

### Task 6: `repository_dispatch` — External Event Triggers
1. Create `.github/workflows/external-trigger.yml` with trigger `repository_dispatch`
2. Set it to respond to event type: `deploy-request`
3. Print the client payload: `${{ github.event.client_payload.environment }}`
4. Trigger it using `curl` or `gh`:
   ```bash
   gh api repos/<owner>/<repo>/dispatches \
     -f event_type=deploy-request \
     -f client_payload='{"environment":"production"}'
   ```

Write in your notes: When would an external system (like a Slack bot or monitoring tool) trigger a pipeline?

---

## Hints
- PR merge check: `if: github.event.pull_request.merged == true`
- Cron syntax: `minute hour day-of-month month day-of-week`
- Scheduled workflows only run on the **default branch**
- `workflow_run` gives you access to the triggering workflow's conclusion and artifacts
- `repository_dispatch` requires a personal access token with `repo` scope
- Path filters use glob patterns — `**` matches nested directories

---

## Documentation
Create `day-47-advanced-triggers.md` with:
- Your workflow YAML files
- The cron expressions from Task 3
- Screenshot of the PR checks running on a pull request
- Explanation of `workflow_run` vs `workflow_call` in your own words

---

## Submission
1. Add `day-47-advanced-triggers.md` to `2026/day-47/`
2. Commit and push to your fork

---

## Learn in Public
Share your PR validation workflow on LinkedIn — automated PR gates are a real DevOps flex.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
