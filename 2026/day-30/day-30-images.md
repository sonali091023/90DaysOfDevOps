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

**2. List all images to do this run command: docker images --> on your machine — note the sizes**

<img width="1862" height="947" alt="image" src="https://github.com/user-attachments/assets/9035b13e-c378-47c6-b5be-ee63d9d420ca" />

-->**Note:** Notice how Alpine is dramatically smaller.

**3. Compare `ubuntu` vs `alpine` — why is one much smaller?**

-->**ubuntu:** Ubuntu includes full GNU utilities and **glibc-->larger, feature-rich**, making it heavier but more compatible 

-->**alpine:** Alpine is smaller because it uses **musl libc-->lightweight, simpler**, BusyBox, and a minimal package set, It removes everything that’s not
strictly needed, Alpine is designed specifically for containers

<img width="790" height="737" alt="image" src="https://github.com/user-attachments/assets/27d16476-d7d4-4982-86f0-4bf1167e1860" />

<img width="547" height="456" alt="image" src="https://github.com/user-attachments/assets/0c0cf2c5-ca13-4aa0-b18e-cd857a70ba73" />

**4. Inspect an image — what information can you see?**

<img width="1912" height="982" alt="image" src="https://github.com/user-attachments/assets/c74cdc4c-7619-4819-bb67-d6e2ecaac917" />

**Useful information you can find:** Image ID, Creation date, Operating system, CPU architecture, Environment variables, Default command (CMD)
Entrypoint, Labels, Layers, Exposed ports, Working directory, Image size etc.

-->Find only the image size: docker image inspect nginx --format='{{.Size}}'

-->Find the OS: docker image inspect nginx --format='{{.Os}}'

-->Find the default command: docker image inspect nginx --format='{{.Config.Cmd}}'

<img width="1512" height="142" alt="image" src="https://github.com/user-attachments/assets/ee33f2e3-f6d6-4679-9ae9-b3fda96bc0b8" />

**5. Remove an image you no longer need -->**docker rmi <image id>****

<img width="681" height="707" alt="image" src="https://github.com/user-attachments/assets/7cac2e47-bb40-4b9c-855d-d8a5d004e91b" />

Bonuse Commands:

-->Remove dangling images: docker image prune

-->Remove all unused images: docker image prune -a

-->Check disk usage: docker system df

<img width="847" height="712" alt="image" src="https://github.com/user-attachments/assets/30ed805b-ea20-4770-9ea9-55fcb819d9f2" />

---

### Task 2: Image Layers:

-->Excellent! This task teaches one of Docker's most important concepts: image layers. Understanding layers helps explain why Docker images build quickly, reuse data efficiently, and consume less storage.

**1. Run `docker image history nginx` OR `docker image nginx` — what do you see?**

-->A list of instructions used to build the nginx image (e.g., CMD, EXPOSE, ENTRYPOINT, COPY, RUN, ENV, LABEL) Each instruction corresponds to a layer

<img width="1587" height="802" alt="image" src="https://github.com/user-attachments/assets/7da08174-d5b4-4947-bfb0-2b6c5c16290d" />

**2. Each line is a **layer**. Note how some layers show sizes and some show 0B**

-->Layers with a size (MB or kB) were created by instructions that modify the filesystem,such as RUN, COPY, or ADD.

Layers showing 0B were created by instructions that only change metadata, such as ENV, CMD, EXPOSE, LABEL, or ENTRYPOINT.These do not change the filesystem.

<img width="845" height="555" alt="image" src="https://github.com/user-attachments/assets/83cf598e-f694-4607-90bc-45b3ce0f6a03" />

<img width="866" height="590" alt="image" src="https://github.com/user-attachments/assets/e3061b0e-bd46-49d9-981a-7cf96f9ba7d0" />

**3. Write in your notes: What are layers and why does Docker use them?**

-->Docker layers are read-only filesystem snapshots created by each instruction in a Dockerfile.

-->Docker uses layers because:

They allow build caching (faster builds)

They allow images to share common layers (saves storage).

They make image downloads faster (only new layers are pulled)

**Docker Layers:**

<img width="787" height="827" alt="image" src="https://github.com/user-attachments/assets/adbccf3f-9e8f-4f04-b862-07255694b0bf" />

<img width="742" height="812" alt="image" src="https://github.com/user-attachments/assets/d5c4d4d8-fa84-44af-9d94-ec4d013812c2" />

<img width="792" height="392" alt="image" src="https://github.com/user-attachments/assets/df00cca3-e322-466f-8e29-2527a9ac134c" />

**Notes for your assignment:**

**What are Docker layers?** --> Docker images are made up of multiple read-only layers. Each layer represents a change made during image creation, such as installing software, copying files, or configuring the image. These layers are stacked together to form the final image.

