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

-->Create named volume: docker volume create mysqldata

-->To check the volume list: docker volume ls

-->veriy if any container is running: docker ps

-->Run MySQL Container with Volume: docker run -d --name sql-volume -e MYSQL_ROOT_PASSWORD=test@123 -v mysqldata:/var/lib/mysql mysql

<img width="807" height="420" alt="image" src="https://github.com/user-attachments/assets/ee73ec4c-4b18-41d8-ae38-f94b655adb5c" />

-->Check Running Container: docker ps

-->Access MySQL by going inside container: docker exec -it sql-volume mysql -u root -p

<img width="786" height="401" alt="image" src="https://github.com/user-attachments/assets/55a7c917-7628-4d75-8198-2e1130b03bb1" />

<img width="556" height="147" alt="image" src="https://github.com/user-attachments/assets/9f6ee8e1-e285-43e6-9e14-babbfc8c5d3b" />

-->Create database inside container: CREATE DATABASE testdb;

-->Then to use created database use following container: USE testdb;

-->Now create table: CREATE TABLE test_data (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50));

-->Insert data into that table: INSERT INTO test_data (name) VALUES ('Alice'), ('Bob');

-->Now check the records in the table: SELECT * FROM test_data;

-->Again check the database: show databases;

-->Once done exit from the container: exit

-->Check Running Container: docker ps

-->Stop & Remove Container: docker stop 831da080f31c && docker rm 831da080f31c

-->Check Running Container: docker ps

-->Recreate Container with SAME Volume: docker run -d --name sql-volume -e MYSQL_ROOT_PASSWORD=test@123 -v mysqldata:/var/lib/mysql mysql

-->Check Running Container: docker ps

-->Now again go insode recreated container: docker exec -it sql-volume mysql -u root -p

-->Enter Password and get loggedin to the mysql and Verify Data Persistence:

-->Now check the previously created database: show databases;

-->Now to use the same database use command: use testdb;

-->SELECT * FROM test_data;

-->exit

Verify: docker volume ls, docker volume inspect:

-->docker volume ls

-->**Verify:** `docker volume ls`, docker volume inspect: docker volume inspect mysqldata

**Note:** Container = Ephemeral (temporary) & Volume = Persistent (data stays even if container is deleted), So As long as you use the same volume name, your data 
is safe.

<img width="1785" height="971" alt="image" src="https://github.com/user-attachments/assets/05e3008c-db2e-467c-8b84-c0be59df95bf" />

<img width="1830" height="967" alt="image" src="https://github.com/user-attachments/assets/9690de09-422d-4764-86b5-366f0e3a7bda" />

<img width="1667" height="870" alt="image" src="https://github.com/user-attachments/assets/c801d4b4-d5d0-4943-9270-9094e5953f84" />

<img width="1697" height="290" alt="image" src="https://github.com/user-attachments/assets/0c5a20f3-4d3a-4a4b-8cd2-5efadbc85376" />

<img width="741" height="750" alt="image" src="https://github.com/user-attachments/assets/c79d6012-11a4-4bd8-8df5-e411406d9ae1" />

<img width="786" height="212" alt="image" src="https://github.com/user-attachments/assets/20a9d0a1-0457-4b7c-a07a-2505e2cf3e21" />

-->Any database files written to /var/lib/mysql are actually stored in the mysqldata volume. If you delete the container and create a new one with the same volume, the data is still available.

---

### Task 3: Bind Mounts
1. Create a folder on your host machine with an `index.html` file
2. Run an Nginx container and **bind mount** your folder to the Nginx web directory
3. Access the page in your browser
4. Edit the `index.html` on your host — refresh the browser

**Steps to follow:**

-->Learn how Bind Mounts work. A bind mount directly links a folder on your host machine to a folder inside a container. Any changes made on the host are reflected immediately in the container.

Step 1: Create a Folder on Your Host: mkdir nginx-bind && cd nginx-bind

-->Create an index.html file: echo '<h1>Hello from Bind Mount!</h1>' > index.html then verify ls [Expected: index.html file should be display]

Step 2: Run an Nginx Container with a Bind Mount: docker run -d --name nginx-bind -p 8080:80 -v $(pwd):/usr/share/nginx/html nginx

