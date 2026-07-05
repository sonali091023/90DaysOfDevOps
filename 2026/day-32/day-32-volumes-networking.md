# Day 32 – Docker Volumes & Networking

## Task
Today's goal is to **solve two real problems: data persistence and container communication**.

Containers are ephemeral — they lose data when removed. And by default, containers can't easily talk to each other. Today you fix both.

---

## Expected Output
- A markdown file: `day-32-volumes-networking.md`
- Screenshots of your experiments

---

## Challenge Tasks

### Task 1: The Problem
1. Run a Postgres or MySQL container
2. Create some data inside it (a table, a few rows — anything)
3. Stop and remove the container
4. Run a new one — is your data still there?

Write what happened and why.

**Steps to follow:**

-->This task is designed to show you why Docker volumes are needed. By default, a container's writable layer is temporary. When you remove the container, everything stored inside it is deleted unless you've mounted a volume.

Step 1: Pull the PostgreSQL Image: docker pull postgres:17

-->Once pulled verify: docker images

Step 2: Run a PostgreSQL Container (Without a Volume): 

-->docker run -d --name postgres-demo -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=testdb -p 5432:5432 postgres:17

<img width="811" height="455" alt="image" src="https://github.com/user-attachments/assets/d443c521-c6ad-4f09-aa06-cf950a8d446a" />

-->Once the container gets create verify it: docker ps

Step 3: Connect to PostgreSQL: To connect to PostgreSQL Open a shell inside the container: docker exec -it postgres-demo psql -U admin -d testdb

<img width="747" height="152" alt="image" src="https://github.com/user-attachments/assets/b18a26a0-fa44-4870-bfd2-57ac8e0629d5" />

Step 4: Create a Table: CREATE TABLE students (id SERIAL PRIMARY KEY,name VARCHAR(100),city VARCHAR(100));

-->Once table gets create insert some data: INSERT INTO students(name, city) VALUES('Alice','Delhi'),('Bob','Mumbai'),('Charlie','Pune');

-->Nove once the records insert to verify: SELECT * FROM students;

-->Noe exit from the container

Step 5: Stop the Container: docker stop postgres-demo

Step 6: Remove the Container: docker rm postgres-demo [Now the container is gone.]

Step 7: Run a New PostgreSQL Container Again Here use the same command: 

-->docker run -d --name postgres-demo -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=testdb -p 5432:5432 postgres:17

Step 8: Check for the Table: docker exec -it postgres-demo psql -U admin -d testdb

-->Then to check created table run command: SELECT * FROM students; [Here expected: ERROR: relation "students" does not exist, This is because the database was recreated from scratch.]

<img width="1902" height="912" alt="image" src="https://github.com/user-attachments/assets/36733c62-d175-427d-ab23-df42c4490e5c" />

<img width="1911" height="510" alt="image" src="https://github.com/user-attachments/assets/d0da9751-5a7a-48f7-883f-abd4da7fcfcc" />

<img width="707" height="677" alt="image" src="https://github.com/user-attachments/assets/bbe621f0-9dee-4e7a-9544-0fbb6469d5df" />

**Write what happened and why?**

-->So Data is lost when a container is removed because containers are ephemeral and do not persist data by default. The PostgreSQL data directory was stored inside the container. Removing the container deleted its writable layer. Since no Docker volume was attached, all database files were lost. A new container creates a new, empty database.

**Key Takeaway:**

-->Without a volume: Data is lost when the container is removed.

-->With a volume: Data persists even if the container is stopped or deleted.

---

### Task 2: Named Volumes
1. Create a named volume -->**docker volume create my-db-volume**
2. Run the same database container, but this time **attach the volume** to it
3. Add some data, stop and remove the container
4. Run a brand new container with the **same volume**
5. Is the data still there?

Verify: docker volume ls, docker volume inspect

**Steps to follow:**

 -->Store your PostgreSQL data in a Docker named volume so it survives even if the container is deleted.

 Step 1: Create a Named Volume: docker volume create postgres-data 

 -->To verify created volume: docker volume ls

 Step 2: Run PostgreSQL with the Volume Attached: 

 -->docker run -d --name postgres-db -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=testdb -v postgres-data:/var/lib/postgresql/data -p 5432:5432 postgres:17

 <img width="717" height="241" alt="image" src="https://github.com/user-attachments/assets/c4d87ede-107b-437c-b2ea-5ddbeb9d32fc" />

Step 3: Create Some Data: First go inside container: docker exec -it postgres-db psql -U admin -d testdb

-->Create a table and insert data: CREATE TABLE students (id SERIAL PRIMARY KEY, name VARCHAR(50));

-->INSERT INTO students(name)VALUES ('Alice'), ('Bob');

-->SELECT * FROM students;

-->To exit use command: \q

Step 4: Stop and Remove the Container: docker stop postgres-db && docker rm postgres-db [**Note:** The container is deleted, but the volume still exists.]

