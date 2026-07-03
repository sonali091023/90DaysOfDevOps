Multi-Stage Dockerfile for a Node.js Application

This project demonstrates how to build a lightweight and secure Docker image for a Node.js application using a multi-stage Docker build.

Project Structure
.
├── Dockerfile
├── app.js
├── default.conf
├── package.json
└── public
    └── index.html

Tech Stack
Category	Technology
Language	JavaScript
Runtime	Node.js 20
Backend	Node.js
Frontend	HTML
Package Manager	npm
Containerization	Docker
Base Image	node:20-alpine
Web Server	Node.js HTTP Server

Features
Multi-stage Docker build
Lightweight node:20-alpine base image
Installs only production dependencies
Runs the application as a non-root user
Exposes port 3000
Optimized Docker image size
Dockerfile Stages
Stage 1 – Dependency Installation
Uses node:20-alpine
Sets /app as the working directory
Copies package.json
Installs only production dependencies:
npm install --omit=dev
Stage 2 – Final Image
Uses a fresh node:20-alpine image
Creates a non-root user (appuser)
Copies production dependencies from Stage 1
Copies application source code
Changes file ownership
Runs the application as a non-root user
Exposes port 3000
Build the Docker Image
docker build -t node-multistage .
Run the Container
docker run -d -p 3000:3000 --name node-app node-multistage
Verify the Application

Open your browser and visit:

http://localhost:3000

or use:

curl http://localhost:3000
View Running Containers
docker ps
View Logs
docker logs node-app
Stop the Container
docker stop node-app
Remove the Container
docker rm node-app
Remove the Image
docker rmi node-multistage
Technologies Used
Node.js 20
Docker
Alpine Linux
Multi-Stage Docker Builds
Learning Objectives

This project demonstrates:

Creating efficient Docker images
Using multi-stage builds
Installing only production dependencies
Running containers as a non-root user
Reducing Docker image size
Following Docker security best practices
