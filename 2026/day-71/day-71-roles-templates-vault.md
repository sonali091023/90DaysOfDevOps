# Day 71 -- Roles, Galaxy, Templates and Vault

## Task
Your playbooks are getting bigger. Tasks, variables, handlers, files -- all living in one YAML file that grows longer every day. In real projects, you manage dozens of servers with different roles -- web servers, databases, monitoring agents, load balancers. You need a way to organize, reuse, and share automation.

Today you learn Ansible Roles (the standard way to structure automation), Jinja2 Templates (dynamic config files), Ansible Galaxy (the community marketplace), and Ansible Vault (secrets management).

---

## Expected Output
- A custom Ansible role built from scratch
- A Jinja2 template rendering dynamic config files
- A role installed from Ansible Galaxy
- Secrets encrypted with Ansible Vault
- A markdown file: `day-71-roles-templates-vault.md`

---

## Challenge Tasks

### Task 1: Jinja2 Templates
Templates let you generate config files dynamically using variables and facts.

1. Create `templates/nginx-vhost.conf.j2`:
```jinja2
# Managed by Ansible -- do not edit manually
server {
    listen {{ http_port | default(80) }};
    server_name {{ ansible_hostname }};

    root /var/www/{{ app_name }};
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    access_log /var/log/nginx/{{ app_name }}_access.log;
    error_log /var/log/nginx/{{ app_name }}_error.log;
}
```

