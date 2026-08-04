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
2. What does "it works on my machine" mean and why is it a real problem?
3. How many times a day can a team safely deploy manually?

**Steps to follow:**

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

1. Continuous Integration — what happens, how often, what it catches
2. Continuous Delivery — how it's different from CI, what "delivery" means
3. Continuous Deployment — how it differs from Delivery, when teams use it
Write one real-world example for each.

**Steps to follow:**

1. **Continuous Integration** — what happens, how often, what it catches

-->CI Definition: Continuous Integration (CI) is the practice of regularly merging code changes into a shared repository, usually several times a day. Every change automatically triggers a build and tests to ensure the new code works correctly with the existing code. It helps catch problems early before they reach production.

Q. What happens?
- Developers frequently push code to a shared repository.
- The CI pipeline automatically builds the application and runs tests.
- If any test fails, developers are notified immediately.

Q. How often?
- Multiple times a day, whenever code is pushed.

Q. What does it catch?
- Build failures
- Syntax errors
- Failed unit/integration tests
- Merge conflicts
- Some security or code quality issues

**Real-world example:** A developer pushes code to GitHub. GitHub Actions automatically builds the project and runs all tests. If a test fails, the developer fixes the issue before merging the code.

2. **Continuous Delivery** — how it's different from CI, what "delivery" means

-->CD Definition: Continuous Delivery extends Continuous Integration by automatically preparing the application for release after all tests pass. The application is always in a deployable state, but a person decides when to deploy it to production.

Q. How is it different from CI?
- CI focuses on building and testing code. Continuous Delivery also packages and prepares the application for deployment after successful tests.

Q. What does "delivery" mean?
- The application is automatically made ready for deployment.
- Deployment to production requires manual approval.

**Real-world example:** After GitHub Actions completes the build and tests, the application is automatically deployed to a staging environment. A release manager reviews it and manually approves deployment to production.

3. **Continuous Deployment** — how it differs from Delivery, when teams use it

-->CD Definition: Continuous Deployment goes one step further than Continuous Delivery. After the application passes all automated tests, it is automatically deployed to production without any manual approval. Every successful change can reach users immediately.

Q. How is it different from Continuous Delivery?
- Continuous Delivery: Manual approval is required before production deployment.
- Continuous Deployment: Deployment to production happens automatically after all checks pass.

Q. When do teams use it?
- Teams with strong automated testing and monitoring.
- Applications that release updates frequently, such as SaaS platforms and web applications.

**Real-world example:** A developer pushes code to GitHub. The CI/CD pipeline builds the application, runs all tests, and if everything passes, it is automatically deployed to production without any human intervention.

**Quick Comparison: **
<img width="905" height="312" alt="image" src="https://github.com/user-attachments/assets/f29c5112-7524-4569-a5f4-2befad69ff87" />

---

### Task 3: Pipeline Anatomy
A pipeline has these parts — write what each one does:
- Trigger — what starts the pipeline
- Stage — a logical phase (build, test, deploy)
- Job — a unit of work inside a stage
- Step — a single command or action inside a job
- Runner — the machine that executes the job
- Artifact — output produced by a job

**Steps to follow:**

1. **Trigger: ** A Trigger is the event that starts the CI/CD pipeline automatically. It tells the pipeline when to begin running.

**Common Trigger Types:**
- **git push** → runs on every code push
- **pull_request** → runs when a PR is opened/updated
- **merge to main** → runs only when code lands in main branch
- **schedule (cron)** → runs at fixed times ("every night at 2 AM")
- **manual** → a human clicks "Run Pipeline"
- **webhook** → an external system sends an HTTP signal
- **tag created** → triggers on version tags like v1.0.0

Common examples: 
- A developer pushes code to GitHub.
- A pull request is created or merged.
- A scheduled time (Cron job: daily/nightly build).
- A manual button click.

Eg: A developer pushes new code to the main branch, and the pipeline starts automatically.

2. **Stage: ** A Stage is a logical phase in the pipeline that groups related jobs together. Stages help organize the pipeline into separate parts such as building, testing, and deploying the application.

**Common stages:**
- **build** --> Compiles the code
- **test** --> validates the quality
- **security-scan** 
- **deploy-staging** -->Pre-prod smkoe test
- **deploy-production** --> Live!

Eg: The pipeline first runs the Build stage, then the Test stage, and finally the Deploy stage.

**Note:** If test stage fails → deploy-staging never runs. Production is always protected.

