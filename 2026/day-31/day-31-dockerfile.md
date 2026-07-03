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

**Steps to follow:**

-->Command to create image based on Dockerfile: docker build -f Dockerfile.task1 -t my-ubuntu:v1 .

-->To check created image: docker images

-->Command to create container based on image: docker run -it --name ubuntu-img my-ubuntu:v1

-->**docker ps:** So container stops when its main process exists so if wanted to see the container then we have to use command **docker ps -a**

**Verify:** The message prints on `docker run'

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/faa886b3-64bf-4610-83b1-d82a9cc273dc" />

<img width="1917" height="511" alt="image" src="https://github.com/user-attachments/assets/a80cc79c-851f-4ade-bc56-cc9471d2bf53" />

**Breakdown:**

--> -f Dockerfile.dev → Specifies the custom Dockerfile.

--> -t my-ubuntu:v1 → Tags the image with a name and version.

--> . → Uses the current directory as the build context (files available to the Docker build).

**Note:** pull access denied’ usually occurs due to incorrect image name or private repository access issues. And ubuntu is the public image for that ne need 
to login to the Dockerhub.

-->A container stops when its main process exits; to keep it running, you must run a long-lived process or use interactive mode.

-->Command to login to DockerHub: **user login -u <username> and then provide pswd**

-->Interactive container: **docker run -it --name <container name> <image name> /bin/bash** 
**Note:** docker run=create + start the cont, -it=interactive terminal, /bin/bash=Command to run inside container if want to get out of the container use command **exit**, This is not mandatory but if you want to keep alive the container then you can use it. "/bin/bash is a long-running interactive process"

-->Background running container: **docker run -d --name my-ubuntu ubuntu sleep infinity** 
**Note:** This command used to keep a container running in the background, Here -d is detached, sleep infinity is Long-running process

-->Web server: **docker run -d --name my-nginx -p 8080:80 nginx** 
**Note:** way to run an nginx container in the background with port mapping, -p 8080:80 Map host port → container port

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

**Steps to follow:**

-->Create new dir and get into it: mkdir dockerfile-demo && cd dockerfile-demo

-->Create Dockerfile: vi Dockerfile.task2 

-->Create image based on Dockerfile: docker build -f Dockerfile.task2 -t docker-demo:v1 .

-->To verify created image: docker images

-->Create container based on image: docker run -d --name demo-container -p 8080:80 docker-demo:v1

-->to verify creatted container: docker ps

<img width="1467" height="960" alt="image" src="https://github.com/user-attachments/assets/7a290345-0f2b-47e4-806e-24b268fe2e71" />

<img width="1912" height="330" alt="image" src="https://github.com/user-attachments/assets/65d664c7-9d85-47b1-b372-6654a71a8f08" />

<img width="1917" height="592" alt="image" src="https://github.com/user-attachments/assets/2daf12cf-ad1e-44cb-b663-c79aa2caf439" />

**Note:** A Dockerfile uses instructions like **FROM**, **RUN**, **COPY**, **WORKDIR**, **EXPOSE**, and **CMD** to define how an image is built and how a container runs. 

**FROM:** To define Base image [& in above example Uses the Nginx base image.]

<img width="726" height="335" alt="image" src="https://github.com/user-attachments/assets/c715202d-1b92-4892-9d9f-a6bdfd326b6b" />

**RUN:** Executes a command during image build

<img width="727" height="580" alt="image" src="https://github.com/user-attachments/assets/e1b84766-6a90-4297-8508-95871c0baef1" />

WORKDIR: Sets the working directory for the next instructions.[IN container workdir will get create]

<img width="712" height="672" alt="image" src="https://github.com/user-attachments/assets/1f5fdb30-46fa-47e7-9e2f-4ecba0f4ace4" />

COPY index.html . : Copies index.html from your computer into the image.

<img width="707" height="505" alt="image" src="https://github.com/user-attachments/assets/6209146e-0ff7-479e-b876-dda0cafa84e0" />

EXPOSE 80: Documents that the container uses port 80.

<img width="727" height="551" alt="image" src="https://github.com/user-attachments/assets/84a3fd2f-baf4-4914-8c24-2668fff3419a" />

CMD: Starts the Nginx server when the container runs.

<img width="707" height="582" alt="image" src="https://github.com/user-attachments/assets/9f07f01a-a295-4157-ad27-77b1a614ff4c" />

ENTRYPOINT: specifies the main program that the container always executes

<img width="692" height="502" alt="image" src="https://github.com/user-attachments/assets/294674d1-d02e-46f8-b9ce-52276a056060" />

<img width="702" height="555" alt="image" src="https://github.com/user-attachments/assets/4580b65f-25af-45b3-b042-f5ddce590d1d" />

<img width="700" height="382" alt="image" src="https://github.com/user-attachments/assets/30a5723c-1fd0-49d7-aabc-45cb9d080b54" />

<img width="687" height="712" alt="image" src="https://github.com/user-attachments/assets/d7252688-83d2-4f5f-91f6-d73a95d1a2f1" />

<img width="807" height="402" alt="image" src="https://github.com/user-attachments/assets/d8cfd7d0-0694-4c40-bd8a-cacdbb4bf0c5" />

<img width="827" height="580" alt="image" src="https://github.com/user-attachments/assets/bffd20f2-1c11-40be-948f-01d9a4192552" />

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
