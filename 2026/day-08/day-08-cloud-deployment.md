# Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

## Task
Today's goal is to **deploy a real web server on the cloud** and learn practical server management.

You will:
- Launch a cloud instance (AWS EC2 or Utho)
- Connect via SSH
- Install Nginx
- Configure security groups for web access (port 80 by default for nginx)
- Extract and save logs to a file
- Verify your webpage is accessible from the internet

This is real DevOps work - exactly what you'll do in production.

---

## Expected Output
By the end of today, you should have:

1. A markdown file named: `day-08-cloud-deployment.md`
2. Screenshots showing:
   - SSH connection to your server
   - Nginx welcome page accessible from browser
   - Log file contents
3. The log file: `nginx-logs.txt`

---

## Prerequisites
- AWS account (Free Tier) OR Utho account
- Basic understanding of Linux commands (Days 1-7)
- SSH client (Terminal on Mac/Linux, PuTTY on Windows)

---

## Guidelines

### Part 1: Launch Cloud Instance & SSH Access (15 minutes)

**Step 1: Create a Cloud Instance**

Commands used:

-->mkdir -p ~/.ssh

-->cd /mnt/c/Users/sonaa/Downloads/

-->find . -iname "day08kp.pem"

-->chmod 400 "day08kp.pem" [Permissions wasnt chnage here so used below commands]

-->cp /mnt/c/Users/sonaa/Downloads/day08kp.pem ~/.ssh/

-->chmod 400 ~/.ssh/day08kp.pem

-->ls -l ~/.ssh/day08kp.pem

-->find . -iname "day08kp.pem"

-->pwd

-->ls -la

-->stat ~/.ssh/day08kp.pem

-->cd .ssh/

-->ssh -i "day08kp.pem" ubuntu@ec2-98-89-28-135.compute-1.amazonaws.com

**Step 2: Connect via SSH**

<img width="1917" height="917" alt="image" src="https://github.com/user-attachments/assets/c6a5cce1-b06b-475e-a366-ec0e5d7073fa" />

<img width="1775" height="941" alt="image" src="https://github.com/user-attachments/assets/9e0b5fb3-dcb7-4349-a565-8b397b7e484d" />

---

### Part 2: Install Docker & Nginx (20 minutes)

**Step 1: Update System** -->sudo apt update

**Step 3: Install Nginx** -->sudo apt install nginx -y

**Verify Nginx is running:** -->nginx -version

<img width="1882" height="852" alt="image" src="https://github.com/user-attachments/assets/c3822212-3e79-42ba-a85c-f4f5b01ab39e" />

<img width="1836" height="907" alt="image" src="https://github.com/user-attachments/assets/b8666ca5-3e1f-4885-8622-264cca7c5b17" />

<img width="1767" height="972" alt="image" src="https://github.com/user-attachments/assets/4f5fb61e-d749-4427-b0d9-618e47bc4b4c" />

<img width="1681" height="72" alt="image" src="https://github.com/user-attachments/assets/384e2097-7ac4-4a0a-90eb-d96ccec4e8d8" />

---

### Part 3: Security Group Configuration (10 minutes)

**Test Web Access:**
Open browser and visit: `http://<your-instance-ip>`

You should see the **Nginx welcome page**!

📸 **Screenshot this page** - you'll need it for submission

<img width="1902" height="752" alt="image" src="https://github.com/user-attachments/assets/9b06e614-33f3-45b4-8152-9fedacf3799a" />

---

### Part 4: Extract Nginx Logs (15 minutes)

**Step 1: View Nginx Logs**

**Step 2: Save Logs to File**

<img width="1911" height="520" alt="image" src="https://github.com/user-attachments/assets/f01514c3-5c75-4155-b736-ead2337b9cfe" />

