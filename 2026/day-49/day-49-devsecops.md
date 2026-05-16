# Day 49 – DevSecOps: Add Security to Your CI/CD Pipeline

## Task
You can build and deploy automatically. But what if your Docker image has a known vulnerability? What if someone accidentally commits a password? Today you learn **DevSecOps** — adding simple, automated security checks to your pipeline so problems are caught **before** they reach production.

Don't worry — this isn't a security course. You're just adding a few smart steps to the pipeline you already built.

---

## Expected Output
- Security scanning added to your `github-actions-capstone` repo (from Day 48)
- A markdown file: `day-49-devsecops.md`
- Screenshot of a security scan running in your pipeline

---

## What is DevSecOps?

Think of it like this:

**Without DevSecOps:**
> You build the app → deploy it → a security team finds a vulnerability weeks later → you scramble to fix it

**With DevSecOps:**
> You open a PR → the pipeline automatically checks for vulnerabilities → you fix it before it ever gets merged

**That's it.** DevSecOps = adding security checks to the pipeline you already have. Not a separate process — just a few extra steps.

---

## Key Principles (Keep These in Mind)

1. **Catch problems early** — A vulnerability found in a PR takes 5 minutes to fix. The same vulnerability found in production takes days.

2. **Automate the checks** — Don't rely on someone remembering to check. Let the pipeline do it every time.

3. **Block on critical issues** — If a scan finds a serious vulnerability, the pipeline should fail — just like a failing test.

4. **Never put secrets in code** — Use GitHub Secrets (you learned this on Day 44). No `.env` files, no hardcoded API keys.

5. **Give only the access needed** — Your workflow doesn't need write access to everything. Limit permissions.

---

## Challenge Tasks

### Task 1: Scan Your Docker Image for Vulnerabilities
Your Docker image might use a base image with known security issues. Let's find out.

Add this step to your main branch pipeline (after Docker build, before deploy):
```yaml
- name: Scan Docker Image for Vulnerabilities
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'your-username/your-app:latest'
    format: 'table'
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
```

What this does:
- `trivy` scans your Docker image for known CVEs (Common Vulnerabilities and Exposures)
- `format: 'table'` prints a readable table in the logs
- `exit-code: '1'` means **fail the pipeline** if CRITICAL or HIGH vulnerabilities are found
- If it passes, your image is clean — proceed to push and deploy

Push and check the Actions tab. Read the scan output.

**Verify:** Can you see the vulnerability table in the logs? Did it pass or fail?

<img width="1912" height="898" alt="image" src="https://github.com/user-attachments/assets/cac27835-ebad-404c-8766-64b95fdcf118" />
<img width="1907" height="882" alt="image" src="https://github.com/user-attachments/assets/090a76ca-a637-4d61-9e39-b1749b846727" />
<img width="1905" height="897" alt="image" src="https://github.com/user-attachments/assets/74df082a-49fc-4a1f-a0b8-e2245ab0070f" />
<img width="1877" height="896" alt="image" src="https://github.com/user-attachments/assets/fc4bcc8e-faa4-4892-87df-5fe4ee01a617" />
<img width="1891" height="888" alt="image" src="https://github.com/user-attachments/assets/afe67a69-5826-480a-8413-6cd3297f135d" />
-->this error is not a bug, it’s expected behavior from Trivy, We can see Error: Process completed with exit code 1. It means Trivy found HIGH or CRITICAL vulnerabilities, Because of exit-code: 1, it intentionally failed the pipeline. This means Your pipeline is protecting production from vulnerable images.
<img width="1882" height="158" alt="image" src="https://github.com/user-attachments/assets/1b701884-9cd0-4b4b-b8c9-3508367a63dd" />

Write in your notes: What CVEs (if any) were found? What base image are you using?

-->Base Image: node:20-alpine
  
  CVEs Found: Yes, HIGH severity vulnerabilities detected
  
  Status: Pipeline failed

---

### Task 2: Enable GitHub's Built-in Secret Scanning
GitHub can automatically detect if someone pushes a secret (API key, token, password) to your repo.

1. Go to your repo → Settings → **Code security and analysis**
2. Enable **Secret scanning**
3. If available, also enable **Push protection** — this blocks the push entirely if a secret is detected

That's it — no workflow changes needed. GitHub does this automatically.

Write in your notes:
**- What is the difference between secret scanning and push protection?**

-->**Secret Scanning:** Detects secrets (like API keys, tokens, passwords) after they have already been committed to the repository. It sends alerts so you can remove or rotate the secret.

-->**Push Protection:** Prevents secrets from being committed in the first place., It blocks the push immediately if a secret is detected and warns the developer.

-->**Secret Scanning** = detect after commit [detection] & **Push Protection** = block before commit/push [prevention]

**- What happens if GitHub detects a leaked AWS key in your repo?**

-->GitHub automatically detects the AWS key using secret scanning, It generates a security alert in the repository, The repository owner/admin is notified, GitHub may also notify AWS, and the key can be automatically revoked.

-->You must: Remove the key from the code/repo, Rotate or regenerate a new key immediately.

**Note:** If GitHub detects a leaked AWS key, it raises a security alert, may notify AWS to revoke the key, and the developer must remove and rotate the key immediately. If push protection is enabled, the push is blocked.