**Why does Docker use layers?**

-->Layers allow Docker to reuse common parts between images.

-->They enable build caching, making image builds much faster.

-->Shared layers reduce disk space usage.

-->Only new or changed layers are downloaded when pulling images, improving download speed.

<img width="770" height="597" alt="image" src="https://github.com/user-attachments/assets/79a9ac7a-b441-41f9-9add-1437b3d7337e" />

---

### Task 3: Container Lifecycle:

-->This task helps you understand the Docker Container Lifecycle—the different states a container goes through from creation to deletion.

**Practice the full lifecycle on one container:**

1. **Create** a container (without starting it) --> docker create --name myubuntu ubuntu sleep 300

<img width="701" height="601" alt="image" src="https://github.com/user-attachments/assets/46966a3f-a591-4773-80a4-a35f4b3cdaaa" />

<img width="1621" height="162" alt="image" src="https://github.com/user-attachments/assets/04298add-799a-413e-bbb5-5e7a09667fcd" />

2. **Start** the container --> docker run -d --name samplecont nginx

<img width="712" height="472" alt="image" src="https://github.com/user-attachments/assets/9326d6c9-b5e2-45ab-a8a2-283e2a65a592" />

<img width="1387" height="187" alt="image" src="https://github.com/user-attachments/assets/ebe046c5-4ed7-4a2c-827a-a092142b32ba" />

3. **Pause** it and check status --> docker pause samplecont

<img width="686" height="477" alt="image" src="https://github.com/user-attachments/assets/d45c66a1-f6e2-4a1c-bd16-3e1898cf80ab" />

<img width="1302" height="180" alt="image" src="https://github.com/user-attachments/assets/e60e192a-8801-4799-8186-dbda1f7f3244" />

4. **Unpause** it --> docker unpause samplecont

<img width="712" height="477" alt="image" src="https://github.com/user-attachments/assets/752538b9-b531-46a4-99c5-086348987451" />

<img width="1356" height="181" alt="image" src="https://github.com/user-attachments/assets/93f0dcae-17c4-4bb3-89c8-a7b0d9ce8db7" />

5. **Stop** it -->docker stop samplecont

<img width="675" height="467" alt="image" src="https://github.com/user-attachments/assets/6a028cef-4f35-4242-bba5-b6020649b8fe" />

<img width="1477" height="162" alt="image" src="https://github.com/user-attachments/assets/52e11d77-a802-4122-8447-cfa9351c8086" />

6. **Restart** it -->docker restart samplecont

<img width="677" height="472" alt="image" src="https://github.com/user-attachments/assets/6e6686f8-d572-4521-a7d0-3f65941a0879" />

<img width="1316" height="177" alt="image" src="https://github.com/user-attachments/assets/1c5e2b49-8a72-4f09-9570-b0075edacb28" />

7. **Kill** it -->docker kill samplecont

<img width="730" height="510" alt="image" src="https://github.com/user-attachments/assets/fb255820-c1ef-440e-996e-acc35396c202" />

<img width="1347" height="167" alt="image" src="https://github.com/user-attachments/assets/76e47c69-18f0-41c3-a1ba-347f949427fa" />

8. **Remove** it -->docker rm samplecont

<img width="702" height="356" alt="image" src="https://github.com/user-attachments/assets/85e63d8d-ec87-4e79-801b-d3126269dc24" />

<img width="1322" height="142" alt="image" src="https://github.com/user-attachments/assets/db1180ff-fc7d-40f4-8400-b0a86ae23910" />

<img width="737" height="597" alt="image" src="https://github.com/user-attachments/assets/ebb0faed-a545-4bd6-b917-0e2c895ba6d9" />

<img width="805" height="696" alt="image" src="https://github.com/user-attachments/assets/aab1fe76-08e1-41ec-9eaf-f63fcdc85ea4" />

<img width="917" height="336" alt="image" src="https://github.com/user-attachments/assets/b7f3b8dc-37b5-457d-bb00-7dabc71865c7" />

<img width="845" height="587" alt="image" src="https://github.com/user-attachments/assets/8afa2cf4-2d54-4d06-a60d-10e0bae7f1fa" />

---

### Task 4: Working with Running Containers:

-->Great! This task teaches you how to work with running containers, inspect them, and interact with them. We'll use an Nginx container.

1. Run an Nginx container in detached mode --> docker run -d --name mynginx -p 8080:80 nginx

<img width="1917" height="237" alt="image" src="https://github.com/user-attachments/assets/bc17e1cc-eaec-4523-9667-ae546a564e5d" />

<img width="727" height="767" alt="image" src="https://github.com/user-attachments/assets/364106f3-715b-4b18-8dc4-e93e9cb3aa89" />

2. Verify in your browser: http://localhost:8080 [You should see the Welcome to nginx! page.]

