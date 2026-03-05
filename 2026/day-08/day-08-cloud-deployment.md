**Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment**

**Launch a cloud instance (AWS EC2 )**

<img width="1911" height="792" alt="instance-created" src="https://github.com/user-attachments/assets/38eab6dc-8f45-4c65-8824-4538c23f12cb" />

**Connect via ssh**

<img width="1360" height="747" alt="connect-with-inst" src="https://github.com/user-attachments/assets/1fd24c57-b726-4c57-8d6b-4bfc1793d13e" />

**Install Nginx**

<img width="1542" height="958" alt="nginx installed" src="https://github.com/user-attachments/assets/95815956-c716-4800-9254-c21a443a305b" />

**Install Docker**

<img width="1698" height="883" alt="Dockerinstalled" src="https://github.com/user-attachments/assets/1fdc0716-d246-4685-93eb-0630753120b7" />

**Verify Nginx and Docker is running**

<img width="1512" height="716" alt="docker and nginx status" src="https://github.com/user-attachments/assets/55a60e74-8179-4f34-9182-0b2b2d928b82" />

**Test Web Access to Nginx**

<img width="1913" height="961" alt="nginx-webpage-launched" src="https://github.com/user-attachments/assets/3682b364-f6f2-46d7-a08e-93f604babae3" />

**View the Nginx Log**

<img width="1896" height="967" alt="image" src="https://github.com/user-attachments/assets/00def8a8-a4d7-4ae7-a6f4-db640d89a768" />

**Save Logs to File**

<img width="1907" height="902" alt="image" src="https://github.com/user-attachments/assets/2df253a5-766f-4d05-ba9e-e879b72c3980" />

**Download Log File to Your Local Machine**

<img width="911" height="335" alt="logfiledownload" src="https://github.com/user-attachments/assets/f2d14f0d-6e86-4fb4-9739-f8b8a16e02ad" />

**Commands used for the execution:**
--> sudo apt update

--> sudo apt install nginx -y

--> nginx -version

--> sudo apt install docker.io -y

--> docker --version

--> sudo systemctl status nginx

--> sudo systemctl start nginx

--> sudo systemctl enable nginx

--> sudo systemctl enable docker

--> sudo systemctl status docker

--> cat /var/log/nginx/access.log

--> cat /var/log/nginx/access.log | tee -a nginx-logs.txt

--> scp -i your-key.pem ubuntu@your instance pulic-ip:~/nginx-logs.txt .

--> sftp -i your-key.pem ubuntu@your instance pulic-ip 
    get nginx-logs.txt

**What I Learned**

How to install Docker

How to install NGINX

How to update Ubuntu system

How to check logs of NGINX

How to check service status, service logs

How to store logs of service to a file

How to download a file from ec2-instance to local using scp