2. Create a playbook `template-demo.yml`:
```yaml
---
- name: Deploy Nginx with template
  hosts: web
  become: true
  vars:
    app_name: terraweek-app
    http_port: 80

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Create web root
      file:
        path: "/var/www/{{ app_name }}"
        state: directory
        mode: '0755'

    - name: Deploy vhost config from template
      template:
        src: templates/nginx-vhost.conf.j2
        dest: "/etc/nginx/conf.d/{{ app_name }}.conf"
        owner: root
        mode: '0644'
      notify: Restart Nginx

    - name: Deploy index page
      copy:
        content: "<h1>{{ app_name }}</h1><p>Host: {{ ansible_hostname }} | IP: {{ ansible_default_ipv4.address }}</p>"
        dest: "/var/www/{{ app_name }}/index.html"

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

Run it with `--diff` to see the rendered template:
```bash
ansible-playbook template-demo.yml --diff
```

**Steps to foloow:**

Step 1: Create the Directory Structure: Inside your ansible-practice folder: mkdir -p templates

Step 2: Create the Template File: vi nginx-vhost.conf.j2 & add above line of code into it

Step 3: Create the Playbook: vi template-demo.yml & add above line of code into it

Step 4: Check Your Inventory: Verify your inventory contains a web group **vi inventory.ini**

Step 5: Important AWS/Linux Distribution Check: here basically based on OS check the yum or apt is used in the script

Step 6: Dry Run First: So before changing anything, This shows what Ansible would do: ansible-playbook -i inventory.ini template-demo.yml --check

<img width="1911" height="507" alt="image" src="https://github.com/user-attachments/assets/e72beee7-225c-4df9-ab36-acfe65b1b4b8" />

step 7: Test connectivity before running the playbook: ansible web -i inventory.ini -m ping

<img width="1450" height="226" alt="image" src="https://github.com/user-attachments/assets/956e8b51-6076-4eb7-af3e-86d32c776c81" />

Step 8: Run with Diff: ansible-playbook -i inventory.ini template-demo.yml --diff

-->So here Ansible will Connect to that one server, Install Nginx, Create /var/www/terraweek-app, Generate the Nginx config from the Jinja2 template, Create the index.html, Restart Nginx etc.

<img width="1902" height="962" alt="image" src="https://github.com/user-attachments/assets/08828ad9-93fe-4ff4-820c-81de20a03558" />
<img width="1913" height="693" alt="image" src="https://github.com/user-attachments/assets/9a677ea6-428f-4212-af5d-592af2bb5206" />

Step 8: SSH Into the Server: ssh -i ../terraform-practice/my-key.pem ubuntu@3.110.204.168

<img width="1708" height="547" alt="image" src="https://github.com/user-attachments/assets/53ec7571-04ac-4626-9cf8-be4893e30dce" />

Step 9: Verify the Generated Config: View the generated file: sudo cat /etc/nginx/conf.d/terraweek-app.conf

<img width="992" height="362" alt="image" src="https://github.com/user-attachments/assets/2cd554ca-9569-4d5d-b501-b1e5afb8fc53" />

Step 10: Verify the Web Page: Check the generated HTML:

<img width="1227" height="61" alt="image" src="https://github.com/user-attachments/assets/197d80dd-ef24-4c33-974d-465750226261" />

<img width="718" height="750" alt="image" src="https://github.com/user-attachments/assets/21bcb343-f05c-4538-b3b3-707f598479e6" />

**Note:** If Nginx fails to restart after deployment, test the configuration: **sudo nginx -t** This will show the exact line causing the issue and is the first troubleshooting step most 
DevOps engineers use after deploying a new Nginx configuration.

-->Ansibles stength: That write the script ince and apply it on to many machinse.

<img width="710" height="452" alt="image" src="https://github.com/user-attachments/assets/aadb29a8-d5d0-4198-b4bd-a078e0744d1b" />

**Issue faced:** The authenticity of host '13.201.19.61 (13.201.19.61)' can't be established. ED25519 key fingerprint is SHA256:dhT2Knaq9IL1NFh0U4444444444444444444444444444444. This key is not known by any other names.

-->1. Check whether the key file exists: ls -l ../terraform-practice/my-key.pem

-->2. Check the contents of the PEM file: If in case file is currpt then we cant see the file content: cat terrform-practice/my-key.pem 

-->3. Check file permissions: It should be available for user only that is also in read state only: ls -l /home/sona/trainwithshubham/90DaysOfDevOps/2026/day-71/terraform-practice/my-key.pem

-->4. Validate the key format: ssh-keygen -l -f /home/sona/trainwithshubham/90DaysOfDevOps/2026/day-71/terraform-practice/my-key.pem

-->5. Think back to how the key was created: first check how was .pem file was created whether it is created via aws console or manually, or by using command & if it is created via command in 
that case first detstoy the created instance for that use command: **terraform destroy** 

-->If the key is damaged: As we have destroyed the instance now delete the .pem file for that use command: **rm my-key.pem** Now keep the one thing in mind that is AWS only gives you the 
private key once means When you run create-key-pair, AWS returns the private key material exactly one time. If you lose or corrupt my-key.pem, AWS cannot regenerate it for that key pair.

-->You cannot create another key pair with the same AWS key name, And if wanted to create the easiest solution is often, Delete the old key pair in AWS:**aws ec2 delete-key-pair --key-name my-key**

-->Create a fresh key pair: **aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem**

-->Once the key gets create secure it with the command: **chmod 400 my-key.pem**

<img width="762" height="812" alt="image" src="https://github.com/user-attachments/assets/02a3c109-6a67-477b-97a4-6e1de75cf27c" />

**Verify:** SSH into the web server and read the generated config. Are the variables replaced with actual values?

-->Yes. After SSHing into the server and viewing the generated configuration file, the Jinja2 variables were replaced with actual values. To check use 
command: **sudo cat /etc/nginx/conf.d/terraweek-app.conf**
<img width="742" height="283" alt="image" src="https://github.com/user-attachments/assets/900854ae-4af9-4a55-bff2-fc35db4075ec" />

---

### Task 2: Understand the Role Structure
An Ansible role has a fixed directory structure. Each directory has a specific purpose:

```
roles/
  webserver/
    tasks/
      main.yml         # The main task list
    handlers/
      main.yml         # Handlers (restart services, etc.)
    templates/
      nginx.conf.j2    # Jinja2 templates
    files/
      index.html       # Static files to copy
    vars/
      main.yml         # Role variables (high priority)
    defaults/
      main.yml         # Default variables (low priority, easily overridden)
    meta/
      main.yml         # Role metadata and dependencies
