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

-->Since you've already worked with Node.js, Docker, and Docker Compose, let's build a realistic 3-tier application.

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

---

### Task 2: depends_on & Healthchecks
1. Add `depends_on` to your compose file so the app starts **after** the database
2. Add a **healthcheck** on the database service
3. Use `depends_on` with `condition: service_healthy` so the app waits for the database to be truly ready, not just started

**Test:** Bring everything down and up — does the app wait for the DB?

-->1. Start db container

-->2. Start redis container

-->3. Check healthcheck of db & redis

-->4. Only when BOTH are healthy → start web container

**Note:** depends_on with condition: service_healthy ensures that a service starts only after its dependent services are fully ready and healthy, not just started.

<img width="1893" height="978" alt="image" src="https://github.com/user-attachments/assets/f1e45c56-73bc-4dbe-8e59-1d3bcd2ccbb1" />

---

### Task 3: Restart Policies
1. Add `restart: always` to your database service
2. Manually kill the database container — does it come back?

-->When we set the **condition restart:always** then Docker will ALWAYS try to keep the container running, For example when container/app crashes, docker kill 

in that case container will et restart, But when we do manually docker stop at the time it Stops temporarily, And when we do Docker daemon restart/system 

reboot at the time container starts again

<img width="1552" height="623" alt="image" src="https://github.com/user-attachments/assets/98d07cd5-251d-4ff4-b3cb-c4292a8a52b6" />

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

<img width="628" height="308" alt="image" src="https://github.com/user-attachments/assets/d70ccaa5-8d3e-4fe8-96fa-8b82831ebdbf" />

<img width="857" height="790" alt="image" src="https://github.com/user-attachments/assets/cf80391a-3adf-4388-9fc0-33c4468ba1a5" />

---

### Task 5: Named Networks & Volumes

1. Define **explicit networks** in your compose file instead of relying on the default

-->We have implemented Explicit Network it Isolates your app, Better control than default network, Clear architecture

3. Define **named volumes** for database data

-->Also implemented Named Volume it Keeps DB data safe, Survives container deletion

5. Add **labels** to your services for better organization

-->then implemented Labels it Helps in filtering/logging, Useful in monitoring tools (Prometheus, Grafana), Better organization 

-->To check the labels use command: **docker inspect day-34-web-1**

---

### Task 6: Scaling (Bonus)
1. Try scaling your web app to 3 replicas using `docker compose up --scale`
2. What happens? What breaks?
3. Write in your notes: Why doesn't simple scaling work with port mapping?

-->Command used: **docker-compose up --scale web=3**

-->faced error: **Error response from daemon: failed to set up container networking: driver failed programming external connectivity on endpoint day-34-web-1 
(307673a5303f37a218a32badc6a51cd5a706bf9f9e164287327c15951c723541): Bind for 0.0.0.0:8000 failed: port is already allocated**

-->This happens because we have mapped host port with container port= **ports: 8000:8000** So ONLY ONE container can use host port 8000 and remain 2 may 

face conflict issue, because Multiple containers → same host port → NOT allowed 

-->So simple scaling fails with port mapping becasue, Docker cannot map multiple containers to the same host port, so scaling services with fixed port 

bindings causes conflicts.

-->To solve this we can remove the mapping concept, Then access via another service (like Nginx), We can also use load balancer, So we can say Scaling fails 

with port mapping because multiple containers cannot bind to the same host port. A load balancer is required to distribute traffic.

<img width="1892" height="557" alt="image" src="https://github.com/user-attachments/assets/3841d520-beb6-4876-8f05-50dc591ba375" />

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
