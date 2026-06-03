# Day 72 -- Ansible Project: Automate Docker and Nginx Deployment

## Task
Five days of Ansible -- inventory, ad-hoc commands, playbooks, modules, handlers, variables, facts, conditionals, loops, roles, templates, Galaxy, and Vault. Today you put it all together and build what you would actually do on the job.

Automate a complete deployment: install Docker, pull and run a containerized application, set up Nginx as a reverse proxy in front of it, and manage everything through Ansible roles. One command to go from a fresh server to a fully running, production-style setup.

---

## Expected Output
- A complete Ansible project with custom roles for Docker and Nginx
- Docker containers running on managed nodes, deployed entirely through Ansible
- Nginx configured as a reverse proxy to the container
- Vault-encrypted Docker Hub credentials
- A markdown file: `day-72-ansible-project.md`
- A running app accessible through Nginx on port 80

---

## Challenge Tasks

### Task 1: Plan the Project Structure
Create the complete project layout:

```
ansible-docker-project/
  ansible.cfg
  inventory.ini
  site.yml                          # Master playbook
  group_vars/
    all.yml                         # Common variables
    web/
      vars.yml                      # Nginx variables
      vault.yml                     # Encrypted Docker Hub credentials
  roles/
    common/                         # Shared setup for all servers
      tasks/main.yml
    docker/                         # Docker installation and container management
      tasks/main.yml
      templates/
        docker-compose.yml.j2
      handlers/main.yml
      defaults/main.yml
    nginx/                          # Nginx reverse proxy
      tasks/main.yml
      templates/
        nginx.conf.j2
        app-proxy.conf.j2
      handlers/main.yml
      defaults/main.yml
```

Generate the role skeletons:
```bash
mkdir -p ansible-docker-project/roles
cd ansible-docker-project
ansible-galaxy init roles/common
ansible-galaxy init roles/docker
ansible-galaxy init roles/nginx
```

**Steps to follow:**

Step 1: Create Project Directory: mkdir ansible-docker-project && cd ansible-docker-project

Step 2: Create Role Skeletons: Create the roles directory: mkdir roles && cd roles & then inside it Generate the three roles:

-->ansible-galaxy init common

-->ansible-galaxy init docker

-->ansible-galaxy init nginx

-->To verify use command: tree roles

**Note:** Here bymistake created roles/roles dir to fix this i have used commands: 

-->pwd

-->tree -L 2