<img width="702" height="287" alt="image" src="https://github.com/user-attachments/assets/f517c7b8-bfa1-46f5-a643-28c39f443da0" />

-->docker ps:

<img width="1917" height="806" alt="image" src="https://github.com/user-attachments/assets/b4fdf9c5-81a4-4eb2-882b-bf5dbad8885f" />

Step 3: Access the Website: http://localhost:8080  [Expected: We should see Hello from Bind Mount!]

<img width="1917" height="705" alt="image" src="https://github.com/user-attachments/assets/0654801e-b0e2-4a0a-9e29-fe685033eb8d" />

Step 4: Edit index.html on Your Host: echo "<h1>Docker Bind Mount Updated!</h1>" > index.html OR edit it with vim editor

Step 5: Refresh the Browser: http://localhost:8080 [Expected: You'll immediately see the updated content]

<img width="1917" height="740" alt="image" src="https://github.com/user-attachments/assets/3a22ac59-c65a-42ee-972d-35b771bb16ea" />

<img width="792" height="785" alt="image" src="https://github.com/user-attachments/assets/383db209-4737-4899-be70-a3ecf69d5275" />

**Key Takeaway:**

-->Bind Mount: Shares a host directory with a container. Changes are visible immediately.

-->Named Volume: Stores persistent data managed by Docker, commonly used for databases.

---

### Task 4: Docker Networking Basics

List all Docker networks on your machine
Inspect the default bridge network
Run two containers on the default bridge — can they ping each other by name?
Run two containers on the default bridge — can they ping each other by IP?

**Steps to follow:**

-->Understand how Docker's default bridge network works and how containers communicate.

Step 1: List All Docker Networks: docker network ls 

<img width="632" height="137" alt="image" src="https://github.com/user-attachments/assets/5aec9158-fd4b-4847-987b-854809578398" />

<img width="1331" height="215" alt="image" src="https://github.com/user-attachments/assets/222a85ba-b602-4e98-91ca-3eb6a0d480ee" />

Note: Here in the network list bridge is the default network

Step 2: Inspect the Default Bridge Network: docker network inspect bridge

<img width="742" height="191" alt="image" src="https://github.com/user-attachments/assets/ace0f811-29a8-4aae-9a42-fdc6c6b1b0e6" />

<img width="1560" height="972" alt="image" src="https://github.com/user-attachments/assets/31fd5141-1361-4fbd-a0c6-d3326b5e956c" />

Step 3: Run Two Containers on the Default Bridge: 

-->Container 1: docker run -dit --name container1 alpine sh

-->Container 2: docker run -dit --name container2 alpine sh

-->To verify: docker ps

Step 4: Install ping (Alpine Image): The Alpine image doesn't include ping by default, Go inside container1: docker exec -it container1 sh

-->& then install ping: apk update && apk add iputils

Step 5: Can They Ping by Name?: To verify run command inside container 1: ping container2

<img width="732" height="332" alt="image" src="https://github.com/user-attachments/assets/d6e0a7ed-bd89-4e8d-8def-dc042c45b531" />

<img width="1671" height="667" alt="image" src="https://github.com/user-attachments/assets/6aadb685-3a4b-4fb5-bac9-94d8b198ca72" />

-->ping: bad address 'container2' It will get fail, because The default bridge network does not provide automatic DNS-based name resolution between containers.

Step 6: Find the IP of container2: So first exit from the container 1: exit & then run command: docker inspect container2 OR run below command:

-->docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container2 [Expected: ip address will get]

<img width="1727" height="925" alt="image" src="https://github.com/user-attachments/assets/8e23aa09-485e-4149-8a0a-38ad6e4a1e5a" />

Step 7: Ping by IP: Go back into container1: docker exec -it container1 sh

-->ping 172.17.0.3 [Expected: it succeeds]

<img width="1825" height="215" alt="image" src="https://github.com/user-attachments/assets/b6955e14-71a6-4639-94c5-c2600c555ceb" />

<img width="786" height="642" alt="image" src="https://github.com/user-attachments/assets/b9e5f2ad-e23c-432c-be13-18d22eb17fac" />

**Key Takeaway:**

-->Default bridge network: Communication works by IP, not by container name.

-->User-defined bridge network: Communication works by both IP and container name, thanks to Docker's built-in DNS.

---

