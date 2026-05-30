# Day 69 -- Ansible Playbooks and Modules

## Task
Ad-hoc commands are useful for quick checks, but real automation lives in playbooks. A playbook is a YAML file that describes the desired state of your servers -- 
which packages to install, which services to run, which files to place where. You write it once, run it a hundred times, and get the same result every time.

Today you write your first playbooks and learn the modules that you will use on every project.

---

## Expected Output
- Multiple playbooks that install packages, manage services, and configure files
- A clear understanding of plays, tasks, modules, and handlers
- A markdown file: `day-69-playbooks.md`

---

## Challenge Tasks

### Task 1: Your First Playbook
Create `install-nginx.yml`:

```yaml
---
- name: Install and start Nginx on web servers
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Start and enable Nginx
      service:
        name: nginx
        state: started
        enabled: true

    - name: Create a custom index page
      copy:
        content: "<h1>Deployed by Ansible - TerraWeek Server</h1>"
        dest: /usr/share/nginx/html/index.html
```

(Use `apt` instead of `yum` if your instances run Ubuntu)

Run it:
```bash
ansible-playbook install-nginx.yml
```

**Steps to perform:**

1. Create inventery.ini file

2. Create terraform_practice dir under that also create files name as main.tf, variables.tf, terraform.tfvars, outputs.tf etc. Also create my-key.pem file. For that use command:
**aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > my-key.pem**

3. Once the my-key.pem file will get create chnage the executable permission of the file for user, group and other for that use command: **sudo chmod 400 my-key.pem** to avoid error,
<img width="1916" height="227" alt="image" src="https://github.com/user-attachments/assets/bae2ebe3-af83-42ad-9e2a-fa0018e507c9" />
<img width="805" height="792" alt="image" src="https://github.com/user-attachments/assets/22a24044-f11f-4061-a783-d8271fd43957" />

Troubleshooting commands: Before running command: **ansible all -i inventory.ini -m ping** Run below commands and try to handle the issue, 

-->Command: **ansible-inventory -i inventory.ini --list**: "Show me exactly how Ansible understands my inventory file.", is used to display the inventory in JSON format after Ansible processes it.
<img width="1832" height="565" alt="image" src="https://github.com/user-attachments/assets/aa561206-7fc2-48cf-91d8-941ac6a10b30" />

-->Command: **ansible-inventory -i inventory.ini --graph**: This is graphicial/visual view which is better than json, This helps catch inventory mistakes before troubleshooting SSH or playbook issues.
<img width="1533" height="152" alt="image" src="https://github.com/user-attachments/assets/773cadc9-28bc-42f7-bda1-08eaccb99eba" />

4. Then create above mentioned file **vi install-nginx.yml** and add above code to install nginx

5. then check the connectivity by running command: **ansible -i inventory.ini web -m ping**
<img width="1657" height="222" alt="image" src="https://github.com/user-attachments/assets/b18c23f2-0b6b-49f3-be52-c9354c2ac4a8" />

6. Then run command to install nginx: **ansible-playbook -i inventory.ini install-nginx.yml** And nginx will get install to the server

7. Read the output carefully -- every task shows `changed`, `ok`, or `failed`.
<img width="1900" height="476" alt="image" src="https://github.com/user-attachments/assets/2114ad2b-f01b-4bdc-aef5-8723b4be0ace" />

Now run it **again**. Notice that tasks show `ok` instead of `changed`. This is **idempotency** -- Ansible only makes changes when needed.
<img width="1917" height="487" alt="image" src="https://github.com/user-attachments/assets/f025826e-59a0-4b74-9f21-7cd005fbcbea" />

**Verify:** Curl the web server's public IP. Do you see your custom page?
<img width="1248" height="592" alt="image" src="https://github.com/user-attachments/assets/75e6a095-ede8-4b43-b241-76e455e34856" />

---

### Task 2: Understand the Playbook Structure
Open your playbook and annotate each part in your notes:

```yaml
---                                    # YAML document start
- name: Play name                      # PLAY -- targets a group of hosts
  hosts: web                           # Which inventory group to run on
  become: true                         # Run tasks as root (sudo)

  tasks:                               # List of TASKS in this play
    - name: Task name                  # TASK -- one unit of work
      module_name:                     # MODULE -- what Ansible does
        key: value                     # Module arguments
```

