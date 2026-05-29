<img width="1877" height="308" alt="image" src="https://github.com/user-attachments/assets/249596d9-9a8d-4f00-8ab5-5df5e566f9c4" /># Day 68 -- Introduction to Ansible and Inventory Setup

## Task
Terraform provisions infrastructure. But who installs packages, configures services, manages users, and keeps servers in the desired state after they exist? That is the job of a configuration management tool, and Ansible is the industry standard.

Today you install Ansible, set up an inventory of servers, and run your first ad-hoc commands -- all without installing a single agent on the target machines. Ansible is agentless. SSH is all it needs.

---

## Expected Output
- Ansible installed on your control node
- 2-3 EC2 instances running as managed nodes
- A working inventory file with grouped hosts
- Successful ad-hoc commands run against remote servers
- A markdown file: `day-68-ansible-intro.md`

---

## Challenge Tasks

### Task 1: Understand Ansible
Research and write short notes on:

**1. What is configuration management? Why do we need it?**

-->Configuration management (CM) is the process of defining, organizing, maintaining, and automating the setup and state of systems, servers, applications, and infrastructure.

-->In DevOps and cloud environments, configuration management ensures that systems are: Consistent, Repeatable, Automated, Version-controlled etc.

-->Instead of manually configuring servers one by one, configuration management tools apply predefined configurations automatically.

**2. How is Ansible different from Chef, Puppet, and Salt?**
<img width="622" height="222" alt="image" src="https://github.com/user-attachments/assets/f2288fe5-5495-4824-b2e1-f0786ae3f874" />

**1. Ansible:** it works Control node connects to servers using SSH, Executes tasks remotely, No agent installation required.

-->**Ansible uses:** Configuration management, Application deployment, Server provisioning, Orchestration etc.

<img width="201" height="151" alt="image" src="https://github.com/user-attachments/assets/9e5aa277-0352-49fe-a4e0-20e50019e6cc" />

-->**Advantages:** Very easy to learn, Human-readable YAML, Agentless, Great for cloud + Kubernetes + CI/CD, Fast setup

-->**Disadvantages:** Slower at very large scale, SSH overhead, Less powerful event engine compared to Salt

**2. Chef:** it works: Uses Chef Server + Chef Client (agent)., Clients periodically pull configuration & Language uses Ruby DSL
<img width="156" height="72" alt="image" src="https://github.com/user-attachments/assets/c0018bde-7a10-4b00-ba7f-6046067d5cd4" />

-->**Advantages:** Extremely powerful, Strong for complex infrastructure logic, Good scalability

-->**Disadvantages:** Steep learning curve, Ruby knowledge helps, More setup complexity

**3. Puppet:** it works Puppet agents pull configs from Puppet Master & Language used Puppet DSL.
<img width="173" height="62" alt="image" src="https://github.com/user-attachments/assets/37c94d54-a0a3-4f96-ae54-8750e5eb543f" />

-->**Advantages:** Mature enterprise ecosystem, Strong compliance management, Good reporting capabilities

-->**Disadvantages:** Harder syntax than Ansible, Agent maintenance required, Slower onboarding

**4. Salt:** it works Salt Master communicates with Salt Minions. Supports remote execution + event-driven automation. & Language used YAML + Python

-->**Advantages:** Extremely fast, Real-time automation, Excellent at large-scale infrastructure, Strong event system

-->**Disadvantages:** More operational complexity, Less beginner-friendly than Ansible, Requires understanding Salt architecture

**Final Summary:**
<img width="668" height="253" alt="image" src="https://github.com/user-attachments/assets/243109ef-74e8-4772-b388-438da56b6ef7" />
   
**3. What does "agentless" mean? How does Ansible connect to managed nodes?**

-->In configuration management and automation, agentless means: You do not install a special background service (agent/client/minion) on the target machines.

-->With Ansible: No Ansible agent runs continuously on managed servers., The control node connects only when needed & Tasks are executed remotely and then the connection closes.

-->Ansible uses SSH (Secure Shell) & Connects to Managed Nodes, Here anisible Opens an SSH connection, Copies a small temporary module/script, Executes it remotely, Gets the result back, Removes temporary files etc.

-->In Ansible Agent is Needed Because: SSH already exists on most Linux servers, WinRM exists on Windows, Ansible reuses these standard protocols etc.

4. Draw or describe the Ansible architecture:
   - **Control Node** -- the machine where Ansible runs (your laptop or a jump server)
   - **Managed Nodes** -- the servers Ansible configures (your EC2 instances)
   - **Inventory** -- the list of managed nodes
   - **Modules** -- units of work Ansible executes (install a package, copy a file, start a service)
   - **Playbooks** -- YAML files that define what to do on which hosts
