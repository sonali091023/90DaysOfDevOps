Task 1
FROM ubuntu

RUN apt update && apt install nginx -y

RUN echo "Hello from my custom image!"

CMD ["echo", "Container is running"]

#==================================================================================================

task 2
#Uses lightweight nginx base image
FROM nginx:alpine

#Sets working directory inside container, This is where nginx serves files from
WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

#Copies your file into container, Here . means current WORKDIR
COPY webpage.html index.html

#Runs during build time, Creates a layer (for learning/demo)
RUN echo "NGINX image built successfully!"

#Documents that container uses port 80, Helps others understand usage
EXPOSE 80

#Starts nginx in foreground, Keeps container running
CMD ["nginx", "-g", "daemon off;"]

#=====================================================================================================
task 3 
FROM alpine

CMD ["echo", "hello"]
--------------------------------------------------
FROM alpine

ENTRYPOINT ["echo"]

#======================================================================================================

task 4
FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY index.html .

RUN echo "Launch the website"

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

#==========================================================================================================
task 5

FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY . .

RUN echo "Ignores unnecessary files"

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
