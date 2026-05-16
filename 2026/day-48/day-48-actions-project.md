# Day 48 – GitHub Actions Project: End-to-End CI/CD Pipeline

## Task
You've learned workflows, triggers, secrets, Docker builds, reusable workflows, and advanced events. Today you **put it all together** in one project — a complete, production-style CI/CD pipeline that builds, tests, and deploys using everything you've learned from Day 40 to Day 47.

This is your GitHub Actions capstone.

---

## Expected Output
- A GitHub repo with a working app, Dockerfile, and complete CI/CD pipeline
- At least 3 workflow files working together
- A markdown file: `day-48-actions-project.md`
- Screenshot of your full pipeline in action

---

## Challenge Tasks

### Task 1: Set Up the Project Repo
1. Create a new repo called `github-actions-capstone` (or use your existing `github-actions-practice`)
2. Add a simple app — pick any one:
   - A Python Flask/FastAPI app with one endpoint
   - A Node.js Express app with one endpoint
   - Your Dockerized app from Day 36
3. Add a `Dockerfile` and a basic test (even a script that curls the health endpoint counts)
4. Add a `README.md` with a project description

<img width="1863" height="977" alt="image" src="https://github.com/user-attachments/assets/326997eb-c27a-4e09-994e-6bdffecd1b9b" />
<img width="837" height="978" alt="image" src="https://github.com/user-attachments/assets/ca304e4e-d1cb-4911-833c-fdd9c99810c4" />
<img width="922" height="188" alt="image" src="https://github.com/user-attachments/assets/1a0bfe4e-32ba-4c35-a8b3-28a21ce8bc87" />
<img width="1348" height="987" alt="image" src="https://github.com/user-attachments/assets/fc57f71a-d6b7-445b-a1a6-a5d374796e1f" />
<img width="1291" height="291" alt="image" src="https://github.com/user-attachments/assets/6c4b2360-099e-4c57-8332-6a5c0b5e3f61" />

---

### Task 2: Reusable Workflow — Build & Test
Create `.github/workflows/reusable-build-test.yml`:
1. Trigger: `workflow_call`
2. Inputs: `python_version` (or `node_version`), `run_tests` (boolean, default: true)
3. Steps:
   - Check out code
   - Set up the language runtime
   - Install dependencies
   - Run tests (only if `run_tests` is true)
   - Set output: `test_result` with value `passed` or `failed`

This workflow does NOT deploy — it only builds and tests.

---

### Task 3: Reusable Workflow — Docker Build & Push
Create `.github/workflows/reusable-docker.yml`:
1. Trigger: `workflow_call`
2. Inputs: `image_name` (string), `tag` (string)
3. Secrets: `docker_username`, `docker_token`
4. Steps:
   - Check out code
   - Log in to Docker Hub
   - Build and push the image with the given tag
   - Set output: `image_url` with the full image path



<img width="1090" height="962" alt="image" src="https://github.com/user-attachments/assets/1fbd8e7a-bead-492e-bce6-05f1705dc76b" />
<img width="677" height="335" alt="image" src="https://github.com/user-attachments/assets/8d7cfd9b-fa54-4219-bc54-a537f24db3d4" />
<img width="1892" height="862" alt="image" src="https://github.com/user-attachments/assets/56f09a25-fbbf-4f0f-bf90-c9b873c4f784" />
<img width="1406" height="790" alt="image" src="https://github.com/user-attachments/assets/e0e04ae0-fb7a-4c7d-b6a5-05836605362d" />
<img width="1898" height="772" alt="image" src="https://github.com/user-attachments/assets/7c8b9502-2b01-48a7-a927-989defcff811" />

---

### Task 4: PR Pipeline
Create `.github/workflows/pr-pipeline.yml`:
1. Trigger: `pull_request` to `main` (types: `opened`, `synchronize`)
2. Call the reusable build-test workflow:
   - Run tests: `true`
3. Add a standalone job `pr-comment` that:
   - Runs after the build-test job
   - Prints a summary: "PR checks passed for branch: `<branch>`"
