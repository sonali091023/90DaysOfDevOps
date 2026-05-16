# Day 45 – Docker Build & Push in GitHub Actions

## Task
Today you build a **complete CI/CD pipeline** — code pushed to GitHub automatically builds a Docker image and ships it to Docker Hub. No manual steps.

This is exactly what happens in real production pipelines.

---

## Expected Output
- A complete workflow: `.github/workflows/docker-publish.yml`
- Your Docker image live on Docker Hub
- A status badge in your repo README
- A markdown file: `day-45-docker-cicd.md`

---

## Challenge Tasks

### Task 1: Prepare
1. Use the app you Dockerized on Day 36 (or any simple Dockerfile)
2. Add the Dockerfile to your `github-actions-practice` repo (or create a minimal one)
3. Make sure `DOCKER_USERNAME` and `DOCKER_TOKEN` secrets are set from Day 44

-->used github repository URL: https://github.com/sonali091023/github-actions-practice.git 

<img width="1240" height="725" alt="image" src="https://github.com/user-attachments/assets/afdc7d0c-a403-4040-99e3-a2e9bbd17273" />

<img width="1388" height="840" alt="image" src="https://github.com/user-attachments/assets/292e4fff-e253-4503-8cec-c002d5fd3380" />

<img width="1862" height="905" alt="image" src="https://github.com/user-attachments/assets/6daa8440-7c42-4790-83f5-c103d221ddce" />

<img width="1867" height="903" alt="image" src="https://github.com/user-attachments/assets/c0423253-293d-4666-bbd8-a014f3b925ce" />

<img width="1870" height="903" alt="image" src="https://github.com/user-attachments/assets/39f234b0-182d-47ca-8168-8360fd3f6dff" />

Note: I created a GitHub Actions workflow that triggers on push to main, checks out the repository, and builds a Docker image using the Dockerfile. I verified the build by inspecting the logs to confirm successful image creation and tagging.

---

### Task 2: Build the Docker Image in CI
Create `.github/workflows/docker-publish.yml` that:
1. Triggers on push to `main`
2. Checks out the code
3. Builds the Docker image and tags it

**Verify:** Check the build step logs — does the image build successfully?
-->Yes image got build successfully!!!

-->You push code to main

-->GitHub Actions starts a runner (Ubuntu VM)

-->Your repo is downloaded

-->Docker builds image using your Dockerfile

-->Image gets tag → my-app:latest

<img width="1888" height="902" alt="image" src="https://github.com/user-attachments/assets/25926600-3faf-42d6-a33b-9cf69233ca83" />

<img width="1872" height="892" alt="image" src="https://github.com/user-attachments/assets/d816e28f-ce61-4772-b25c-4cd5b8895bdf" />

---

### Task 3: Push to Docker Hub
Add steps to:
1. Log in to Docker Hub using your secrets
2. Tag the image as `username/repo:latest` and also `username/repo:sha-<short-commit-hash>`
3. Push both tags

<img width="1917" height="902" alt="image" src="https://github.com/user-attachments/assets/752ad1f6-997a-47e6-94a0-301b94d829eb" />

<img width="1887" height="906" alt="image" src="https://github.com/user-attachments/assets/f6402241-25bb-4701-a166-523591c88366" />

<img width="1871" height="900" alt="image" src="https://github.com/user-attachments/assets/0e62f5ff-30db-4f36-a4de-e5e7206f724a" />

<img width="1797" height="891" alt="image" src="https://github.com/user-attachments/assets/85f06ee5-999b-47f5-8914-40be3aeb7b84" />

**Verify:** Go to Docker Hub — is your image there with both tags?

<img width="1903" height="902" alt="image" src="https://github.com/user-attachments/assets/19cbbac4-4626-47d2-9882-6ea5b5f0f520" />

---

### Task 4: Only Push on Main
Add a condition so the push step only runs on the `main` branch — not on feature branches or PRs.

Test it: push to a feature branch and verify the image is built but NOT pushed.
-->So image is built and tried to push to both main and feature branch but as we have set only main branch so it pushed to main branch only and ont in featuch branch, And also in Dockerhub we can see 2 images got pushed from main branch based on requirement.