**Step 3: Download Log File to Your Local Machine**
```bash
# On your local machine (new terminal window)
# For AWS:
scp -i your-key.pem ubuntu@<your-instance-ip>:~/nginx-logs.txt .

# For Utho:
scp root@<your-instance-ip>:~/nginx-logs.txt .
```

Commands used:

-->sudo cat /var/log/nginx/access.log

-->sudo cp /var/log/nginx/access.log ~/nginx-logs.txt

-->sudo cat /var/log/nginx/access.log > ~/nginx-logs.txt

-->ls -l ~/nginx-logs.txt

-->sudo chown ubuntu:ubuntu ~/nginx-logs.txt

-->ls -l ~/nginx-logs.txt

-->exit

-->scp -i ~/.ssh/day08kp.pem ubuntu@ec2-98-89-28-135.compute-1.amazonaws.com:~/nginx-logs.txt .

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/86c00286-b172-4e81-ab38-c6263f868f75" />

---


## Documentation Template

Create your `day-08-cloud-deployment.md` with this structure:

## Commands Used
[List the key commands you used]

# Connect to EC2
ssh -i ~/.ssh/day08kp.pem ubuntu@<public-dns>

# Install Nginx
sudo apt update
sudo apt install nginx -y

# Manage Nginx
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl reload nginx

# View Logs
sudo cat /var/log/nginx/access.log
sudo cat /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Save Logs
sudo cat /var/log/nginx/access.log > ~/nginx-logs.txt

# Download Logs
scp -i ~/.ssh/day08kp.pem ubuntu@<public-dns>:~/nginx-logs.txt .

# Exit
exit

## Challenges Faced
[Describe any issues and how you solved them]

- Faced SSH authentication issues because the .pem key was stored on the Windows-mounted drive (/mnt/c), where Linux file permissions (chmod 400) were not applied correctly. Solved it by moving the key to ~/.ssh in WSL and setting the correct permissions.
- Encountered difficulty copying Nginx logs from the EC2 instance using scp due to file permission issues. Fixed it by creating the log file in the ubuntu user's home directory and ensuring the file had the correct ownership and read permissions.
- Initially couldn't access the Nginx web page because the required HTTP port was not open. Resolved it by allowing inbound traffic on port 80 in the EC2 Security Group.
- Verified the Nginx service status and restarted the service whenever configuration changes were made to ensure the web server was running correctly.

## What I Learned
[3-5 bullet points of key learnings]

- Learned how to launch an AWS EC2 instance and connect to it securely using SSH with a PEM key.
- Learned how to install, start, enable, and manage the Nginx web server using systemctl.
- Learned how to view, monitor, and extract Nginx access and error logs from a Linux server.
- Learned how to securely transfer files from a remote EC2 instance to a local machine using the scp command.
- Understood the importance of Linux file permissions and AWS Security Groups in enabling secure server access.

---


## Why This Matters for DevOps

This exercise teaches you:
- **Cloud infrastructure provisioning** - launching and configuring servers
- **Remote server management** - SSH, security, access control
- **Service deployment** - installing and running applications
- **Log management** - accessing and analyzing logs
- **Security** - configuring firewalls and security groups

These are core skills for any DevOps engineer working in production.

---


## Submission
1. Fork this `90DaysOfDevOps` repository
2. Navigate to the `2026/day-08/` folder
3. Add your `day-08-cloud-deployment.md` file
4. Add your `nginx-logs.txt` file
5. Add screenshots (name them: `ssh-connection.png`, `nginx-webpage.png`, `docker-nginx.png`)
6. Commit and push your changes to your fork

---

## Learn in Public
Share your Day 08 progress on LinkedIn:

- Post 2-3 lines on deploying your first cloud server
- Share screenshot of your Nginx webpage
- Mention one challenge you faced and solved
- Optional: Share your instance IP (if comfortable)

Use hashtags:
```
#90DaysOfDevOps
#DevOpsKaJosh
#TrainWithShubham
```

Happy Learning
**TrainWithShubham**
