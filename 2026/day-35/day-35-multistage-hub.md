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

**Steps to follow:**

-->This task is designed to show why single-stage Docker builds often produce unnecessarily large images. Later, you'll optimize the image using multi-stage builds and compare the results.

Step 1: Create the Project: mkdir day-35-task1 && cd day-35-task1

Step 2: Create app.js: vi app.js

<img width="687" height="262" alt="image" src="https://github.com/user-attachments/assets/0f36a0cf-ef08-4f01-acd4-cde894d51cf8" />

Step 3: Create package.json: vi package.json

<img width="701" height="316" alt="image" src="https://github.com/user-attachments/assets/edb18786-157c-4a0c-b769-63f4e04994ee" />

Step 4: Create a Single-Stage Dockerfile: vi Dockerfile

<img width="747" height="602" alt="image" src="https://github.com/user-attachments/assets/2b50b280-b593-445f-a6e5-ac4c91573559" />

Step 5: Build the Image: docker build -t hello-node-single .

Step 6: Check Image Size: docker images 

-->The exact size depends on the Node base image version and your Docker installation. We can also inspect it directly: docker image ls hello-node-single OR docker image inspect hello-node-single

<img width="1797" height="972" alt="image" src="https://github.com/user-attachments/assets/23cb4030-2670-4225-98fa-723f7b93c7a7" />

<img width="1917" height="951" alt="image" src="https://github.com/user-attachments/assets/1a00e74a-8cae-4c91-a3b2-ca3212b0589e" />

<img width="1911" height="752" alt="image" src="https://github.com/user-attachments/assets/9e714e6c-1fab-4285-b80d-4ac2717b9d08" />

Step 7: Run the Container: docker run -d -p 3000:3000 --name hello-app hello-node-single

-->Now test it: curl http://localhost:3000 [Expected output: Hello from Docker!]

-->To test the same on browser for that launch URL: http://localhost:3000

<img width="1907" height="165" alt="image" src="https://github.com/user-attachments/assets/f40328e5-226d-4f1a-a64e-d59081d3d593" />

<img width="1917" height="646" alt="image" src="https://github.com/user-attachments/assets/cfb7cdd3-0a0e-4960-a72f-e51891458b24" />

Step 8: Why Is the Image Large?: 

<img width="772" height="270" alt="image" src="https://github.com/user-attachments/assets/dc9e07e4-b406-4b33-8c24-df18431c5786" />

Observation:

- Image contains the Node runtime and build tools.
- All build dependencies remain in the final image.
- Image is larger than necessary for a simple Hello World application.
- This serves as the baseline for comparison with a multi-stage build.

Step 9: Record Your Results: [notes.md](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-35/notes.md)

---

### Task 2: Multi-Stage Build
1. Rewrite the Dockerfile using **multi-stage build**:
   - Stage 1: Build the app (install dependencies, compile)
   - Stage 2: Copy only the built artifact into a minimal base image (`alpine`, `distroless`, or `scratch`)
2. Build the image and check its size again
3. Compare the two sizes
Write in your notes: Why is the multi-stage image so much smaller?

**Steps to follow:**

-->Great! This task demonstrates one of the biggest benefits of Docker: multi-stage builds. Since your Node.js app doesn't require compilation (it's plain JavaScript), the "build" stage will mainly install dependencies, and the final stage will contain only what is needed to run the application.

<img width="1142" height="162" alt="image" src="https://github.com/user-attachments/assets/98453abe-6ba6-4b5d-8936-5197a1bdeb40" />

Step 1: Create a Multi-Stage Dockerfile: vi Dockerfile

<img width="695" height="586" alt="image" src="https://github.com/user-attachments/assets/d8bc6178-f008-41ae-8ae1-277fe1308ede" />

**Dockerfile breakdown as follow:**

<img width="721" height="756" alt="image" src="https://github.com/user-attachments/assets/d91cd63d-ae4b-421d-9a51-ea541f978d83" />

<img width="712" height="707" alt="image" src="https://github.com/user-attachments/assets/abb2a594-63b6-4eba-b5ff-37c6c938a18f" />