Step 5: Run a New Container with the Same Volume: docker run -d --name postgres-db -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin123 -e POSTGRES_DB=testdb -v postgres-data:/var/lib/postgresql/data -p 5432:5432 postgres:17

Step 6: Connect again & Verify the Data :   

-->Run SELECT * FROM students; [**Note:** The table and data are still there because they were stored in the named volume]

-->To exit use command: \q

Step 7: Verify the Volume: docker volume ls [we will get List all volumes]

-->Inspect the volume: docker volume inspect postgres-data

<img width="836" height="492" alt="image" src="https://github.com/user-attachments/assets/b34bf764-6dbc-43a8-b077-b622c483c099" />

<img width="1917" height="862" alt="image" src="https://github.com/user-attachments/assets/49b77e1a-e6b0-42ac-814b-8599d0b533c2" />

<img width="1917" height="811" alt="image" src="https://github.com/user-attachments/assets/21a1d71d-f9cf-48e4-9e82-c36541ff89ab" />


-->Create named volume: **docker volume create my-db-volume**

-->To check the volume list: **docker volume ls**

-->Run MySQL Container with Volume: **docker run -d --name sql-volume -e MYSQL_ROOT_PASSWORD=test@123 -v mysqldata:/var/lib/mysql mysql**

-->Check Running Container: **docker ps**

-->Access MySQL by going inside container: **docker exec -it sql-volume mysql -u root -p**  

-->Enter Password and get loggedin to the mysql and then perform following steps:

-->**CREATE DATABASE testdb;**

-->**USE testdb;**

-->**CREATE TABLE test_data (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));**

-->**INSERT INTO test_data (name) VALUES ('Alice'), ('Bob');**

-->**SELECT * FROM test_data;**

-->**show databases;**

-->**exit**

-->Check Running Container: **docker ps**

-->Stop & Remove Container: **docker stop 831da080f31c && docker rm 831da080f31c**

-->Check Running Container: **docker ps**

-->Recreate Container with SAME Volume: **docker run -d --name persistent -e MYSQL_ROOT_PASSWORD=test@123 -v mysqldata:/var/lib/mysql mysql**

-->Check Running Container: **docker ps**

-->**docker exec -it persistent mysql -u root -p**  

-->Enter Password and get loggedin to the mysql and Verify Data Persistence:

-->**show databases;**

-->**use testdb**

-->**SELECT * FROM test_data;**

-->**exit**

-->**docker volume ls**

-->**Verify:** `docker volume ls`, docker volume inspect: **docker volume inspect mysqldata**

**Note:** Container = Ephemeral (temporary) & Volume = Persistent (data stays even if container is deleted), So As long as you use the same volume name, your data 
is safe.


---

### Task 3: Bind Mounts
1. Create a folder on your host machine with an `index.html` file
2. Run an Nginx container and **bind mount** your folder to the Nginx web directory
3. Access the page in your browser
4. Edit the `index.html` on your host — refresh the browser

**Commands Used:** 

-->Create folder: **mkdir nginx-bind**

