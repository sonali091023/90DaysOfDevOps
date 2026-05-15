# Day 30 – Docker Images & Container Lifecycle

## Task
Today's goal is to **understand how images and containers actually work**.

You will:
- Learn the relationship between images and containers
- Understand image layers and caching
- Master the full container lifecycle

---

## Expected Output
- A markdown file: `day-30-images.md`
- Screenshots of key commands

---

## Challenge Tasks

### Task 1: Docker Images

**1. Pull the `nginx`, `ubuntu`, and `alpine` images from Docker Hub** 

**docker pull nginx**

**docker pull ubuntu**

**docker pull alpine**

**2. List all images on your machine — note the sizes**

<img width="1901" height="675" alt="image" src="https://github.com/user-attachments/assets/73d1a478-f0ac-4040-8f19-2077308b6c20" />

**3. Compare `ubuntu` vs `alpine` — why is one much smaller?**

-->**ubuntu:** Ubuntu includes full GNU utilities and **glibc-->larger, feature-rich**, making it heavier but more compatible 

-->**alpine:** Alpine is smaller because it uses **musl libc-->lightweight, simpler**, BusyBox, and a minimal package set, It removes everything that’s not

strictly needed, Alpine is designed specifically for containers

**4. Inspect an image — what information can you see?**

<img width="1916" height="968" alt="image" src="https://github.com/user-attachments/assets/31ec1836-f4f6-4768-874c-60e2091d0469" />

Image ID: sha256:341bf0f3ce6c...

Image: nginx:latest

Exposed Port: 80/tcp (HTTP)

Repository: docker.io/library/nginx

Environment variable

NGINX Version: 1.29.5

ENTRYPOINT

CMD

Lables,maintainer

Filesystem | Uses layered filesystem | 7 layers

**5. Remove an image you no longer need -->**docker rmi <image id>****

<img width="1503" height="346" alt="image" src="https://github.com/user-attachments/assets/1f5bce28-e888-47fb-a95d-e9e104ff18a2" />

---

### Task 2: Image Layers

**1. Run `docker image history nginx` — what do you see?**

-->A list of instructions used to build the nginx image (e.g., CMD, EXPOSE, ENTRYPOINT, COPY, RUN, ENV, LABEL) Each instruction corresponds to a layer

<img width="1335" height="497" alt="image" src="https://github.com/user-attachments/assets/86d397ad-8cd4-4edc-96e9-4f2f52d75574" />

**2. Each line is a **layer**. Note how some layers show sizes and some show 0B**

-->Layers with a size (MB or kB) were created by instructions that modify the filesystem,such as RUN, COPY, or ADD.

Layers showing 0B were created by instructions that only change metadata, such as ENV, CMD, EXPOSE, LABEL, or ENTRYPOINT.These do not change the filesystem.

**3. Write in your notes: What are layers and why does Docker use them?**

-->Docker layers are read-only filesystem snapshots created by each instruction in a Dockerfile.

-->Docker uses layers because:

They allow build caching (faster builds)

They allow images to share common layers (saves storage).

They make image downloads faster (only new layers are pulled)

---

### Task 3: Container Lifecycle
Practice the full lifecycle on one container:
1. **Create** a container (without starting it) --> **docker run -d --name samplecont nginx**
2. **Start** the container --> **docker run -d --name samplecont nginx**
3. **Pause** it and check status --> **docker pause samplecont**
4. **Unpause** it --> **docker unpause samplecont**
5. **Stop** it -->**docker stop samplecont**
6. **Restart** it -->**docker restart samplecont**
7. **Kill** it -->**docker kill samplecont**
8. **Remove** it **docker rm samplecont**

Check `docker ps -a` after each step — observe the state changes.

<img width="1393" height="912" alt="image" src="https://github.com/user-attachments/assets/2df732ab-63c0-42fe-8cd0-34dce27a4b6a" />

<img width="1420" height="343" alt="image" src="https://github.com/user-attachments/assets/b22cd9bc-5b65-4d58-89e8-b66ffa47e75f" />

---

### Task 4: Working with Running Containers
1. Run an Nginx container in detached mode --> **docker run -d --name nginx-container nginx**

<img width="1302" height="208" alt="image" src="https://github.com/user-attachments/assets/06ff3e56-fc4c-47f2-b338-c0de91ebcf8b" />

2. View its **logs** -->**docker logs nginx-container**

<img width="1170" height="680" alt="image" src="https://github.com/user-attachments/assets/45cbd42c-97c9-4455-ba40-1ed418bd08a4" />

3. View **real-time logs** (follow mode) --> **docker logs -f nginx-container**

<img width="1176" height="650" alt="image" src="https://github.com/user-attachments/assets/07b2cd51-0f3a-4256-81cc-7acfe566c94e" />

4. **Exec** into the container and look around the filesystem --> **docker exec -it 7b4e98176a29 bash**

<img width="1763" height="880" alt="image" src="https://github.com/user-attachments/assets/8238f24d-d995-4010-900f-aec228bf5a47" />

5. Run a single command inside the container without entering it --> **docker exec nginx-container ls /**

<img width="656" height="507" alt="image" src="https://github.com/user-attachments/assets/98cd0268-1260-4ccb-b061-46652e24e716" />

7. **Inspect** the container — find its IP address, port mappings, and mounts -->**docker inspect nginx-container**

<img width="1126" height="447" alt="image" src="https://github.com/user-attachments/assets/1612e253-5b64-44b9-bee5-314bf7fd0869" />

<img width="500" height="368" alt="image" src="https://github.com/user-attachments/assets/735db477-c205-4da9-bbdf-e6c0da78b850" />

<img width="808" height="461" alt="image" src="https://github.com/user-attachments/assets/0558e78a-30d2-4253-a877-d16e1708298e" />

---

### Task 5: Cleanup
1. Stop all running containers in one command --> **docker stop $(docker ps -q)**

<img width="1342" height="256" alt="image" src="https://github.com/user-attachments/assets/d0fb95e6-2779-4dd6-8972-72400a176a89" />

3. Remove all stopped containers in one command

-->**docker container prune** This will ask for confirmation to delete the stopped container

-->**docker container prune -f** This is directly delete the stopped container

-->**docker rm $(docker ps -aq -f status=exited)** This will delete the exited status containers

<img width="1448" height="397" alt="image" src="https://github.com/user-attachments/assets/f6df5e52-78b3-49c1-99b2-9276cb9b5322" />

6. Remove unused images --> **docker rmi <img-id>**

<img width="1130" height="143" alt="image" src="https://github.com/user-attachments/assets/fba63baa-fd76-41ee-90a0-b762495bab70" />

7. Check how much disk space Docker is using -->

**docker system df** This is used to check the docker disk usage

**docker system df -v:** We can get the detailed information about container and image etc.

<img width="1341" height="237" alt="image" src="https://github.com/user-attachments/assets/30150d6c-1d64-440e-a4f2-b3b3df5da769" />

---

## Hints
- Image history: `docker image history`
- Create without starting: `docker create`
- Follow logs: `docker logs -f`
- Inspect: `docker inspect`
- Cleanup: `docker system df`, `docker system prune`

---

## Submission
1. Add your `day-30-images.md` to `2026/day-30/`
2. Commit and push to your fork

---

## Learn in Public
Share what surprised you about image layers or container states on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