Answer:
1. What is the difference between a play and a task?

-->A play defines: Which hosts to target, Which user to run as, Which tasks to execute OR Defines target hosts and contains tasks.
<img width="460" height="228" alt="image" src="https://github.com/user-attachments/assets/5c7d054c-455e-4e56-a6ed-5e90e5256ac0" />

-->A task is a single action. OR A single unit of work performed using a module
<img width="215" height="270" alt="image" src="https://github.com/user-attachments/assets/e69a203e-ce81-4b8e-99ac-b05f467a6631" />
<img width="188" height="307" alt="image" src="https://github.com/user-attachments/assets/065da4cb-a47e-44b5-a692-74ea8ea7738f" />

2. Can you have multiple plays in one playbook?

-->Yes, One playbook can contain multiple plays targeting different host groups.
<img width="520" height="632" alt="image" src="https://github.com/user-attachments/assets/92a91479-9012-4202-991e-da80bc479b0a" />

3. What does `become: true` do at the play level vs the task level?

-->**Play Level:** All tasks inherit sudo privileges. Whcih are Equivalent to: Task 1: sudo, Task 2: sudo, Task 3: sudo , Even in case You write it once. OR Play level → applies to all tasks.
<img width="152" height="181" alt="image" src="https://github.com/user-attachments/assets/d6c2ca5f-1d11-4f78-a30f-6f381d7cf703" />

-->**Task Level:** Only this task uses sudo. Other tasks run as the normal user OR Task level → applies only to that specific task.
<img width="272" height="393" alt="image" src="https://github.com/user-attachments/assets/9df1566a-851b-4095-be1a-4a9183f3131b" />

4. What happens if a task fails -- do remaining tasks still run?

-->No. Ansible stops executing further tasks for that host. If Task 1 fails: TASK [Install Nginx] FAILED, Task 2 will not run on that host.

-->By default, Ansible stops executing subsequent tasks for that host unless ignore_errors: true is used.
<img width="257" height="296" alt="image" src="https://github.com/user-attachments/assets/27f40faf-3ce4-4a51-a26d-e3d6bb2dd2b5" />
<img width="455" height="487" alt="image" src="https://github.com/user-attachments/assets/7bf4842e-9ede-47ee-8d10-c52b154275a8" />

---

### Task 3: Learn the Essential Modules
Practice each of these modules by writing a playbook called `essential-modules.yml` with multiple tasks:

1. **`yum`/`apt`** -- Install and remove packages:
```yaml
- name: Install multiple packages
  yum:
    name:
      - git
      - curl
      - wget
      - tree
    state: present
```

2. **`service`** -- Manage services:
```yaml
- name: Ensure Nginx is running
  service:
    name: nginx
    state: started
    enabled: true
```

3. **`copy`** -- Copy files from control node to managed nodes:
```yaml
- name: Copy config file
  copy:
    src: files/app.conf
    dest: /etc/app.conf
    owner: root
    group: root
    mode: '0644'
```

4. **`file`** -- Create directories and manage permissions:
```yaml
- name: Create application directory
  file:
    path: /opt/myapp
    state: directory
    owner: ec2-user
    mode: '0755'
```

5. **`command`** -- Run a command (no shell features):
```yaml
- name: Check disk space
  command: df -h
  register: disk_output

- name: Print disk space
  debug:
    var: disk_output.stdout_lines
```

6. **`shell`** -- Run a command with shell features (pipes, redirects):
```yaml
- name: Count running processes
  shell: ps aux | wc -l
  register: process_count

- name: Show process count
  debug:
    msg: "Total processes: {{ process_count.stdout }}"
```

7. **`lineinfile`** -- Add or modify a single line in a file:
```yaml
- name: Set timezone in environment
  lineinfile:
    path: /etc/environment
    line: 'TZ=Asia/Kolkata'
    create: true
```

Create a `files/` directory with a sample `app.conf` file for the copy task. Run the playbook against all servers.

**Document:** What is the difference between `command` and `shell`? When should you use each?

---