```

Every directory contains a `main.yml` that Ansible loads automatically. You only create the directories you need.

Generate a skeleton with:
```bash
ansible-galaxy init roles/webserver
```

**Steps to follow:**

Step 1: Move to Your Ansible Practice Directory

Step 2: Generate the Role Skeleton: ansible-galaxy init roles/webserver

Step 3: Explore the Generated Structure: tree roles/webserver

<img width="1451" height="605" alt="image" src="https://github.com/user-attachments/assets/8343367e-6e02-473f-9a66-91635bd82eec" />

Step 4: Understand Each Directory:

<img width="372" height="795" alt="image" src="https://github.com/user-attachments/assets/e51ad939-76f5-47c7-9a8a-de45ae45a831" />

<img width="362" height="780" alt="image" src="https://github.com/user-attachments/assets/0d12f687-4136-46d6-adeb-d4fe2ad76cd4" />

<img width="322" height="567" alt="image" src="https://github.com/user-attachments/assets/f7c5671f-1035-4143-9ef8-b608dd144f6d" />

<img width="437" height="812" alt="image" src="https://github.com/user-attachments/assets/4bc7bf72-49ce-4489-b75c-4dc7ea8f551f" />

Explore the generated directory. Read the README.md that Galaxy creates.

Step 5: Open Every main.yml: 

-->cat roles/webserver/tasks/main.yml

-->cat roles/webserver/handlers/main.yml

-->cat roles/webserver/defaults/main.yml

-->cat roles/webserver/vars/main.yml

-->cat roles/webserver/meta/main.yml

Note: Notice that most contain comments only. They are placeholders waiting for your configuration.

<img width="1465" height="973" alt="image" src="https://github.com/user-attachments/assets/1dcaff4b-289f-4d7e-8820-d7a2d7b3ce14" />

**Document:** What is the difference between `vars/main.yml` and `defaults/main.yml`?

-->This is one of the most important Ansible interview questions.

<img width="771" height="252" alt="image" src="https://github.com/user-attachments/assets/091f4d31-3cb2-48c7-a74f-836ecdc44145" />

<img width="746" height="763" alt="image" src="https://github.com/user-attachments/assets/116253a8-61d3-418c-a3b2-2e4ad39cc6bb" />

<img width="673" height="646" alt="image" src="https://github.com/user-attachments/assets/16e9a98b-ba9b-4929-a64a-0042ce9ea4f6" />


---

### Task 3: Build a Custom Webserver Role
Build a complete `webserver` role from scratch:

**`roles/webserver/defaults/main.yml`:**
```yaml
---
http_port: 80
app_name: myapp
max_connections: 512
```

**`roles/webserver/tasks/main.yml`:**
```yaml
---
- name: Install Nginx
  yum:
    name: nginx
    state: present

- name: Deploy Nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    mode: '0644'
  notify: Restart Nginx

- name: Deploy vhost config
  template:
    src: vhost.conf.j2
    dest: "/etc/nginx/conf.d/{{ app_name }}.conf"
    owner: root
    mode: '0644'
  notify: Restart Nginx

- name: Create web root
  file:
    path: "/var/www/{{ app_name }}"
    state: directory
    mode: '0755'

- name: Deploy index page
  template:
    src: index.html.j2
    dest: "/var/www/{{ app_name }}/index.html"
    mode: '0644'

- name: Start and enable Nginx
  service:
    name: nginx
    state: started
    enabled: true
```

**`roles/webserver/handlers/main.yml`:**
```yaml
---
- name: Restart Nginx
  service:
    name: nginx
    state: restarted
```

**`roles/webserver/templates/index.html.j2`:**
```html
<h1>{{ app_name }}</h1>
<p>Server: {{ ansible_hostname }}</p>
<p>IP: {{ ansible_default_ipv4.address }}</p>
<p>Environment: {{ app_env | default('development') }}</p>
<p>Managed by Ansible</p>
```

Create the `vhost.conf.j2` and `nginx.conf.j2` templates yourself based on what you learned in Task 1.

Now call the role from a playbook `site.yml`:
```yaml
---
- name: Configure web servers
  hosts: web
  become: true
  roles:
    - role: webserver
      vars:
        app_name: terraweek
        http_port: 80
