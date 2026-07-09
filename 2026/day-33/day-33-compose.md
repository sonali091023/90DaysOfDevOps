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

<img width="1917" height="262" alt="image" src="https://github.com/user-attachments/assets/9f1db0af-6a34-467f-9a3c-081e32436849" />

<img width="1896" height="167" alt="image" src="https://github.com/user-attachments/assets/8f15bdc1-763c-4169-bfd4-e7a37e2663ea" />

<img width="1912" height="867" alt="image" src="https://github.com/user-attachments/assets/806a3a58-2771-4b69-8c3b-db38639bc9e6" />

<img width="1917" height="980" alt="image" src="https://github.com/user-attachments/assets/805c87af-866a-437a-b9bf-a562cf686bd9" />

-->If you see the WordPress login page (instead of the installation wizard) and your test post is still there after logging in, then your named MySQL volume is working correctly, and you've successfully completed the persistence requirement.

---

### Task 4: Compose Commands
Practice and document these:

Start services in detached mode
View running services
View logs of all services
View logs of a specific service
Stop services without removing
Remove everything (containers, networks)
Rebuild images if you make a change

**Steps to follow:**

-->This task is about learning the most commonly used Docker Compose commands. Since your WordPress + MySQL application is already running, you can practice these commands directly.

-->Make sure you're inside your project directory: cd wordpress-compose

-->1. Start services in detached mode: Detached mode runs the containers in the background: docker compose up -d

-->To verify run command: docker ps OR docker ps -a

-->View running services: docker-compose ps [Note: Docker Compose provides a summary of the services in the project.]

-->View logs of all services: To see logs from both WordPress and MySQL: docker-compose logs OR To see live logs use command: docker compose logs -f & then to break it use ctrl + c

-->View logs of a specific service [For the WordPress service:]: docker-compose logs wordpress OR to check live logs use command: docker compose logs -f wordpress

-->Also check for mysql service use command: docker-compose logs db OR docker-compose logs -f db [**Note:** Use the service names (wordpress and db) from your docker-compose.yml, not the container names.]

-->Stop services without removing them: This stops the containers but keeps them available to restart later: docker-compose stop && docker-compose ps [Now You'll see the services are stopped, To start them again: docker compose start

-->Remove everything (containers and networks): This stops and removes the containers and the project network: docker-compose down & then verify: docker-compose ps [Expected: No services should be running]

**Important:** This command does not remove named volumes, So your MySQL data remains, If you also wanted to remove the volumes (not required for this task), you would use:

-->To delete the database data: docker compose down -v

-->Rebuild images after making changes: If you modify a Dockerfile or build configuration: docker-compose up --build OR in detached mode: docker-compose up --build -d

-->If you only want to rebuild without starting: docker-compose build

<img width="766" height="571" alt="image" src="https://github.com/user-attachments/assets/9fa4605e-073a-4d93-9bef-621b62f0bfce" />

<img width="751" height="227" alt="image" src="https://github.com/user-attachments/assets/16ec8de5-6f43-47f2-a327-f891b6a032bd" />

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/7bd9780b-15f2-47a8-8882-8a73294a1b70" />

<img width="1917" height="971" alt="image" src="https://github.com/user-attachments/assets/42fc0676-595c-4df0-926e-36b368b4daff" />

<img width="1917" height="895" alt="image" src="https://github.com/user-attachments/assets/e85e01ba-cefd-4ac8-a45c-6023cac661ee" />

<img width="1905" height="222" alt="image" src="https://github.com/user-attachments/assets/970131e3-e4c6-4665-ab4d-aa7a5213a2b2" />

---

### Task 5: Environment Variables
1. Add environment variables directly in your docker-compose.yml
2. Create a .env file and reference variables from it in your compose file
3. Verify the variables are being picked up

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

2. Create a `.env` file and reference variables from it in your compose file -->vi .env

<img width="747" height="606" alt="image" src="https://github.com/user-attachments/assets/6185b012-7181-4040-b61b-ecd134d4356a" />

3. Verify the variables are being picked up-->docker-compose config

<img width="1697" height="780" alt="image" src="https://github.com/user-attachments/assets/be651136-08aa-4b45-b575-e641dde1a1f3" />

<img width="700" height="560" alt="image" src="https://github.com/user-attachments/assets/6aae427e-322d-48ca-a229-0d5222470a8f" />

-->The output of docker compose config (or docker-compose config) shows that Docker Compose successfully read your .env file and substituted the variables, means the variable substitution worked perfectly.

<img width="687" height="682" alt="image" src="https://github.com/user-attachments/assets/07546e23-9f83-496b-bddb-2d7f6ffd143b" />

<img width="762" height="306" alt="image" src="https://github.com/user-attachments/assets/c3288e78-265d-4a4d-a3ed-f8318593ca67" />

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
