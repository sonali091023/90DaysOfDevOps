# Day 39 – What is CI/CD?

## Task
Before writing a single pipeline, understand **why CI/CD exists** and what it actually does.

Today is a research and diagram day — no pipelines yet. Get the concepts right first.

---

## Expected Output
- A markdown file: `day-39-cicd-concepts.md`
- A pipeline diagram (hand-drawn or text-based)

---

## Challenge Tasks

### Task 1: The Problem
Think about a team of 5 developers all pushing code to the same repo manually deploying to production.

Write in your notes:
1. What can go wrong?

-->When multiple developers manually deploy code to the same production environment, several problems can occur:
- **Code conflicts:** Two developers may change the same file, causing merge conflicts or accidentally overwriting each other's work.
- **Wrong version deployment:** A developer may deploy an outdated or incorrect version of the application.
- **No quality checks:** Without automated testing, bugs, failed tests, security issues, or syntax errors can reach production and even break the application.
- **Inconsistent deployments:** Different developers may use different commands, skip important steps, forget environment variables, or use the wrong configuration files, leading to inconsistent deployments.
- **Human errors:** Manual deployments increase the chance of mistakes, which can cause application downtime or unexpected issues.
- **Environment differences:** The application may work on one developer's computer but fail in production because of different software versions, dependencies, or configurations.
- **No clear deployment history:** It becomes difficult to know who deployed which version, when it was deployed, and why, making troubleshooting harder.
- **Deployment conflicts:** If two developers deploy at the same time, one deployment may overwrite the other, resulting in the wrong version being released.
- **Difficult rollback:** If something goes wrong, manually reverting to the previous working version can be slow, stressful, and error-prone.

**In short:** Manual deployments are slow, inconsistent, difficult to track, and prone to human error, which is why teams use CI/CD pipelines to automate testing and deployments, making releases faster, safer, and more reliable.

2. What does "it works on my machine" mean and why is it a real problem?

-->"It works on my machine" means the application runs correctly on one developer's computer but fails on another developer's system or in production.

This happens because:
- Different operating systems
- Different software versions
- Missing dependencies
- Different environment variables
- Different configurations

Why it's a real problem:
- Developers waste time trying to reproduce issues.
- Bugs appear only after deployment.
- Releases become unreliable.
- Team productivity decreases.

-->This is one of the main reasons teams use CI/CD pipelines, containers (like Docker), and automated testing to ensure the application behaves the same in every environment.

3. How many times a day can a team safely deploy manually?

-->There is no fixed limit, but manual deployments are generally not safe to perform frequently. A team can usually manage 1–3 manual deployments per day without significantly increasing the risk of mistakes. As deployment frequency increases, the chances of human error also increase. With a CI/CD pipeline, deployments are automated, tested, and consistent, allowing teams to deploy dozens or even hundreds of times per day safely.

**Key Takeaway:**

Manual deployment:
- Slow
- Error-prone
- Difficult to scale

CI/CD deployment:
- Automated
- Consistent
- Fast
- Reliable
- Easy to deploy many times a day

---

### Task 2: CI vs CD
Research and write short definitions (2-3 lines each):
1. **Continuous Integration** — what happens, how often, what it catches

-->**Continuous Integration (CI):** CI is the practice where every developer merges their code into a shared repository multiple times a day, triggering 
an automated pipeline that builds the code, runs tests, and checks for errors immediately. It catches bugs, merge conflicts, broken builds, and failing tests at the moment they're introduced — not days later.

-->**Real-World Example:** A developer at Spotify pushes a new feature branch. Within minutes, GitHub Actions automatically runs 800 unit tests, checks 
code formatting, scans for security vulnerabilities, and reports back — before any human reviews the PR. The broken test is caught in 4 minutes, not 4 days.

2. **Continuous Delivery** — how it's different from CI, what "delivery" means

-->**Continuous Delivery picks up where CI ends:** after code passes all automated tests, it is automatically packaged and pushed to a staging/pre-production 
environment, making it ready to deploy to production at any time. The key distinction from CI: CI validates code quality, Delivery ensures the software is always
in a releasable state. The final push to production still requires a human approval click.

-->**Real-World Example:** At Netflix, after CI passes, the build is automatically deployed to a staging environment where smoke tests, performance tests, 
and canary checks run. The release manager sees a green dashboard and clicks "Deploy to Production" — the code ships in 2 minutes. The human decides when, 
not how.