<img width="797" height="151" alt="image" src="https://github.com/user-attachments/assets/01c1888c-fc8c-47e2-a11b-22691c107452" />

-->Step 2: Build the Image: docker build -t multi-stage-image .

<img width="1806" height="962" alt="image" src="https://github.com/user-attachments/assets/396a31a6-89f6-490a-9d45-8384d37c0b02" />

Step 3: Check Image Size: docker images

<img width="1891" height="261" alt="image" src="https://github.com/user-attachments/assets/42a17b6e-db8c-4903-89e6-2596d7ba7eb1" />

-->Now here the image size is: 136MB

-->Step 4: Run the Container: docker run -itd --name multi-stage-container -p 3000:3000 multi-stage-image:latest

-->Now test it: curl http://localhost:3000 [Expected output: Hello from Docker!]

<img width="1890" height="126" alt="image" src="https://github.com/user-attachments/assets/81353b94-bf39-4a63-b164-e2dee011cef2" />

-->To test the same on browser for that launch URL: http://localhost:3000

<img width="1917" height="650" alt="image" src="https://github.com/user-attachments/assets/4865f7ce-5f4f-4b73-93f3-0f91e2deea29" />

Step 5: Compare the Images: 

<img width="891" height="292" alt="image" src="https://github.com/user-attachments/assets/ff4ef333-76d5-49ec-8062-ecf66ae9da79" />

Q. Why is the multi-stage image so much smaller?
-->A multi-stage build reduces image size because:

The final image starts from a fresh base image instead of keeping all layers from the build stage.
Build-time files, caches, and temporary artifacts are left behind in the builder stage.
Only the files required to run the application are copied into the final image.
Using node:20-alpine provides a much smaller base than the standard node:20 image.

The result is a leaner image that downloads faster, starts quicker, consumes less storage, and has a smaller attack surface.

[task2-notes.md](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-35/task2-notes.md)

---

