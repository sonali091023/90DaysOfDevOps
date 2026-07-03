# 📝 To-Do List App with Nginx Reverse Proxy using Docker Compose

A simple multi-container application that demonstrates how to serve a **static frontend** through **Nginx** while forwarding API requests to a **Node.js backend** using **Docker Compose**.

This project helps you understand:

* Dockerfile
* Docker Compose
* Multi-container applications
* Nginx Reverse Proxy
* Docker networking
* Health Checks
* Container dependencies

---

# 📂 Project Structure

```text
to-do-list-app/
├── backend
│   ├── Dockerfile
│   ├── app.js
│   └── package.json
├── docker-compose.yml
├── frontend
│   └── index.html
└── nginx
    └── default.conf
```

---

# 🛠️ Tech Stack

* Node.js
* Express.js
* HTML
* Nginx
* Docker
* Docker Compose

---

# 🏗️ Project Architecture

The application consists of three main components.

## 🖥️ Frontend

The frontend is a static web page served by Nginx.

### Files

```text
frontend/
└── index.html
```

### Responsibilities

* Displays the To-Do List user interface.
* Sends requests to the backend API.
* Served directly by the Nginx container.

---

## ⚙️ Backend

The backend is built using **Node.js** and **Express.js**.

### Files

```text
backend/
├── Dockerfile
├── app.js
└── package.json
```

### Responsibilities

* Runs the Express server.
* Processes API requests.
* Returns responses to the frontend.
* Runs on **port 3000** inside the Docker network.

---

## 🌐 Reverse Proxy (Nginx)

Nginx serves the frontend and forwards API requests to the backend.

### Files

```text
nginx/
└── default.conf
```

### Responsibilities

* Serves static HTML files from the `frontend` directory.
* Listens on **port 80** inside the container.
* Exposes **port 8089** on the host.
* Proxies API requests to the backend container.

---

# 🔄 Application Flow

```text
                  Browser
                     │
                     ▼
          http://localhost:8089
                     │
                     ▼
               Nginx Container
          ┌──────────┴──────────┐
          │                     │
          ▼                     ▼
 Serve frontend/index.html   Forward API Requests
                                    │
                                    ▼
                           Node.js Backend
                                    │
                                    ▼
                              Send Response
```

---

# 🐳 Docker Compose Services

## Backend Service

The **backend** service:

* Builds the Docker image from the `backend` directory.
* Sets the environment variable:

```text
NODE_ENV=production
```

* Restarts automatically if the container stops.
* Includes a health check to verify the application is responding on **port 3000**.

### Health Check

```yaml
healthcheck:
  test: ["CMD", "node", "-e", "require('http').get('http://localhost:3000', res => process.exit(res.statusCode === 200 ? 0 : 1))"]
  interval: 30s
  timeout: 10s
  retries: 3
```

The backend is considered **healthy** only when it responds with an HTTP **200 OK** status.

---

## Nginx Service

The **nginx** service:

* Uses the official `nginx:alpine` image.
* Maps:

```text
Host Port      Container Port
8089     --->       80
```

* Mounts the frontend directory:

```text
./frontend
```

* Loads the custom Nginx configuration:

```text
./nginx/default.conf
```

* Waits until the backend passes its health check before starting.

---

# ❤️ Health Check

Docker continuously checks whether the backend application is running correctly.

If the backend becomes unhealthy:

* Docker marks the container as **unhealthy**.
* Nginx starts only after the backend is healthy.
* Combined with `restart: always`, this improves application reliability.

---

# ▶️ Running the Project

Build and start the containers:

```bash
docker compose up --build
```

Run in detached mode:

```bash
docker compose up -d --build
```

---

# 🌐 Access the Application

Open your browser:

```text
http://localhost:8089
```

The request flow is:

```text
Browser
   │
   ▼
Nginx
   │
   ├── Serves index.html
   │
   └── Forwards API requests
             │
             ▼
      Node.js Backend
```

---

# 📋 Useful Docker Commands

### View running containers

```bash
docker ps
```

### View logs

```bash
docker compose logs
```

### Follow logs

```bash
docker compose logs -f
```

### View backend logs only

```bash
docker compose logs backend
```

### Enter the backend container

```bash
docker exec -it backend sh
```

### Enter the Nginx container

```bash
docker exec -it nginx sh
```

### Stop the project

```bash
docker compose down
```

### Restart the project

```bash
docker compose up --build
```

---

# 🧹 Cleanup

Stop and remove all containers:

```bash
docker compose down
```

Remove unused Docker resources:

```bash
docker system prune -a
```

> **Note:** `docker system prune -a` removes all unused containers, images, networks, and build cache. Use it carefully.

---

# 📚 Key Docker Concepts Demonstrated

* Building custom Docker images
* Multi-container applications
* Docker Compose
* Nginx Reverse Proxy
* Static website hosting
* Docker networking
* Health checks
* Automatic container restart
* Service dependency management using `depends_on`
* Environment variables

---

# 🎯 Learning Outcomes

After completing this project, you will understand how to:

* Build a custom Node.js Docker image.
* Serve a static frontend with Nginx.
* Reverse proxy API requests to a backend container.
* Configure Docker health checks.
* Use `depends_on` with service health conditions.
* Manage multi-container applications using Docker Compose.
* Build a simple production-style application architecture.

---