3. **Continuous Deployment** — how it differs from Delivery, when teams use it

-->**Continuous Deployment is the most advanced stage:** every code change that passes all automated tests is deployed to production automatically, with 
zero human intervention. It differs from Continuous Delivery in one critical way: there is no manual approval gate. Teams use it when they have extremely high 
confidence in their test coverage, strong monitoring, and fast rollback capability.

-->**Real-World Example:** Amazon's engineering teams push thousands of deployments daily. A developer merges a one-line bug fix → CI runs → all tests pass → code 
is live in production within minutes, automatically. If error rates spike, automated rollback triggers instantly — no human needed at any step.

Write one real-world example for each.

-->**CI = "Does it work?" → Delivery = "Is it ready?" → Deployment = "It's already live."**

---

### Task 3: Pipeline Anatomy
A pipeline has these parts — write what each one does:

1. **Trigger** — what starts the pipeline

-->A trigger is the event that fires the pipeline automatically. It listens for specific actions in your repository or system and kicks off the entire CI/CD
process without any human manually pressing "run." Without a trigger, a pipeline is just a sleeping script.

**Common Trigger Types:**

**git push** → runs on every code push

**pull_request** → runs when a PR is opened/updated

**merge to main** → runs only when code lands in main branch

**schedule (cron)** → runs at fixed times ("every night at 2 AM")

**manual** → a human clicks "Run Pipeline"

**webhook** → an external system sends an HTTP signal

**tag created** → triggers on version tags like v1.0.0

Common examples: 
- Pushing code to GitHub
- Creating a Pull Request (PR)
- Running the pipeline manually
- A scheduled (cron) run

Eg: I push code to the main branch → Pipeline starts automatically.

2. **Stage** — a logical phase (build, test, deploy)

-->A stage is a named, logical grouping of related jobs that represents one phase of the software delivery process. Stages run sequentially, Stage 2 only starts if Stage 1 passes. This acts as a quality gate: broken code never advances to the next phase. Stages usually run one after another.

**stages:**
  
  - **build** --> Compiles the code
  
  - **test** --> validates the quality
  
  - **security-scan** 
  
  - **deploy-staging** -->Pre-prod smkoe test
  
  - **deploy-production** --> Live!

 --> **Note:** If test stage fails → deploy-staging never runs. Production is always protected.

3. **Job** — a unit of work inside a stage OR we can say A step is a single command or action inside a job. 

--> A job is a specific, self-contained task that lives inside a stage. Multiple jobs in the same stage can run in parallel, speeding up the pipeline significantly. Each job runs in its own isolated environment and has a clear pass/fail outcome that determines if the pipeline proceeds. A stage can contain one or more jobs.

-->All 4 must pass → Stage is GREEN, Any 1 fails → Stage is RED → pipeline stops

4. **Step** — a single command or action inside a job

-->  A step is the smallest atomic unit of a pipeline — one command, one script, or one pre-built action that does exactly one thing. Steps inside a job run strictly in order, one after another. If any step fails, the entire job stops immediately and is marked as failed. OR we can say A step is a single command or action inside a job.

<img width="616" height="227" alt="image" src="https://github.com/user-attachments/assets/5907a3b5-6359-4790-bc9d-9ce842d76b30" />





-->Step 3 fails (bad package) → Steps 4 & 5 never run

<img width="337" height="257" alt="image" src="https://github.com/user-attachments/assets/67c78d20-370f-4b76-98c1-8807c2d655ae" />

4. **Runner** — the machine that executes the job

-->A runner is the physical or virtual machine (or container) that actually runs your job's steps. It's the execution engine of the pipeline. Each job is
assigned to a runner, which pulls the job instructions, sets up the environment, executes every step, and reports the result back to the CI/CD platform.

Runner types
<img width="655" height="332" alt="image" src="https://github.com/user-attachments/assets/79e3ea30-52c2-469e-98b3-f8a258fc59db" />

<img width="628" height="218" alt="image" src="https://github.com/user-attachments/assets/926029ca-654f-4b2b-9090-166f3d54256e" />

5. **Artifact** — output produced by a job

-->An artifact is any file, folder, or package produced by a job that needs to be stored or passed to a later stage. Artifacts are the "handoff" mechanism 
between stages — the build stage compiles your code into an artifact, and the deploy stage picks up that exact artifact to ship to production. This guarantees 
what was tested is exactly what gets deployed.

