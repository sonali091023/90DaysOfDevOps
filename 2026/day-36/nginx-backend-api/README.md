# 🚀 Nginx Reverse Proxy with Node.js Backend using Docker Compose

A simple Docker project demonstrating how to run a **Node.js + Express** application behind an **Nginx Reverse Proxy** using **Docker** and **Docker Compose**.

This project is ideal for learning:

* Dockerfile creation
* Docker Compose
* Multi-container applications
* Nginx Reverse Proxy
* Bind mounts (Live Reload)
* Docker networking

---

# 📂 Project Structure

```text
nginx-backend-api/
├── Dockerfile
├── docker-compose.yml
├── app
│   ├── node_modules
│   ├── nodemon.json
│   ├── package.json
│   ├── public
│   │   └── index.html
│   └── server.js
└── nginx
    └── default.conf
```

---

# 🛠️ Tech Stack

* Node.js 20 (Alpine)
* Express.js
* Nginx
* Docker
* Docker Compose

---

# 🏗️ Project Architecture

This project consists of four major components.

## 🖥️ Frontend

The frontend is a simple static web page displayed in the user's browser.

### Files

```text
app/public/index.html
```

### Responsibilities

* Displays the user interface.
* Sends requests to the backend when required.
* In this project, the frontend is a static HTML page.

---

## ⚙️ Backend

The backend is built using **Node.js** and **Express.js**.

### Files

```text
app/server.js
app/package.json
app/nodemon.json
app/node_modules/
```

### Responsibilities

* Starts the Express server.
* Serves the frontend files.
* Handles API requests.
* Returns responses to clients.
* Runs on **Port 3000**.

---

## 🌐 Reverse Proxy (Nginx)

Nginx acts as the entry point for incoming requests.

### Files

```text
nginx/default.conf
```

### Responsibilities

* Listens on **Port 8080**.
* Receives requests from the browser.
* Forwards requests to the Node.js backend running on **Port 3000**.
* Improves scalability by separating web server responsibilities from the application server.

---

## 🐳 Docker & Docker Compose

Docker containerizes the application, while Docker Compose manages multiple containers.

### Files

```text
Dockerfile
docker-compose.yml
```

### Responsibilities

* Builds the Node.js image.
* Creates and starts both containers.
* Automatically connects the containers using a Docker network.
* Enables live development using bind mounts.

---

# 🔄 Application Flow

```text
                Browser
                   │
                   ▼
        http://localhost:8080
                   │
                   ▼
        Nginx Reverse Proxy
                   │
                   ▼
     Node.js + Express Backend
                   │
          ┌────────┴────────┐
          ▼                 ▼
   Serve index.html      Handle API
          │                 │
          └────────┬────────┘
                   ▼
             Send Response
```

---

# 📌 Component Summary

| Component        | Technology                 | Purpose                                        |
| ---------------- | -------------------------- | ---------------------------------------------- |
| Frontend         | HTML (`public/index.html`) | Displays the user interface                    |
| Backend          | Node.js + Express          | Serves frontend files and handles API requests |
| Reverse Proxy    | Nginx                      | Forwards browser requests to the backend       |
| Containerization | Docker                     | Packages the application into containers       |
| Orchestration    | Docker Compose             | Runs and manages multiple containers           |

---

# 📦 Dockerfile Explanation

The Dockerfile performs the following steps:

1. Uses the official **Node.js 20 Alpine** image.
2. Sets the working directory to `/app`.
3. Copies `package.json` files.
4. Installs project dependencies using `npm install`.
5. Copies the application source code.
6. Exposes **Port 3000**.
7. Starts the application using:

```bash
npm run dev
```

---

# 🐳 Docker Compose Services

## App Service

The **app** service:

* Builds the Docker image using the local Dockerfile.
* Runs the Node.js application.
* Maps **Port 3000**.
* Uses bind mounts for live code reloading.

```yaml
volumes:
  - ./app:/app
  - /app/node_modules
```

---

## Nginx Service

The **nginx** service:

* Uses the official `nginx:alpine` image.
* Maps **Port 8080** to container port **80**.
* Loads the custom Nginx configuration.
* Depends on the Node.js application container.

---

# ▶️ Running the Project

## Build and Start

```bash
docker compose up --build
```

Run in detached mode:

```bash
docker compose up -d --build
```

---

# 🌐 Access the Application

### Through Nginx

```
http://localhost:8080
```

### Directly to the Node.js Application

```
http://localhost:3000
```

---

# 🔄 Live Reload

The project uses a bind mount:

```yaml
volumes:
  - ./app:/app
```

Benefits:

* No need to rebuild the image after every code change.
* Source code changes are immediately reflected inside the container.
* Perfect for local development.

---

# 📋 Useful Docker Commands

## View Running Containers

```bash
docker ps
```

## View Logs

```bash
docker compose logs
```

Follow logs in real time:

```bash
docker compose logs -f
```

## Enter the Node.js Container

```bash
docker exec -it node_app sh
```

## Enter the Nginx Container

```bash
docker exec -it nginx_proxy sh
```

## Stop Containers

```bash
docker compose down
```

## Rebuild Containers

```bash
docker compose up --build
```

---

# 🧹 Cleanup

Stop and remove containers:

```bash
docker compose down
```

Remove unused Docker resources:

```bash
docker system prune -a
```

> **Note:** `docker system prune -a` removes unused containers, images, networks, and build cache. Use it carefully.

---

# 🎯 Learning Outcomes

After completing this project, you will understand how to:

* Build a custom Docker image for a Node.js application.
* Create and manage multi-container applications with Docker Compose.
* Configure Nginx as a reverse proxy.
* Enable live reloading using bind mounts.
* Understand Docker networking and inter-container communication.
* Separate frontend, backend, and reverse proxy responsibilities.
* Deploy a simple production-like application architecture using Docker.

---

# 👨‍💻 Author

**Sonali**

This project is part of the **90 Days of DevOps** learning journey.