```

Run it:
```bash
ansible-playbook site.yml
```

**Steps to follow:**

Step 1: Verify Role Structure: tree roles/webserver

Step 2: Create Default Variables: vi roles/webserver/defaults/main.yml

Step 3: Create Tasks: vi roles/webserver/tasks/main.yml & add above code into it

Step 4: Create Handler: vi roles/webserver/handlers/main.yml

Step 5: Create index.html Template: vi roles/webserver/templates/index.html.j2

Step 6: Create nginx.conf.j2: You built Nginx templates in Task 1. Create: vi roles/webserver/templates/nginx.conf.j2

Step 7: Create vhost.conf.j2: vi roles/webserver/templates/vhost.conf.j2

Step 8: Create site.yml: Create it in the root of ansible project: vi site.yml

Step 9: Validate YAML: In the root of your Ansible project: Inside playbooks directory

Step 9: Validate YAML: Before running, check syntax: ansible-playbook -i inventory.ini playbooks/site.yml --syntax-check

<img width="1383" height="82" alt="image" src="https://github.com/user-attachments/assets/9ec67007-2b4f-4472-980f-60ac06318810" />

Step 10: Run the Role: ansible-playbook -i inventory.ini playbooks/site.yml

<img width="1901" height="967" alt="image" src="https://github.com/user-attachments/assets/8d6f9028-a866-4a6f-98d5-51f0f200de9f" />

<img width="1902" height="707" alt="image" src="https://github.com/user-attachments/assets/90a66a80-0487-47b6-ab8d-23ddaa2123a1" />

**Faced issue:** in file: vi roles/webserver/templates/vhost.conf.j2 mentioned user as nginx, That works on some distributions such as Amazon Linux, but on Ubuntu the Nginx service runs as: ubuntu, To confirm Check your OS: cat /etc/os-release, If it is ubuntu then make chnages in the file: vi roles/webserver/templates/vhost.conf.j2 

<img width="1918" height="873" alt="image" src="https://github.com/user-attachments/assets/e7e804b0-bcc5-4b3f-a8a2-bdefc945a8cc" />

Step 11: Verify Nginx Service: ssh -i ../terraform-practice/my-key.pem ubuntu@3.110.204.168

<img width="1418" height="493" alt="image" src="https://github.com/user-attachments/assets/85ca9e55-1b28-4344-b604-b7cbb14c5adc" />

-->sudo systemctl status nginx

<img width="1365" height="375" alt="image" src="https://github.com/user-attachments/assets/646af9fd-e2d8-4079-9265-bfea5542c057" />

Step 12: Verify Generated Files

-->Check Nginx config: sudo cat /etc/nginx/nginx.conf

-->Check virtual host: sudo cat /etc/nginx/conf.d/terraweek.conf

-->Check generated webpage: cat /var/www/terraweek/index.html

<img width="1482" height="752" alt="image" src="https://github.com/user-attachments/assets/bcf9f7bb-e1d2-4abe-a3db-c39f825e95d8" />

Step 13: Curl from the Server: curl localhost

<img width="1095" height="40" alt="image" src="https://github.com/user-attachments/assets/7d080c58-483e-4c8f-a087-546c2ac93a14" />

**Verify:** Curl the web server. Does the custom page load?

-->Yes, that's the final verification step for the task. After fixing Nginx and rerunning the playbook successfully, verify in this order:

Step 14: Curl from Your Laptop: ansible all -i inventory.ini -m shell -a "curl -s ifconfig.me"

<img width="1676" height="133" alt="image" src="https://github.com/user-attachments/assets/389cc80c-f9ce-4d00-ae0c-0ebc254a5510" />

-->curl http://3.110.204.168

<img width="1658" height="62" alt="image" src="https://github.com/user-attachments/assets/1d8a440f-318f-4538-8aea-5ab8e6156130" />

<img width="655" height="292" alt="image" src="https://github.com/user-attachments/assets/b343c900-b25b-4e79-9fe9-6694e2f2098f" />

-->Nginx listening on port 80: sudo ss -tulpn | grep :80

<img width="1620" height="72" alt="image" src="https://github.com/user-attachments/assets/f063ad8d-aadb-4c07-8f2f-1b08b5b229e0" />

-->Web root exists: ls -l /var/www/terraweek

-->Generated page exists: cat /var/www/terraweek/index.html

<img width="740" height="202" alt="image" src="https://github.com/user-attachments/assets/d6ecefe3-0cd1-4eeb-8737-04c194a8749e" />

---

### Task 4: Ansible Galaxy -- Use Community Roles
Ansible Galaxy is a marketplace of pre-built roles.

1. **Search for roles:**
```bash
ansible-galaxy search nginx --platforms EL
ansible-galaxy search mysql
```

2. **Install a role from Galaxy:**
```bash
ansible-galaxy install geerlingguy.docker
```

3. **Check where it was installed:**
```bash
ansible-galaxy list
```

4. **Use the installed role** -- create `docker-setup.yml`:
```yaml
---
- name: Install Docker using Galaxy role
  hosts: app
  become: true
  roles:
    - geerlingguy.docker
