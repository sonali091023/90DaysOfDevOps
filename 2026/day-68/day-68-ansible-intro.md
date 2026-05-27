# Day 68 -- Introduction to Ansible and Inventory Setup

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

2. Managed Nodes: Managed nodes are the systems Ansible configures. Eg: EC2 instances, Linux VMs, Kubernetes worker nodes, Database servers etc.

-->They usually need: SSH access, Python installed Eg: Web servers, App servers, Database servers, Docker hosts

3. Inventory: The Inventory tells Ansible: which servers exist, how to connect to them and how they are grouped.
<img width="263" height="545" alt="image" src="https://github.com/user-attachments/assets/2309826c-e9bf-4b4e-ae5f-25f9fcb1d33d" />

4. Modules: Modules are the actual units of work.

-->They perform tasks like: install packages, copy files, create users, start services.
<img width="487" height="252" alt="image" src="https://github.com/user-attachments/assets/b62a7d81-aabd-45d0-9397-f424c4e7a206" />
<img width="212" height="262" alt="image" src="https://github.com/user-attachments/assets/b3c84fb2-c272-48ab-aaf0-0daf86d5a90a" />

5. Playbooks: Playbooks are YAML files describing: what to do, on which hosts, in what order.
<img width="257" height="316" alt="image" src="https://github.com/user-attachments/assets/61a1a1a2-5c4a-4c83-8a76-e616f97a1915" />


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

Confirm the output shows the Ansible version, config file path, and Python version.

**Document:** On which machine did you install Ansible? Why is it only needed on the control node?

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

**Troubleshoot:** If ping fails:
- Check the SSH key path and permissions (`chmod 400 your-key.pem`)
- Check the security group allows SSH from your IP
- Check the `ansible_user` matches your AMI (ec2-user for Amazon Linux, ubuntu for Ubuntu)

---

### Task 5: Run Ad-Hoc Commands
Ad-hoc commands let you run quick one-off tasks without writing a playbook.

1. **Check uptime on all servers:**
```bash
ansible all -i inventory.ini -m command -a "uptime"
```

2. **Check free memory on web servers only:**
```bash
ansible web -i inventory.ini -m command -a "free -h"
```

3. **Check disk space on all servers:**
```bash
ansible all -i inventory.ini -m command -a "df -h"
```

4. **Install a package on the web group:**
```bash
ansible web -i inventory.ini -m yum -a "name=git state=present" --become
```
(Use `apt` instead of `yum` if running Ubuntu)

5. **Copy a file to all servers:**
```bash
echo "Hello from Ansible" > hello.txt
ansible all -i inventory.ini -m copy -a "src=hello.txt dest=/tmp/hello.txt"
```

6. **Verify the file was copied:**
```bash
ansible all -i inventory.ini -m command -a "cat /tmp/hello.txt"
```

**Document:** What does `--become` do? When do you need it?

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

3. **Use patterns:**
```bash
ansible 'web:app' -i inventory.ini -m ping        # OR: web or app
ansible 'all:!db' -i inventory.ini -m ping        # NOT: all except db
```

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

**Verify:** Does `ansible all -m ping` work without specifying the inventory file?

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
