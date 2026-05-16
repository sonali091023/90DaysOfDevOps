# Day 44 – Secrets, Artifacts & Running Real Tests in CI

## Task
Today your pipeline starts doing **real work** — storing sensitive values securely, saving build outputs, and running actual tests from your previous days.

---

## Expected Output
- New workflow files in your `github-actions-practice` repo
- A markdown file: `day-44-secrets-artifacts.md`
- A passing test run in CI

--- 

## Challenge Tasks

### Task 1: GitHub Secrets
1. Go to your repo → Settings → Secrets and Variables → Actions
2. Create a secret called `MY_SECRET_MESSAGE`
3. Create a workflow that reads it and prints: `The secret is set: true` (never print the actual value)
4. Try to print `${{ secrets.MY_SECRET_MESSAGE }}` directly — what does GitHub show?

-->Used here github repository for the github actions practice: https://github.com/sonali091023/github-actions-practice

Write in your notes: Why should you never print secrets in CI logs?

-->CI logs can be accessed by multiple users or systems

-->Even though GitHub masks secrets, it is not 100% foolproof

-->Secrets may leak through transformations, partial matches, or external integrations

-->Exposing secrets can lead to security breaches (API misuse, data leaks, unauthorized access) etc.

<img width="1893" height="843" alt="image" src="https://github.com/user-attachments/assets/62332a1d-1647-429e-8b18-60644ded11d0" />

---

### Task 2: Use Secrets as Environment Variables
1. Pass a secret to a step as an environment variable
2. Use it in a shell command without ever hardcoding it
3. Add `DOCKER_USERNAME` and `DOCKER_TOKEN` as secrets (you'll need these on Day 45)

<img width="1910" height="768" alt="image" src="https://github.com/user-attachments/assets/dc857273-a4ed-4031-b7f0-b22c2b1803bc" />

<img width="1902" height="908" alt="image" src="https://github.com/user-attachments/assets/2a77400a-2ea9-4576-8f4e-1281b8fdd504" />

-->**Note:** GitHub Secrets are used to securely store sensitive data. They are injected into workflows as environment variables and should never be printed in logs. .env files are not 
used in GitHub Actions; instead, secrets are accessed at runtime for secure operations like API calls or deployments.

---

### Task 3: Upload Artifacts
1. Create a step that generates a file — e.g., a test report or a log file
2. Use `actions/upload-artifact` to save it
3. After the workflow runs, download the artifact from the Actions tab

**How to download Artifact:**

-->Go to your repo → Actions tab

-->Click your workflow run (Artifact Demo)

-->Scroll down to Artifacts section

-->You’ll see: test-report

-->Click → Download ZIP

<img width="1898" height="913" alt="image" src="https://github.com/user-attachments/assets/229a74dd-2eef-4a4f-b381-d4ad1bf7b13e" />

**Verify:** Can you see and download it from GitHub?

-->A file generated during a workflow and stored by GitHub for later use. Eg: Test reports, Build outputs (JAR, ZIP, binaries), Logs, Duration of the data is bydefault 90 days, 
And they are Downloadable anytime during that period.

<img width="870" height="91" alt="image" src="https://github.com/user-attachments/assets/93632945-6363-413d-9849-89a8e5907de3" />

<img width="1485" height="842" alt="image" src="https://github.com/user-attachments/assets/e4862cea-3741-4d2a-b69b-093ab1a46df8" />

**Note:** Artifacts in GitHub Actions are used to store files generated during a workflow, such as test reports or build outputs. They can be uploaded using actions/upload-artifact and downloaded later from the Actions tab or used across jobs.

---

### Task 4: Download Artifacts Between Jobs
1. Job 1: generate a file and upload it as an artifact
2. Job 2: download the artifact from Job 1 and use it (print its contents)

Write in your notes: When would you use artifacts in a real pipeline?

-->To pass build outputs between jobs (e.g., build → test → deploy)

-->To store test reports for later review

-->To preserve logs for debugging failures

-->To share generated files (binaries, packages) across workflow stages

<img width="1897" height="902" alt="image" src="https://github.com/user-attachments/assets/6e1d636f-f1f8-4ca3-a4b2-c09605797e19" />

<img width="1542" height="757" alt="image" src="https://github.com/user-attachments/assets/74d28aae-c1f2-468d-9bd3-79c84e9593cb" />

**Note:** Artifacts are:Temporary storage between jobs, Not meant for long-term storage (use releases/S3 for that)

---

### Task 5: Run Real Tests in CI
Take any script from your earlier days (Python or Shell) and run it in CI:
1. Add your script to the `github-actions-practice` repo
2. Write a workflow that:
   - Checks out the code
   - Installs any dependencies needed
   - Runs the script
   - Fails the pipeline if the script exits with a non-zero code

<img width="1880" height="852" alt="image" src="https://github.com/user-attachments/assets/b832022d-f63a-4553-82c2-25004e062f1b" />

3. Intentionally break the script — verify the pipeline goes red

<img width="1882" height="882" alt="image" src="https://github.com/user-attachments/assets/908844ca-7826-4b27-8ca8-32330cdd5a96" />

4. Fix it — verify it goes green again

<img width="1877" height="836" alt="image" src="https://github.com/user-attachments/assets/812b5abc-cf16-407c-8f7c-6386ac1ed41e" />

---

### Task 6: Caching
1. Add `actions/cache` to a workflow that installs dependencies
2. Run it twice — observe the time difference
3. Write in your notes: What is being cached and where is it stored?

-->When I added **actions/cache** to my GitHub Actions workflow, I enabled caching for Python dependencies downloaded by **pip**. During the first run, the workflow checked for an existing cache using a key based on the OS and the requirements.txt file, but since no cache existed, it showed “Cache not found”. Then pip install downloaded all required packages from the internet and stored those downloaded files in the **~/.cache/pip** directory. At the end of the job, GitHub saved this directory in its remote cache storage. During the second run, the workflow again checked the cache using the same key and this time found it, so it restored the cached files. As a result, pip reused the already downloaded packages instead of downloading them again, making the installation step much faster. It’s important to understand that this cache stores downloaded package files, not the fully installed libraries—those are installed in the Python environment (site-packages). So overall, **caching helps reduce build time by avoiding repeated downloads while still installing dependencies each time**.

<img width="1820" height="895" alt="image" src="https://github.com/user-attachments/assets/837c9a27-1db4-4427-aa34-464cd27a7b67" />

<img width="1876" height="858" alt="image" src="https://github.com/user-attachments/assets/3a15a56e-a8f5-40c9-8bc2-91f56c5bc746" />

<img width="1417" height="143" alt="image" src="https://github.com/user-attachments/assets/c1140d0e-6090-470f-92b0-15245e8436c8" />

---

## Hints
- Secrets: `${{ secrets.SECRET_NAME }}`
- Upload artifact: `uses: actions/upload-artifact@v4`
- Download artifact: `uses: actions/download-artifact@v4`
- Cache: `uses: actions/cache@v4`
- GitHub masks secret values in logs automatically

---

## Documentation
Create `day-44-secrets-artifacts.md` with:
- Screenshots of artifact download
- Screenshot of your passing test run
- What you learned about secrets management

---

## Submission
1. Add `day-44-secrets-artifacts.md` to `2026/day-44/`
2. Commit and push to your fork

---

## Learn in Public
Share your first real test run passing in CI on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