--> Go inside folder: **cd nginx-bind/**

--> Create file: **vi index.html**

--> Run Nginx Container with Bind Mount: **docker run -d --name nginx-bind-container -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx:alpine**

--> Verify the created container: **docker ps**

-->Verify the content of the file: **cat index.html**


-->Edit the content of the file: **vi index.html**

-->Verify the updated content of the file: **cat index.html**

-->Access in Browser: **http://localhost:8080** 

**Note:** Output will update without restarting container.

-->If in case this doesnt work **-v $(pwd):/usr/share/nginx/html** use full path as follows **-v /home/ubuntu/nginx-bind:/usr/share/nginx/html**

<img width="1810" height="473" alt="image" src="https://github.com/user-attachments/assets/c3afd936-829a-4308-93a4-fd183b526c47" />

<img width="637" height="430" alt="image" src="https://github.com/user-attachments/assets/d6c06b90-c652-48f0-80df-1807361be249" />

Write in your notes: What is the difference between a named volume and a bind mount?

-->**Volumes:** Managed by Docker, Stored in a part of the host filesystem which is managed by Docker, Preferred method for data persistence.

-->**Bind Mounts:** Maps a file or directory on the host to a file or directory in the container, More complex but provides flexibility to interact with the host system.

---

### Task 4: Docker Networking Basics
1. List all Docker networks on your machine -->**docker network ls**

-->So bdidge is the default docker network.

<img width="520" height="171" alt="image" src="https://github.com/user-attachments/assets/99b4804f-ee17-402f-bc37-ccc5bec41a2d" />

2. Inspect the default `bridge` network -->**docker network inspect bridge**

<img width="828" height="966" alt="image" src="https://github.com/user-attachments/assets/3968efe5-fd80-4c26-ad40-eb5a948f3fbf" />

3. Run two containers on the default bridge — can they ping each other by **name**?

-->No on the default bridge network by using container name, 2 differnt containers cant communicate with eachother.

-->container1: **docker run -it --name container1 busybox sh**

-->**docker exec -it container1 sh**

-->**ping container1**

-->container2: **docker run -it --name container2 busybox sh**

-->**docker exec -it container2 sh**

-->**ping container2**

<img width="992" height="437" alt="image" src="https://github.com/user-attachments/assets/efedab7e-2228-4dd7-a199-77a06a154c35" />

4. Run two containers on the default bridge — can they ping each other by **IP**?

-->Yes on the default bridge network by using ip address, 2 differnt containers can communicate with eachother.

-->Container1: **docker run -it --name container1 busybox sh**

-->**docker exec -it container1 sh**

-->**ip addr**

-->**ping 172.18.0.2**

<img width="1511" height="710" alt="image" src="https://github.com/user-attachments/assets/82f99acb-3690-4b5d-869c-7b989325b185" />

-->container2: **docker run -it --name container2 busybox sh**

-->**docker exec -it container2 sh**

-->**ip addr**

-->**ping 172.18.0.3**

<img width="1250" height="731" alt="image" src="https://github.com/user-attachments/assets/290f1256-d2da-4276-8e2d-a5e16e577170" />

---

### Task 5: Custom Networks
1. Create a custom bridge network called `my-app-net` -->**docker network create my-app-net**

2. Run two containers on `my-app-net`

-->**docker run -dit --name container1 --network my-app-net alpine sh**

-->**docker run -dit --name container2 --network my-app-net alpine sh**

-->**docker ps**

3. Can they ping each other by **name** now?
 
-->Go inside container1: **docker exec -it e4401baf0b82 sh**

-->**ping container2**

-->Go inside container2: **docker exec -it e4401baf0b82 sh**  

-->**ping container1**

4. Write in your notes: Why does custom networking allow name-based communication but the default bridge doesn't?

-->Default Docker bridge network does not have built-in DNS,so containers cannot resolve each other by name.they need IPs.

-->User-defined networks have embedded DNS, so containers can communicate using their names.

-->**Note:** Custom Docker networks enable name-based communication because they include an internal DNS server, while the default bridge network lacks this 

feature and only supports IP-based communication.

---

### Task 6: Put It Together
1. Create a custom network  --> **docker network create my-app-net**

2. Run a **database container** (MySQL/Postgres) on that network with a volume for data

-->Run a database container (PostgreSQL + volume): **docker run -d --name my-db --network my-app-net -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=test@123 -e POSTGRES_DB=mydb -v pgdata:/var/lib/postgresql/data postgres:16**

-->Here above command Creates DB container my-db, Attaches to my-app-net this is custom network, Adds persistent volume (pgdata), Sets username/password/db

3. Run an **app container** (use any image) on the same network

-->**docker run -dit --name my-app --network my-app-net alpine sh**

4. Verify the app container can reach the database by container name

-->Yse based on container name they can talk with each other due to DNS Resolution. 

-->To go inside app container: **docker exec -it my-app sh**

-->ping db container from app container: **ping my-db**

-->Check DB port: **nc -zv my-db 5432**  

-->PostgreSQL server listens on port 5432 inside the container, Check if service is running on port 5432 of my-db, So no IP needed, No port mapping needed 

(internal communication will happen)

-->**Note:** This proves app can reach DB service, So my-db is resolved via Docker DNS, No need to use IP address, Both containers communicate over my-app-net 

which is custom network it has DNS resolution which default network dont have which is bridge network.

<img width="1862" height="971" alt="image" src="https://github.com/user-attachments/assets/766aed7c-b891-4f03-8d72-15e0fbc5f356" />

-->**Note:** Containers on the same custom Docker network can communicate using container names because Docker provides an internal DNS service. This allows 

application containers to connect to database containers using service names instead of IP addresses, which is more reliable.

-->Common default ports (VERY IMPORTANT/Default port = where the service “lives” by default)

-->PostgreSQL=5432

-->MySQL=3306

-->MongoDB=27017

-->Nginx(HTTP)=80

-->HTTPS=443

-->Redis=6379

-->A default port is the standard port on which a service listens (e.g., PostgreSQL uses 5432), allowing applications to connect without additional configuration.

-->[**Internal port** → where app runs/listens[Used for container to container communicaton], **EXPOSE** → just info [Used in Dockerfile], **-p [runtime defined]** → actual access from outside]

-->Internal ports are where applications run inside containers, EXPOSE documents those ports, and -p maps them to the host to allow external access.

---

## Hints
- Volumes: `docker volume create`, `-v volume_name:/path`
- Bind mount: `-v /host/path:/container/path`
- Networking: `docker network create`, `--network`
- Ping: `docker exec container1 ping container2`

---

## Submission
1. Add your `day-32-volumes-networking.md` to `2026/day-32/`
2. Commit and push to your fork

---

## Learn in Public
Share what happened when you deleted a container without a volume on LinkedIn. The "aha moment" is real.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
