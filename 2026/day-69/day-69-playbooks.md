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

-->**command** executes a command directly without a shell, making it more secure and predictable.

-->**shell** executes through /bin/sh, allowing shell features such as pipes(|), redirects(> ,>>), variables($HOME), and wildcards(*), Command chaining (&&)

**Note:** Prefer command by default and use shell only when shell-specific functionality is required.

<img width="513" height="802" alt="image" src="https://github.com/user-attachments/assets/ed79f3ee-5d5c-4919-b024-21feb817bd63" />

<img width="388" height="806" alt="image" src="https://github.com/user-attachments/assets/e6c59a3f-5579-4348-a452-60b2fed865a3" />

**Steps to follow:**

Step 1: Create a files Directory

<img width="240" height="472" alt="image" src="https://github.com/user-attachments/assets/aba8ad3b-b08c-4381-8242-edffecaf22ee" />

Step 2: Create app.conf: Create app.conf file under files dir: vi app.conf and add following: APP_NAME=TerraWeek, APP_ENV=Development, APP_PORT=8080 

<img width="1047" height="150" alt="image" src="https://github.com/user-attachments/assets/11883eba-7a93-4ce1-8319-e01086a67e42" />

Step 3: Create essential-modules.yml: vi essential-modules.yml and add above line of code

Step 4: Validate the Playbook: ansible-playbook -i inventory.ini essential-modules.yml --syntax-check

<img width="1652" height="76" alt="image" src="https://github.com/user-attachments/assets/7020d070-4671-4418-a2b5-f94ec616f16c" />

Step 5: Run the Playbook: ansible-playbook -i inventory.ini essential-modules.yml

<img width="1852" height="961" alt="image" src="https://github.com/user-attachments/assets/1c24c0bd-11c7-4653-a9fd-81b0a1f311f6" />

Step 6: Understand the Output: 

<img width="273" height="303" alt="image" src="https://github.com/user-attachments/assets/7cd365cf-6758-4586-b345-0664dd19cf47" />

Step 7: Verify on EC2: SSH into the instance: ssh -i terraform-practice/my-key.pem ubuntu@13.127.63.252 Once get in run the commands: git --version & curl --version & wget --version & tree --version

**Steps verify output:**
1. ssh -i terraform-practice/my-key.pem ubuntu@13.127.63.252

<img width="1317" height="502" alt="image" src="https://github.com/user-attachments/assets/ac27ac99-394b-4b39-a086-d6b4617ada6d" />

2. verify git --version, curl --version & wget --version:

<img width="1915" height="976" alt="image" src="https://github.com/user-attachments/assets/6b34aad1-f49b-43d7-8852-07cc2cbaa7f3" />

3. verify **tree --version**, then check the content: **cat /etc/app.conf** then check the file and that permissions: **ls -ld /opt/myapp** later checked **grep TZ /etc/environment**

<img width="1498" height="353" alt="image" src="https://github.com/user-attachments/assets/4fa41fc8-d4d7-4608-bbef-962b7c6c85ce" />
 
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

**Steps to follow:**
Step 1: Create vi nginx-config.yml & add above line of code

Step 2: Create vi nginx.conf under files dir only where previously we have created app.conf file

Step 3: Validate the Playbook: ansible-playbook -i inventory.ini nginx-config.yml --syntax-check

Step 4: Run the Playbook (First Time): ansible-playbook -i inventory.ini nginx-config.yml

<img width="387" height="667" alt="image" src="https://github.com/user-attachments/assets/2ccc2120-c194-4628-933b-7325a3e6ff18" />

Step 5: Verify Website: curl http://13.127.63.252

<img width="530" height="32" alt="image" src="https://github.com/user-attachments/assets/d4600704-b3f1-469c-b714-9754a0c850f6" />

Step 6: Run the Playbook Again: ansible-playbook -i inventory.ini nginx-config.yml

<img width="392" height="327" alt="image" src="https://github.com/user-attachments/assets/89f1b97f-1345-4435-a8f9-594461c685ff" />

Step 7: Observe the Handler: On the second run: You should NOT see: RUNNING HANDLER [Restart Nginx], because nothing changed. Therefore no notification was sent.

<img width="245" height="526" alt="image" src="https://github.com/user-attachments/assets/8fce876b-fc21-4665-b227-850d5ccbda8e" />

<img width="328" height="693" alt="image" src="https://github.com/user-attachments/assets/0a451e0c-6957-41b6-90ba-bb9ad8e09efa" />

<img width="371" height="818" alt="image" src="https://github.com/user-attachments/assets/25d629be-9c63-4ef4-920a-d00d38161d5e" />

<img width="1911" height="742" alt="image" src="https://github.com/user-attachments/assets/90997b8d-dc15-4c80-bd78-28adbebd7e15" />

<img width="1918" height="478" alt="image" src="https://github.com/user-attachments/assets/dcbcaf29-9a7e-4516-bc13-2d535751dcd8" />

**Verify:** Run it twice and compare the output. Does the handler run both times?
-->No.

-->First run: the configuration file is copied, so the task reports changed and triggers the handler.

-->Second run: the configuration file is already identical, so the task reports ok and the handler is not triggered.

**Note:** The handler runs only when a notified task makes a change.

**Why are handlers useful?**

