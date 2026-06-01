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

Explore the generated directory. Read the README.md that Galaxy creates.

**Document:** What is the difference between `vars/main.yml` and `defaults/main.yml`?

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

**Verify:** Curl the web server. Does the custom page load?

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

**Document:** Why use a `requirements.yml` instead of installing roles manually?

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

**Document:** Why is `--vault-password-file` better than `--ask-vault-pass` for automated pipelines?

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
