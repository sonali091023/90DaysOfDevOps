# Day 35 – Multi-Stage Builds & Docker Hub

## Task
Today's goal is to **build optimized images and share them with the world**.

Multi-stage builds are how real teams ship small, secure images. Docker Hub is how you distribute them. Both are interview favourites.

---

## Expected Output
- A markdown file: `day-35-multistage-hub.md`
- Dockerfiles demonstrating multi-stage builds
- An image pushed to your Docker Hub account

---

## Challenge Tasks

### Task 1: The Problem with Large Images
1. Write a simple Go, Java, or Node.js app (even a "Hello World" is fine)
2. Create a Dockerfile that builds and runs it in a **single stage**
3. Build the image and check its **size**

Commands used:

-->**vi app.js**

-->**npm init -y > touch package.json** 

-->**vi Dockerfile**

-->**docker build -t node-single-stage .**
 
-->**docker images**

-->**docker run -d --name huge-img-cont -p 3000:3000 node-single-stage**

-->**docker ps**

-->Created image: node-single-stage size is 1.1GB because full Node image is heavy, It Contains unnecessary build tools.

<img width="988" height="963" alt="image" src="https://github.com/user-attachments/assets/ea23bfa1-2170-48bf-a25b-b895ac33ae51" />

<img width="1918" height="986" alt="image" src="https://github.com/user-attachments/assets/ec9fb862-b721-499c-8754-89dccb6c1a1a" />

<img width="396" height="276" alt="image" src="https://github.com/user-attachments/assets/ae7259bc-3fac-447e-b7f4-e34258e031f5" />

---

### Task 2: Multi-Stage Build
1. Rewrite the Dockerfile using **multi-stage build**:
   - Stage 1: Build the app (install dependencies, compile)
   - Stage 2: Copy only the built artifact into a minimal base image (`alpine`, `distroless`, or `scratch`)
2. Build the image and check its size again
3. Compare the two sizes

-->In below screenshot we can see the single-stage-img size and multi-stage-img size, As compare to single-stage-image size multi-stage image size is smaller.

-->A single-stage build relies on the full node:20 image and carries everything along — build tools, npm cache, and extra layers — none of which are needed to run the app, pushing the image size up to ~900MB–1GB.

<img width="750" height="167" alt="image" src="https://github.com/user-attachments/assets/557d71b0-37f7-4156-a428-d8cb99966873" />

Write in your notes: Why is the multi-stage image so much smaller?

<img width="967" height="972" alt="image" src="https://github.com/user-attachments/assets/e414c5e0-7718-4fe3-97a0-3f5439de5602" />

<img width="1425" height="406" alt="image" src="https://github.com/user-attachments/assets/754343c3-562f-419a-a691-a0c9a836937d" />


---

### Task 3: Push to Docker Hub
1. Create a free account on [Docker Hub](https://hub.docker.com) (if you don't have one)
2. Log in from your terminal -->docker login -u <usernmae> & then provide Private access token and you will login to Dockerhub acc successfully
3. Tag your image properly: `yourusername/image-name:tag`
-->To avoid separate tagging for any image use following format while image creation: **docker build -t <dockerhub-username>/<image name>:latest .**
4. Push it to Docker Hub -->**docker push <dockerhub-username>/<image name>:latest**
5. Pull it on a different machine (or after removing locally) to verify --> **docker pull <dockerhub-username>/<image name>:latest**

<img width="1890" height="192" alt="image" src="https://github.com/user-attachments/assets/bec1591b-353c-4796-9741-463e760ebe22" />

<img width="1907" height="207" alt="image" src="https://github.com/user-attachments/assets/84e98a33-3ecd-446f-855d-3e5e2d9ac8de" />

<img width="1157" height="42" alt="image" src="https://github.com/user-attachments/assets/457f7989-492b-470e-9820-d2a8b13b25c9" />

<img width="1070" height="75" alt="image" src="https://github.com/user-attachments/assets/7078d89e-abfa-400d-bca2-cef65521734c" />

<img width="1906" height="408" alt="image" src="https://github.com/user-attachments/assets/92ed2196-d17a-4ac5-bee5-ee126eaff85c" />

---

### Task 4: Docker Hub Repository
1. Go to Docker Hub and check your pushed image

<img width="1507" height="240" alt="image" src="https://github.com/user-attachments/assets/29f74f3e-6c2a-4939-8baa-5e58dee1a68d" />

2. Add a **description** to the repository

<img width="805" height="301" alt="image" src="https://github.com/user-attachments/assets/3ae78ad3-309b-41ef-8fc9-d48b9afca43d" />


3. Explore the **tags** tab — understand how versioning works

<img width="1537" height="782" alt="image" src="https://github.com/user-attachments/assets/5b98448e-7c9b-4e6d-ba69-22cf16c5e31f" />


5. Pull a specific tag vs `latest` — what happens?

-->By using following command and here used tag v1 instead of latest **docker pull sonali0910/node-multi-stage:v1** Now if the image is available with v1 tag imge will get pulled and if not manifest unknown error and if we dont mention any tag and use command like follow **docker pull sonali0910/node-multi-stage** Then in thsi case docker will use tag latest bydefault and pull that image i case available, And if not we may face issuemanifest unknown error.

---

### Task 5: Image Best Practices
Apply these to one of your images and rebuild:
1. Use a **minimal base image** (alpine vs ubuntu — compare sizes)
2. **Don't run as root** — add a non-root USER in your Dockerfile
3. Combine `RUN` commands to **reduce layers**
4. Use **specific tags** for base images (not `latest`)

Check the size before and after.

-->By using docker minimal images alpine: node:18-alpine and ubuntu: node:18-slim based on that we can see the image size in below image,

<img width="1907" height="300" alt="image" src="https://github.com/user-attachments/assets/10b68707-6425-402a-862d-f748cafd1793" />


---

## Hints
- Multi-stage: use `FROM ... AS builder` then `COPY --from=builder`
- Login: `docker login`
- Tag: `docker tag local-image:tag username/repo:tag`
- Push: `docker push username/repo:tag`
- Non-root user: `RUN adduser` + `USER`

---

## Submission
1. Add your Dockerfiles and `day-35-multistage-hub.md` to `2026/day-35/`
2. Include the link to your Docker Hub repo
3. Commit and push to your fork

---

## Learn in Public
Share your before/after image sizes on LinkedIn — the difference is always impressive.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