-->mv roles/roles/* roles/

-->rmdir roles/roles

-->tree -L 2

<img width="976" height="496" alt="image" src="https://github.com/user-attachments/assets/62c10d86-e8bd-427f-9881-ac60ec0fc3ac" />

<img width="175" height="367" alt="image" src="https://github.com/user-attachments/assets/55f29088-efef-4174-ab97-0895dec7b16b" />

<img width="1737" height="972" alt="image" src="https://github.com/user-attachments/assets/ca77dc3f-a02f-424c-a335-931bf06addec" />

<img width="1668" height="561" alt="image" src="https://github.com/user-attachments/assets/8344d5fd-6edb-4f9a-bbb6-a04ca03ac57f" />

Step 3: Create Remaining Project Structure: Create variable folders: First get out of rolses dir and the run command: mkdir -p group_vars/web & then inside it Create top-level files:

-->touch ansible.cfg

-->touch inventory.ini

-->touch site.yml

-->touch group_vars/all.yml

-->touch group_vars/web/vars.yml

-->touch group_vars/web/vault.yml

Step 4: Verify Structure: tree

<img width="346" height="442" alt="image" src="https://github.com/user-attachments/assets/40d5df84-572f-4f78-a7c4-ae936a44e6b3" />

<img width="1180" height="977" alt="image" src="https://github.com/user-attachments/assets/50b6cdbb-20d4-4c38-aaa7-db123d866ddf" />

Step 5: Configure ansible.cfg: 

<img width="401" height="426" alt="image" src="https://github.com/user-attachments/assets/84b05258-8fcf-48e7-9e76-cbf89e4ba7b5" />

Step 6: Configure inventory.ini: 

<img width="401" height="352" alt="image" src="https://github.com/user-attachments/assets/e02e465a-4889-45f0-a821-40923a1e891b" />

Step 7: Test Inventory: You should see JSON output: ansible-inventory --list

<img width="1307" height="531" alt="image" src="https://github.com/user-attachments/assets/a3cd04a9-4443-43d5-b6d1-45c311725c92" />

Step 8: Test Connectivity: ansible all -m ping

<img width="1270" height="247" alt="image" src="https://github.com/user-attachments/assets/1261a70f-078d-470d-94d7-432e3b59e3ff" />

Step 9: Prepare Role Files: Create the files that today's project requires:

-->touch roles/docker/templates/docker-compose.yml.j2

-->touch roles/docker/defaults/main.yml

Docker handler: 

-->touch roles/docker/handlers/main.yml

Nginx Role:

-->touch roles/nginx/templates/nginx.conf.j2

-->touch roles/nginx/templates/app-proxy.conf.j2

-->touch roles/nginx/defaults/main.yml

-->touch roles/nginx/handlers/main.yml

Common Role: The generated role already contains: roles/common/tasks/main.yml So no extra role need to create

Step 10: Create Initial site.yml: So here site.yml file is created at root level

Step 11: Add Common Variables: Create under dir: vi group_vars/all.yml

<img width="403" height="308" alt="image" src="https://github.com/user-attachments/assets/b9af1d3b-7d1a-4d48-ad14-b39ab0cbe1b9" />

Step 12: Add Web Variables: vi group_vars/web/vars.yml

<img width="491" height="247" alt="image" src="https://github.com/user-attachments/assets/3cab59a4-16a0-4e1b-a1e3-2c16f44d2089" />

Step 13: Create Encrypted Vault File: ansible-vault create group_vars/web/vault.yml

-->Edit the created vault.yml file: ansible-vault edit group_vars/web/vault.yml

-->Encrypt the created vault file: ansible-vault encrypt vault.yml

-->To chnage the vault.yml password: ansible-vault rekey group_vars/web/vault.yml

<img width="385" height="186" alt="image" src="https://github.com/user-attachments/assets/303e2e3c-3cc2-4521-9ccb-894c91c8b0df" />

**Ansible vault commands:**

1. Create a Vault File: ansible-vault create vault.yml [Creates and encrypts a new file ]

2. View Vault Contents: ansible-vault view vault.yml [Displays decrypted content without editing.]

3. Edit Vault Contents: ansible-vault edit vault.yml [Opens the file in your editor and re-encrypts on save.]

4. Encrypt Existing File: Before: username: admin & password: secret123 Encrypt: ansible-vault encrypt vault.yml [It will Encrypt the data]

5. Decrypt File: ansible-vault decrypt vault.yml [Converts encrypted file back to plain text.]

6. Change Vault Password: ansible-vault rekey vault.yml [Prompts for: Current password, New password, Confirm new password]

7. Encrypt Multiple Files: ansible-vault encrypt file1.yml file2.yml file3.yml

8. Decrypt Multiple Files: ansible-vault decrypt file1.yml file2.yml

9. Rekey Multiple Files: ansible-vault rekey file1.yml file2.yml

10. Encrypt a Single String: ansible-vault encrypt_string 'mypassword'

Output:

!vault |
          $ANSIBLE_VAULT;1.1;AES256
          ...

Useful when only one variable is secret.

11. Encrypt Variable by Name: ansible-vault encrypt_string --stdin-name dockerhub_password

Enter:

mypassword

Output:

dockerhub_password: !vault |
          
          $ANSIBLE_VAULT;1.1;AES256
          
          ...

12. Run Playbook and Ask for Vault Password: ansible-playbook site.yml --ask-vault-pass

Shortcut:

ansible-playbook site.yml -J

13. Use Password File: Create: echo "mypassword" > .vault_pass then chnage the permission of the file sudo chmod 600 .vault_pass

Run: ansible-playbook site.yml --vault-password-file .vault_pass

14. Configure Default Password File In ansible.cfg:

[defaults]

vault_password_file = .vault_pass

-->Then simply: Run command: ansible-playbook site.yml It will not ask for passowrd prompt.

15. Check if File Is Vault Encrypted: head -1 vault.yml

Encrypted files start with: $ANSIBLE_VAULT;1.1;AES256

Step 14: Verify Vault: cat group_vars/web/vault.yml

<img width="1036" height="185" alt="image" src="https://github.com/user-attachments/assets/3ba66272-f3b1-4924-a0db-669a5449f649" />

-->Final Check: tree -L 4

<img width="1078" height="976" alt="image" src="https://github.com/user-attachments/assets/763faf65-3b5d-41b2-8ed5-857948500ac4" />

Set up your `ansible.cfg` and `inventory.ini` using what you built on Day 68.

---

### Task 2: Build the Common Role
The `common` role runs on every server -- baseline packages and setup.

**`roles/common/tasks/main.yml`:**
```yaml
---
- name: Update package cache
  yum:
    update_cache: true
  tags: common

- name: Install common packages
  yum:
    name: "{{ common_packages }}"
    state: present
  tags: common

- name: Set hostname
  hostname:
    name: "{{ inventory_hostname }}"
  tags: common

- name: Set timezone
  timezone:
    name: "{{ timezone }}"
  tags: common

- name: Create deploy user
  user:
    name: deploy
    groups: wheel
    shell: /bin/bash
    state: present
  tags: common
```

(Use `apt` instead of `yum` if your instances run Ubuntu)

**`group_vars/all.yml`:**
```yaml
---
timezone: Asia/Kolkata
project_name: devops-app
app_env: development
common_packages:
  - vim
  - curl
  - wget
  - git
  - htop
  - tree
  - jq
  - unzip
```

**Steps to follow:**

Step 1: Open group_vars/all.yml: vi group_vars/all.yml So here already data were available and if wanted add new dont delete previous one onstead merge the new data into it.

<img width="367" height="437" alt="image" src="https://github.com/user-attachments/assets/a9a40829-d36e-48a8-91ee-dc21f2e5865a" />

Step 2: Understand Why These Variables Are Here: 

<img width="458" height="408" alt="image" src="https://github.com/user-attachments/assets/20c39b9d-90b7-484c-be87-6e69be3c944b" />

<img width="662" height="692" alt="image" src="https://github.com/user-attachments/assets/2aa10079-59a1-4ba2-a649-19803607b95c" />

Step 3: Open the Common Role: vi roles/common/tasks/main.yml [Remove the default content created by ansible-galaxy.]

Step 4: Add the Common Role Tasks: Add the belwo code into file: vi roles/common/tasks/main.yml

<img width="422" height="557" alt="image" src="https://github.com/user-attachments/assets/533a16c6-b47a-4025-96d9-be52373ab6e0" />

Step 5: Why We Changed wheel: 

<img width="367" height="506" alt="image" src="https://github.com/user-attachments/assets/58dcc2d7-de15-4bd2-992b-3ba35c2ada43" />

Step 6: Verify YAML Syntax: ansible-playbook site.yml --syntax-check

<img width="1170" height="92" alt="image" src="https://github.com/user-attachments/assets/3253504c-3d7d-4a06-b06d-712ca43695c9" />

Step 7: Create a Minimal site.yml: vi site.yml [Which is already created in task 1 and added code to it as well.]

Step 8: Verify Inventory: ansible all -m ping

<img width="1017" height="257" alt="image" src="https://github.com/user-attachments/assets/bf92ff42-76ea-4529-a883-6adad064aa5d" />

**How to create .vault_pass file?**

-->echo "your_vault_password" > .vault_pass

-->And then chnage the permission of the file: chmod 600 .vault_pass

-->Verify the seted periomssion of the file: ls -la .vault_pass  [Now Ansible can automatically read the password & we dont have to run cmd: ansible-playbook site.yml --ask-vault-pass all the time]

-->Once this .vault_pass file gets created configure it int in the ansible.cfg [vault_password_file = .vault_pass] file and then while exection we dont have to enter the password everytime.

Step 9: Run the Common Role: ansible-playbook site.yml

<img width="1896" height="742" alt="image" src="https://github.com/user-attachments/assets/96719872-d06c-4a69-aeed-b047aa61892e" />

Step 10: Verify Package Installation: ssh -i ../terreaform-practice/my-key.pem ubuntu@13.207.184.47 & ssh -i ../terreaform-practice/my-key.pem ubuntu@13.207.196.162

<img width="1227" height="881" alt="image" src="https://github.com/user-attachments/assets/8717d6da-6e0d-4296-9d4b-6f52228a38f2" />

Step 11: Verify Hostname: hostname

<img width="1186" height="862" alt="image" src="https://github.com/user-attachments/assets/9d1fda6e-9619-4383-aa40-b13ed55843d8" />

Step 12: Verify Timezone: timedatectl

<img width="1136" height="946" alt="image" src="https://github.com/user-attachments/assets/e9d1a0ec-5451-4eb2-99c3-635ec93c0876" />

Step 13: Verify Deploy User: id deploy

<img width="1180" height="877" alt="image" src="https://github.com/user-attachments/assets/36cd7184-820e-4a47-b1b9-c63f0cd6df9b" />

Step 14: Test Tags: ansible-playbook site.yml --tags common [Useful later when your project contains Docker and Nginx roles too.]

<img width="1912" height="830" alt="image" src="https://github.com/user-attachments/assets/453ae45c-a62f-469b-a0f7-f714cc675f7d" />

---

### Task 3: Build the Docker Role
This role installs Docker, starts the service, pulls images, and runs containers.

**`roles/docker/defaults/main.yml`:**
```yaml
---
docker_app_image: nginx
docker_app_tag: latest
docker_app_name: myapp
docker_app_port: 8080
docker_container_port: 80
```

**`roles/docker/tasks/main.yml`:**
Write tasks that:
1. Install Docker dependencies (`yum-utils`, `device-mapper-persistent-data`, `lvm2`)
2. Add the Docker CE repository
3. Install Docker CE
4. Start and enable the Docker service
5. Add the `deploy` user to the `docker` group
6. Install Docker Compose (via pip or direct download)
7. Log in to Docker Hub using vault-encrypted credentials:
```yaml
- name: Log in to Docker Hub
  community.docker.docker_login:
    username: "{{ vault_docker_username }}"
    password: "{{ vault_docker_password }}"
  become_user: deploy
  when: vault_docker_username is defined
```
8. Pull the application image:
```yaml
- name: Pull application image
  community.docker.docker_image:
    name: "{{ docker_app_image }}"
    tag: "{{ docker_app_tag }}"
    source: pull
```
9. Run the container:
```yaml
- name: Run application container
  community.docker.docker_container:
    name: "{{ docker_app_name }}"
    image: "{{ docker_app_image }}:{{ docker_app_tag }}"
    state: started
    restart_policy: always
    ports:
      - "{{ docker_app_port }}:{{ docker_container_port }}"
```
10. Verify the container is running:
```yaml
- name: Wait for container to be healthy
  uri:
    url: "http://localhost:{{ docker_app_port }}"
    status_code: 200
  retries: 5
  delay: 3
  register: health_check
  until: health_check.status == 200
```

Tag all tasks with `docker`.

**`roles/docker/handlers/main.yml`:**
```yaml
---
- name: Restart Docker
  service:
    name: docker
    state: restarted
```

**Install the required Ansible collection** (needed for `community.docker` modules):
```bash
ansible-galaxy collection install community.docker
```

**Steps to follow:**

Step 1: Install Docker Collection on Control Node: ansible-galaxy collection install community.docker

<img width="1711" height="162" alt="image" src="https://github.com/user-attachments/assets/844c12b1-89d4-4887-b755-5ce0dc7753a8" />

Step 2: Create Docker Default Variables: vi roles/docker/defaults/main.yml

<img width="251" height="206" alt="image" src="https://github.com/user-attachments/assets/b2ea8cc0-d02d-4a7e-863a-4f4237951e8e" />

Step 3: Configure Vault Variables: 

<img width="671" height="447" alt="image" src="https://github.com/user-attachments/assets/3e30fb6c-98f3-4202-9cbd-1e3cf8a61bd2" />

Step 4: Create Docker Handler: vi roles/docker/handlers/main.yml

<img width="307" height="201" alt="image" src="https://github.com/user-attachments/assets/bd7a9899-aab7-4bf5-993b-bdd1c81835a4" />

Step 5: Build Docker Tasks: Added above mentioned tasks in file: vi roles/docker/tasks/main.yml

Step 6: Update site.yml: 

<img width="280" height="316" alt="image" src="https://github.com/user-attachments/assets/24d6a7bf-52dc-4c0b-8910-87357762fdb4" />

Step 7: Syntax Check: ansible-playbook site.yml --syntax-check

-->To resume the exection from the failed task: ansible-playbook site.yml --tags docker --start-at-task="Install Docker Python SDK"

<img width="1586" height="107" alt="image" src="https://github.com/user-attachments/assets/a0b58b60-5208-437b-88d8-836f74f0b0e6" />

Step 8: Run Only Docker Tasks: ansible-playbook site.yml --tags docker

<img width="1721" height="900" alt="image" src="https://github.com/user-attachments/assets/cb178528-b4bb-4371-8668-05be10cb1580" />

Step 9: Verify on App Server: Here ssh to web-server only -->ssh -i ../terraform-practice/my-app.pem ubuntu@13.207.196.162

<img width="1866" height="838" alt="image" src="https://github.com/user-attachments/assets/3fc9d003-3411-4261-a1fd-b1ff989bfe65" />

Step 10: Verify Web Response: curl localhost:8080

<img width="1717" height="673" alt="image" src="https://github.com/user-attachments/assets/649d4670-f790-459f-9b42-125680f7b3e6" />

-->Also on the browser: First make sure port 8080 is opened and then paste the instance ip:8080 and there also we can see the nginx webpage

<img width="1761" height="852" alt="image" src="https://github.com/user-attachments/assets/e8c07b27-8520-410b-a347-3a3a89789926" />

---

### Task 4: Build the Nginx Role
This role installs Nginx and configures it as a reverse proxy to the Docker container.

**`roles/nginx/defaults/main.yml`:**
```yaml
---
nginx_http_port: 80
nginx_upstream_port: 8080
nginx_server_name: "_"
```

**`roles/nginx/tasks/main.yml`:**
Write tasks that:
1. Install Nginx
2. Remove the default Nginx site config
3. Deploy the main Nginx config from a template
4. Deploy the reverse proxy config from a template
5. Test Nginx config before reloading:
```yaml
- name: Test Nginx configuration
  command: nginx -t
  changed_when: false
```
6. Start and enable Nginx
7. Use a handler to reload Nginx when any config changes

Tag all tasks with `nginx`.

**`roles/nginx/templates/app-proxy.conf.j2`:**
```nginx
# Reverse Proxy to Docker Container -- Managed by Ansible
upstream docker_app {
    server 127.0.0.1:{{ nginx_upstream_port }};
}

server {
    listen {{ nginx_http_port }};
    server_name {{ nginx_server_name }};

    location / {
        proxy_pass http://docker_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /health {
        access_log off;
        return 200 'OK';
        add_header Content-Type text/plain;
    }

{% if app_env == 'production' %}
    access_log /var/log/nginx/{{ project_name }}_access.log;
    error_log /var/log/nginx/{{ project_name }}_error.log;
{% else %}
    access_log /var/log/nginx/{{ project_name }}_access.log;
    error_log /var/log/nginx/{{ project_name }}_error.log debug;
{% endif %}
}
```

**`roles/nginx/handlers/main.yml`:**
```yaml
---
- name: Reload Nginx
  service:
    name: nginx
    state: reloaded

- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

**Steps to follow:**

Step 1: Configure Default Variables: vi roles/nginx/defaults/main.yml

<img width="273" height="212" alt="image" src="https://github.com/user-attachments/assets/51f9300f-b0fc-4913-9836-dd8a023fb495" />

Step 2: Create Nginx Handlers: vi roles/nginx/handlers/main.yml

<img width="256" height="326" alt="image" src="https://github.com/user-attachments/assets/35bc5251-de49-465e-9061-962f5b2dd180" />

Step 3: Create Main Nginx Configuration Template: vi roles/nginx/templates/nginx.conf.j2

<img width="397" height="455" alt="image" src="https://github.com/user-attachments/assets/c7365cf4-a9cb-49ff-97b8-310d4cd43079" />

Step 4: Create Reverse Proxy Template: vi roles/nginx/templates/app-proxy.conf.j2

<img width="592" height="651" alt="image" src="https://github.com/user-attachments/assets/d2b35d9c-3c56-48ce-a50e-bf44017a0490" />

Step 5: Create Nginx Tasks: vi roles/nginx/tasks/main.yml

Step 6: Update site.yml: vi site.yml

<img width="366" height="463" alt="image" src="https://github.com/user-attachments/assets/380e3dc9-7788-4cc7-b417-07e2e2881680" />

Step 7: Syntax Check: ansible-playbook site.yml --syntax-check

<img width="438" height="495" alt="image" src="https://github.com/user-attachments/assets/519555aa-55c6-45ad-9067-b039f8a415f8" />

<img width="1587" height="72" alt="image" src="https://github.com/user-attachments/assets/1f8d08f2-43f3-452a-8952-1b976508f4b8" />

Step 8: Run Only Nginx Tasks: ansible-playbook site.yml --tags nginx

<img width="1857" height="970" alt="image" src="https://github.com/user-attachments/assets/9ebf3533-a627-443a-8318-6604768a148f" />

<img width="1652" height="955" alt="image" src="https://github.com/user-attachments/assets/4620d55f-4ab4-4853-ad99-78a4426ec0ba" />

Step 9: Verify on Web Server: ssh -i ../terraform-practice/my-key.pem ubuntu@13.207.184.47

<img width="1652" height="955" alt="image" src="https://github.com/user-attachments/assets/a55e5813-f502-4403-a79c-5add792317cc" />

<img width="782" height="797" alt="image" src="https://github.com/user-attachments/assets/3ee1882f-c8ad-4dca-9e79-5349051e77a0" />

<img width="645" height="697" alt="image" src="https://github.com/user-attachments/assets/7c8c8117-4388-4bd6-a1f8-9e042ad1ae2e" />

---

### Task 5: Encrypt Docker Hub Credentials with Vault
1. Create the vault file:
```bash
ansible-vault create group_vars/web/vault.yml
```
Add:
```yaml
vault_docker_username: your-dockerhub-username
vault_docker_password: your-dockerhub-token
```

2. Create a vault password file for convenience:
```bash
echo "YourVaultPassword" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore
```

3. Reference it in `ansible.cfg`:
```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
vault_password_file = .vault_pass
```

**Steps to follow:**

Step 1: Decide Where the Vault File Belongs: 

<img width="577" height="671" alt="image" src="https://github.com/user-attachments/assets/4a36bc6a-ae7f-4707-99f6-ad653e833770" />

<img width="618" height="287" alt="image" src="https://github.com/user-attachments/assets/d0ed9a4a-b641-497c-8f66-26feb7c69ea8" />

<img width="1267" height="518" alt="image" src="https://github.com/user-attachments/assets/df0dce51-cf6b-467d-b85f-9cf5436bdd0a" />

Step 2: Create the Vault File: ansible-vault create group_vars/web/vault.yml & set your dockerhub username and password here: ansible-vault create group_vars/web/vault.yml 

-->So once run the above command we will prompted to set the password for the vault.yml file and once its done vault.yml file will get create.

Step 3: Verify the File is Encrypted: cat group_vars/web/vault.yml

<img width="1613" height="302" alt="image" src="https://github.com/user-attachments/assets/39506142-0092-4905-adb4-ab1b43e8007b" />

Step 4: Create Vault Password File: echo "DevOps@123" > .vault_pass [Note: Use the same password you entered during ansible-vault create.]

-->The secure this .vault_pass for that use command: chmod 600 .vault_pass

-->Then verify the same with command: ls -l .vault_pass

Step 5: Prevent Git from Uploading It: we can add this .vault_pass file in .gitignore file 

Step 6: Configure Ansible: vi ansible.cfg: Here we can give the reference of the .vault_pass file to avoid the same file in command while exection

<img width="377" height="177" alt="image" src="https://github.com/user-attachments/assets/c2e4af45-0d1e-4878-9b4d-ba9c373cad73" />

-->To verify use command: cat ansible.cfg

Step 7: Test Vault Access: ansible-vault view group_vars/web/vault.yml

-->So Because vault_password_file is configured in ansible.cfg file, So it should display username and password when we run above command.

<img width="498" height="771" alt="image" src="https://github.com/user-attachments/assets/00c90dbf-8ca7-4f61-9104-eb5c0bc298e5" />

---

### Task 6: Write the Master Playbook and Deploy
**`site.yml`:**
```yaml
---
- name: Apply common configuration
  hosts: all
  become: true
  roles:
    - common
  tags: common

- name: Install Docker and run containers
  hosts: web
  become: true
  roles:
    - docker
  tags: docker

- name: Configure Nginx reverse proxy
  hosts: web
  become: true
  roles:
    - nginx
  tags: nginx
```

Deploy the full stack:
```bash
# Dry run first -- always
ansible-playbook site.yml --check --diff

# Full deploy
ansible-playbook site.yml
```

Note: 

Use tags for selective execution:
```bash
# Only set up Docker and containers
ansible-playbook site.yml --tags docker

# Only update Nginx config
ansible-playbook site.yml --tags nginx

# Skip common setup
ansible-playbook site.yml --skip-tags common
```

**Steps to follow:**

-->ssh to the instance first: ssh -i ../terraform-practice/my-key.yml ubuntu@

Verify Direct Container Access: curl http://<public-ip>:8080

Verify Nginx Reverse Proxy: curl http://<public-ip> OR curl http://<public-ip>:80

<img width="247" height="158" alt="image" src="https://github.com/user-attachments/assets/1972cbf5-13f3-4784-bfc9-ef217ab209f4" />

Note: Before running the playbook common commands to use:

-->Let's validate that Ansible can see the roles: ansible-playbook site.yml --syntax-check

-->Then run a dry run: ansible-playbook site.yml --check --diff

**This is where we'll likely catch any:**

-->missing variables

-->vault issues

-->template issues

-->role dependency issues

Faced issue: While running dry run command i faced issue as below, that is like No package matching 'tree' is available
<img width="1918" height="432" alt="image" src="https://github.com/user-attachments/assets/96cb74ed-1c6b-4009-b8f0-c1bcd5f4ab90" />

**So to fix this issue followed steps:**

-->Step 1: Check the common role: cat roles/common/tasks/main.yml OR or at least the package installation task.

<img width="302" height="167" alt="image" src="https://github.com/user-attachments/assets/6320374b-b2c7-4d12-9111-f11bb519b8b8" />

Step 2: Check the OS of the servers: ansible all -i inventory.ini -m setup -a "filter=ansible_distribution" OR we can ssh to the server and run command: cat /etc/os-release.

**The reason is that:**

-->tree exists on Ubuntu/Debian.

-->tree exists on Amazon Linux, but repositories may not be enabled yet.

-->Sometimes a package cache issue causes Ansible to think it's unavailable.

Step 3: Fastest debugging: grep -R "tree" roles/common

-->Quick manual test: To ssh to the server and install manually tree package, And i f it installing successfully then the issue is probably: stale package cache, repository configuration,
or a package list problem.

-->If it fails manually too, the exact error will tell us what's wrong. For now, send me: roles/common/defaults/main.yml & roles/common/vars/main.yml Also Output of cat /etc/os-release from one server

**There are two possibilities:**

**Possibility 1: Ubuntu 26.04 repository issue** Since you're on a very new Ubuntu release: Ubuntu 26.04 LTS (Resolute Raccoon) the package metadata or repositories may not be fully available on those images.

**Possibility 2: Ansible's --check mode** Sometimes package modules behave oddly in check mode because they simulate installation without actually performing all repository operations.

-->So manily reason behind failure is Possibility 2 due to running dry run command we may face issue sometimes so to cross check just once run playboook exection command: ansible-playbook site.yml & this will definitely get pass. 

<img width="1912" height="976" alt="image" src="https://github.com/user-attachments/assets/3427470b-6f7b-42f3-87a2-03cf47dca575" />

<img width="1855" height="897" alt="image" src="https://github.com/user-attachments/assets/0272382a-5e0a-4b2b-9856-f39d12d30263" />

**Verify:**
1. Curl the server on port 8080 -- does the Docker container respond directly?

-->curl http://65.2.73.250:8080 == returned the Nginx welcome page, confirming that the Docker container is running correctly and responding directly on port 8080 through the app server.

2. Curl the server on port 80 -- does Nginx reverse proxy the request to the container?

-->Yes. curl http://52.66.175.134 or curl http://52.66.175.134:80 It returned the Nginx welcome page, confirming that the web server is successfully serving requests on port 80 and forwarding them to the application running in the Docker container through the Nginx reverse proxy.

3. Check `docker ps` on the server -- is the container running with the correct port mapping?

Yes. docker ps: on the app server showed the container in a running state with the port mapping: 0.0.0.0:8080->80/tcp & This confirms that requests sent to port 8080 on the app server are correctly forwarded to port 80 inside the Docker container, so the container is running with the expected port mapping.

-->So here **web-server ansible_host**=52.66.175.134 & **app-server ansible_host**=65.2.73.250

-->On web_server executed command: curl http://52.66.175.134:80 OR curl http://52.66.175.134 We can see the nginx welcome page 

-->On app_server executed command: curl http://65.2.73.250:8080 OR curl http://52.66.175.134:80 OR curl http://52.66.175.134:80 We can see the nginx welcome page  

-->In this project, the application is running inside a Docker container on the app server. The container uses the nginx:latest image and is configured with a port mapping of 8080:80, which means requests sent to port 8080 on the app server are forwarded to port 80 inside the container. When the command curl http://65.2.73.250:8080 was executed on the app server, it returned the Nginx welcome page. This confirms that the Docker container is running successfully and is accessible directly through port 8080.

-->The web server has Nginx installed and configured as a reverse proxy. A reverse proxy receives client requests and forwards them to another server—in this case, the app server where the Docker container is running. When the command curl http://52.66.175.134 or curl http://52.66.175.134:80 was executed, the Nginx welcome page was displayed. This confirms that the web server is successfully receiving requests on port 80 and serving content. In a typical production setup, users access the web server, and the web server forwards requests to the application server running the container.

-->Therefore, the verification demonstrates two successful layers of access. First, the application can be accessed directly through the app server on port 8080, proving that the Docker container is running correctly. Second, the application can be accessed through the web server on port 80, proving that Nginx is functioning correctly and handling incoming web requests. This confirms that the Ansible deployment successfully configured both the Docker-based application layer and the Nginx web server layer.

<img width="573" height="471" alt="image" src="https://github.com/user-attachments/assets/d67c7852-7516-4543-911d-9c533649c069" />

web_server o/p:

<img width="1837" height="978" alt="image" src="https://github.com/user-attachments/assets/cfb19901-4ee1-4a9d-be6b-c7c9b8b182a6" />
<img width="1577" height="518" alt="image" src="https://github.com/user-attachments/assets/f3a3a0b0-3272-4421-8446-a2d344ec398a" />

app-server o/p:
<img width="1668" height="968" alt="image" src="https://github.com/user-attachments/assets/bc874a14-17a9-4236-ba83-d16adf4dcdc7" />
<img width="1607" height="970" alt="image" src="https://github.com/user-attachments/assets/dcd9bfaa-b30e-42b7-aa4e-c311bb33bee6" />
<img width="1598" height="410" alt="image" src="https://github.com/user-attachments/assets/9868c838-4173-408f-acd0-64a4796f4ab8" />
<img width="1852" height="856" alt="image" src="https://github.com/user-attachments/assets/185a10a9-d1c1-413a-94e8-cfb7bd7ed200" />

---

### Task 7: Bonus -- Deploy a Different App and Re-Run
Change the Docker image to something else. Update `group_vars/all.yml` or pass extra vars:

```bash
ansible-playbook site.yml --tags docker \
  -e "docker_app_image=httpd docker_app_tag=latest docker_app_name=apache-app"
```

The old container should be replaced with the new one. Nginx still proxies traffic -- no config change needed.

Now run the full playbook one more time:
```bash
ansible-playbook site.yml
```
Faced issue: fatal: [app-server]: FAILED! => {"changed": false, "msg": "Error connecting: Error while fetching server API version: Not supported URL scheme http+docker"}

<img width="1915" height="961" alt="image" src="https://github.com/user-attachments/assets/ce88debd-66d5-4556-b6c1-b14cefabaddc" />

To fix this:

<img width="678" height="790" alt="image" src="https://github.com/user-attachments/assets/83e72e53-3063-44e0-a542-4763c0808689" />

Note: The failure occurred because the old Nginx container and new Apache container had different names, so the old container was not removed and continued using port 8080. Keeping the same container name allowed Ansible to remove the old container first and successfully deploy the new Apache container on the same port.

The output should show mostly `ok` with zero or minimal `changed`. This proves your entire setup is **idempotent**.

-->Here i replace the image from nginx to httpd and run the command: ansible-playbook site.yml So here existing container got destroyed and new one gort created with httpd:latest image hence proved entire setup is independent. 

-->Also tried to launch the Sample JioHotstar web application
<img width="1890" height="970" alt="image" src="https://github.com/user-attachments/assets/54c2994e-7dbc-4b11-a759-980decff01be" />

Steps followed: 

-->So at root level itself i have created dir: my-app & then inside created files: **Dockerfile**, **app.py**, **requirements.txt** & then also create **templates dir** and again inside it create **index.html** file etc.

-->Now go inside my-app dir: cd my-app

<img width="905" height="891" alt="image" src="https://github.com/user-attachments/assets/c606c43a-c91f-49a0-adc2-07897519537b" />

-->Then created image first: docker build -t my-flask-app:v1 .

-->Verify image is created or not: docker images

-->Create container based on image: docker run -d -p 8081:5000 my-flask-app:v1     [Note: By default, Flask runs on port 5000]

-->To verify the created container: docker ps

-->Tag the image with dockerhub username: docker tag my-flask-app:v1 sonali0910/my-flask-app:v1

-->Login to the dockerhub: docker login

-->Then push the docker image to the dockerhub: docker push sonali0910/my-flask-app:v1

-->Now get out of the dir: cd ..

-->Now at root level run command: ansible-playbook site.yml & this is how our application will get deploy on the server machine

<img width="1906" height="961" alt="image" src="https://github.com/user-attachments/assets/e3deb7a3-eaf4-4286-a49a-b6e52cf9ce74" />

-->Now ssh to the server: ssh -i ../terraform-practice/my-key.pem ubuntu@65.2.73.250

<img width="1347" height="537" alt="image" src="https://github.com/user-attachments/assets/82dac4e4-cd51-42e3-9ce0-a28537a03f5b" />

<img width="1610" height="136" alt="image" src="https://github.com/user-attachments/assets/e3db1f1b-75a0-46a0-acf2-99895e5eb419" />

**Note:** If face any issue like when on browser when we launch the application: http://65.2.73.250:8081/ At the time if we face "This site cant be reached" So to fix this we can use command: sudo docker logs <container-id> OR sudo docker logs $(sudo docker ps -lq)

-->Moreover to get the created list of files and dirs in the container use command: sudo docker exec a6e72dec097f find /app -type f

<img width="742" height="101" alt="image" src="https://github.com/user-attachments/assets/38f76a5b-4b92-49d3-90f6-cd31f5e40da4" />

-->To run the curl command at terminal: curl http://65.2.73.250:8081 & application got launched

-->And to launch the application on the browser: http://65.2.73.250:8081 & application got launched

<img width="1866" height="935" alt="image" src="https://github.com/user-attachments/assets/1906c2dd-dc83-4569-a0f6-7e5da4232e5f" />

**Reflect and document:**

1. How many total tasks ran?

<img width="1905" height="976" alt="image" src="https://github.com/user-attachments/assets/9907411b-d11c-41ec-808a-b71b9ffcde91" />

<img width="1901" height="533" alt="image" src="https://github.com/user-attachments/assets/ccc8e92f-b604-4fee-add1-5fd587b90f2f" />

-->This way: myapp container will be removed, httpd:latest will be pulled, New myapp container will start on port 8080, No extra -e arguments are needed.

2. Map each Ansible concept to the day you learned it:

| Day | Concept Used |
|-----|-------------|
| 68 | Inventory, ad-hoc commands, SSH setup |
| 69 | Playbooks, modules, handlers |
| 70 | Variables, facts, conditionals, loops |
| 71 | Roles, templates, Galaxy, Vault |
| 72 | Everything combined in one project |

<img width="690" height="557" alt="image" src="https://github.com/user-attachments/assets/e231a5b9-a10d-480b-a4e3-f63c858a7b62" />

3. What would you add for production? (SSL with certbot, monitoring, log rotation, multi-container Compose)

<img width="658" height="453" alt="image" src="https://github.com/user-attachments/assets/c879bc8b-83de-4983-b99d-2a4277c4ece2" />

4. Clean up your EC2 instances when done. If you used Terraform: `terraform destroy`. If manual: terminate from the console.
-->terraform destroy

---

## Hints
- Install `community.docker` collection before running: `ansible-galaxy collection install community.docker`
- If `community.docker` modules are not available, you can use `command` or `shell` with `docker run` as a fallback
- Nginx and the Docker container run on the same server -- Nginx listens on port 80, container on port 8080
- `nginx -t` tests the config without reloading -- always run this before a reload
- `restart_policy: always` ensures the container restarts after a server reboot
- Tags let you update just Docker containers or just Nginx config independently
- `--check --diff` is your best friend before any deployment
- If the container port conflicts with another service, change `docker_app_port` in defaults
- The `uri` module is a clean way to health-check without installing curl on the managed node

---

## Documentation
Create `day-72-ansible-project.md` with:
- Your complete project directory structure
- Key files: `site.yml`, each role's `tasks/main.yml`, the Nginx reverse proxy template
- Screenshot of `ansible-playbook site.yml` running end-to-end
- Screenshot proving idempotency (second run with all ok)
- Screenshot of `docker ps` on the server showing the running container
- Screenshot of curling port 80 through Nginx
- How you used tags for selective deployment
- How Vault protected Docker Hub credentials
- Architecture: Ansible -> Server [Nginx:80 -> Docker Container:8080]

---

## Submission
1. Add `day-72-ansible-project.md` to `2026/day-72/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Completed the Ansible block -- automated a full Docker + Nginx deployment with custom roles. Docker installed, container running, Nginx reverse-proxying, secrets encrypted with Vault. One command sets up the entire server. Five days from zero to production-grade automation."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
