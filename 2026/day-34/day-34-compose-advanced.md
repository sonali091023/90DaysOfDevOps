# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Task
Today's goal is to **build more complex, production-like setups with Docker Compose**.

Yesterday was basics. Today you handle real scenarios — app + database + cache, healthchecks, restart policies, and service dependencies.

---

## Expected Output
- A markdown file: `day-34-compose-advanced.md`
- All compose files and Dockerfiles you create

---

## Challenge Tasks

### Task 1: Build Your Own App Stack
Create a `docker-compose.yml` for a 3-service stack:
- A **web app** (use Python Flask, Node.js, or any language you know)
- A **database** (Postgres or MySQL)
- A **cache** (Redis)

Write a simple Dockerfile for the web app. The app doesn't need to be complex — even a "Hello World" that connects to the database is enough.

**Steps to follow:**

-->Since you've already worked with Node.js, PostgreSQL, Dockerfiles, and Docker Compose, let's build a 3-service Docker Compose stack using:

Web App: Node.js + Express

Database: PostgreSQL

Cache: Redis

Step 1: Create the Node.js App: mkdir app && cd app & then inside it create file package.json & add below line of code:

<img width="670" height="352" alt="image" src="https://github.com/user-attachments/assets/63f0daa0-57d3-4aed-ba20-8a2150bd9eb7" />

-->app/server.js

<img width="722" height="772" alt="image" src="https://github.com/user-attachments/assets/d3c64840-499a-4fce-adfe-bbf18a47b664" />
<img width="732" height="215" alt="image" src="https://github.com/user-attachments/assets/7a61f309-743a-4df9-b01b-4869bd3472db" />

Step 2: Dockerfile: Also create Dockerfile under app dir: 

<img width="691" height="321" alt="image" src="https://github.com/user-attachments/assets/ef2d9af0-9064-4369-a25e-35f79febb80e" />

Step 3: docker-compose.yml:

<img width="755" height="777" alt="image" src="https://github.com/user-attachments/assets/24b496fc-d8d0-46cf-b795-a28fd8aa2282" />
<img width="750" height="402" alt="image" src="https://github.com/user-attachments/assets/53bc4d7e-4e5a-4f38-9f54-5ae9b0044975" />

Step 4: Optional .env

<img width="667" height="322" alt="image" src="https://github.com/user-attachments/assets/d041e7c6-14d0-48e2-8369-c8932f4a86ef" />

Step 5: Run the Stack: docker compose up --build

-->Verify Containers: docker ps [Expected: following containers should be display node-app, postgres-db, redis-cache]

-->Now to Test the Application run the URl in the browser: http://localhost:3000

<img width="681" height="245" alt="image" src="https://github.com/user-attachments/assets/1df33eee-f7df-46c2-bfca-afad6779ed4c" />

<img width="697" height="547" alt="image" src="https://github.com/user-attachments/assets/67ca1c19-8e9e-451e-a6b3-f42432ee0097" />

<img width="652" height="517" alt="image" src="https://github.com/user-attachments/assets/ca2f33cb-a7d5-4003-9fc1-b5b07d728444" />

<img width="776" height="555" alt="image" src="https://github.com/user-attachments/assets/994c62c9-5a62-4f39-b05d-510464f9faf1" />

<img width="1902" height="930" alt="image" src="https://github.com/user-attachments/assets/0db3c221-f6ee-4f0e-bb10-18dcc2f67ec6" />

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/c6cf5b4f-4ae3-4e23-8f2d-7e3975b6dc27" />

<img width="882" height="762" alt="image" src="https://github.com/user-attachments/assets/dd5b07a6-7619-4084-907a-ca3216c7b61b" />

<img width="1917" height="966" alt="image" src="https://github.com/user-attachments/assets/e78cc68d-b768-43f0-a831-05ecb4062dcf" />

<img width="1897" height="886" alt="image" src="https://github.com/user-attachments/assets/327bf4bc-1ead-433a-90a6-faa0a9b46d4c" />

<img width="1917" height="851" alt="image" src="https://github.com/user-attachments/assets/e2ba3349-614d-4579-9f16-e0c36907b02d" />

---

### Task 2: depends_on & Healthchecks
1. Add `depends_on` to your compose file so the app starts **after** the database
2. Add a **healthcheck** on the database service
3. Use `depends_on` with `condition: service_healthy` so the app waits for the database to be truly ready, not just started

**Test:** Bring everything down and up — does the app wait for the DB?

**Steps to follow:**

-->This task is about making sure your application waits until the database is actually ready before starting. Without a health check, Docker Compose only waits for the database container to start—not for PostgreSQL to finish initializing.

Step 1: Update docker-compose.yml: 