```

Run it -- Docker gets installed with a single role call.

5. **Use a requirements file** for managing multiple roles. Create `requirements.yml`:
```yaml
---
roles:
  - name: geerlingguy.docker
    version: "7.4.1"
  - name: geerlingguy.ntp
```

Install all at once:
```bash
ansible-galaxy install -r requirements.yml
```

**Steps to follow:**

Step 1: Move to Your Ansible Project: Go inside ansible-practice directory & run command: ansible-galaxy --version

<img width="1290" height="195" alt="image" src="https://github.com/user-attachments/assets/d706e1d4-22ce-4075-be54-e95ceb18f387" />

Step 2: Search for Roles: Search for Nginx roles: ansible-galaxy search nginx, Search for MySQL roles: ansible-galaxy search mysql

<img width="1705" height="955" alt="image" src="https://github.com/user-attachments/assets/c09710ee-0887-41d6-b5c5-09059129d3b1" />

<img width="1890" height="977" alt="image" src="https://github.com/user-attachments/assets/918599f4-1eb0-4816-a304-a70cd653df89" />

Step 3: Install a Galaxy Role: ansible-galaxy role install geerlingguy.docker

<img width="1628" height="177" alt="image" src="https://github.com/user-attachments/assets/e2cc60a1-dd76-4953-a042-ca515f5742eb" />

Step 4: Verify Installation: List installed roles: ansible-galaxy role list

<img width="1352" height="150" alt="image" src="https://github.com/user-attachments/assets/42dd78db-e587-41ad-a4f5-b9ce3ce6d3f5" />

Step 5: Inspect the Installed Role: Find where it was installed: ls roles/geerlingguy.docker

<img width="1446" height="82" alt="image" src="https://github.com/user-attachments/assets/edaf81f2-dad2-4d8d-999a-3e1d2eee93f4" />

-->vi roles/geerlingguy.docker/README.md This is very important. Before using any Galaxy role, always read: Supported operating systems, Required variables, Example playbook, Dependencies etc.

Step 6: Create a New Inventory Group: add an app group to your inventory: [web] web-server ansible_host=3.110.204.168

Step 7: Create docker-setup.yml: vi playbooks/docker-setup.yml

<img width="400" height="143" alt="image" src="https://github.com/user-attachments/assets/c755dbd8-2e6e-40f2-8d1e-caf33a3735f6" />

Step 8: Syntax Check: ansible-playbook -i inventory.ini playbooks/docker-setup.yml --syntax-check

<img width="1891" height="97" alt="image" src="https://github.com/user-attachments/assets/153d7cc3-eb27-459d-b144-52b6390afe9b" />

Step 9: Run the Playbook: ansible-playbook -i inventory.ini playbooks/docker-setup.yml 

<img width="1918" height="976" alt="image" src="https://github.com/user-attachments/assets/c6ef59af-8653-4d0e-9afb-171e564b86c7" />

<img width="1907" height="977" alt="image" src="https://github.com/user-attachments/assets/897010fe-2a8b-4833-9f98-d581f2c2a0a8" />

<img width="1910" height="347" alt="image" src="https://github.com/user-attachments/assets/80f7b72e-a9e4-44ec-b312-a48efdcb21d7" />

-->The role may: Install Docker packages, Start Docker service, Configure repositories, Enable service All through one role call.

Step 10: Verify Docker: SSH into the server: ssh -i ../terraform-practice/my-key.pem ubuntu@3.110.204.168

-->docker --version

-->sudo systemctl status docker

<img width="1850" height="973" alt="image" src="https://github.com/user-attachments/assets/a708c9fe-6e97-4943-bde1-0cdabb8d6aab" />

Step 11: Use requirements.yml: Ok exit from the ubuntu user and crearte file vi requirements.yml and add below code into it,

<img width="252" height="128" alt="image" src="https://github.com/user-attachments/assets/32e824c1-7e6c-420f-bedb-34ce4d22f49a" />

Step 12: Install All Roles at Once: Here Ansible reads the file and installs every listed role: ansible-galaxy role install -r requirements.yml

<img width="1687" height="218" alt="image" src="https://github.com/user-attachments/assets/9b475711-604c-43c1-83fe-d1bbef6bad1c" />

Step 13: Verify: ansible-galaxy role list

<img width="1522" height="146" alt="image" src="https://github.com/user-attachments/assets/d97bf2d9-ac90-4439-8d97-7930f00cae27" />

**Document:** Why use a `requirements.yml` instead of installing roles manually?
-->requirements.yml provides a declarative and reproducible way to manage Ansible role dependencies. Instead of manually installing each role, all required roles and versions are stored in a single file. Team members, CI/CD pipelines, and new environments can install the exact same set of roles using one command. This improves consistency, version control, automation, and maintainability.

<img width="578" height="781" alt="image" src="https://github.com/user-attachments/assets/1fc933be-7613-407e-b84c-03cc87c7cf7f" />

---

### Task 5: Ansible Vault -- Encrypt Secrets
Never put passwords, API keys, or tokens in plain text. Ansible Vault encrypts sensitive data.

1. **Create an encrypted file:**
```bash
ansible-vault create group_vars/db/vault.yml
```
It will ask for a vault password, then open an editor. Add:
```yaml
vault_db_password: SuperSecretP@ssw0rd
vault_db_root_password: R00tP@ssw0rd123
vault_api_key: sk-abc123xyz789
```
Save and exit. Open the file with `cat` -- it is fully encrypted.

2. **Edit an encrypted file:**
```bash
ansible-vault edit group_vars/db/vault.yml
```

3. **View without editing:**
```bash
ansible-vault view group_vars/db/vault.yml
```

4. **Encrypt an existing file:**
```bash
ansible-vault encrypt group_vars/db/secrets.yml
```

5. **Use vault variables in a playbook** -- create `db-setup.yml`:
```yaml
---
- name: Configure database
  hosts: db
  become: true

  tasks:
    - name: Show DB password (never do this in production)
      debug:
        msg: "DB password is set: {{ vault_db_password | length > 0 }}"