---

### Task 3: Scan Dependencies for Known Vulnerabilities
If your app uses packages (pip, npm, etc.), those packages might have known vulnerabilities.

Add this to your **PR pipeline** (not the main pipeline):
```yaml
- name: Check Dependencies for Vulnerabilities
  uses: actions/dependency-review-action@v4
  with:
    fail-on-severity: critical
```

This checks any **new** dependencies added in the PR against a vulnerability database. If a dependency has a critical CVE, the PR check fails.

Test it:
1. Open a PR that adds a package to your app
2. Check the Actions tab — did the dependency review run?

**Verify:** Does the dependency review show up as a check on your PR?

<img width="1138" height="967" alt="image" src="https://github.com/user-attachments/assets/f0cad2dc-863d-484a-a0ad-acbcb5ec41df" />
<img width="1907" height="692" alt="image" src="https://github.com/user-attachments/assets/a384ef84-1f17-4074-b498-c0189e9a8764" />
<img width="1702" height="865" alt="image" src="https://github.com/user-attachments/assets/19d63d86-5403-4a70-aad6-48f454e848ab" />
<img width="1907" height="900" alt="image" src="https://github.com/user-attachments/assets/422ca889-6efd-4644-a9d7-abc81f929081" />
<img width="1896" height="806" alt="image" src="https://github.com/user-attachments/assets/65b17bc2-2aa9-4814-b135-9a726db45b56" />

**Note:** dependency-review-action does NOT work without Dependency Graph, This is a GitHub limitation, not your mistake.
<img width="1877" height="567" alt="image" src="https://github.com/user-attachments/assets/7482182d-d13a-4054-a696-ec302503400e" />

---

### Task 4: Add Permissions to Your Workflows
By default, workflows get broad permissions. Lock them down.

Add this block near the top of your workflow files (after `on:`):
```yaml
permissions:
  contents: read
```

If a workflow needs to comment on PRs, add:
```yaml
permissions:
  contents: read
  pull-requests: write
```

Update at least 2 of your existing workflow files with a `permissions` block.

**Write in your notes: Why is it a good practice to limit workflow permissions?**

-->Limiting workflow permissions follows the principle of least privilege, meaning workflows only get the minimum access they need. This reduces the risk of security breaches and prevents misuse of repository resources.

**What could go wrong if a compromised action has write access to your repo?**

-->If a compromised or malicious action has write access, it could:

Push malicious code to the repository

Modify or delete important files

Leak secrets such as tokens or API keys

Create or manipulate pull requests

Inject backdoors or vulnerabilities into the application

**Note:** Limiting permissions reduces security risk by granting only necessary access, A compromised action with write access can alter code, leak secrets, or damage the repo

---

### Task 5: See the Full Secure Pipeline
Look at what your pipeline does now:

```
PR opened
  → build & test
  → dependency vulnerability check     ← NEW (Day 49)
  → PR checks pass or fail

Merge to main
  → build & test
  → Docker build
  → Trivy image scan (fail on CRITICAL) ← NEW (Day 49)
  → Docker push (only if scan passes)
  → deploy

Always active
  → GitHub secret scanning              ← NEW (Day 49)
  → push protection for secrets         ← NEW (Day 49)
```

Draw this diagram in your notes. You just built a **DevSecOps pipeline** — security is now part of your automation, not an afterthought.

<img width="1200" height="1600" alt="cicd pipeline" src="https://github.com/user-attachments/assets/d475e61e-d3dd-4a4a-a94a-47459edb63c5" />

---

## Brownie Points (Optional — For the Curious)

### Pin Actions to Commit SHAs
Tags like `@v4` can be moved by the action author. For extra security, pin to the exact commit:
```yaml
# Instead of this:
uses: actions/checkout@v4

# Use this:
uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```
This protects against supply chain attacks where a tag is silently changed.

### Upload Scan Results to GitHub Security Tab
Add SARIF output to Trivy and upload it — your scan results will appear in the repo's **Security** tab:
```yaml
- uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'your-username/your-app:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'
- uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: 'trivy-results.sarif'
```

### Learn About OIDC (Keyless Authentication)
Instead of storing cloud credentials as long-lived secrets, GitHub Actions can use OIDC to get short-lived tokens automatically. Research: "GitHub Actions OIDC" — it's how production pipelines authenticate to AWS, GCP, and Azure without storing any keys.

---

## Hints
- Trivy action docs: look up `aquasecurity/trivy-action` on GitHub
- `exit-code: '1'` = fail the step, `exit-code: '0'` = just warn
- Dependency review only works on `pull_request` events (not on push)
- Permissions block goes at the workflow level or the job level
- GitHub secret scanning is free for public repos

---

## Documentation
Create `day-49-devsecops.md` with:
- What DevSecOps means in your own words (2-3 sentences)
- Screenshot of Trivy scan output in your pipeline
- Your updated pipeline diagram with security steps
- What you learned about secret scanning and dependency review

---

## Submission
1. Add `day-49-devsecops.md` to `2026/day-49/`
2. Commit and push to your fork

---

## Learn in Public
Share your pipeline diagram on LinkedIn — "My CI/CD pipeline now scans for vulnerabilities automatically." Simple, powerful, and impressive.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