4. Do **NOT** build or push Docker images on PRs

**Verify:** Open a PR — does it run tests only (no Docker push)?

<img width="892" height="655" alt="image" src="https://github.com/user-attachments/assets/1a33b644-3a64-4461-a5b3-c2627feeb2a4" />
<img width="1533" height="711" alt="image" src="https://github.com/user-attachments/assets/46d7ba32-c29c-4a74-b7f9-4e206f7524f3" />
<img width="1523" height="776" alt="image" src="https://github.com/user-attachments/assets/25828d4d-77eb-42a6-af15-026702d24d18" />
<img width="1860" height="848" alt="image" src="https://github.com/user-attachments/assets/a4fe567e-ea34-4859-a6b5-54dd12076b65" />
<img width="1911" height="707" alt="image" src="https://github.com/user-attachments/assets/40dc3a81-3cac-49ec-a6e4-1435743a6039" />
<img width="1881" height="902" alt="image" src="https://github.com/user-attachments/assets/6782e78a-b9cd-4fd4-96e1-a4e1223c57a7" />
<img width="1861" height="320" alt="image" src="https://github.com/user-attachments/assets/d401b864-9731-4c30-9eee-59083a2fb452" />
<img width="1916" height="631" alt="image" src="https://github.com/user-attachments/assets/c94b2f06-b288-4389-a2f5-18135dddf325" />
<img width="1907" height="607" alt="image" src="https://github.com/user-attachments/assets/cec51d87-784e-4260-ab6f-6eab21677b50" />

---

### Task 5: Main Branch Pipeline
Create `.github/workflows/main-pipeline.yml`:
1. Trigger: `push` to `main`
2. Job 1: Call the reusable build-test workflow
3. Job 2 (depends on Job 1): Call the reusable Docker workflow
   - Tag: `latest` and `sha-<short-commit-hash>`
4. Job 3 (depends on Job 2): `deploy` job that:
   - Prints "Deploying image: `<image_url>` to production"
   - Uses `environment: production` (set this up in repo Settings → Environments)
   - Requires manual approval if you've set up environment protection rules

**Verify:** Merge a PR to `main` — does it run tests → build Docker → deploy in sequence?

<img width="1078" height="430" alt="image" src="https://github.com/user-attachments/assets/cab941bb-2782-47bb-9e43-9f84d8d2dd75" />
<img width="1793" height="601" alt="image" src="https://github.com/user-attachments/assets/c509c84f-8ebc-4b49-83f5-c1932b6dd74b" />
<img width="1797" height="862" alt="image" src="https://github.com/user-attachments/assets/8957b72c-c476-40dd-bc5f-87a4e97abff4" />
<img width="1880" height="843" alt="image" src="https://github.com/user-attachments/assets/13d9a411-d32c-415a-b1a0-98cbd90b31e6" />
<img width="1840" height="773" alt="image" src="https://github.com/user-attachments/assets/d2e73f91-ff57-4ba3-9670-90f9880ef955" />
<img width="1885" height="785" alt="image" src="https://github.com/user-attachments/assets/6ee9408d-381d-4365-aec0-16c80678054c" />
<img width="1911" height="536" alt="image" src="https://github.com/user-attachments/assets/6242a543-2812-4463-8cac-ff83ab6c4a71" />
<img width="1881" height="896" alt="image" src="https://github.com/user-attachments/assets/07d1304c-770b-4992-96e9-29da703a77f2" />
<img width="1868" height="261" alt="image" src="https://github.com/user-attachments/assets/a1520f5b-4e67-4f9d-8070-acb43158d3c9" />

---

### Task 6: Scheduled Health Check
Create `.github/workflows/health-check.yml`:
1. Trigger: `schedule` with cron `'0 */12 * * *'` (every 12 hours) + `workflow_dispatch` for manual testing
2. Steps:
   - Pull your latest Docker image
   - Run the container in detached mode
   - Wait 5 seconds, then curl the health endpoint
   - Print pass/fail based on the response
   - Stop and remove the container