```

Run with the vault password:
```bash
ansible-playbook db-setup.yml --ask-vault-pass
```

6. **Use a password file** (better for CI/CD):
```bash
echo "YourVaultPassword" > .vault_pass
chmod 600 .vault_pass
echo ".vault_pass" >> .gitignore

ansible-playbook db-setup.yml --vault-password-file .vault_pass
```

Or set it in `ansible.cfg`:
```ini
[defaults]
vault_password_file = .vault_pass
```

**Steps to follow:**

Step 1: Create the db Directory: Go to ansible-practice dir & then mkdir -p group_vars/db latter run command: tree group_vars

<img width="1295" height="265" alt="image" src="https://github.com/user-attachments/assets/8f5ce82a-5121-4a22-afb7-85bf083de852" />

Step 2: Create an Encrypted Vault File: ansible-vault create group_vars/db/vault.yml So once we run this command we will be prompted to set the valut passowrd

<img width="312" height="76" alt="image" src="https://github.com/user-attachments/assets/f8562f82-141d-49b7-9836-e759a997929e" />

Step 3: Verify Encryption: cat group_vars/db/vault.yml That means the secrets are encrypted.

<img width="1476" height="308" alt="image" src="https://github.com/user-attachments/assets/24e76cfd-93af-4d23-b19c-2e306f6d1016" />

Step 4: View Without Editing: ansible-vault view group_vars/db/vault.yml

<img width="1498" height="186" alt="image" src="https://github.com/user-attachments/assets/30cf98f4-7c0f-4b74-b316-acaa670861c4" />

Step 5: Edit the Vault: ansible-vault edit group_vars/db/vault.yml Edit the valut_api_key and then save the changes

Step 6: Create the Test Playbook: vi playbooks/db-setup.yml

<img width="542" height="192" alt="image" src="https://github.com/user-attachments/assets/dbe819e1-38c4-46ab-8bfd-966f94cee076" />

Step 7: Make Sure You Have a DB Group: cat inventory.ini

Step 8: Run with Vault Password Prompt: ansible-playbook -i inventory.ini playbooks/db-setup.yml --ask-vault-pass

<img width="1918" height="433" alt="image" src="https://github.com/user-attachments/assets/1e1f5429-4692-489e-8640-f447d08588a4" />

-->Notice: The secret is used, The actual password is not displayed.

Step 9: Create a Vault Password File: echo "admin123" > .vault_pass & then run command to set the secure permission: chmod 600 .vault_pass and then to check the permission: ls -l .vault_pass

<img width="1665" height="186" alt="image" src="https://github.com/user-attachments/assets/21a8759f-45ae-4383-aed7-856d2f276aa8" />

Step 10: Prevent Git from Tracking It: vi .gitignore in this file add following file .vault_pass & then runt git status command

<img width="1335" height="243" alt="image" src="https://github.com/user-attachments/assets/3e97db78-ef43-425d-965c-bdeb3170b13c" />

Step 11: Run Without Prompting: ansible-playbook -i inventory.ini playbooks/db-setup.yml --vault-password-file .vault_pass

<img width="1911" height="413" alt="image" src="https://github.com/user-attachments/assets/8cb4f4de-637b-43c2-9466-8ddbe4c61a0b" />

Step 12: Configure ansible.cfg: In this file added the vault password file: vi ansible.cfg

-->Now you can simply run: ansible-playbook playbooks/db-setup.yml

<img width="1918" height="390" alt="image" src="https://github.com/user-attachments/assets/6c6a7359-3cba-4392-853f-8f9f432c95fd" />

**Document:** Why is `--vault-password-file` better than `--ask-vault-pass` for automated pipelines?

--> --vault-password-file enables non-interactive execution, which is required for CI/CD systems such as Jenkins, GitHub Actions, GitLab CI, and Azure DevOps. Automated pipelines cannot manually enter passwords. By storing the vault password in a secured file or secret manager and referencing it through --vault-password-file, playbooks can decrypt secrets automatically while maintaining security and automation.

<img width="702" height="183" alt="image" src="https://github.com/user-attachments/assets/c9ce469c-be0f-427a-b594-bcc3dd5f58eb" />

**Note:** Best Practice For learning: .vault_pass For production: Store vault passwords in Jenkins credentials, Use GitHub Secrets, Use HashiCorp Vault, Never commit vault passwords to Git etc.

That separation of encrypted data and password storage is the key concept behind Ansible Vault. 

---

### Task 6: Combine Roles, Templates, and Vault
Write a complete `site.yml` that uses everything you learned today:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true
  roles:
    - role: webserver
      vars:
        app_name: terraweek
        http_port: 80

- name: Configure app servers with Docker
  hosts: app
  become: true
  roles:
    - geerlingguy.docker

- name: Configure database servers
  hosts: db
  become: true
  tasks:
    - name: Create DB config with secrets
      template:
        src: templates/db-config.j2
        dest: /etc/db-config.env
        owner: root
        mode: '0600'
```