### Task 4: Handlers -- Restart Services Only When Needed
Handlers are tasks that run only when triggered by a `notify`. This avoids unnecessary service restarts.

Create `nginx-config.yml`:
```yaml
---
- name: Configure Nginx with a custom config
  hosts: web
  become: true

  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present

    - name: Deploy Nginx config
      copy:
        src: files/nginx.conf
        dest: /etc/nginx/nginx.conf
        owner: root
        mode: '0644'
      notify: Restart Nginx

    - name: Deploy custom index page
      copy:
        content: "<h1>Managed by Ansible</h1><p>Server: {{ inventory_hostname }}</p>"
        dest: /usr/share/nginx/html/index.html

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: true

  handlers:
    - name: Restart Nginx
      service:
        name: nginx
        state: restarted
```

Create `files/nginx.conf` with a basic Nginx config.

Run the playbook:
- First run: handler triggers because the config file is new
- Second run: handler does NOT trigger because nothing changed

**Verify:** Run it twice and compare the output. Does the handler run both times?

---

### Task 5: Dry Run, Diff, and Verbosity
Before running playbooks on production, always preview changes first.

1. **Dry run (check mode)** -- shows what would change without changing anything:
```bash
ansible-playbook install-nginx.yml --check
```

2. **Diff mode** -- shows the actual file differences:
```bash
ansible-playbook nginx-config.yml --check --diff
```

3. **Verbosity** -- increase output detail for debugging:
```bash
ansible-playbook install-nginx.yml -v       # verbose
ansible-playbook install-nginx.yml -vv      # more verbose
ansible-playbook install-nginx.yml -vvv     # connection debugging
```

4. **Limit to specific hosts:**
```bash
ansible-playbook install-nginx.yml --limit web-server
```

5. **List what would be affected without running:**
```bash
ansible-playbook install-nginx.yml --list-hosts
ansible-playbook install-nginx.yml --list-tasks
```

**Document:** Why is `--check --diff` the most important flag combination for production use?

---

### Task 6: Multiple Plays in One Playbook
Write `multi-play.yml` with separate plays for each server group:

```yaml
---
- name: Configure web servers
  hosts: web
  become: true
  tasks:
    - name: Install Nginx
      yum:
        name: nginx
        state: present
    - name: Start Nginx
      service:
        name: nginx
        state: started
        enabled: true

- name: Configure app servers
  hosts: app
  become: true
  tasks:
    - name: Install Node.js dependencies
      yum:
        name:
          - gcc
          - make
        state: present
    - name: Create app directory
      file:
        path: /opt/app
        state: directory
        mode: '0755'

- name: Configure database servers
  hosts: db
  become: true
  tasks:
    - name: Install MySQL client
      yum:
        name: mysql
        state: present
    - name: Create data directory
      file:
        path: /var/lib/appdata
        state: directory
        mode: '0700'
```

Run it:
```bash
ansible-playbook multi-play.yml
```

Watch the output -- each play targets a different group, and tasks run only on the relevant hosts.

**Verify:** Is Nginx only installed on web servers? Is MySQL only on db servers?

---

## Hints
- YAML indentation matters -- use 2 spaces, never tabs
- `state: present` means "install if not already installed", `state: absent` means "remove"
- `state: started` means "start if not running", `state: restarted` means "always restart"
- Handlers run once at the end of all tasks, even if notified multiple times
- `register` saves a task's output to a variable, `debug` prints it
- `{{ inventory_hostname }}` is a built-in variable that returns the current host's name
- `ansible-playbook --syntax-check playbook.yml` validates YAML syntax before running
- Always test with `--check --diff` before applying to production

---

## Documentation
Create `day-69-playbooks.md` with:
- Your first playbook with annotations explaining each section
- All seven module examples with what each does
- Screenshot of the playbook run showing changed vs ok tasks
- Screenshot proving idempotency (second run shows all ok)
- How handlers work with a before/after comparison
- Difference between `--check`, `--diff`, and `-v`

---

## Submission
1. Add `day-69-playbooks.md` to `2026/day-69/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Wrote my first Ansible playbooks today -- installed Nginx, managed services, copied files, and learned handlers. Ran the same playbook twice and it made zero changes the second time. Idempotency is beautiful."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
