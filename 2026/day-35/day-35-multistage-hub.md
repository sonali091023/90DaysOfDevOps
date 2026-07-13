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