<img width="471" height="458" alt="image" src="https://github.com/user-attachments/assets/73809704-ebca-4474-9088-02bddc8e0342" />

**1. Control Node:** Ansible runs from the Control Node. This is: your laptop, a VM, a CI/CD server, or a jump/bastion server.

-->It contains: Ansible installation Inventory files, Playbooks, Roles, SSH keys etc. Eg: Laptop, Jenkins Server, Bastion Host

**2. Managed Nodes:** Managed nodes are the systems Ansible configures. Eg: EC2 instances, Linux VMs, Kubernetes worker nodes, Database servers etc.

-->They usually need: SSH access, Python installed Eg: Web servers, App servers, Database servers, Docker hosts

**3. Inventory:** The Inventory tells Ansible: which servers exist, how to connect to them and how they are grouped.
<img width="263" height="545" alt="image" src="https://github.com/user-attachments/assets/2309826c-e9bf-4b4e-ae5f-25f9fcb1d33d" />

**4. Modules:** Modules are the actual units of work.

-->They perform tasks like: install packages, copy files, create users, start services.
<img width="487" height="252" alt="image" src="https://github.com/user-attachments/assets/b62a7d81-aabd-45d0-9397-f424c4e7a206" />
<img width="212" height="262" alt="image" src="https://github.com/user-attachments/assets/b3c84fb2-c272-48ab-aaf0-0daf86d5a90a" />

**5. Playbooks:** Playbooks are YAML files describing: what to do, on which hosts, in what order.
<img width="257" height="316" alt="image" src="https://github.com/user-attachments/assets/61a1a1a2-5c4a-4c83-8a76-e616f97a1915" />
<img width="316" height="837" alt="image" src="https://github.com/user-attachments/assets/0469c2cc-efca-4e7d-99aa-f0fffcbe622b" />

---

### Task 2: Set Up Your Lab Environment
You need 2-3 EC2 instances to practice on. Choose one approach:

**Option A: Use Terraform (recommended -- you just learned this)**
Use your TerraWeek skills to provision 3 EC2 instances with:
- Amazon Linux 2 or Ubuntu 22.04
- `t2.micro` instance type
- A security group allowing SSH (port 22)
- A key pair for SSH access

**Option B: Launch manually from AWS Console**
Create 3 instances with the same specs above.

Label them mentally:
- **Instance 1:** web server
- **Instance 2:** app server
- **Instance 3:** db server

Verify you can SSH into each one from your control node:
```bash
ssh -i ~/your-key.pem ec2-user@<public-ip-1>
ssh -i ~/your-key.pem ec2-user@<public-ip-2>
ssh -i ~/your-key.pem ec2-user@<public-ip-3>
```
<img width="1820" height="960" alt="image" src="https://github.com/user-attachments/assets/a228d815-61a2-4e82-b642-c34e9ba5aa87" />
<img width="1742" height="982" alt="image" src="https://github.com/user-attachments/assets/9449e807-f648-4ef1-bc17-9768721346f1" />
<img width="1703" height="925" alt="image" src="https://github.com/user-attachments/assets/a438fcce-d0a0-47ae-af2e-8fe2600b0896" />
<img width="1767" height="976" alt="image" src="https://github.com/user-attachments/assets/d96a858e-f289-471a-97fd-eabf29b6c3aa" />
<img width="1777" height="947" alt="image" src="https://github.com/user-attachments/assets/3da899be-a66b-4c8a-9979-2ecc58798a3f" />
<img width="1736" height="956" alt="image" src="https://github.com/user-attachments/assets/c10c11d8-64ea-4766-a5cb-0209e3766214" />
<img width="671" height="223" alt="image" src="https://github.com/user-attachments/assets/349d28f2-eedd-44e9-8984-c156be0c8240" />


**Steps to follow:**
1. Create main.tf, variables.tf, terraform.tfvars, outputs.tf files to create 3 ec2 instance with mentioned requirements
2. then terraform validate
3. terraform plan
4. terraform apply
5. then once the ec2 instance got created to connect with them use command ssh -i my-key.pem ubuntu@,your-ip-add> [for amazon linux: ec2-user & for ubuntu: ubuntu user use]

**Some troubleshooting commands:**
1. If we havent created key-pair via terrafrom script in that case we can create it via aws console as well [Create Key Pair from AWS Console] for that login there and search for "ec2 key-pair" and then we will get option "key-pairs" --> and then click on create key-pair -->select RSA & .pem option & .pem key will get generate.

2. Option 2 is Create Key Pair Using AWS CLI for that use command: aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem Here after creating set the permission chmod 400 my-key.pem 

3. Then to access the instance use command: ssh -i my-key.pem ubuntu@,your-ip-address> & you will connect with the instance