<img width="712" height="677" alt="image" src="https://github.com/user-attachments/assets/c082d211-9297-467e-a814-a3baea19a1c2" />
<img width="702" height="555" alt="image" src="https://github.com/user-attachments/assets/fd140fbc-728a-4d57-bbb9-ccb698458a8e" />

<img width="897" height="717" alt="image" src="https://github.com/user-attachments/assets/c730d6d6-0949-4905-aeb9-15a5da2ecfdd" />

<img width="880" height="486" alt="image" src="https://github.com/user-attachments/assets/01970d1b-1a28-432f-b4f4-c44fe855b3a7" />

<img width="767" height="500" alt="image" src="https://github.com/user-attachments/assets/10827c5c-fea7-4d0f-a2c6-717c3b1844ff" />

<img width="852" height="767" alt="image" src="https://github.com/user-attachments/assets/64ae02f5-33b1-44c0-87c8-5009745b865f" />

<img width="847" height="352" alt="image" src="https://github.com/user-attachments/assets/674ec41b-2e3d-4f30-bb7c-d8775b3ba3f3" />

Step 2: What the Healthcheck Does: 

<img width="810" height="711" alt="image" src="https://github.com/user-attachments/assets/f9ff9082-1fb2-4065-943a-19de6872c5ec" />

Step 3: How depends_on Works: 

<img width="897" height="447" alt="image" src="https://github.com/user-attachments/assets/1e907d8a-24f3-46c2-beb4-b74f58da0eb7" />

Step 4: Bring Everything Down: 

<img width="692" height="262" alt="image" src="https://github.com/user-attachments/assets/7b9d8c35-cb9e-4def-9552-4b1023a968cd" />

Step 5: Start the Stack: docker-compose up --build -d [Expected: Notice that the Node.js application starts only after the database health check succeeds.]

Step 6: Verify the Health Status: List the running containers: docker-compose ps

-->You can also inspect the health status directly: docker inspect postgres-db

-->Or filter just the health information: docker inspect --format='{{json .State.Health}}' postgres-db

<img width="857" height="632" alt="image" src="https://github.com/user-attachments/assets/9292075d-c70e-4442-a6a2-be941b880ec8" />

<img width="1897" height="975" alt="image" src="https://github.com/user-attachments/assets/6961fde8-a9c0-4b42-ba78-560c001a3f89" />

<img width="1912" height="972" alt="image" src="https://github.com/user-attachments/assets/41dc8643-39af-486c-80f3-719c198394f6" />

<img width="1917" height="982" alt="image" src="https://github.com/user-attachments/assets/e5045624-6f44-490c-b87f-39aeb360d073" />

<img width="1917" height="980" alt="image" src="https://github.com/user-attachments/assets/b59282d9-1d26-475f-87dd-054493335adc" />

---

### Task 3: Restart Policies
Add restart: always to your database service
Manually kill the database container — does it come back?
Try restart: on-failure — how is it different?
Write in your notes: When would you use each restart policy?

**Steps to follow:**

-->This task helps you understand how Docker automatically restarts containers under different conditions.

Step 1: Add restart: always

<img width="802" height="760" alt="image" src="https://github.com/user-attachments/assets/a2352c87-953a-491a-9ab8-d4ac0434b384" />

Step 2: Start the stack/container: docker-compose up -d

-->Verify the containers: docker ps

Step 3: Manually kill the database container: Kill the PostgreSQL container: docker kill postgres-db

-->Now Immediately check: docker ps

Step 4: Check if it restarts automatically: docker ps [Expected: Notice the container is running again.]

-->we can also verify by using command: docker inspect postgres-db --format='{{.RestartCount}}' [Expected: So here The restart count increases each time Docker restarts it.]

Step 5: Change to on-failure: 

<img width="717" height="377" alt="image" src="https://github.com/user-attachments/assets/1170a2bc-2368-4739-83bc-33ba517e2df4" />

Step 6: Test on-failure: 

-->Test 1 – Kill the container: docker kill postgres-db

-->Then to verify: docker ps [Expected: The container may restart because docker kill causes the process to exit with a non-zero status (failure), which matches the on-failure policy.]

Test 2 – Stop the container gracefully: docker stop postgres-db

-->Noe to verify: docker ps -a [Expected: It does not restart because it exited successfully with status code 0.]

<img width="1040" height="796" alt="image" src="https://github.com/user-attachments/assets/dcbc84a6-314e-4812-a36c-434582e78e9f" />

<img width="911" height="775" alt="image" src="https://github.com/user-attachments/assets/ebda4297-8d18-411c-976f-9479e5d1fc85" />

1. Add `restart: always` to your database service
2. Manually kill the database container — does it come back?

