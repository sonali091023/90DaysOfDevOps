# Day 29 – Introduction to Docker

## Task
Today's goal is to **understand what Docker is and run your first container**.

You will:
- Learn why containers exist and how they differ from VMs
- Install Docker on your machine
- Run and explore containers from Docker Hub

---

## Expected Output
- A markdown file: `day-29-docker-basics.md`
- Screenshots of your running containers

---

## Challenge Tasks

### Task 1: What is Docker?
Research and write short notes on:

**- What is a container and why do we need them?**

-->A container is a lightweight, portable unit that packages an application together with everything it needs to run—such as Application code, runtime, libraries,

  Configuration files, and system dependencie etc. So it can run consistently across different environments.

  -->We needs container because, Different environments cause issues (Windows vs Linux, missing dependencies, version conflicts). Containers ensure consistent 
  
  execution everywhere. We can run the same container from laptop, testing server, AWS / Azure / GCP cloud etc.

**- Containers vs Virtual Machines — what's the real difference?**

-->A **container** is a lightweight isolated environment that shares the host OS kernel. Docker is the common platform for the container, containers can be Orchestrated at scale using: by using Kubernetes, Containers do NOT include a full OS.

-->A **Virtual Machine** is a full computer inside your computer, It runs using a hypervisor like: VMware, VirtualBox, Hyper-V, KVM (Kernel-based Virtual Machine)

Each VM has its own complete operating system

**- What is the Docker architecture? (daemon, client, images, containers, registry)**

-->**Docker follows a client–server architecture**. It is made up of five main building blocks: Docker Client, Docker Daemon, Images, Containers, and Registry etc. 

-->**1. Docker client** [This is kind of Remote control of Docker who Sends commands to the Docker Daemon, Uses REST API under the hood]

-->**2. Docker deamon** is the brain of Docker, Responsibilities of the docker deamon are to Builds images, Runs containers, Manages networks and volumes, Talks to registry, Handles container lifecycle. Docker deamon runs at the background on the host system. Its like the Engine that does all the work.

-->**3. Docker image** is a read-only blueprint of an application, Which contains Application code, Runtime (Python, NodeJS, Java, etc.), Dependencies, Configurations etc. , Images are used to create containers.

-->**4.container** is a running instance of an image, In the container Image becomes a live process, Runs in isolated environment, Has its own filesystem, 
network, processes etc.

-->So overall its like **image is the Recipe** and **Container is like cooked dish.**

-->**5. Docker registry** is a storage system for Docker images. here dockerhub is the public registory we used to Stores images, it lets you push/pull images etc

-->Other options available such as AWS ECR, Google Container Registry, Private registries etc.

**Draw or describe the Docker architecture in your own words:**

1. The developer types a Docker command using the Docker Client.

2. The Docker Client sends the request to the Docker Daemon.

3. The Docker Daemon checks whether the required Docker image exists locally.

4. If the image is missing, the daemon downloads it from a Docker Registry (such as Docker Hub).

5. Using the image, the daemon creates and starts a Docker Container.

6. The running container executes the application in an isolated environment while sharing the host operating system kernel.
<img width="745" height="795" alt="image" src="https://github.com/user-attachments/assets/191ac668-52f9-4191-9c9f-0ce2dacd86a3" />

---

### Task 2: Install Docker

1. Install Docker on your machine (or use a cloud instance) -->**sudo apt update**, **sudo apt install docker.io -y**

2. sudo systemctl start docker

3. sudo systemctl enable docker

4. sudo systemctl status docker

5. Verify the installation -->**docker --version**

6. **docker info**: This displays details about: Docker Engine, Storage Driver, Containers, Images, CPU and Memory, Docker Root Directory

7. Run the `hello-world` container --> **docker run hello-world**

8. docker images

9. docker ps -a

<img width="1672" height="972" alt="image" src="https://github.com/user-attachments/assets/df54fbb6-deb2-4451-b1a9-f5cedc3b1a67" />

<img width="1500" height="972" alt="image" src="https://github.com/user-attachments/assets/a2dc0d9a-06c8-4cf9-b17b-80c97af4b60d" />