4. To see any of the instance details use command: terraform state show 'aws_instance.instance["one"]'

5. To know the ami id use command: terraform state show 'aws_instance.instance["one"]' | grep ami

6. If incase outputs.tf file not created and wanted to know the ip-address of any instance then for that use command: terraform console to go inside it and then run command: aws_instance.instance["one"].public_ip & you will get it. & if outputs.tf file created in that case can use command: terraform output

---

### Task 3: Install Ansible
Install Ansible on your **control node** (your laptop or one dedicated EC2 instance):

```bash
# macOS
brew install ansible

# Ubuntu/Debian
sudo apt update
sudo apt install ansible -y

# Amazon Linux / RHEL
sudo yum install ansible -y
# or
pip3 install ansible

# Verify
ansible --version
```

Steps to follow:

1. sudo apt update & sudo apt install ansible -y

2. ansible --version

<img width="1886" height="970" alt="image" src="https://github.com/user-attachments/assets/e99fd52a-504a-4dc5-bb52-4e7404e7fa86" />
<img width="460" height="662" alt="image" src="https://github.com/user-attachments/assets/533b91f2-e0ac-4147-a60e-3e3cc0eea204" />


Confirm the output shows the Ansible version, config file path, and Python version.
<img width="1552" height="272" alt="image" src="https://github.com/user-attachments/assets/602d09ee-4dd5-4696-aafa-54a5ecb24b25" />

**Document:** On which machine did you install Ansible? Why is it only needed on the control node?
-->Ansible was installed on the control node machine. The control node is the system from which Ansible commands and playbooks are executed to manage other servers called managed nodes or target nodes. Ansible is only required on the control node because it follows an agentless architecture. This means no Ansible software needs to be installed on the target machines. Instead, Ansible connects to the managed nodes using SSH and executes tasks remotely.

**The control node contains:** Ansible package, Inventory files, Playbooks, Configuration files, SSH keys used for authentication etc.

-->When a playbook is executed, the control node: Connects to the target machines through SSH, Copies temporary modules/scripts, Executes the required tasks, Returns the output back to the control node

-->This approach makes Ansible lightweight, easy to maintain, and simple to scale because there is no need to install or manage agents on every server.

---

### Task 4: Create Your Inventory File
The inventory tells Ansible which servers to manage. Create a project directory and your first inventory:

```bash
mkdir ansible-practice && cd ansible-practice
```

Create a file called `inventory.ini`:
```ini
[web]
web-server ansible_host=<PUBLIC_IP_1>

[app]
app-server ansible_host=<PUBLIC_IP_2>

[db]
db-server ansible_host=<PUBLIC_IP_3>

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/your-key.pem
```

Verify Ansible can reach all hosts:
```bash
ansible all -i inventory.ini -m ping
```
You should see green `SUCCESS` with `"ping": "pong"` for each host.
<img width="1918" height="563" alt="image" src="https://github.com/user-attachments/assets/fa30428d-6cb5-4f47-9399-a6f1c5c801c0" />

**Troubleshoot:** If ping fails:
- Check the SSH key path and permissions (`chmod 400 your-key.pem`) --> for that use command: find ~ -name "*.pem"
<img width="1478" height="83" alt="image" src="https://github.com/user-attachments/assets/e684afb3-34e9-47c3-bea7-e2059fa60e4f" />

- Check the security group allows SSH from your IP
<img width="1906" height="800" alt="image" src="https://github.com/user-attachments/assets/be3fa44b-9ca2-4632-8cd2-39a9d81431d9" />

- Check the `ansible_user` matches your AMI (ec2-user for Amazon Linux, ubuntu for Ubuntu)
Checked used ubuntu as using ubuntu ami id

---

### Task 5: Run Ad-Hoc Commands
Ad-hoc commands let you run quick one-off tasks without writing a playbook.

1. **Check uptime on all servers:**
```bash
ansible all -i inventory.ini -m command -a "uptime"
```
<img width="1866" height="170" alt="image" src="https://github.com/user-attachments/assets/71589386-244c-4601-bc1b-e8af44bf1c19" />

2. **Check free memory on web servers only:**
```bash
ansible web -i inventory.ini -m command -a "free -h"
```
<img width="1843" height="120" alt="image" src="https://github.com/user-attachments/assets/30b3e647-c549-4872-b489-43b948973c2c" />


3. **Check disk space on all servers:**
```bash
ansible all -i inventory.ini -m command -a "df -h"
```
<img width="1877" height="967" alt="image" src="https://github.com/user-attachments/assets/db8a86bb-0b15-491d-845d-911016ebdd77" />

