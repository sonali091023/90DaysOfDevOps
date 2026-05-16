# Day 46 – Reusable Workflows & Composite Actions

## Task
You've been writing workflows from scratch every time. In the real world, teams **don't repeat themselves** — they create reusable workflows that any repo can call like a function. Today you learn `workflow_call` and composite actions.

---

## Expected Output
- A reusable workflow and a caller workflow in your `github-actions-practice` repo
- A custom composite action
- A markdown file: `day-46-reusable-workflows.md`

---

## Challenge Tasks

### Task 1: Understand `workflow_call`
Before writing any code, research and answer in your notes:
1. What is a **reusable workflow**?

-->A reusable workflow in GitHub Actions is a full workflow (not just a single step) that you can call from another workflow.

-->Think of it like this: A normal workflow = one complete pipeline (build, test, deploy) & A reusable workflow = a pipeline template you can reuse across projects or jobs

-->This reusable workflows are usefull because of following reasons, Avoid duplicating the same CI/CD logic, Standardize pipelines across repos, Easier maintenance (change in one place → affects all callers)

-->Commaon examples: Common Docker build + push logic, Standard CI pipeline (install → test → lint), Deployment workflow used across multiple services

2. What is the `workflow_call` trigger?

-->workflow_call is a special trigger that makes a workflow callable by another workflow.

-->Normally workflows run on events like: push & pull_request,

-->But a reusable workflow uses:
on:
  workflow_call:     #Note: Tells GitHub: “Don’t run this automatically—only run it when another workflow calls it

-->We can also define inouts, secrets etc.

<img width="228" height="142" alt="image" src="https://github.com/user-attachments/assets/5c60024c-d4bb-4db7-aac9-90e92e509566" />
   
3. How is calling a reusable workflow different from using a regular action (`uses:`)?

-->**Regular uses: (Action):** When you write: - uses: actions/checkout@v4 [You are using an action from GitHub Actions.]

-->This means You are calling just one step, It does one specific task

Eg: Checkout code, Setup Node.js, Login to Docker etc

-->Its like A single function that does one job

-->**Reusable Workflow (uses: at job level)**  [**Note:** This makes your workflow reusable, meaning: It won’t run on push or PR, It only runs when another workflow calls it]

<img width="512" height="77" alt="image" src="https://github.com/user-attachments/assets/542819b5-2bdb-4066-8e4d-532586414d1a" />

-->This means You are calling a full workflow & That workflow can have Multiple steps, Multiple jobs, Complete pipeline logic etc.

-->Calling a full project or pipeline, not just one function

<img width="758" height="277" alt="image" src="https://github.com/user-attachments/assets/b0b924c8-8d3c-4eb2-853a-694e01859f7b" />

-->**Action** = single step & **Reusable workflow** = complete workflow (multiple steps/jobs)

4. Where must a reusable workflow file live?
-->A reusable workflow must be inside: .github/workflows/ directory 

---

### Task 2: Create Your First Reusable Workflow
Create `.github/workflows/reusable-build.yml`:
1. Set the trigger to `workflow_call`
2. Add an `inputs:` section with:
   - `app_name` (string, required)
   - `environment` (string, required, default: `staging`)
3. Add a `secrets:` section with:
   - `docker_token` (required)
4. Create a job that:
   - Checks out the code
   - Prints `Building <app_name> for <environment>`
   - Prints `Docker token is set: true` (never print the actual secret)

**Verify:** This file alone won't run — it needs a caller. That's next.

<img width="1887" height="802" alt="image" src="https://github.com/user-attachments/assets/cdcfa986-d85d-421c-a30b-6de1a467c58f" />

---

### Task 3: Create a Caller Workflow
Create `.github/workflows/call-build.yml`:
1. Trigger on push to `main`
2. Add a job that uses your reusable workflow:
   ```yaml
   jobs:
     build:
       uses: ./.github/workflows/reusable-build.yml
       with:
         app_name: "my-web-app"
         environment: "production"
       secrets:
         docker_token: ${{ secrets.DOCKER_TOKEN }}
   ```
3. Push to `main` and watch it run

**Verify:** In the Actions tab, do you see the caller triggering the reusable workflow? Click into the job — can you see the inputs printed?
<img width="1877" height="888" alt="image" src="https://github.com/user-attachments/assets/6d0d85d3-260d-45c5-9271-336f0c4de51e" />


---

### Task 4: Add Outputs to the Reusable Workflow
Extend `reusable-build.yml`:
1. Add an `outputs:` section that exposes a `build_version` value
2. Inside the job, generate a version string (e.g., `v1.0-<short-sha>`) and set it as output
3. In your caller workflow, add a second job that:
   - Depends on the build job (`needs:`)
   - Reads and prints the `build_version` output

**Verify:** Does the second job print the version from the reusable workflow?

-->Yes it should print the version from the reusable workflow, BUT only if everything is wired correctly.
<img width="1915" height="778" alt="image" src="https://github.com/user-attachments/assets/dbf0b22f-128a-463e-94dd-acbdda7b897b" />
<img width="1861" height="883" alt="image" src="https://github.com/user-attachments/assets/b8d05a7a-e57a-45d4-a48f-f39680cd820f" />
<img width="1910" height="627" alt="image" src="https://github.com/user-attachments/assets/03c1a45f-56e7-4074-9c41-a05d21cd050c" />

---

### Task 5: Create a Composite Action
Create a **custom composite action** in your repo at `.github/actions/setup-and-greet/action.yml`:
1. Define inputs: `name` and `language` (default: `en`)
2. Add steps that:
   - Print a greeting in the specified language
   - Print the current date and runner OS
   - Set an output called `greeted` with value `true`
3. Use the composite action in a new workflow with `uses: ./.github/actions/setup-and-greet`

**Verify:** Does your custom action run and print the greeting?
-->Yes, your custom action is running correctly and printing the greeting
<img width="1905" height="897" alt="image" src="https://github.com/user-attachments/assets/98b5d383-6ba2-4778-bbb9-19876b081940" />

---

### Task 6: Reusable Workflow vs Composite Action
Fill this in your notes:

| | Reusable Workflow | Composite Action |
|---|---|---|
| Triggered by | `workflow_call` | `uses:` in a step |
| Can contain jobs? | Yes (multiple jobs) | No (only steps inside a single job) |
| Can contain multiple steps? | yes | yes |
| Lives where? | .github/workflows/ | .github/actions/ |
| Can accept secrets directly? | Yes (via secrets:) | No (must be passed as inputs) |
| Best for | Reusing full CI/CD pipelines (build, test, deploy) | Reusing a group of steps (small logic like setup, scripts) |

---

## Hints
- Reusable workflows must be in `.github/workflows/` directory
- Caller syntax: `uses: ./.github/workflows/file.yml` (same repo) or `uses: org/repo/.github/workflows/file.yml@main` (cross-repo)
- Composite action: `action.yml` with `runs: using: "composite"`
- Reusable workflow outputs: `on: workflow_call: outputs: name: value: ${{ jobs.job-id.outputs.name }}`
- A reusable workflow can be called by at most 20 unique caller workflows in a single run

---

## Documentation
Create `day-46-reusable-workflows.md` with:
- Your reusable workflow and caller workflow YAML
- Your composite action YAML
- The comparison table from Task 6
- Screenshot of the caller workflow triggering the reusable one

---

## Submission
1. Add `day-46-reusable-workflows.md` to `2026/day-46/`
2. Commit and push to your fork

---

## Learn in Public
Share how you built your first reusable workflow on LinkedIn — this is a real production skill.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