Common Artifact Types:
<img width="732" height="172" alt="image" src="https://github.com/user-attachments/assets/987cbc7d-9d9b-4a2c-afef-0ff2bdfb84e5" />

<img width="808" height="307" alt="image" src="https://github.com/user-attachments/assets/21b7c27c-3b28-42df-b31d-cc272fc74303" />

<img width="437" height="365" alt="image" src="https://github.com/user-attachments/assets/590f0da6-7ff8-4b89-a255-cc1d4d002bab" />


-->Code enters as a trigger, flows through stages → jobs → steps, executes on a runner, and produces artifacts that carry the verified build all the way to production. 

---

### Task 4: Draw a Pipeline
Draw a CI/CD pipeline for this scenario:
--> A developer pushes code to GitHub. The app is tested, built into a Docker image, and deployed to a staging server.

Include at least 3 stages. Hand-drawn and photographed is perfectly fine.

<img width="1280" height="960" alt="developer to staging scenario" src="https://github.com/user-attachments/assets/fbb7b37c-e03a-49c4-94a4-c57156fa20e4" />


**Pipeline Walkthrough — Stage by Stage**

The trigger fires the moment a developer runs git push. GitHub detects the push via a webhook and instantly hands control to the CI/CD runner. No human needs to press anything.

**Stage 1** — Test runs three jobs simultaneously on separate runners — lint, unit tests, and security scanning — all in parallel. This is where the pipeline earns its keep: bad code is caught in minutes, not days. If even one job fails, the pipeline stops dead and nothing proceeds to build.

<img width="480" height="632" alt="image" src="https://github.com/user-attachments/assets/3a60ee91-b33a-4df7-bdc2-ea1335cb4b0e" />

**Stage 2** — Build only starts after all three test jobs go green. The runner executes a docker build, tags the image with the exact Git commit SHA (e.g. myapp:sha-a3f9b2) for full traceability, and pushes it to Docker Hub. The image is now the artifact — the verified, immutable package that carries the code all the way to production.

<img width="640" height="251" alt="image" src="https://github.com/user-attachments/assets/20b782bb-81a2-4b8b-87d1-605b233f9d76" />

**Stage 3** — Deploy to Staging pulls that exact image from the registry, SSH's into the staging server, runs docker run, and immediately fires a smoke test job in parallel — hitting the /health endpoint, checking database connectivity, and running critical E2E paths. If the health check fails, the pipeline alerts the team and the broken version never goes further.

<img width="657" height="290" alt="image" src="https://github.com/user-attachments/assets/4b608e84-76f5-4d97-ba9f-5864ac1fa721" />

---

### Task 5: Explore in the Wild
1. Open any popular open-source repo on GitHub (Kubernetes, React, FastAPI — pick one you know)
2. Find their `.github/workflows/` folder
3. Open one workflow YAML file
4. Write in your notes:
   - What triggers it?
   - How many jobs does it have?
   - What does it do? (best guess)

.github/workflows/pull-kubernetes-e2e-gce.yaml

<img width="1023" height="551" alt="image" src="https://github.com/user-attachments/assets/e15b8511-1324-4dba-a341-3437eb192d05" />

**Trigger**

-->Runs on push to main branch

-->Runs on pull_request targeting main

-->Runs on schedule (every 12 hours)

-->Also runs on updates to the PR (new commits)

**Jobs**

-->Multiple jobs (build, test, e2e)

**What it does**

-->Builds the application code

-->Runs unit and integration tests

-->Creates a test Kubernetes cluster (on cloud)

-->Runs end-to-end (E2E) tests

-->Validates that the PR does not break the system


---

## Hints
- CI/CD is a practice, not just a tool
- GitHub Actions, Jenkins, GitLab CI, CircleCI — all are tools that implement CI/CD
- A pipeline failing is not a problem — it's CI/CD doing its job

---

## Documentation
Create `day-39-cicd-concepts.md` with:
- Your CI vs CD vs CD definitions
- Pipeline anatomy notes
- Your pipeline diagram
- What you found in the open-source repo

---

## Submission
1. Add your `day-39-cicd-concepts.md` to `2026/day-39/`
2. Commit and push to your fork

---

## Learn in Public
Share your pipeline diagram on LinkedIn — even a rough hand-drawn one gets engagement.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