<img width="1725" height="866" alt="image" src="https://github.com/user-attachments/assets/f3da55f3-b0c4-4d17-a174-43e53e3f1c39" />

**Read the output carefully — it explains what just happened**

-->Docker first checks your local machine for the image. It wasn't there, so it went to the internet.

-->Docker downloaded the hello-world image from Docker Hub (From Docker's public image registry).

-->Think of an image as a recipe and a container as the dish made from it. Docker used the image to spin up a live, running container.

-->Inside the container, a small program executed and printed the "Hello from Docker!" message to your terminal.

-->Since the only job of this container was to print that message, it automatically stopped after doing so.

---

### Task 3: Run Real Containers

1. Run an **Nginx** container and access it in your browser --> **docker run -d -p 8080:80 nginx** 

<img width="832" height="397" alt="image" src="https://github.com/user-attachments/assets/8d12a36a-1a50-4d35-9221-509a27233a5f" />

<img width="1745" height="677" alt="image" src="https://github.com/user-attachments/assets/a8e6a5c9-f963-4780-83d9-19d84943e636" />

2. Run an **Ubuntu** container in interactive mode — explore it like a mini Linux machine --> **docker run -it ubuntu**

<img width="1100" height="605" alt="image" src="https://github.com/user-attachments/assets/4b0d1628-60cd-46f9-a921-23c68a25940a" />

3. List all running containers -->**docker ps**

<img width="1692" height="170" alt="image" src="https://github.com/user-attachments/assets/7e3dde57-9671-4962-8193-b8a4342b367a" />

4. List all containers (including stopped ones) -->**docker ps -a**

<img width="1855" height="203" alt="image" src="https://github.com/user-attachments/assets/4920259e-dbde-4128-a463-91c2e2fdab22" />

5. Stop and remove a container

<img width="1650" height="271" alt="image" src="https://github.com/user-attachments/assets/ca80b834-7668-4804-aa3f-a9e9ceb589b1" />


---

### Task 4: Explore
1. Run a container in **detached mode** — what's different? --> **docker run -d nginx**

<img width="688" height="72" alt="image" src="https://github.com/user-attachments/assets/bc894395-0a02-45b7-b2d7-9afc572f91c5" />


2. Give a container a custom **name** --> **docker run -d --name nginx-container nginx**

<img width="1211" height="146" alt="image" src="https://github.com/user-attachments/assets/459a5535-e87e-4f37-8d07-ebdc8b317e04" />


3. Map a **port** from the container to your host --> **docker run -d --name new-nginx-cont -p 8080:80 nginx**

<img width="1472" height="177" alt="image" src="https://github.com/user-attachments/assets/0d1f8a62-9a6a-4533-b0ba-0f3a858a648f" />

<img width="1782" height="537" alt="image" src="https://github.com/user-attachments/assets/a5e13122-5c21-45bf-b090-2b3cee421ea7" />

5. Check **logs** of a running container --> **docker logs <container id>**

<img width="997" height="565" alt="image" src="https://github.com/user-attachments/assets/55b2043a-c392-4c19-942f-6f87bf20e055" />

6. Run a command **inside** a running container -->**docker exec -it <container id> bash**

<img width="1475" height="330" alt="image" src="https://github.com/user-attachments/assets/4709c8a1-6b11-49c8-a571-2e9337316ed5" />


---

## Hints
- `docker run`, `docker ps`, `docker stop`, `docker rm`
- Interactive mode: `-it` flag
- Detached mode: `-d` flag
- Port mapping: `-p host:container`
- Naming: `--name`
- Logs: `docker logs`
- Exec into container: `docker exec`

---

## Why This Matters for DevOps
Docker is the foundation of modern deployment. Every CI/CD pipeline, Kubernetes cluster, and microservice architecture starts with containers. Today you took the first step.

---

## Submission
1. Add your `day-29-docker-basics.md` to `2026/day-29/`
2. Commit and push to your fork

---

## Learn in Public
Share your first Docker container screenshot on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