### Task 3: Push to Docker Hub
Create a free account on Docker Hub (if you don't have one)
Log in from your terminal
Tag your image properly: yourusername/image-name:tag
Push it to Docker Hub
Pull it on a different machine (or after removing locally) to verify

**Steps to follow:**

Step 1: Create a Docker Hub Account:

-->Go to https://hub.docker.com & Sign up for a free account (skip if you already have one).

Step 2: Log in from the Terminal:

-->docker login -u <usernmae> & then provide Private access token and you will login to Dockerhub acc successfully

-->Once configured to verify: docker info

Step 3: Tag Your Image: 

-->Check your local images: docker images: multi-stage-image:latest

-->Tag it using your Docker Hub username: docker tag multi-stage-image:latest sonali0910/multi-stage-image:latest

**Note:** To avoid separate tagging for any image use following format while image creation: docker build -t <dockerhub-username>/<image name>:latest .

-->once tagging complete to verify: docker images

4. Push it to Docker Hub:

-->docker push sonali0910/multi-stage-image:latest

<img width="1712" height="975" alt="image" src="https://github.com/user-attachments/assets/aae99148-bacb-4006-bbea-75df97fe8305" />

<img width="1895" height="720" alt="image" src="https://github.com/user-attachments/assets/42b424ac-e13d-49eb-852b-3c6c6ae29335" />

<img width="1911" height="952" alt="image" src="https://github.com/user-attachments/assets/2b53fe0e-c959-4448-86e8-4096d8ed1e01" />

5. Pull it on a different machine (or after removing locally) to verify --> docker pull sonali0910/multi-stage-image:latest

-->docker images

-->docker ps

-->docker run -itd --name multi-stage-container -p 3000:3000 sonali0910/multi-stage-image:latest

-->docker ps

-->YTo test: curl http://localhost:3000

-->To test the same on browser: http://localhost:3000

<img width="1917" height="501" alt="image" src="https://github.com/user-attachments/assets/1cbd042d-a279-4907-8f10-4006924a50f5" />

<img width="1912" height="726" alt="image" src="https://github.com/user-attachments/assets/4883bdea-dd2e-4868-9fbd-7a56c041744e" />

---

### Task 4: Docker Hub Repository
1. Go to Docker Hub and check your pushed image
2. Add a description to the repository
3. Explore the tags tab — understand how versioning works
4. Pull a specific tag vs latest — what happens?

**Steps to follow:**

Step 1: Check Your Repository:

<img width="696" height="147" alt="image" src="https://github.com/user-attachments/assets/9acffebd-efa9-4d26-9243-707897bb9d75" />

Step 2: Add a Description:

<img width="827" height="202" alt="image" src="https://github.com/user-attachments/assets/dab5eed7-8ede-4801-8d7f-95165be9f1ce" />

Step 3: Explore the Tags Tab: 

<img width="647" height="357" alt="image" src="https://github.com/user-attachments/assets/c9cd9169-6cfb-4339-ac23-0d2dde440804" />

Step 4: Pull a Specific Tag: 

<img width="652" height="286" alt="image" src="https://github.com/user-attachments/assets/f75dac6c-a47c-44d2-b111-de7072ee7604" />

Step 5: Pull the latest Tag: 

<img width="732" height="667" alt="image" src="https://github.com/user-attachments/assets/1fadeebd-a14b-462d-b3dc-d3b6920d0c09" />

**Notes:**

-->A repository stores one application's images.

-->A tag represents a specific version of that image.

-->latest is just another tag—it is not automatically the newest image. It only points to whichever image was explicitly tagged and pushed as latest.

-->Using versioned tags (e.g., 1.0, 1.1, 2.0) makes deployments reliable because you know exactly which image version you're running.

---

### Task 5: Image Best Practices
Apply these to one of your images and rebuild:
1. Use a **minimal base image** (alpine vs ubuntu — compare sizes)
2. **Don't run as root** — add a non-root USER in your Dockerfile
3. Combine `RUN` commands to **reduce layers**
4. Use **specific tags** for base images (not `latest`)

**Steps to follow:**

-->This task focuses on Docker image best practices. You can apply them to your existing Node.js Hello World application.

-->Optimized Dockerfile:

<img width="696" height="637" alt="image" src="https://github.com/user-attachments/assets/e35814fb-f32e-40dc-80d9-7c471bcc63cb" />

-->Best Practices Applied:

<img width="732" height="750" alt="image" src="https://github.com/user-attachments/assets/556f2536-6d1f-41ae-a43f-7ea567ed82b0" />

<img width="747" height="442" alt="image" src="https://github.com/user-attachments/assets/13084310-0e47-4cb6-ab45-e71ccbc644ea" />

<img width="712" height="587" alt="image" src="https://github.com/user-attachments/assets/5643db09-b75f-44ec-9c3b-ceeaaabe9632" />

<img width="870" height="810" alt="image" src="https://github.com/user-attachments/assets/769402b9-3e6b-4653-9804-994fc84298bf" />

<img width="842" height="722" alt="image" src="https://github.com/user-attachments/assets/d7f90a0f-af22-4b09-91bb-8b2fdf60784b" />

-->Build the Optimized Image: docker build -t hello-node-optimized:1.0 .

-->Compare Image Sizes: docker images

-->Verify the Container: docker run -d -p 3000:3000 --name hello-node hello-node-optimized:1.0

-->Test it: curl http://localhost:3000

-->Test in browser: http://localhost:3000

<img width="1917" height="960" alt="image" src="https://github.com/user-attachments/assets/17c194f7-b1d5-4ba2-85c2-f5c37e6178fb" />

<img width="1907" height="152" alt="image" src="https://github.com/user-attachments/assets/42f20bb9-ab3b-4453-b6f2-cd992ffc5ea0" />

<img width="1852" height="157" alt="image" src="https://github.com/user-attachments/assets/587a1c26-1117-4836-a8f7-c2bbde03cf6c" />

<img width="1917" height="776" alt="image" src="https://github.com/user-attachments/assets/26f5933a-8d61-403f-bce5-765ac95ff2f6" />

-->docker exec -it b9159a18fef2 sh

-->whoami

-->id

<img width="1631" height="127" alt="image" src="https://github.com/user-attachments/assets/e3e292d4-b8ce-4b43-a033-5688193c26b2" />

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