<img width="1876" height="902" alt="image" src="https://github.com/user-attachments/assets/1ee8e5b7-affd-4470-b7a8-d6d910a0abfc" />

<img width="1892" height="911" alt="image" src="https://github.com/user-attachments/assets/025f3726-e97c-4c2e-b49f-10aaade9b13d" />

<img width="1866" height="822" alt="image" src="https://github.com/user-attachments/assets/fb138c10-a374-4bf9-98eb-992a18b3db89" />

<img width="1887" height="920" alt="image" src="https://github.com/user-attachments/assets/bdcc948e-2d69-40cf-9ab6-290bea66834f" />

---

### Task 5: Add a Status Badge
1. Get the badge URL for your `docker-publish` workflow from the Actions tab
2. Add it to your `README.md`
3. Push — the badge should show green

**Steps follow:**

-->Go to your repo on GitHub

-->Click on Actions tab

-->On the left sidebar, click your workflow (e.g. docker-publish)

-->On the right side, you’ll see “Create status badge” click on it and one badge regarding popup will get open there we wil. get URL copy it and paste it in README.md file and then commit the chnages .

<img width="1703" height="783" alt="image" src="https://github.com/user-attachments/assets/a6731309-c988-4646-8629-316e3ffa4a1f" />

-->On failure we can see the badge in red color with status failing
<img width="1585" height="830" alt="image" src="https://github.com/user-attachments/assets/ee3f18fc-661a-46e7-b41d-72c0de872f4c" />

-->We uses badges because it shows real-time pipeline health, Improves project visibility, Helps teams quickly detect failures, Standard practice in DevOps & open-source projects etc.

---

### Task 6: Pull and Run It
1. On your local machine (or a cloud server), pull the image you just pushed
<img width="1096" height="367" alt="image" src="https://github.com/user-attachments/assets/babf461d-3aef-4b3f-9bf2-52f439313613" />

2. Run it
<img width="1876" height="202" alt="image" src="https://github.com/user-attachments/assets/eff9c348-b57c-47db-b3b4-369dc0a699c0" />

3. Confirm it works
<img width="1881" height="686" alt="image" src="https://github.com/user-attachments/assets/4b40a853-711b-4e90-85ff-356b1a4c2187" />
<img width="847" height="305" alt="image" src="https://github.com/user-attachments/assets/072b90bf-8155-4212-ba76-5dd45a8f762f" />
<img width="1887" height="852" alt="image" src="https://github.com/user-attachments/assets/50fd023f-5c07-4197-83a3-4cd361a5edc2" />


Write in your notes: What is the full journey from `git push` to a running container?

-->When I push code to GitHub using git push, it triggers a GitHub Actions workflow defined in my repository. The workflow runs on a GitHub-hosted runner, where it first checks out the code and then builds a Docker image using the Dockerfile. After building the image, the workflow logs in to Docker Hub using stored secrets, tags the image (for example, latest and commit SHA), and pushes it to Docker Hub.

Once the image is available in Docker Hub, I can pull it onto any machine using docker pull. After pulling the image, I run it as a container using docker run, which starts the application inside an isolated environment. Finally, I verify that the container is running correctly by accessing it via a browser or API endpoint.

This completes the full CI/CD flow from code commit to a running containerized application.

---

## Hints
- Docker login: `uses: docker/login-action@v3`
- Build and push: `uses: docker/build-push-action@v5`
- Short SHA: `${{ github.sha }}` (use `cut` or `slice` to get first 7 chars)
- Badge URL format: `https://github.com/<user>/<repo>/actions/workflows/<file>.yml/badge.svg`

---

## Documentation
Create `day-45-docker-cicd.md` with:
- Your complete workflow YAML
- Docker Hub link to your image
- Screenshot of the pipeline run
- The full journey described in Task 6

---

## Submission
1. Add `day-45-docker-cicd.md` to `2026/day-45/`
2. Commit and push to your fork

---

## Learn in Public
Share your Docker Hub image link and the green badge on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