Create `templates/db-config.j2`:
```jinja2
# Database Configuration -- Managed by Ansible
DB_HOST={{ ansible_default_ipv4.address }}
DB_PORT={{ db_port | default(3306) }}
DB_PASSWORD={{ vault_db_password }}
DB_ROOT_PASSWORD={{ vault_db_root_password }}
```

Run:
```bash
ansible-playbook site.yml
```

**Steps to follow:**

-->This task is basically a mini real-world infrastructure project because it combines: Roles, Templates, Ansible Galaxy, Vault, Variables, Multiple host groups Let's do it step by step.

Step 1: Check Your Inventory: vi inventory.ini

<img width="1463" height="438" alt="image" src="https://github.com/user-attachments/assets/807fcc97-3424-4c95-9058-45f5ac49db3a" />

Step 2: Verify Project Structure: use command: tree

<img width="1061" height="947" alt="image" src="https://github.com/user-attachments/assets/199e175e-b7af-4608-af94-9a0317782342" />
<img width="1215" height="907" alt="image" src="https://github.com/user-attachments/assets/5489cde0-d951-44dd-b086-5683a91da986" />

Step 3: Create the Database Templates: mkdir -p templates && templates/db-config.j2

<img width="351" height="122" alt="image" src="https://github.com/user-attachments/assets/b9cd2a2c-9c74-438b-bf3d-ad639be53bc7" />