### Task 5: Custom Networks
Create a custom bridge network called my-app-net
Run two containers on my-app-net
Can they ping each other by name now?
Write in your notes: Why does custom networking allow name-based communication but the default bridge doesn't?

**Steps to follow:**

-->This task is meant to teach you how Docker networking and DNS work.

Step 1: Create a custom bridge network: docker network create my-app-net

-->To Verify it: docker network ls

Step 2: Run two containers on the custom network: 

-->docker run -dit --name container1 --network my-app-net alpine sh

-->docker run -dit --name container2 --network my-app-net alpine sh

-->docker ps

Step 3: Install ping (Alpine doesn't include it): Before this go insode container: 

-->docker exec -it container1 sh

-->then install ping: apk update && apk add iputils

-->Now ping to the second container from one container by its name: ping container2 [Expected: pinging output should be display and to break it ctrl + c]

-->You can also test from the second container, to do this first go insode containre two: docker exec -it container2 sh

-->Now install and ping as well to container one: apk update && apk add iputils && ping container1

Step 4: Inspect the network: docker network inspect my-app-net [expected: You'll see both containers attached to the network.]

<img width="747" height="780" alt="image" src="https://github.com/user-attachments/assets/53ae7412-deca-413b-89e3-499d681de077" />

<img width="827" height="351" alt="image" src="https://github.com/user-attachments/assets/a62f2284-138a-45af-871b-9730a64112fc" />

<img width="1825" height="966" alt="image" src="https://github.com/user-attachments/assets/98ccc7cd-9e38-4bbc-af26-771b939c0fd5" />

<img width="1725" height="677" alt="image" src="https://github.com/user-attachments/assets/08031d46-cef1-413a-acb9-744de060f3d8" />

---

### Task 6: Put It Together
Create a custom network
Run a database container (MySQL/Postgres) on that network with a volume for data
Run an app container (use any image) on the same network
Verify the app container can reach the database by container name

**Steps to follow:**

-->This task combines Docker Networks + Volumes + Containers into a simple multi-container setup.

Step 1: Create a custom network: docker network create my-app-net

-->Then to verify: docker network ls

Step 2: Create a volume for database persistence: docker volume create postgres-data

-->To verify: docker volume ls

Step 3: Run the PostgreSQL container(PostgreSQL + volume): docker run -d --name postgres-db --network my-app-net -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=password -e POSTGRES_DB=mydb -v postgres-data:/var/lib/postgresql/data postgres:16-alpine

-->Check that it is running: docker ps

Step 4: Run an application container: For this task, use an Alpine container as a simple client: docker run -dit --name app-container --network my-app-net alpine sh

Step 5: Verify the app container can reach the database for that go inside container first: docker exec -it app-container sh

-->Install networking tools: apk update && apk add iputils bind-tools

-->Ping the PostgreSQL container by its container name: ping postgres-db [Expected: Pinging output should be display]

-->You can also verify DNS resolution: nslookup postgres-db

-->exit from the container: exit

-->Verify the volume is attached: Inspect the PostgreSQL container: docker inspect postgres-db

<img width="557" height="197" alt="image" src="https://github.com/user-attachments/assets/d82cdd70-91be-49c4-8871-dd81919a5216" />

-->Verify the network: docker network inspect my-app-net [Expected: Both containers should be displayed connected postgres-db & app-container]

<img width="820" height="321" alt="image" src="https://github.com/user-attachments/assets/4dbb169f-98aa-490c-9b6b-3d01388b7472" />

<img width="1720" height="772" alt="image" src="https://github.com/user-attachments/assets/d88c3430-ce00-44f2-b22c-5e76362b674e" />

<img width="1697" height="967" alt="image" src="https://github.com/user-attachments/assets/5e3e9ff3-3bec-412d-81e5-5cb58023891f" />

<img width="1917" height="966" alt="image" src="https://github.com/user-attachments/assets/347ed00d-a22e-492d-b34a-b436b1666de6" />

<img width="1917" height="982" alt="image" src="https://github.com/user-attachments/assets/f27e0a5e-fe3a-4a21-bfdd-c68dc9f1983e" />

<img width="1902" height="977" alt="image" src="https://github.com/user-attachments/assets/4b445fc6-2219-4beb-ba9c-93e42a0f72ea" />

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
