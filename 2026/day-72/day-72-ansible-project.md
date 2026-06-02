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

Use tags for selective execution:
```bash
# Only set up Docker and containers
ansible-playbook site.yml --tags docker

# Only update Nginx config
ansible-playbook site.yml --tags nginx

# Skip common setup
ansible-playbook site.yml --skip-tags common
```

**Verify:**
1. Curl the server on port 8080 -- does the Docker container respond directly?
2. Curl the server on port 80 -- does Nginx reverse proxy the request to the container?
3. Check `docker ps` on the server -- is the container running with the correct port mapping?

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

The output should show mostly `ok` with zero or minimal `changed`. This proves your entire setup is **idempotent**.

**Reflect and document:**
1. How many total tasks ran?
2. Map each Ansible concept to the day you learned it:

| Day | Concept Used |
|-----|-------------|
| 68 | Inventory, ad-hoc commands, SSH setup |
| 69 | Playbooks, modules, handlers |
| 70 | Variables, facts, conditionals, loops |
| 71 | Roles, templates, Galaxy, Vault |
| 72 | Everything combined in one project |

3. What would you add for production? (SSL with certbot, monitoring, log rotation, multi-container Compose)
4. Clean up your EC2 instances when done. If you used Terraform: `terraform destroy`. If manual: terminate from the console.

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