<img width="1912" height="727" alt="image" src="https://github.com/user-attachments/assets/a9023c51-d66a-4a8a-a523-4cfdeed73925" />

3. View its **logs** -->docker logs mynginx

-->Logs contain everything the application's main process writes to standard output (stdout) and standard error (stderr).

<img width="1917" height="637" alt="image" src="https://github.com/user-attachments/assets/a7959509-994d-4575-b5d7-2b1809410793" />

4. View **real-time logs** (follow mode) --> docker logs -f mynginx

-->Now refresh http://localhost:8080 in your browser. You'll see access log entries appear, for example:

<img width="1917" height="682" alt="image" src="https://github.com/user-attachments/assets/de7f614b-f5a2-4d8e-86ca-dd4a5da48cb1" />

5. **Exec** into the container and look around the filesystem --> docker exec -it mynginx /bin/bash

**Note:** If /bin/bash isn't available, use: docker exec -it mynginx /bin/sh

-->Check your current directory: pwd

-->List files: ls

-->List the Nginx configuration: ls /etc/nginx

-->View the web page files: ls /usr/share/nginx/html

-->View the default web page: cat /usr/share/nginx/html/index.html

-->exit

<img width="1837" height="776" alt="image" src="https://github.com/user-attachments/assets/3f97ba50-4781-465a-bdde-e6a2bb9e38a5" />

6. Run a single command inside the container without entering it --> docker exec mynginx ls /usr/share/nginx/html

-->docker exec mynginx hostname

-->Check nginx version: docker exec mynginx nginx -v

<img width="1437" height="165" alt="image" src="https://github.com/user-attachments/assets/54c0a4bf-afd6-4686-b412-03177126d0ab" />

7. **Inspect** the container — find its IP address, port mappings, and mounts -->docker inspect mynginx [This returns detailed JSON metadata about the container.]

-->Find the container IP address: docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mynginx

-->Find the port mapping: docker port mynginx OR Use: docker inspect -f '{{json .NetworkSettings.Ports}}' mynginx

-->Find mounted volume: docker inspect -f '{{json .Mounts}}' mynginx

<img width="1917" height="962" alt="image" src="https://github.com/user-attachments/assets/436f9961-a499-4726-b99a-5c3426761542" />

<img width="1852" height="241" alt="image" src="https://github.com/user-attachments/assets/b97bd6f3-ae96-491c-a896-2712c5b8b243" />

**Useful inspection fields:**

-->Container name: docker inspect -f '{{.Name}}' mynginx

-->Container status: docker inspect -f '{{.State.Status}}' mynginx

-->Image used: docker inspect -f '{{.Config.Image}}' mynginx

-->Hostname: docker inspect -f '{{.Config.Hostname}}' mynginx

<img width="1547" height="217" alt="image" src="https://github.com/user-attachments/assets/c8031777-b5c1-4d20-a590-8da7f30cba59" />

---

### Task 5: Cleanup:

-->Excellent! This task focuses on Docker cleanup, which is an important practice to free up disk space and keep your Docker environment organized.

-->Check running containers first: docker ps

1. Stop all running containers in one command --> docker stop $(docker ps -q)

<img width="702" height="652" alt="image" src="https://github.com/user-attachments/assets/3d540811-82bc-4131-a225-74e5acc13317" />

<img width="1745" height="186" alt="image" src="https://github.com/user-attachments/assets/1be031be-2e6b-4958-bbf1-c2acbb4218ab" />

2. Remove all stopped containers in one command:

<img width="687" height="797" alt="image" src="https://github.com/user-attachments/assets/a150da29-35ee-4b3e-aa65-31fe1a4f041e" />

-->**docker container prune** This will ask for confirmation to delete the stopped container

-->**docker container prune -f** This is directly delete the stopped container

-->**docker rm $(docker ps -aq -f status=exited)** This will delete the exited status containers

3. Remove unused images --> **docker rmi <img-id> OR docker image prune**

-->Remove all unused images: docker image prune -a & if wanted to skip the confirmation: docker image prune -a -f

Note: This deletes any image that isn't currently used by a container. If you need an image again later, Docker will download it when you run or pull it.

4. Check how much disk space Docker is using:

**docker system df** This is used to check the docker disk usage

**docker system df -v:** We can get the detailed information about container and image etc.

<img width="1852" height="982" alt="image" src="https://github.com/user-attachments/assets/df86dff4-c439-43aa-8734-eccf6ff3edb6" />

<img width="772" height="342" alt="image" src="https://github.com/user-attachments/assets/d63e6c15-59d0-48ce-a8b9-06d695232554" />

<img width="857" height="382" alt="image" src="https://github.com/user-attachments/assets/9f2e39dc-e48d-42c3-91ae-ee63903243ca" />

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