-->When we set the **condition restart:always** then Docker will ALWAYS try to keep the container running, For example when container/app crashes, docker kill 

in that case container will et restart, But when we do manually docker stop at the time it Stops temporarily, And when we do Docker daemon restart/system 

reboot at the time container starts again

3. Try `restart: on-failure` — how is it different?

-->When we use **condition restart: on-failure** then Docker will restart the container ONLY if it fails (crashes), And it not restart the app in case 

Exit code = 0 (normal exit), docker kill, docker stop, system reboot etc.

-->So the key idea is on-failure = restart ONLY if something goes wrong, restart: on-failure restarts the container only when it exits with a non-zero , 
status code, indicating a failure.

5. Write in your notes: When would you use each restart policy?

-->**condition restart: unless-stopped** is actually the best choice for most real-world setups, Here Docker will Start container → If it crashes → Restart it 

automatically, But If YOU manually stop it → Docker will NOT restart it

-->So when Container crashes, System reboot, docker kill in that case only container will get restart, but when we stop and remove the container manually 

at the time container will not restart

-->**condition restart: no** Here container will not restart. 

---

### Task 4: Custom Dockerfiles in Compose
1. Instead of using a pre-built image for your app, use `build:` in your compose file to build from a Dockerfile
2. Make a code change in your app
3. Rebuild and restart with one command

-->**Note:** What happens internally is Docker sees build:, Rebuilds image from Dockerfile, Stops old container, Starts new container with updated code

-->**Using build:** in docker-compose allows us to build custom images from a Dockerfile, and docker compose up --build rebuilds and restarts containers with updated code.

<img width="692" height="592" alt="image" src="https://github.com/user-attachments/assets/1f47c6ae-8995-4bbb-a61c-57dbdd049512" />

<img width="817" height="486" alt="image" src="https://github.com/user-attachments/assets/260b6925-93eb-4b4f-a5b3-f477d1ad95de" />

<img width="840" height="497" alt="image" src="https://github.com/user-attachments/assets/d193f3c2-1ddf-4005-9135-99ec72ab982e" />

<img width="692" height="761" alt="image" src="https://github.com/user-attachments/assets/9e5ca0ea-b511-4a1c-bc29-d777ba83423d" />
<img width="880" height="736" alt="image" src="https://github.com/user-attachments/assets/455c447f-82dd-4e12-a907-6636b18db189" />

---

### Task 5: Named Networks & Volumes
Define explicit networks in your compose file instead of relying on the default
Define named volumes for database data
Add labels to your services for better organization

**Steps to follow:**

-->This task is about adopting Docker Compose best practices. While Docker Compose automatically creates a default network and anonymous volumes if you don't specify them, explicitly defining networks, volumes, and labels makes your setup cleaner, easier to manage, and closer to production deployments.

1. Define **explicit networks** in your compose file instead of relying on the default

-->We have implemented Explicit Network it Isolates your app, Better control than default network, Clear architecture

2. Define **named volumes** for database data

-->Also implemented Named Volume it Keeps DB data safe, Survives container deletion

3. Add **labels** to your services for better organization

-->then implemented Labels it Helps in filtering/logging, Useful in monitoring tools (Prometheus, Grafana), Better organization 

-->To check the labels use command: **docker inspect day-34-web-1**

**Project Structure:**

<img width="1210" height="242" alt="image" src="https://github.com/user-attachments/assets/ac4f4f21-85f1-450f-8624-c0c315157a45" />

**Recommended docker-compose.yml:**

<img width="710" height="812" alt="t5i2" src="https://github.com/user-attachments/assets/a98f9d66-59c3-49ac-a882-c8e331374238" />

<img width="747" height="360" alt="image" src="https://github.com/user-attachments/assets/9b09f463-5d48-48ac-bfc7-d845da252059" />

**Why each section is used:**

<img width="717" height="650" alt="image" src="https://github.com/user-attachments/assets/4f5c98bd-b721-4b12-962b-78cd16e3e5fc" />

<img width="735" height="502" alt="image" src="https://github.com/user-attachments/assets/4213db09-d2b3-422c-a47a-6fa4dd0f0556" />

<img width="702" height="627" alt="image" src="https://github.com/user-attachments/assets/3f17206f-95ac-4a59-be65-296faac3228b" />

<img width="706" height="466" alt="image" src="https://github.com/user-attachments/assets/1d4972b4-0b33-4f10-9a23-497a73ae7816" />

<img width="761" height="425" alt="image" src="https://github.com/user-attachments/assets/dc1f0fa6-9c68-4194-b42f-087a642eae57" />

