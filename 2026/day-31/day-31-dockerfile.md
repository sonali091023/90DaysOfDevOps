# Day 31 – Dockerfile: Build Your Own Images

## Task
Today's goal is to **write Dockerfiles and build custom images**.

This is the skill that separates someone who uses Docker from someone who actually ships with Docker.

---

## Expected Output
- A markdown file: `day-31-dockerfile.md`
- All Dockerfiles you create

---

## Challenge Tasks

### Task 1: Your First Dockerfile
1. Create a folder called `my-first-image`
2. Inside it, create a `Dockerfile` that:
   - Uses `ubuntu` as the base image
   - Installs `curl`
   - Sets a default command to print `"Hello from my custom image!"`
3. Build the image and tag it `my-ubuntu:v1`
4. Run a container from your image

**Created Dockerfile:**

<img width="533" height="200" alt="image" src="https://github.com/user-attachments/assets/e666ae1a-b86b-4277-8344-dfee4e04815b" />

-->Command to create image based on Dockerfile: **docker build -t my-ubuntu:v1 .**

-->**docker images**

-->Command to create container based on image: **docker run -it --name ubuntu-img my-ubuntu:v1**

-->**docker ps** So container stops when its main process exists so if wanted to see the container then we have to use command **docker ps -a**

**Verify:** The message prints on `docker run'

<img width="1912" height="972" alt="image" src="https://github.com/user-attachments/assets/407645fb-7071-484a-a896-d36b33f994f1" />

**Note:** 

-->pull access denied’ usually occurs due to incorrect image name or private repository access issues. And ubuntu is the public image for that ne need 

to login to the Dockerhub.

-->A container stops when its main process exits; to keep it running, you must run a long-lived process or use interactive mode.

-->Command to login to DockerHub: **user login -u <username> and then provide pswd**

-->Interactive container: **docker run -it --name <container name> <image name> /bin/bash** [docker run=create + start the cont, -it=interactive terminal, 

/bin/bash=Command to run inside container if want to get out of the container use command **exit**, This is not mandatory but if you want to keep alive the

container then you can use it. "/bin/bash is a long-running interactive process"]

-->Background running container: **docker run -d --name my-ubuntu ubuntu sleep infinity** [This command usedmto keep a container running in the background, 

Here -d is detached, sleep infinity is Long-running process]

-->Web server: **docker run -d --name my-nginx -p 8080:80 nginx** [way to run an nginx container in the background with port mapping, -p 8080:80

Map host port → container port]

---

### Task 2: Dockerfile Instructions
Create a new Dockerfile that uses **all** of these instructions:
- `FROM` — base image
- `RUN` — execute commands during build
- `COPY` — copy files from host to image
- `WORKDIR` — set working directory
- `EXPOSE` — document the port
- `CMD` — default command

Build and run it. Understand what each line does.

**Note:** A Dockerfile uses instructions like **FROM**, **RUN**, **COPY**, **WORKDIR**, **EXPOSE**, and **CMD** to define how an image is built and how a container runs. 

**Note:** So once the container is launched after that if we update the content in the webpage.html file we can see the updates that is because we built image → 

file copied inside container-->You changed webpage.html on your system-->Container is still using old copied version, Because of this line in Dockerfile: 

**COPY webpage.html index.html** And This happens only at build time, not runtime, So if you want to see the latest changes you have to stop and delete the 

container, Also delete the image and then recreate the image and container as well.

<img width="972" height="937" alt="image" src="https://github.com/user-attachments/assets/33d117b4-af56-4e74-9fe2-3eb525c6d756" />

<img width="1812" height="262" alt="image" src="https://github.com/user-attachments/assets/428b265b-8816-47e6-a223-15412c947ecc" />

Dockerfile:

<img width="922" height="448" alt="image" src="https://github.com/user-attachments/assets/1f332c4c-31e2-4b39-808d-a18017af93dd" />

Command to create image: **docker build -t nginx-image:latest .**

Command to create container: **docker run -it --name nginx-container -p 8080:80 nginx-image:latest**

---

### Task 3: CMD vs ENTRYPOINT

1. Create an image with `CMD ["echo", "hello"]` — run it, then run it with a custom command. What happens?

Dockerfile:

FROM alpine

CMD ["echo", "hello"]

-->Command to create image:  **docker build -t new-img .**

-->**docker run new-img:latest** Now there is no need to creatre container we can directly run it normally, Because Docker runs the default: echo hello

-->**docker run new-img:latest echo hi** We can Run with custom command as well and here CMD got overridden, So Docker replaces CMD with your new command.

**CMD = default command (can be overridden)**

<img width="952" height="722" alt="image" src="https://github.com/user-attachments/assets/7807b3c0-7a1e-4179-8173-55db01205934" />

2. Create an image with `ENTRYPOINT ["echo"]` — run it, then run it with additional arguments. What happens?

Dockerfile:

FROM alpine

ENTRYPOINT ["echo"]

Command to create image: **docker build -t entrypoint-img .**

**docker run entrypoint-img** So Nothing prints just empty line, that is because ENTRYPOINT = echo No arguments passed → echo prints nothing

-->**docker run entrypoint-img hello-world** if we Run with arguments we can see the output hello world, So Docker did NOT replace ENTRYPOINT It appended your 

arguments to it, **So ENTRYPOINT = fixed command**

3. Write in your notes: When would you use CMD vs ENTRYPOINT?

-->**CMD:** You want to provide a default command that can be easily overridden

**Use cases such as:**

Running different scripts in same container

Testing / debugging containers

Flexible containers for multiple purposes

Eg: CMD ["echo", "hello"]

docker run myimage → hello

docker run myimage echo hi → hi So user can replace the command completely 

-->**ENTRYPOINT:** You want to define a fixed main command

**Use cases such as:**

Container behaves like a tool/program

You always want a specific executable to run

Restrict users from changing core behavior

Eg: ENTRYPOINT ["echo"]

docker run myimage hello → hello So here echo always runs, User only passes arguments

-->Best Practice is we can use the ENTRYPOINT and CMD together

ENTRYPOINT ["python"]

CMD ["app.py"]

-->**ENTRYPOINT:** docker run myimage → python app.py [ENTRYPOINT = fixed command]

-->**CMD:** docker run myimage test.py → python test.py [CMD = default argument (can change)]

---

### Task 4: Build a Simple Web App Image
1. Create a small static HTML file (`index.html`) with any content
2. Write a Dockerfile that:
   - Uses `nginx:alpine` as base
   - Copies your `index.html` to the Nginx web directory
3. Build and tag it `my-website:v1`
4. Run it with port mapping and access it in your browser

<img width="1082" height="828" alt="image" src="https://github.com/user-attachments/assets/fee5804c-d8e3-4610-b812-d6c55499a869" />

<img width="1897" height="323" alt="image" src="https://github.com/user-attachments/assets/522cf453-25ce-42b7-afe2-134de9ada7f2" />

<img width="1898" height="967" alt="image" src="https://github.com/user-attachments/assets/0e6ba415-c2fb-4da6-91db-a147dd714917" />

---

### Task 5: .dockerignore
1. Create a `.dockerignore` file in one of your project folders
2. Add entries for: `node_modules`, `.git`, `*.md`, `.env`
3. Build the image — verify that ignored files are not included

<img width="1848" height="868" alt="image" src="https://github.com/user-attachments/assets/6bbb58cc-4a52-4342-bdd9-64c4a7697812" />

<img width="997" height="236" alt="image" src="https://github.com/user-attachments/assets/dd910cc2-6061-48bd-b800-44e0a4e25753" />

Command used to create image: **docker build -t my-nginx-img .**

Command used to remove unnecessary files: **docker run --rm website:latest ls /usr/share/nginx/html**

**Explaination of above command What this means**

--> docker run → start a container from the image

--> --rm → automatically remove container after it exits

--> website:latest → your Docker image name

--> ls /usr/share/nginx/html → list files inside Nginx web root folder

---

### Task 6: Build Optimization
1. Build an image, then change one line and rebuild — notice how Docker uses **cache**
2. Reorder your Dockerfile so that frequently changing lines come **last**
3. Write in your notes: Why does layer order matter for build speed?

---

## Hints
- Build: `docker build -t name:tag .`
- The `.` at the end is the build context
- `COPY . .` copies everything from host to container
- Nginx serves files from `/usr/share/nginx/html/`

---

## Submission
1. Add your Dockerfiles and `day-31-dockerfile.md` to `2026/day-31/`
2. Commit and push to your fork

---

## Learn in Public
Share your custom Docker image or Nginx screenshot on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
