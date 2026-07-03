# Day 36 – Docker Project: Dockerize a Full Application

## Task
Today's goal is to **take a real application and Dockerize it end-to-end**.

No tutorials. No hand-holding. Pick an app, write the Dockerfile, set up Compose, and ship it. This is what you'll do on the job.

---

## Expected Output
- A markdown file: `day-36-docker-project.md`
- Complete project with Dockerfile, docker-compose.yml, and app code
- Image pushed to Docker Hub

---

## Challenge Tasks

### Task 1: Pick Your App
Choose **one** of these (or use your own project):
- A **Python Flask/Django** app with a database
- A **Node.js Express** app with MongoDB
- A **static website** served by Nginx with a backend API
- Any app from your GitHub that doesn't have Docker yet

If you don't have an app, clone a simple open-source one and Dockerize it.

**Steps to follow:**

<img width="722" height="600" alt="image" src="https://github.com/user-attachments/assets/bd920a1f-0c59-495a-b04d-6a1dfbfd27e2" />

<img width="780" height="812" alt="image" src="https://github.com/user-attachments/assets/9b84f178-49db-4d94-8cd2-3ad01f999347" />

[to-do-list-app](https://github.com/sonali091023/90DaysOfDevOps/tree/master/2026/day-36/to-do-list-app)

---

### Task 2: Write the Dockerfile
1. Create a Dockerfile for your application
2. Use a **multi-stage build** if applicable
3. Use a **non-root user**
4. Keep the image **small** — use alpine or slim base images
5. Add a `.dockerignore` file

Build and test it locally.

**Steps to follow:**

<img width="735" height="512" alt="image" src="https://github.com/user-attachments/assets/1d790164-3ce0-4e30-b741-bd53790bbe42" />

<img width="700" height="522" alt="image" src="https://github.com/user-attachments/assets/b6220825-1b3f-485d-b67d-0aecc5867446" />

<img width="695" height="397" alt="image" src="https://github.com/user-attachments/assets/66239be9-f081-409f-8d05-0b3b70d3bce7" />

<img width="747" height="772" alt="image" src="https://github.com/user-attachments/assets/8dd9b575-9638-444c-830f-5f604e250749" />

<img width="711" height="410" alt="image" src="https://github.com/user-attachments/assets/e43d16aa-7197-449f-bf18-14f2c1c14405" />

<img width="747" height="537" alt="image" src="https://github.com/user-attachments/assets/efb7a03c-947c-4713-a44c-4809aa54852a" />

[multi-stage-dockerfile](https://github.com/sonali091023/90DaysOfDevOps/tree/master/2026/day-36/multi-stage-dockerfile)

---

### Task 3: Add Docker Compose
Write a `docker-compose.yml` that includes:
1. Your **app** service (built from Dockerfile)
2. A **database** service (Postgres, MySQL, MongoDB — whatever your app needs)
3. **Volumes** for database persistence
4. A **custom network**
5. **Environment variables** for configuration (use `.env` file)
6. **Healthchecks** on the database

Run `docker compose up` and verify everything works together.

**Steps to follow:**

-->Create docker-compose file and then also create .env file

<img width="755" height="371" alt="image" src="https://github.com/user-attachments/assets/6d09b695-1cd6-44c5-9645-ea3fb654e845" />

<img width="697" height="651" alt="image" src="https://github.com/user-attachments/assets/d082d04b-18ff-421b-8858-fc54c255ef72" />

<img width="731" height="731" alt="image" src="https://github.com/user-attachments/assets/cffe0b45-faf0-4158-89c6-6b5e00b48d1e" />

<img width="697" height="807" alt="image" src="https://github.com/user-attachments/assets/8d991460-1288-4fd2-a00d-19a0380eae37" />

<img width="1907" height="922" alt="image" src="https://github.com/user-attachments/assets/310168b0-01f9-4281-9d74-8d77450b2595" />

[nginx-backend-api](https://github.com/sonali091023/90DaysOfDevOps/tree/master/2026/day-36/nginx-backend-api)

---

### Task 4: Ship It
1. Tag your app image
2. Push it to Docker Hub
3. Share the Docker Hub link
4. Write a `README.md` in your project with:
   - What the app does
   - How to run it with Docker Compose
   - Any environment variables needed
  
**Steps to follow:**

-->Step 1: Log in to Docker Hub: docker login -u <username> [Enter your Docker Hub username and password (or access token).]

-->Step 2: Check Your Images: docker images  [If you built using Docker Compose, the image name is often based on the project directory, for example: nginx-backend-api-app]

-->Step 3: Tag the Image: docker tag nginx-backend-api-app:latest sonali0910/nginx-backend-api:v1

-->Then verify docker images: docker images

-->Step 4: Push to Docker Hub: docker push sonali0910/nginx-backend-api:v1

-->Step 5: Share Docker Hub Link: [nginx-backend-api:v1](https://hub.docker.com/repository/docker/sonali0910/nginx-backend-api-app/general)

<img width="1917" height="752" alt="image" src="https://github.com/user-attachments/assets/74c9de9d-2845-46f6-8a2e-881b88ef4a6b" />

---

### Task 5: Test the Whole Flow
1. Remove all local images and containers
2. Pull from Docker Hub and run using only your compose file
3. Does it work fresh? If not — fix it until it does

**Steps to follow:**

-->Yes. Task 5 is meant to verify that your project is reproducible on a clean machine. The idea is to ensure that anyone can clone your project, 
pull your image from Docker Hub, and run it successfully without relying on anything left on your computer.

-->Step 1: Stop and Remove Existing Containers: docker-compose down -v [This removes: Containers, Networks & Volumes created by Compose]

-->Step 2: Remove Local Images: docker images

-->Remove your project image(s): docker rmi <img-name> OR Or remove all unused images: docker image prune -a

**Note:** docker image prune -a removes all unused images, so don't use it if you still need other images.

Step 3: Verify Everything is Gone: docker ps -a

-->Also check images: docker images

Step 4: Modify docker-compose.yml to Use Docker Hub Image:

<img width="777" height="611" alt="image" src="https://github.com/user-attachments/assets/5b1f9511-a063-45f5-9fa7-aedc17988baa" />

-->Step 5: Pull the Image: docker-compose pull OR docker pull <img-name>

-->Then Step 6: Start the Application: docker-compose up -d

-->Step 7: Verify Everything: docker ps

-->docker images

Step 8: Test the Application: 

Open: Nginx: http://localhost:8080 Also Node.js: http://localhost:3001 [If both load successfully, your deployment works from a clean environment.]

<img width="827" height="777" alt="image" src="https://github.com/user-attachments/assets/1e28f4ee-8abe-451a-9f0b-37b140ab60d7" />

<img width="1917" height="980" alt="image" src="https://github.com/user-attachments/assets/c507e125-411a-4590-b1d4-455d73b53078" />

<img width="1912" height="942" alt="image" src="https://github.com/user-attachments/assets/3634a02d-fd0b-43e9-8b9f-af87866d11bc" />

<img width="1917" height="642" alt="image" src="https://github.com/user-attachments/assets/fe0938e9-371b-461d-8b21-93de0bb30eaf" />

---

## Documentation
Create `day-36-docker-project.md` with:
- What app you chose and why
- Your Dockerfile (with comments explaining each line)
- Challenges you faced and how you solved them
- Final image size
- Docker Hub link

---

## Submission
1. Add all project files and `day-36-docker-project.md` to `2026/day-36/`
2. Commit and push to your fork

---

## Learn in Public
Share your Dockerized project on LinkedIn — include the Docker Hub link so others can pull and run it.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
