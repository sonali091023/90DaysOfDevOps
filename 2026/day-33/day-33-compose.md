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

### Task 3: Two-Container Setup

Write a `docker-compose.yml` that runs:   -->**mkdir wordpress-app && cd wordpress-app**

Create below both containers in **vi docker-compose.yml**

- A **WordPress** container

- A **MySQL** container

-->**docker-compose up -d**

They should:

- Be on the same network (Compose does this automatically)

-->This network **wordpress-app_default** was automatically created by Docker Compose — we didn't have to do anything, When we run **docker-compose up -d** Docker 

Compose automatically:

-->**Read your docker-compose.yml**

-->**Created a default network named projectfolder_default==wordpress-app_default**

-->**Attached all containers in the file to that network**

-->That's why containers can talk to each other, WordPress can reach MySQL just by using service name db — because both containers are on the same network wordpress-app_default.

WORDPRESS_DB_HOST: db:3306

-->Verify containers are on same network: **docker network inspect wordpress-app_default**

-->One docker-compose up -d creates everything automatically

-->To see the docker network list: **docker network ls**

<img width="677" height="201" alt="image" src="https://github.com/user-attachments/assets/676070cc-6281-4c45-b030-ada2d3d083e5" />

-->Verify containers are on same network: **docker network inspect wordpress-app_default**

<img width="1150" height="971" alt="image" src="https://github.com/user-attachments/assets/af8a57fc-6490-4064-9ebc-fc51033f80b4" />

- MySQL should have a named volume for data persistence

- WordPress should connect to MySQL using the service name

Start it, access WordPress in your browser, and set it up.

**Verify:** Stop and restart with `docker compose down` and `docker compose up` — is your WordPress data still there?

<img width="1921" height="894" alt="image" src="https://github.com/user-attachments/assets/2e6aa1a5-f4f8-4d89-bcdb-908684b9622c" />

<img width="866" height="557" alt="image" src="https://github.com/user-attachments/assets/e55df36a-ee01-4fa8-bcde-dfecc25027eb" />

<img width="1431" height="757" alt="image" src="https://github.com/user-attachments/assets/6299f8cf-9829-4ab7-a444-de0b90c2805a" />

<img width="1905" height="970" alt="image" src="https://github.com/user-attachments/assets/1a6e10f8-8364-413c-8669-849d8ef31741" />

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