3. **Job:** A Job is a specific unit of work inside a stage. Each stage can contain one or more jobs, and each job performs a particular task. 

Examples:
- Compile the application
- Run unit tests
- Build a Docker image
- Deploy the application

Eg: In the Test stage, one job runs unit tests while another job runs integration tests.

4. **Step:** A Step is a single command or action inside a job. Multiple steps are executed one after another to complete the job.

Examples:
- Check out the source code
- Install dependencies
- Run npm install
- Execute npm test
- Build the application

Example: A build job may contain these steps:
1. Checkout the code.
2. Install dependencies.
3. Build the application.

5. **Runner:** A Runner is the machine or environment that executes the pipeline jobs. It can be a physical machine, virtual machine, container, or cloud-hosted server.

Types of runners:
- GitHub-hosted runner
- Self-hosted runner

Eg: GitHub Actions uses an Ubuntu virtual machine (ubuntu-latest) to execute pipeline jobs.

6. **Artifact:** An Artifact is a file or output produced by a job that can be saved and used by later stages or downloaded after the pipeline finishes.

Examples:
- Compiled application files
- Docker image
- Test reports
- Log files
- ZIP packages

Eg: The Build stage creates a .jar file, which is saved as an artifact and later used by the Deploy stage.

**Pipeline Flow:**

```
Developer Pushes Code
          │
          ▼
       Trigger
          │
          ▼
   ┌─────────────┐
   │ Build Stage │
   │  └─ Job     │
   │      └─ Steps│
   └─────────────┘
          │
          ▼
   ┌─────────────┐
   │ Test Stage  │
   │  └─ Job     │
   │      └─ Steps│
   └─────────────┘
          │
          ▼
   ┌─────────────┐
   │Deploy Stage │
   │  └─ Job     │
   │      └─ Steps│
   └─────────────┘
          │
          ▼
      Artifact
```

**Quick Summary:**

<img width="751" height="310" alt="image" src="https://github.com/user-attachments/assets/af372623-dc46-4d46-a4db-5326162981b4" />

---

### Task 4: Draw a Pipeline
Draw a CI/CD pipeline for this scenario:
--> A developer pushes code to GitHub. The app is tested, built into a Docker image, and deployed to a staging server.

**Pipeline Diagram:**
```
                 Developer
                     │
                     │ Push Code
                     ▼
                GitHub Repository
                     │
                     │ Trigger Pipeline
                     ▼
         ┌─────────────────────────┐
         │      Stage 1: Test      │
         ├─────────────────────────┤
         │ • Checkout Code         │
         │ • Install Dependencies  │
         │ • Run Unit Tests        │
         └─────────────────────────┘
                     │
             Tests Passed?
                     │
                     ▼
         ┌─────────────────────────┐
         │     Stage 2: Build      │
         ├─────────────────────────┤
         │ • Build Application     │
         │ • Create Docker Image   │
         │ • Save Build Artifact   │
         └─────────────────────────┘
                     │
                     ▼
         ┌─────────────────────────┐
         │    Stage 3: Deploy      │
         ├─────────────────────────┤
         │ • Push Docker Image     │
         │ • Deploy to Staging     │
         │ • Verify Deployment     │
         └─────────────────────────┘
                     │
                     ▼
            Staging Server Ready
```
Simpler Version:
```
Developer
    │
    ▼
Push Code to GitHub [Trigger the code]
    │
    ▼
CI/CD Pipeline      
    │
    ├──────────────┐
    ▼              ▼
[Test Stage]   Run Tests
    │
    ▼
[Build Stage]       
Build App
Create Docker Image
    │
    ▼
[Deploy Stage] 
Deploy to Staging Server
    │
    ▼
Application Running
```

**What to Label in Your Drawing: Make sure your diagram includes:**
- Trigger: Push code to GitHub
- Stage 1: Test
- Stage 2: Build
- Stage 3: Deploy
- Runner: (Optional) GitHub Actions Runner
- Artifact: Docker Image
- Deployment Target: Staging Server

**Explanation of the Flow:** 
- A developer pushes code to the GitHub repository.
- This triggers the CI/CD pipeline.
- The Test stage checks out the code, installs dependencies, and runs automated tests.
- If all tests pass, the Build stage compiles the application and creates a Docker image (the artifact).
- Finally, the Deploy stage deploys the Docker image to the staging server, where the application can be tested before production.

**This diagram satisfies the task requirements by including:**
- Trigger: GitHub push
- 3 Stages: Test → Build → Deploy
- Artifact: Docker image
- Deployment Target: Staging server

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
