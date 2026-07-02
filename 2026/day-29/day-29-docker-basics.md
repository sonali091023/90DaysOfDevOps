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

1. Run an **Nginx** container and access it in your browser --> **docker run -d --name my-nginx -p 8080:80 nginx**

<img width="761" height="327" alt="image" src="https://github.com/user-attachments/assets/be046399-9c23-48f4-b607-4047ccc809ae" />

<img width="1917" height="387" alt="image" src="https://github.com/user-attachments/assets/92f3f64d-e5b1-4288-bc6c-25c40646c71d" />

<img width="1912" height="876" alt="image" src="https://github.com/user-attachments/assets/745feda0-fc37-4c87-b25e-6a59eba4e72e" />

2. Run an **Ubuntu** container in interactive mode — explore it like a mini Linux machine --> **docker run -it ubuntu**

**Explore the Ubuntu Container For that use below commands:**

-->To check present working dir:pwd

-->To check the list: ls

-->To check OS info: cat /etc/os-release

-->To check the hostname: hostname

-->To check the current user: whoami

-->To check the kernel version: uname -a

-->To create a file: touch test.txt

-->ls

-->To check dir & go inside: mkdir docker-demo && cd docker-demo 

-->Create another file: echo "Hello Docker" > hello.txt

-->Reat that file: cat hello.txt

-->Exit from ububtu container: exit

<img width="1902" height="827" alt="image" src="https://github.com/user-attachments/assets/eb0f57d8-a3e1-45ea-9e72-df113f4a543a" />

3. List all running containers -->**docker ps**

4. List all containers (including stopped ones) -->**docker ps -a**

5. Stop and remove a container: docker stop my-nginx && docker rm my-nginx 

<img width="1751" height="312" alt="image" src="https://github.com/user-attachments/assets/db287147-1c0b-4f89-9bb3-a642a702fdad" />

Bonuse commands: 

-->View downloaded images: docker images

-->View container logs: docker logs my-nginx

-->Inspect detailed container information: docker inspect my-nginx

-->Check Docker resource usage: docker stats

<img width="747" height="562" alt="image" src="https://github.com/user-attachments/assets/47bedb9e-d173-4612-9a9f-67f8e00ab505" />

**By completing this task, you will understand how to:**

-->Pull Docker images from a registry.

-->Run containers in detached and interactive modes.

-->Access a web application (Nginx) through a mapped host port.

-->Explore a Linux environment inside an Ubuntu container.

-->View running and stopped containers.

-->Stop, remove, inspect, and monitor Docker containers.

-->Understand the basic Docker container lifecycle from creation to removal.

---

### Task 4: Explore

-->This task focuses on learning the most commonly used Docker commands in real-world DevOps work. Follow the steps below.
1. Run a container in **detached mode** — what's different? --> **docker run -d --name nginx-detached -p 8080:80 nginx**

<img width="767" height="622" alt="image" src="https://github.com/user-attachments/assets/bba91878-a648-4fad-86fe-1a741789a356" />

<img width="1787" height="142" alt="image" src="https://github.com/user-attachments/assets/86bbd329-bdaf-476d-8082-a41da327345a" />

2. Give a container a custom **name** --> **docker run -d --name my-web-server -p 8081:80 nginx**

<img width="696" height="636" alt="image" src="https://github.com/user-attachments/assets/a4010845-ebfb-4226-9066-00d35526b896" />

<img width="1527" height="151" alt="image" src="https://github.com/user-attachments/assets/08463a15-3003-422a-bd56-2f4bd5562c6c" />

<img width="1907" height="782" alt="image" src="https://github.com/user-attachments/assets/c32a4bf2-b181-4cc3-8d4a-a171b7e3672a" />

3. Map a **port** from the container to your host --> **docker run -d --name nginx-port -p 9090:80 nginx**

<img width="755" height="456" alt="image" src="https://github.com/user-attachments/assets/68378912-3b99-4335-92b5-5770117445ae" />

<img width="1715" height="172" alt="image" src="https://github.com/user-attachments/assets/50249783-1a31-4bd5-87e1-eac80045f3f9" />

<img width="1912" height="816" alt="image" src="https://github.com/user-attachments/assets/568985ea-a0e1-4f4c-9b33-b4a2705dec75" />

4. Check **logs** of a running container --> **docker logs <container id>**

<img width="1905" height="772" alt="image" src="https://github.com/user-attachments/assets/4182ba6f-9836-40fb-8b53-acd0a13a3fc4" />

-->Follow logs in real time: docker logs -f my-web-server

<img width="711" height="545" alt="image" src="https://github.com/user-attachments/assets/f155fce0-08bb-47da-b888-188240898eac" />

5. Run a command **inside** a running container -->**docker exec -it <container id> bash**

<img width="1917" height="197" alt="image" src="https://github.com/user-attachments/assets/8db28459-2b29-4f6f-aff8-c1384f78a11a" />

<img width="686" height="606" alt="image" src="https://github.com/user-attachments/assets/12107c8e-5582-4f06-bebc-431488838a53" />

**After completing this task, you should be able to:**

-->Explain the difference between foreground and detached (-d) container execution.

-->Assign meaningful names to containers using --name.

-->Expose container services to the host with port mapping (-p host_port:container_port).

-->Inspect application output using docker logs and docker logs -f.

-->Access and troubleshoot a running container using docker exec -it.

-->Understand that exiting an interactive shell inside a container is different from stopping the container itself.

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
