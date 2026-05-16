# Day 37 – Docker Revision & Cheat Sheet

## Goal
Take a **one-day pause** to consolidate everything from Days 29–36 so Docker actually sticks.

## Expected Output
- A markdown file: `docker-cheatsheet.md`
- A markdown file: `day-37-revision.md` with self-check answers

---

## Self-Assessment Checklist
Mark yourself honestly — **can do**, **shaky**, or **haven't done**:

- [ ] Run a container from Docker Hub (interactive + detached)                  -->can do
- [ ] List, stop, remove containers and images                                  -->can do
- [ ] Explain image layers and how caching works                                -->shaky
- [ ] Write a Dockerfile from scratch with FROM, RUN, COPY, WORKDIR, CMD        -->shaky
- [ ] Explain CMD vs ENTRYPOINT                                                 -->shaky
- [ ] Build and tag a custom image                                              -->can do
- [ ] Create and use named volumes                                              -->can do
- [ ] Use bind mounts                                                           -->can do
- [ ] Create custom networks and connect containers                             -->can do
- [ ] Write a docker-compose.yml for a multi-container app                      -->can do
- [ ] Use environment variables and .env files in Compose                       -->can do
- [ ] Write a multi-stage Dockerfile                                            -->can do
- [ ] Push an image to Docker Hub                                               -->can do
- [ ] Use healthchecks and depends_on                                           -->can do

---

## Quick-Fire Questions
Answer from memory, then verify:

**1. What is the difference between an image and a container?**

-->**Docker image:** is a read-only template with instructions for creating a container, Docker image state is Static and inactive;
   a snapshot of a file system, Docker image cant be chnage once built, Docker image Built from a Dockerfile using docker build . And Stored in registries
   like Docker Hub for sharing. 

-->**Docker container:** is the A runnable instance of an image, State of the docker image is Dynamic and active; a running process in memory, docker 
container is Mutable: Has a writable layer for temporary runtime changes, Docker container Created from an image using docker run or docker create, 
docker container Exists in the local system's RAM/runtime while active.

**2. What happens to data inside a container when you remove it?**

-->When we remove (or delete) a container using **docker rm**, all data written inside that container's filesystem during its lifetime is permanently lost.

-->Containers are designed to be ephemeral (temporary) and stateless. This means that while you can stop and restart a container without losing data, removing 
it destroys the thin "writable layer" on top of the image where all new files, modifications, or database entries were stored. 

-->**What Data is Lost:** Files created at runtime, Database records, Logs and temporary files etc.

-->**What Data is Preserved:** Data in Volumes, Bind Mounts, Images etc.


**3. How do two containers on the same custom network communicate?**

-->Two containers on the **same custom Docker network** communicate directly using built-in DNS resolution. They can reach each other via their container name 
or network alias, removing the need for IP addresses. This mechanism works because Docker’s user-defined bridge networks automatically provide automatic 
service discovery for containers connected to that network. 

**4. What does `docker compose down -v` do differently from `docker compose down`?**

-->**docker compose down:** The docker-compose down command is used to stop and remove the containers created by docker-compose up . It's a way to clean up and 
stop the services defined in the docker-compose. yml file.

-->**docker compose down -v:** whereas if we add **-v** in docker compose down -v command we can delete the volume as well to free up the space, Basically 
we can delete the data which we dont want anymore

**5. Why are multi-stage builds useful?**

-->Multi-stage builds in Docker are used to significantly reduce final image size, improve security, and enhance efficiency by separating the build-time 
environment from the runtime environment. They allow developers to use large images containing SDKs/tools for building code, then copy only the necessary, 
compiled artifacts into a minimal final image, leaving behind build tools and intermediate files.

**6. What is the difference between `COPY` and `ADD`?**

-->**COPY:** Only supports copying local files and directories from the build context (host machine) to the container.

-->**ADD:** Supports all COPY features, plus downloading files from remote URLs and unpacking compressed tar files (gzip, bzip2, xz) automatically.

-->COPY and ADD both add files to a Docker image, but COPY is the best-practice for simple local file copying from local machine to container as it is 
more transparent and predictable.

-->Use ADD only when you specifically need to auto-extract local .tar.gz files into a container.

**7. What does `-p 8080:80` mean?**
--> **-p 8080:80** means, **Here 8080 is the host port and 80 is the container port** and by using -p we can map the host port woth container port OR we can say 
Take traffic coming to localhost:8080 on my machine and forward it to port 80 inside the container.

**8. How do you check how much disk space Docker is using?**

--> By using command **docker system df** we can check how much disk space Docker is using, It shows Images, Containers, Volumes, Build cache, Along with Total size
How much is actively used, How much can be reclaimed, And if you want more detail view in that case we can use command: **docker system df -v** This shows
Individual image sizes, Container sizes, Volume usage.

-->**Note:** If disk is getting full, you can clean unused stuff by using command **docker system prune** OR more aggressively we can use **docker system prune -a**  
but Be careful — this deletes unused containers, images, networks.

-->**Check usage →** docker system df, **Detailed view →** docker system df -v, **Clean space →** docker system prune

---

## Build Your Docker Cheat Sheet
Create `docker-cheatsheet.md` organized by category:
- **Container commands** — run, ps, stop, rm, exec, logs
- **Image commands** — build, pull, push, tag, ls, rm
- **Volume commands** — create, ls, inspect, rm
- **Network commands** — create, ls, inspect, connect
- **Compose commands** — up, down, ps, logs, build
- **Cleanup commands** — prune, system df
- **Dockerfile instructions** — FROM, RUN, COPY, WORKDIR, EXPOSE, CMD, ENTRYPOINT

Keep it short — one line per command, something you'd actually reference on the job.

---

## Revisit Weak Spots
Pick **2 topics** you marked as shaky and redo the hands-on tasks from that day.

---

## Suggested Flow (45–60 minutes)
- 10 min: go through the checklist honestly
- 10 min: answer quick-fire questions
- 20 min: build your cheat sheet
- 10 min: redo one weak area

---

## Submission
1. Add `docker-cheatsheet.md` and `day-37-revision.md` to `2026/day-37/`
2. Commit and push to your fork

---

## Learn in Public
Share your Docker cheat sheet on LinkedIn — help others revise too.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