<img width="717" height="522" alt="image" src="https://github.com/user-attachments/assets/e091cbf2-df8d-4d52-9685-7a58c6282ccb" />

<img width="772" height="702" alt="image" src="https://github.com/user-attachments/assets/3d8b7026-8155-4d26-a78f-c168eb610d82" />

<img width="802" height="297" alt="image" src="https://github.com/user-attachments/assets/af179bf9-c980-4fde-865e-f059b509907c" />

---

### Task 6: Scaling (Bonus)
1. Try scaling your web app to 3 replicas using `docker compose up --scale`
2. What happens? What breaks?
3. Write in your notes: Why doesn't simple scaling work with port mapping?

**Steps to follow:**

-->This is one of the most interesting Docker Compose tasks because it teaches an important limitation of Docker Compose compared to orchestration platforms like Kubernetes or Docker Swarm.

-->Command used: docker-compose up --scale web=3

<img width="647" height="286" alt="image" src="https://github.com/user-attachments/assets/8364c5ef-b676-4fce-a89f-e6186d445b46" />

<img width="1917" height="381" alt="image" src="https://github.com/user-attachments/assets/15b2eb3e-3818-4d4a-9f6c-4f1d3485586c" />

Step 1: Check Your Current Compose File

<img width="707" height="545" alt="image" src="https://github.com/user-attachments/assets/a79edd64-8f06-47fe-a4cd-ec3a45c6ff4b" />

**Step 2: Scale the Service:** docker compose up --scale web=3 -d

<img width="716" height="647" alt="image" src="https://github.com/user-attachments/assets/77037845-4e0f-420e-ac98-7adc37c4d362" />

-->faced error: **Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint day-34-web-1 
(307673a5303f37a218a32badc6a51cd5a706bf9f9e164287327c15951c723541): Bind for 0.0.0.0:8000 failed: port is already allocated**

-->This happens because we have mapped host port with container port= **ports: 8000:8000** So ONLY ONE container can use host port 8000 and remain 2 may 

face conflict issue, because Multiple containers → same host port → NOT allowed 

-->So simple scaling fails with port mapping becasue, Docker cannot map multiple containers to the same host port, so scaling services with fixed port 

bindings causes conflicts.

-->To solve this we can remove the mapping concept, Then access via another service (like Nginx), We can also use load balancer, So we can say Scaling fails 

with port mapping because multiple containers cannot bind to the same host port. A load balancer is required to distribute traffic.

<img width="716" height="647" alt="image" src="https://github.com/user-attachments/assets/57270bf0-e1d8-4593-85ba-95a1cef19786" />

<img width="706" height="605" alt="image" src="https://github.com/user-attachments/assets/7b48d33d-9be8-4b1e-aed1-71ac7850503e" />
<img width="696" height="620" alt="image" src="https://github.com/user-attachments/assets/9261f417-5881-4c4d-bd5f-c6f998da681e" />

<img width="802" height="675" alt="image" src="https://github.com/user-attachments/assets/aed3765f-0a4e-4a87-ab34-cf16fa8a189b" />

<img width="795" height="607" alt="image" src="https://github.com/user-attachments/assets/a6799c60-7a65-47ba-aeb3-74b77b8e93cc" />

**Useful Commands:**

-->Scale up: docker compose-up --scale web=3 -d

-->View running containers:: docker ps

-->View logs from all replicas: docker-compose logs web

-->Scale back down: docker compose up --scale web=1 -d

-->Stop everything: docker-compose down

**Note:**

Command Used:
docker compose up --scale web=3 -d

Observation:
- Docker Compose attempted to create three web containers.
- Only one container could bind to host port 3000.
- Additional replicas failed because the host port was already allocated.

Reason:
Host ports must be unique. Multiple containers cannot bind to the same host port simultaneously.

How This Is Solved:
In production, a reverse proxy or load balancer (such as Nginx, Traefik, Docker Swarm, or Kubernetes Services) exposes a single host port and distributes incoming requests across multiple application replicas.

**Key takeaway:** Docker Compose can create multiple replicas, but simple scaling doesn't work with fixed host port mappings because the host cannot assign the same port (e.g., 3000) to more than one container. In real deployments, scaling is typically combined with a load balancer or an orchestrator like Kubernetes that routes traffic to multiple replicas.

---

## Hints
- Build from Dockerfile: `build: ./app`
- Healthcheck: `healthcheck:` with `test`, `interval`, `timeout`
- Rebuild: `docker compose up --build`
- Scale: `docker compose up --scale web=3`

---

## Submission
1. Add your compose files, Dockerfiles, and `day-34-compose-advanced.md` to `2026/day-34/`
2. Commit and push to your fork

---

## Learn in Public
Share your 3-service app stack running via Compose on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