3. Add a step that creates a summary using `$GITHUB_STEP_SUMMARY`:
   ```bash
   echo "## Health Check Report" >> $GITHUB_STEP_SUMMARY
   echo "- Image: myapp:latest" >> $GITHUB_STEP_SUMMARY
   echo "- Status: PASSED" >> $GITHUB_STEP_SUMMARY
   echo "- Time: $(date)" >> $GITHUB_STEP_SUMMARY
   ```


<img width="1900" height="890" alt="image" src="https://github.com/user-attachments/assets/8490e09c-03ad-481c-88f6-1f35bba9fc69" />
<img width="1888" height="902" alt="image" src="https://github.com/user-attachments/assets/70606768-0e87-4431-96e7-a1165b135410" />
<img width="1902" height="822" alt="image" src="https://github.com/user-attachments/assets/d908ce03-fd13-4d96-90ff-83e432937c6a" />

---

### Task 7: Add Badges & Documentation
1. Add status badges for all your workflows to the repo `README.md`
<img width="1885" height="560" alt="image" src="https://github.com/user-attachments/assets/a8387cf7-e9a8-4375-a2f2-56ce8c190daa" />

2. Add a **pipeline architecture diagram** in your notes — draw (or describe) the flow:
   ```
   PR opened → build & test → PR checks pass
   Merge to main → build & test → Docker build & push → deploy
   Every 12 hours → health check
   ```
3. Fill in your notes: What would you add next? (Slack notifications? Multi-environment? Rollback?)
-->**#Future Improvements:**

- 🔔 Slack / Email Notifications  
  Send alerts on pipeline failure or health check failure.

- 🌍 Multi-Environment Deployment  
  Add staging and production environments with separate approvals.

- 🔁 Rollback Strategy  
  Deploy previous stable Docker image using SHA tags.

- 🧪 Advanced Testing  
  Add unit tests, integration tests, and API contract testing.

- 🔐 Security Scanning  
  Scan Docker images using tools like Trivy.

- 📦 Versioning Strategy  
  Use semantic versioning (v1.0.0) along with commit SHA.

- ☁️ Real Deployment  
  Deploy to cloud (AWS/GCP/Azure Kubernetes or VM).

---

## Brownie Points: Add Security to Your Pipeline
Want to go above and beyond? Add a **DevSecOps** step to your main pipeline:
1. Add `aquasecurity/trivy-action` after the Docker build step to scan your image for vulnerabilities
2. Fail the pipeline if any **CRITICAL** severity CVE is found
3. Upload the scan report as an artifact

This is a preview of what you'll do in depth on **Day 49**. If you get this working today, you're already thinking like a DevSecOps engineer.

-->This is the final CI-CD flow after implementation of the above,
<img width="375" height="252" alt="image" src="https://github.com/user-attachments/assets/5db3b6dd-baae-4f4e-b68d-f9378e9b7fb2" />


---

## Hints
- Environment protection: Repo Settings → Environments → Add `production` → enable "Required reviewers"
- `$GITHUB_STEP_SUMMARY` renders markdown in the Actions run summary page
- Short SHA for tags: `$(echo ${{ github.sha }} | cut -c1-7)`
- Reusable workflow outputs: accessed via `${{ needs.<job>.outputs.<name> }}`
- Use `actions/github-script` if you want to post PR comments programmatically

---

## Documentation
Create `day-48-actions-project.md` with:
- Your pipeline architecture (the flow diagram from Task 7)
- All workflow YAML files
- Screenshot of a PR running the test-only pipeline
- Screenshot of a main branch push running the full pipeline
- Docker Hub link to your pushed image
- What you'd improve next

---

## Submission
1. Add `day-48-actions-project.md` to `2026/day-48/`
2. Commit and push to your fork

---

## Learn in Public
Share your complete pipeline architecture on LinkedIn — you just built production-grade CI/CD from scratch using only GitHub Actions. That's serious DevOps skill.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