Step 4: Create/Update site.yml: Because your playbooks are inside playbooks/: vi playbooks/site.yml

**Note:** Important Because: playbooks/site.yml is inside playbooks/ and templates/db-config.j2 is at the project root, you may need: src: ../templates/db-config.j2, If Ansible later complains it can't find the template, we'll move it into a role or adjust the path.

Step 5: Verify Vault Variables Exist: ansible-vault view group_vars/db/vault.yml

<img width="1197" height="102" alt="image" src="https://github.com/user-attachments/assets/1d0c4a80-b22f-4439-b2c1-4f69b6b29456" />

Step 6: Syntax Check: To check the ansible-practice dir structurre: ansible-playbook playbooks/site.yml --syntax-check

<img width="1185" height="60" alt="image" src="https://github.com/user-attachments/assets/3c588d72-0d65-4f9a-a14b-f3b49907462c" />

Step 7: Run the Playbook: If you configured: vault_password_file = .vault_pass inside ansible.cfg: ansible-playbook playbooks/site.yml







**Verify:** SSH into the db server and check `/etc/db-config.env`. Are the secrets rendered correctly? Is the file permission `600`?

---

## Hints
- Templates use `.j2` extension by convention (Jinja2)
- In templates, `{{ variable }}` renders a value, `{% if %}` is a conditional, `{% for %}` is a loop
- `| default(value)` is a Jinja2 filter that provides a fallback if the variable is undefined
- Role `defaults/` has the lowest priority -- callers can easily override these values
- Role `vars/` has high priority -- use it for values that should not be overridden
- `ansible-galaxy init` creates the full skeleton, but you can delete directories you don't use
- Vault-encrypted files are normal YAML after decryption -- Ansible handles it transparently
- Never commit `.vault_pass` to Git -- always add it to `.gitignore`
- Use `ansible-vault encrypt_string` to encrypt a single value inline instead of a whole file

---

## Documentation
Create `day-71-roles-templates-vault.md` with:
- Your webserver role directory structure
- The Jinja2 templates you created and the rendered output
- Screenshot of the role running successfully
- How you installed and used a Galaxy role
- Vault workflow: create, edit, view, encrypt, decrypt
- Screenshot of the encrypted vault file contents
- When to use roles vs playbooks vs ad-hoc commands

---

## Submission
1. Add `day-71-roles-templates-vault.md` to `2026/day-71/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Built my first Ansible role today -- organized tasks, templates, handlers, and defaults into a reusable structure. Used Galaxy to install community roles, Jinja2 for dynamic configs, and Vault to encrypt secrets. This is production-grade automation."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