-->Handlers prevent unnecessary service restarts, making playbooks more efficient and reducing downtime or disruption to running services, This behavior is another example of Ansible idempotency—changes are applied only when needed.

---

### Task 5: Dry Run, Diff, and Verbosity
Before running playbooks on production, always preview changes first.

1. **Dry run (check mode)** -- shows what would change without changing anything:
```bash
ansible-playbook install-nginx.yml --check
```
<img width="515" height="596" alt="image" src="https://github.com/user-attachments/assets/6f1c49a1-8bd7-4600-a777-0c3800ff6916" />

2. **Diff mode** -- shows the actual file differences:
```bash
ansible-playbook nginx-config.yml --check --diff
```
<img width="642" height="693" alt="image" src="https://github.com/user-attachments/assets/c68a3aa1-d491-4053-907a-a6e9a91db6f4" />

3. **Verbosity** -- increase output detail for debugging:
```bash
ansible-playbook install-nginx.yml -v       # verbose
ansible-playbook install-nginx.yml -vv      # more verbose
ansible-playbook install-nginx.yml -vvv     # connection debugging
```
<img width="377" height="738" alt="image" src="https://github.com/user-attachments/assets/31332137-97db-4ad0-a41a-47230ece9745" />

4. **Limit to specific hosts:**
```bash
ansible-playbook install-nginx.yml --limit web-server
```
<img width="603" height="652" alt="image" src="https://github.com/user-attachments/assets/14b78313-c750-4086-a7d1-d79136d95655" />

5. **List what would be affected without running:**
```bash
ansible-playbook install-nginx.yml --list-hosts
ansible-playbook install-nginx.yml --list-tasks
```
<img width="537" height="815" alt="image" src="https://github.com/user-attachments/assets/c3d386f8-feb1-49a4-ab67-5c4bd36f3d5e" />

<img width="671" height="811" alt="image" src="https://github.com/user-attachments/assets/270e0f23-0ea1-45ad-9a0c-2fdfea9f2844" />

**Document:** Why is `--check --diff` the most important flag combination for production use?
--> **--check** allows you to perform a dry run and see what changes Ansible would make without actually modifying the target systems.

--> **--diff** shows the exact differences in files before and after the proposed changes.

-->When used together: **ansible-playbook playbook.yml --check --diff** you can safely verify: Which tasks would change resources, Which configuration files would be modified, The exact content differences, Potential mistakes before deployment etc. 

-->This greatly reduces the risk of accidental outages, incorrect configurations, and unexpected changes in production environments. 

-->IN short The combination of **--check --diff** provides a safe preview of infrastructure changes. --check simulates execution without making modifications, while --diff displays the exact file changes that would occur. Together they allow engineers to validate changes before deployment, making them one of the most important safeguards for production environments.

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

**Steps to follow:**

<img width="816" height="757" alt="image" src="https://github.com/user-attachments/assets/a2507afe-f475-4c64-84bc-ffc918d0ba95" />

<img width="630" height="495" alt="image" src="https://github.com/user-attachments/assets/c039e886-e999-433b-bd1d-7c5a9da2d71b" />

Step 1: Create the Playbook: Used option1 for now and created one instance and doing ths things in it, Create file **vi multi-play.yml**

Step 2: Validate Syntax: ansible-playbook -i inventory.ini multi-play.yml --syntax-check

Step 3: Preview Hosts: ansible-playbook -i inventory.ini multi-play.yml --list-hosts [This shows which hosts belong to each play.]

Step 4: Run the Playbook: ansible-playbook -i inventory.ini multi-play.yml

<img width="370" height="723" alt="image" src="https://github.com/user-attachments/assets/fc061adf-bfeb-4603-8682-0f190465f39c" />

<img width="472" height="573" alt="image" src="https://github.com/user-attachments/assets/228ade53-6721-4485-bd87-98a900ff0d7f" />

Step 5: Verify the Changes: for that SSH into your server: ssh -i terraform-practice/my-key.pem ubuntu@13.127.63.252

Step 6: Verify Nginx version: nginx -v OR systemctl status nginx

Step 7: Verify App Directory: ls -ld /opt/app

Step 8: Verify MySQL Client: mysql --version

Step 9: Verify Data Directory: ls -ld /var/lib/appdata

<img width="1472" height="547" alt="image" src="https://github.com/user-attachments/assets/c81b9b37-43ce-4518-b1d2-d1ce2503e7a9" />

<img width="1912" height="970" alt="image" src="https://github.com/user-attachments/assets/950ad156-218a-48a4-8843-21a36c4c3f3d" />

<img width="1790" height="567" alt="image" src="https://github.com/user-attachments/assets/0e29ee93-fdff-40ab-86ad-99735047528f" />

Watch the output -- each play targets a different group, and tasks run only on the relevant hosts.

**Verify:** Is Nginx only installed on web servers? Is MySQL only on db servers?

-->Yes. The Nginx tasks are inside: hosts: web, so they run only on hosts in the web inventory group.

Is MySQL only installed on db servers?

-->Yes. The MySQL tasks are inside: hosts: db so they run only on hosts in the db inventory group.

**Note:** Important Note for Your Current Lab: If you place the same EC2 instance in all three groups (web, app, and db), then that one machine will receive all three configurations because it belongs to all three groups. To truly verify separation, you'd need separate servers for each group. This lab is mainly teaching how multiple plays target different inventory groups within a single playbook.

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
