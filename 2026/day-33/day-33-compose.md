# Day 33 – Docker Compose: Multi-Container Basics

## Task
Today's goal is to **run multi-container applications with a single command**.

Yesterday you manually created networks and volumes and ran containers one by one. Docker Compose does all of that in one YAML file.

---

## Expected Output
- A markdown file: `day-33-compose.md`
- All `docker-compose.yml` files you create

---

## Challenge Tasks

### Task 1: Install & Verify

**Steps to follow:**

-->Update and install docker: sudo apt-get update && sudo apt install -y docker.io

-->Install docker compose: sudo apt install docker-compose -y

-->Start the docker and enable it: sudo systemctl start docker && sudo systemctl enable docker

Step 1: Check if Docker Compose is installed: docker-compose version [If Docker Compose is installed, you'll see output similar to:]

**Note:** Modern Docker uses docker compose (with a space). The older standalone command docker-compose (with a hyphen) is deprecated, although it may still work on some systems.

Step 2: Verify Docker Engine: Also verify that Docker itself is installed: docker --version

Step 3: Verify Docker is running: docker info && docker ps

<img width="1896" height="882" alt="t1i1" src="https://github.com/user-attachments/assets/eeb2ccaa-09e4-4e94-9c5f-03f082473b7a" />

<img width="1811" height="977" alt="image" src="https://github.com/user-attachments/assets/b601f389-d764-4cdf-846f-7fedaf934254" />

<img width="1812" height="391" alt="image" src="https://github.com/user-attachments/assets/47be79ea-efd6-4942-87b6-293f7e8dec9e" />

---

### Task 2: Your First Compose File
1. Create a folder `compose-basics` 
2. Write a `docker-compose.yml` that runs a single **Nginx** container with port mapping 
4. Start it with `docker compose up` 
5. Access it in your browser 
6. Stop it with `docker compose down` 

**Steps to follow:**

Step 1: Create the project directory: mkdir compose-basics && cd compose-basics

Step 2: Create docker-compose.yml: Create a file named docker-compose.yml: vi docker-compose.yml

<img width="595" height="300" alt="image" src="https://github.com/user-attachments/assets/4a452ac4-ca53-480a-bb7a-cf464d9031a7" />

Step 3: Start the container: docker-compose up -d

Step 4: Verify the container: Check that it is running: docker ps

Step 5: Access it in your browser: http://localhost:8080 ALSO check in your terminal: curl http://localhost:8080 [Expected: You should see the Welcome to nginx! page.]

Step 6: Stop and remove everything: docker-compose down

-->Now Verify cleanup: docker ps  OR docker ps -a [Expected: The nginx-compose container should no longer appear.]

<img width="1907" height="915" alt="image" src="https://github.com/user-attachments/assets/e969357d-019a-4b70-a8c3-d56cd22776bd" />

<img width="1917" height="772" alt="image" src="https://github.com/user-attachments/assets/e0a3e797-4032-406c-a840-e836d15f45aa" />

---

### Task 3: Two-Container Setup:

Write a docker-compose.yml that runs:

A WordPress container
A MySQL container
They should:

Be on the same network (Compose does this automatically)
MySQL should have a named volume for data persistence
WordPress should connect to MySQL using the service name
Start it, access WordPress in your browser, and set it up.

Verify: Stop and restart with docker compose down and docker compose up — is your WordPress data still there?

**Steps to follow:**

-->This is one of the most important Docker Compose exercises because it introduces the core concepts of multi-container applications, networking, volumes, environment variables, and service dependencies.

-->Steps 1: Create new directroy and go inside it: mkdir wordpress-compose && cd wordpress-compose

-->Step 2: Create a compose file: touch docker-compose.yml

<img width="667" height="732" alt="image" src="https://github.com/user-attachments/assets/224d9427-5944-4c55-aa69-f48bfede9275" />

-->In the above docker-compose file, There are two different sets of credentials involved here:

<img width="731" height="522" alt="image" src="https://github.com/user-attachments/assets/1f8541dd-1f80-4b04-8dd5-7572b4002455" />

<img width="712" height="765" alt="image" src="https://github.com/user-attachments/assets/7b5f43cd-da8d-4059-ac39-945348598d50" />

<img width="807" height="257" alt="image" src="https://github.com/user-attachments/assets/716cb285-6447-4c9d-964f-f53e2e28b71e" />

Step 3: Understand the Compose File: 

<img width="682" height="762" alt="image" src="https://github.com/user-attachments/assets/20dac678-9fc0-46d3-964f-d1340c85f9fb" />
<img width="672" height="462" alt="image" src="https://github.com/user-attachments/assets/f0037cb7-a929-4cd7-80c3-02e974b768a3" />

<img width="702" height="407" alt="image" src="https://github.com/user-attachments/assets/e658d8de-bef1-4f4e-ac85-2cc2663d97e1" />

<img width="677" height="456" alt="image" src="https://github.com/user-attachments/assets/19b8e54c-0fd9-4314-8990-448dd305dc88" />

<img width="670" height="557" alt="image" src="https://github.com/user-attachments/assets/80d248c8-0cb3-4ca8-9fdf-3938d52739d7" />

<img width="707" height="457" alt="image" src="https://github.com/user-attachments/assets/a32c1288-613b-4285-bb09-5f17fcf96042" />

**Note:** docker Compose automatically creates a network like: **wordpress-compose_default** So to verify it run command: docker network ls

Step 4: Start Everything: docker-compose up -d

Step 5: Verify Containers: docker ps [Expected: 2 containers wordpress-app & wordpress-db should be running]

Step 6: Check the Network: docker network ls

-->then inspect the created network: docker network inspect wordpress-compose_default

Step 7: Open WordPress: For that on browser run the url: http://localhost:8080

<img width="676" height="385" alt="image" src="https://github.com/user-attachments/assets/c8e03c6a-ed1c-4787-b65d-cb5ae4b6ed42" />

Step 7: Verify the Volume: docker volume ls [Expected: wordpress-compose_mysql_data]

-->Then inspect the docker volume: docker volume inspect wordpress-compose_mysql_data

Step 8: Stop Everything: docker-compose down [Expected: Created containers will get remove, But the volume is not removed.]

Step 9: Start Again: docker-compose up -d 

-->And then open url in the browser: http://localhost:8080

[Expected Result: You should not see the WordPress installation page again. Instead, you'll see your existing WordPress login page and all your site content because the MySQL data persisted in the named volume.]

Step 10: Confirm the Volume Exists: docker volume ls [Expected: volume wordpress-compose_mysql_data should be display]

<img width="765" height="707" alt="image" src="https://github.com/user-attachments/assets/ff2fb667-f337-4e13-ad90-00993945f52d" />

<img width="1917" height="330" alt="image" src="https://github.com/user-attachments/assets/a4638462-b53d-419b-9408-18815a3ece22" />

<img width="1866" height="185" alt="image" src="https://github.com/user-attachments/assets/4825f20f-88d9-4971-9d53-237181f1ff51" />

<img width="1647" height="972" alt="image" src="https://github.com/user-attachments/assets/d3ba99b0-71cf-4473-a2bb-455cdfb0e4ff" />

<img width="1917" height="971" alt="image" src="https://github.com/user-attachments/assets/9fb841ad-89c8-4295-9304-5431df413eb8" />

<img width="1910" height="966" alt="image" src="https://github.com/user-attachments/assets/11cb0b64-c95c-4118-8060-1eba7620f427" />

<img width="741" height="822" alt="image" src="https://github.com/user-attachments/assets/5eb85649-1b33-4171-baf6-bde714bca13f" />

<img width="737" height="452" alt="image" src="https://github.com/user-attachments/assets/afa90137-a8cd-40d6-b72c-3ef57e50c1a2" />

<img width="1912" height="922" alt="image" src="https://github.com/user-attachments/assets/c05b01cb-d14b-4d51-b15a-e7c3fd083369" />

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/cc185872-7d76-4d71-8098-28fd44ef9923" />

---

### Task 4: Compose Commands
Practice and document these:
1. Start services in **detached mode** -->**docker-compose up -d**

<img width="1566" height="258" alt="image" src="https://github.com/user-attachments/assets/ee9f9ee3-a808-43b2-bf72-ba5b51d783dc" />

2. View running services -->**docker-compose ps**

<img width="1897" height="162" alt="image" src="https://github.com/user-attachments/assets/d531e7a0-950a-441a-8ae0-8ea8a7ce7694" />

3. View **logs** of all services -->**docker-compose logs -f** --> Both containers are healthy.

<img width="1901" height="622" alt="image" src="https://github.com/user-attachments/assets/aabc9630-a8a7-442c-b3cb-f2dc0908759e" />

4. View logs of a **specific** service -->**docker-compose logs -f db**, **docker-compose logs -f wordpress**

<img width="1907" height="440" alt="image" src="https://github.com/user-attachments/assets/a5412776-0ae9-4bb5-a28d-7865e1686f42" />

5. **Stop** services without removing -->**docker-compose stop**

<img width="633" height="128" alt="image" src="https://github.com/user-attachments/assets/de16a85e-c977-439a-9ede-6d9aa51ebad4" />

6. **Remove** everything (containers, networks) -->**docker-compose down**

<img width="636" height="162" alt="image" src="https://github.com/user-attachments/assets/f25f7f8a-91f9-4a48-ad6c-42c1372e528d" />

7. **Rebuild** images if you make a change -->docker-compose up -d --build

-->**Note:** Forces a rebuild of images before starting. Useful after editing a Dockerfile or application code.

<img width="771" height="152" alt="image" src="https://github.com/user-attachments/assets/9ad33a30-d658-410e-a4db-e6b5871f34a8" />

---

### Task 5: Environment Variables

1. Add environment variables directly in your `docker-compose.yml`

-->Below is the example were added the env variables directly,

services:

  db:
  
    image: mysql:8.0
    
    environment:
    
      MYSQL_ROOT_PASSWORD: rootpass
      
      MYSQL_DATABASE: wordpress
      
      MYSQL_USER: wpuser
      
      MYSQL_PASSWORD: wppass

2. Create a `.env` file and reference variables from it in your compose file -->**vi .env**

<img width="467" height="218" alt="image" src="https://github.com/user-attachments/assets/0dfb8b91-ee37-4e42-ac0d-23d394398137" />

3. Verify the variables are being picked up-->**docker-compose config**

<img width="540" height="980" alt="image" src="https://github.com/user-attachments/assets/17ae5771-6637-4966-be83-b66d5f5924a1" />

---

## Hints
- Start: `docker compose up -d`
- Stop: `docker compose down`
- Logs: `docker compose logs -f`
- Compose creates a default network for all services automatically
- Service names in compose are the DNS names containers use to talk to each other

---

## Submission
1. Add your compose files and `day-33-compose.md` to `2026/day-33/`
2. Commit and push to your fork

---

## Learn in Public
Share your WordPress + MySQL running via Compose on LinkedIn.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
