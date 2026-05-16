**Note:**

-->Docker Compose = run multi-container apps with one command

-->No need to manually create networks/volumes (Compose handles it)

**Container commands:**

-->**run:** Creates and starts a new container from an image.

-->**ps:** Shows list of running containers.

-->**stop:** Stops a running container safely/gracefully.

-->**rm:** Removes (deletes) a stopped container permanently.

-->**exec:** To go inside container OR we can say Runs a command inside a running container. 

-->**logs:** Shows logs (output) of a container, We can see what container is doing.

**Image commands:** 

-->**build:** Builds an image from a Dockerfile.

-->**pull:** Downloads an image from a registry (like Docker Hub).

-->**push:** Uploads your image to a registry.

-->**tag:** Adds a new tag (name/version) to an image OR we can say rename or version your image

-->**ls:** **docker images (or docker image ls)**: Lists all images on your system.

-->**rm:** Removes (deletes) an image.

**Volume commands**

-->**docker volume create <volume name>:** Creates a new volume to store persistent data OR we can say create storage outside container.

-->**docker volume ls:** Lists all available volumes.

-->**docker volume inspect:** Shows detailed info about a volume (like mount path).

-->**docker volume rm:** Deletes a volume. 

**Network commands** 

-->**docker network create <network name>:** Creates a custom network[Which will be private] so containers can communicate.

-->**docker network ls:** Lists all Docker networks such as bridge, custom, host none etc 

-->**docker network inspect <network name>:** Shows detailed info about a network.

-->**docker network connect <network name> <container name>:** Connects a running container to a network.

**Compose commands**

-->**docker-compose up:** Starts all services defined in docker-compose.yml

-->**docker-compose down:** Stops and removes containers, networks (and optionally volumes if we run command: docker compose down -v).

-->**docker-compose ps:** Shows status of services (containers).

-->**logs:** Shows logs of all services [To see live logs we can use command: docker compose logs -f]

-->**build:** Builds images defined in compose file [If want to build image without cache use command: docker compose build --no-cache]

**Cleanup commands**

-->**prune:** Docker doesn’t have just docker prune alone—you use it with resources:

-->**docker system prune** Removes unused data: Stopped containers, Unused networks, Dangling images, Build cache

-->**docker system prune -f:** Force (no prompt)

-->**docker image prune** Removes unused images [Removes unused images -a: to remove all unused images]

-->**docker volume prune** Removes unused volumes

-->**docker network prune** Removes unused networks

-->**docker system df:** Shows disk usage by Docker, Output shows:Images size, Containers size, Volumes size, Cache usage [docker system df -v]

**Dockerfile instructions**

-->**FROM:** Sets the base image for your container, Every Dockerfile must start with FROM its starting point (OS + runtime)

-->**RUN:** Executes commands during image build, Used to Installing packages, Setting up environment

-->**COPY:** Copies files from your system → container, [COPY . . = First . = local folder, Second . = container folder] used to bring project into container.

-->**WORKDIR:** Sets the working directory inside container, [WORKDIR /app: All next commands run inside /app]

-->**EXPOSE:** Documents which port the container uses, It Does NOT actually open port (just info) and Real mapping happens with -p, Its more like tell Docker which port app uses

-->**CMD:** Defines the default command to run container, Can be overridden at runtime

-->**ENTRYPOINT:** Defines the main command (fixed: hard to override) for container, main command that always runs

**Simple Flow (example Dockerfile)**

FROM node:20-alpine

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 3000

CMD ["node", "app.js"]

Keep it short — one line per command, something you'd actually reference on the job.