4. **Install a package on the web group:**
```bash
ansible web -i inventory.ini -m yum -a "name=git state=present" --become
```
(Use `apt` instead of `yum` if running Ubuntu)
<img width="1918" height="237" alt="image" src="https://github.com/user-attachments/assets/2d4be6d0-ec79-4699-a13c-9c23d72a9fe3" />

5. **Copy a file to all servers:**
```bash
echo "Hello from Ansible" > hello.txt
ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```
<img width="1918" height="967" alt="image" src="https://github.com/user-attachments/assets/14f43169-b236-4b16-a711-0d1ae455f162" />

6. **Verify the file was copied:**
```bash
ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
```
<img width="1607" height="158" alt="image" src="https://github.com/user-attachments/assets/f01404b4-6140-44b3-9234-f547cdf97643" />

**Document:** What does `--become` do? When do you need it?

--> The **--become** option in Ansible is used to execute tasks with elevated privileges, usually as the root user. It works similarly to using sudo in Linux.

-->By default, Ansible connects to remote servers using a normal user account such as ubuntu or ec2-user. Some administrative tasks require root privileges, and --become allows Ansible to temporarily switch to a privileged user while executing those tasks.

Why --become Is Needed? because, Many system-level operations cannot be performed by regular users. Examples include: Installing packages, Starting or stopping services, Editing files inside /etc, Managing users and groups, Updating system configurations etc.

-->Without --become, these tasks may fail with “Permission denied” errors.

**Example Without --become:** ansible all -i inventory -a "apt install nginx -y" [This may fail because package installation requires root access.]

**Example With --become:** ansible all -i inventory -a "apt install nginx -y" --become [Here, Ansible uses sudo privileges to run the command successfully.]
<img width="601" height="487" alt="image" src="https://github.com/user-attachments/assets/441f5acf-5e6e-43f5-bc7f-43f1832d7cf9" />

---

### Task 6: Explore Inventory Groups and Patterns
1. **Create a group of groups** -- add this to your `inventory.ini`:
```ini
[application:children]
web
app

[all_servers:children]
application
db
```

2. Run commands against different groups:
```bash
ansible application -i inventory.ini -m ping     # web + app servers
ansible db -i inventory.ini -m ping               # only db server
ansible all_servers -i inventory.ini -m ping      # everything
```
<img width="1663" height="862" alt="image" src="https://github.com/user-attachments/assets/9ec373e6-927b-43be-947f-1e82ae4fa7b0" />

3. **Use patterns:**
```bash
ansible 'web:app' -i inventory.ini -m ping        # OR: web or app
ansible 'all:!db' -i inventory.ini -m ping        # NOT: all except db
```
<img width="1762" height="608" alt="image" src="https://github.com/user-attachments/assets/3258bff4-f299-4afa-b6e3-d0eef48211bb" />

4. **Create an `ansible.cfg`** to avoid typing `-i inventory.ini` every time:
```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ec2-user
private_key_file = ~/your-key.pem
```

Now you can simply run:
```bash
ansible all -m ping
```
<img width="1790" height="475" alt="image" src="https://github.com/user-attachments/assets/d6635897-8ab6-411e-9c86-cd1ca2b982a0" />

**Verify:** Does `ansible all -m ping` work without specifying the inventory file?
-->Yes as we have created ansible.org file and mention inventary.ini file overthere after that without specifying the inventory file we can ping the instances.
<img width="1790" height="475" alt="image" src="https://github.com/user-attachments/assets/37c55d83-917a-4b3b-97bd-c0c9b2f4a109" />

---

## Hints
- Ansible uses SSH by default -- no agent installation needed on managed nodes
- `ansible.cfg` is read from the current directory first, then `~/.ansible.cfg`, then `/etc/ansible/ansible.cfg`
- `-m` specifies the module, `-a` specifies the module arguments
- `--become` escalates to root (like `sudo`) -- needed for package installation and service management
- `command` module runs simple commands, `shell` module supports pipes and redirects
- Host key checking can cause issues on first connection -- `host_key_checking = False` in config helps during practice
- Ad-hoc commands are great for quick tasks, but playbooks are better for anything repeatable

---

## Documentation
Create `day-68-ansible-intro.md` with:
- Ansible architecture in your own words
- How you set up your lab (Terraform or manual, with instance details)
- Your `inventory.ini` file (redact IPs if sharing publicly)
- Screenshot of `ansible all -m ping` with all green results
- Five ad-hoc commands you ran and their outputs
- Difference between `command` and `shell` modules

---

## Submission
1. Add `day-68-ansible-intro.md` to `2026/day-68/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Started the Ansible journey today -- set up a control node, created an inventory with three EC2 instances, and ran ad-hoc commands to manage all servers from one terminal. No agents installed anywhere. Ansible just works over SSH."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
