# Day 43 – Jobs, Steps, Env Vars & Conditionals

## Task
Today you learn how to **control the flow** of your pipeline — multi-job workflows, passing data between jobs, environment variables, and running steps only when certain conditions are met.

---

## Expected Output
- New workflow files in your `github-actions-practice` repo
- A markdown file: `day-43-jobs-steps.md`

---

## Challenge Tasks

### Task 1: Multi-Job Workflow
Create `.github/workflows/multi-job.yml` with 3 jobs:
- `build` — prints "Building the app"
- `test` — prints "Running tests"
- `deploy` — prints "Deploying"

Make `test` run only **after** `build` succeeds.
Make `deploy` run only **after** `test` succeeds.

-->Used here github repository for the github actions practice: https://github.com/sonali091023/github-actions-practice

**Verify:** Check the workflow graph in the Actions tab — does it show the dependency chain?
-->Yes it shows dependency flow like **build --> test --> deploy**, So if build executes and passes successfully then only test will trigger and when test will execute and passess 
successfully then only deploy will get triggers.

<img width="1902" height="758" alt="image" src="https://github.com/user-attachments/assets/f00ca41d-e1bd-4630-93d3-773d7a943b90" />


---

### Task 2: Environment Variables
In a new workflow, use environment variables at 3 levels:
1. **Workflow level** — `APP_NAME: myapp`
2. **Job level** — `ENVIRONMENT: staging`
3. **Step level** — `VERSION: 1.0.0`

Print all three in a single step and verify each is accessible.

Then use a **GitHub context variable** — print the commit SHA and the actor (who triggered the run).

-->Under this task Created files such as env-file-demo.yml then created .env file, .gitignore file and .env.example file as well in that we can mention imp env variables.

<img width="1896" height="892" alt="image" src="https://github.com/user-attachments/assets/24fa831e-058b-44c3-8c5c-329080b03f7a" />

---

### Task 3: Job Outputs
1. Create a job that **sets an output** — e.g., today's date as a string
2. Create a second job that **reads that output** and prints it
3. Pass the value using `outputs:` and `needs.<job>.outputs.<name>`

Write in your notes: Why would you pass outputs between jobs?

<img width="1917" height="622" alt="image" src="https://github.com/user-attachments/assets/4c66e206-ae08-4aab-9bfb-32eed1472dd0" />

<img width="1902" height="692" alt="image" src="https://github.com/user-attachments/assets/a4923fb9-bac4-4999-b4ab-a24c18f77db6" />

<img width="1910" height="623" alt="image" src="https://github.com/user-attachments/assets/94e603da-0074-4d90-859e-bb3a451f117f" />

---

### Task 4: Conditionals
In a workflow, add:
1. A step that only runs when the branch is `main`
2. A step that only runs when the previous step **failed**
3. A job that only runs on **push** events, not on pull requests
4. A step with `continue-on-error: true` — what does this do?

<img width="1903" height="902" alt="image" src="https://github.com/user-attachments/assets/fb815477-db16-4e7e-93b8-121e7b3f1ce4" />

---

### Task 5: Putting It Together
Create `.github/workflows/smart-pipeline.yml` that:
1. Triggers on push to any branch
2. Has a `lint` job and a `test` job running in parallel
3. Has a `summary` job that runs after both, prints whether it's a `main` branch push or a feature branch push, and prints the commit message

<img width="1911" height="697" alt="image" src="https://github.com/user-attachments/assets/6c428233-7c7a-4e56-884d-2b2c52f5146c" />

---

## Hints
- Job dependency: `needs: [job-name]`
- Set output: `echo "date=$(date)" >> $GITHUB_OUTPUT`
- Read output: `${{ needs.job-name.outputs.date }}`
- Conditionals: `if: github.ref == 'refs/heads/main'`
- Commit message: `${{ github.event.commits[0].message }}`

---

## Documentation
Create `day-43-jobs-steps.md` with:
- Key workflow snippets
- What `needs:` and `outputs:` do in your own words

---

## Submission
1. Add `day-43-jobs-steps.md` to `2026/day-43/`
2. Commit and push to your fork

---

## Learn in Public
Share the dependency chain diagram from your multi-job workflow on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
