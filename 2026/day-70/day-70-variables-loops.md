# Day 70 -- Variables, Facts, Conditionals and Loops

## Task
Your playbooks work, but they are static -- same packages, same config, same behavior on every server. Real infrastructure is not like that. Web servers need Nginx, app servers need Node.js, production gets more memory than dev. Today you make your playbooks smart.

Variables, facts, conditionals, and loops turn a rigid script into flexible automation that adapts to each host, each group, and each environment.

---

## Expected Output
- Playbooks using variables from multiple sources
- Conditional tasks that run only on specific OS or groups
- Loops that install packages and create users dynamically
- A markdown file: `day-70-variables-loops.md`

---

## Challenge Tasks

### Task 1: Variables in Playbooks
Create `variables-demo.yml`:

```yaml
---
- name: Variable demo
  hosts: all
  become: true

  vars:
    app_name: terraweek-app
    app_port: 8080
    app_dir: "/opt/{{ app_name }}"
    packages:
      - git
      - curl
      - wget

  tasks:
    - name: Print app details
      debug:
        msg: "Deploying {{ app_name }} on port {{ app_port }} to {{ app_dir }}"

    - name: Create application directory
      file:
        path: "{{ app_dir }}"
        state: directory
        mode: '0755'

    - name: Install required packages
      yum:
        name: "{{ packages }}"
        state: present
```

Run it and verify the variables resolve correctly.

Now, override a variable from the command line:
```bash
ansible-playbook variables-demo.yml -e "app_name=my-custom-app app_port=9090"
```

**Steps to follow:** 

Step 1: Create the Playbook First create dir: **mkdir ansible-practice** & then create file: **vi variables-demo.yml** later add above line of code in to it.

Step 2: Why I Changed yum to package: So here Instead of maintaining different versions, use: package, Ansible automatically chooses the correct package manager.

Step 3: Check Inventory: Create inventory file in same anisble-package, But before that we needed one server that created with the help of terraform, Also crated the my-key.pem file and set the permissions for user only to avoid less secure issue in terraform-practice dir.

<img width="1807" height="447" alt="image" src="https://github.com/user-attachments/assets/8c0051d5-746a-4561-ad97-d24d278d79e3" />

Step 4: Run the Playbook: ansible-playbook -i inventory.ini variables-demo.yml

<img width="1913" height="480" alt="image" src="https://github.com/user-attachments/assets/0d461e8f-ff1b-4d2f-b52c-cf8dfd224464" />

<img width="352" height="347" alt="image" src="https://github.com/user-attachments/assets/add3fae8-7965-49a2-a959-5b417408d472" />

Step 5: Verify Directory Creation: For that first ssh to the server for that use command: ssh -i ../terraform-practice/my-key.pem ubuntu@13.233.20.248

Step 6: ls -ld /opt/terraweek-app

<img width="1918" height="677" alt="image" src="https://github.com/user-attachments/assets/5ced8dae-d8c8-40ea-868f-87cbbe8a7f65" />

Step 7: Verify Packages: check the version of all the following packages: git --version && curl --version && wget --version OR dpkg -l | grep git && dpkg -l | grep curl && dpkg -l | grep wget

<img width="1917" height="977" alt="image" src="https://github.com/user-attachments/assets/6ade29a9-57c9-476d-a99f-d16dc6572048" />

Step 8: Override Variables from CLI: ansible-playbook -i inventory.ini variables-demo.yml -e "app_name=my-custom-app app_port=9090" So here we can override the app port number & name.

<img width="1917" height="673" alt="image" src="https://github.com/user-attachments/assets/ec5872d5-83fd-4365-b79b-581a10fe314e" />

<img width="1852" height="711" alt="image" src="https://github.com/user-attachments/assets/0efe3f0f-af12-474e-a9f3-cf014f8395d7" />

<img width="576" height="682" alt="image" src="https://github.com/user-attachments/assets/72a6c665-8126-4803-949d-66eae1079b61" />

**Verify:** Does the CLI variable override the playbook variable?

-->Yes. Variables passed with -e (extra-vars) take precedence over variables defined in the playbook. Running: ansible-playbook -i inventory.ini variables-demo.yml -e "app_name=my-custom-app app_port=9090"
<img width="510" height="151" alt="image" src="https://github.com/user-attachments/assets/4c7c44cb-f769-4345-b023-5933000359d9" />

---

### Task 2: group_vars and host_vars
Variables should not live inside playbooks. Move them to dedicated files.

Create this structure:
```
ansible-practice/
  inventory.ini
  ansible.cfg
  group_vars/
    all.yml
    web.yml
    db.yml
  host_vars/
    web-server.yml
  playbooks/
    site.yml
```

**`group_vars/all.yml`** -- applies to every host:
```yaml
---
ntp_server: pool.ntp.org
app_env: development
common_packages:
  - vim
  - htop
  - tree
```

**`group_vars/web.yml`** -- applies only to the web group:
```yaml
---
http_port: 80
max_connections: 1000
web_packages:
  - nginx
```

**`group_vars/db.yml`** -- applies only to the db group:
```yaml
---
db_port: 3306
db_packages:
  - mysql-server
```

**`host_vars/web-server.yml`** -- applies only to this specific host:
```yaml
---
max_connections: 2000
custom_message: "This is the primary web server"
```

Write a playbook `site.yml` that uses these variables:
```yaml
---
- name: Apply common config
  hosts: all
  become: true
  tasks:
    - name: Install common packages
      yum:
        name: "{{ common_packages }}"
        state: present
    - name: Show environment
      debug:
        msg: "Environment: {{ app_env }}"

- name: Configure web servers
  hosts: web
  become: true
  tasks:
    - name: Show web config
      debug:
        msg: "HTTP port: {{ http_port }}, Max connections: {{ max_connections }}"
    - name: Show host-specific message
      debug:
        msg: "{{ custom_message }}"
```

Run it and observe which variables apply to which hosts.

**Document:** What is the variable precedence? (hint: host_vars > group_vars > playbook vars, and `-e` overrides everything)

---

### Task 3: Ansible Facts -- Gathering System Information
Ansible automatically collects "facts" about each managed node -- OS, IP, memory, CPU, disks, and hundreds more.

1. **See all facts for a host:**
```bash
ansible web-server -m setup
```

2. **Filter specific facts:**
```bash
ansible web-server -m setup -a "filter=ansible_os_family"
ansible web-server -m setup -a "filter=ansible_distribution*"
ansible web-server -m setup -a "filter=ansible_memtotal_mb"
ansible web-server -m setup -a "filter=ansible_default_ipv4"
```

3. **Use facts in a playbook** -- create `facts-demo.yml`:
```yaml
---
- name: Facts demo
  hosts: all
  tasks:
    - name: Show OS info
      debug:
        msg: >
          Hostname: {{ ansible_hostname }},
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }},
          RAM: {{ ansible_memtotal_mb }}MB,
          IP: {{ ansible_default_ipv4.address }}

    - name: Show all network interfaces
      debug:
        var: ansible_interfaces
```

Run it and observe the facts printed for each host.

**Document:** Name five facts you would use in real playbooks and why.

---

### Task 4: Conditionals with when
Tasks should not always run on every host. Use `when` to control execution.

Create `conditional-demo.yml`:

```yaml
---
- name: Conditional tasks demo
  hosts: all
  become: true

  tasks:
    - name: Install Nginx (only on web servers)
      yum:
        name: nginx
        state: present
      when: "'web' in group_names"

    - name: Install MySQL (only on db servers)
      yum:
        name: mysql-server
        state: present
      when: "'db' in group_names"

    - name: Show warning on low memory hosts
      debug:
        msg: "WARNING: This host has less than 1GB RAM"
      when: ansible_memtotal_mb < 1024

    - name: Run only on Amazon Linux
      debug:
        msg: "This is an Amazon Linux machine"
      when: ansible_distribution == "Amazon"

    - name: Run only on Ubuntu
      debug:
        msg: "This is an Ubuntu machine"
      when: ansible_distribution == "Ubuntu"

    - name: Run only in production
      debug:
        msg: "Production settings applied"
      when: app_env == "production"

    - name: Multiple conditions (AND)
      debug:
        msg: "Web server with enough memory"
      when:
        - "'web' in group_names"
        - ansible_memtotal_mb >= 512

    - name: OR condition
      debug:
        msg: "Either web or app server"
      when: "'web' in group_names or 'app' in group_names"
```

Run it and observe which tasks are skipped on which hosts.

**Verify:** Are tasks correctly skipping on hosts that don't match the condition?

---

### Task 5: Loops
Create `loops-demo.yml`:

```yaml
---
- name: Loops demo
  hosts: all
  become: true

  vars:
    users:
      - name: deploy
        groups: wheel
      - name: monitor
        groups: wheel
      - name: appuser
        groups: users

    directories:
      - /opt/app/logs
      - /opt/app/config
      - /opt/app/data
      - /opt/app/tmp

  tasks:
    - name: Create multiple users
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        state: present
      loop: "{{ users }}"

    - name: Create multiple directories
      file:
        path: "{{ item }}"
        state: directory
        mode: '0755'
      loop: "{{ directories }}"

    - name: Install multiple packages
      yum:
        name: "{{ item }}"
        state: present
      loop:
        - git
        - curl
        - unzip
        - jq

    - name: Print each user created
      debug:
        msg: "Created user {{ item.name }} in group {{ item.groups }}"
      loop: "{{ users }}"
```

Run it and observe the loop output -- each iteration is shown separately.

**Document:** What is the difference between `loop` and the older `with_items`? (hint: `loop` is the modern recommended syntax)

---

### Task 6: Register, Debug, and Combine Everything
Build a real-world playbook `server-report.yml` that combines variables, facts, conditionals, and register:

```yaml
---
- name: Server Health Report
  hosts: all

  tasks:
    - name: Check disk space
      command: df -h /
      register: disk_result

    - name: Check memory
      command: free -m
      register: memory_result

    - name: Check running services
      shell: systemctl list-units --type=service --state=running | head -20
      register: services_result

    - name: Generate report
      debug:
        msg:
          - "========== {{ inventory_hostname }} =========="
          - "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
          - "IP: {{ ansible_default_ipv4.address }}"
          - "RAM: {{ ansible_memtotal_mb }}MB"
          - "Disk: {{ disk_result.stdout_lines[1] }}"
          - "Running services (first 20): {{ services_result.stdout_lines | length }}"

    - name: Flag if disk is critically low
      debug:
        msg: "ALERT: Check disk space on {{ inventory_hostname }}"
      when: "'9[0-9]%' in disk_result.stdout or '100%' in disk_result.stdout"

    - name: Save report to file
      copy:
        content: |
          Server: {{ inventory_hostname }}
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          IP: {{ ansible_default_ipv4.address }}
          RAM: {{ ansible_memtotal_mb }}MB
          Disk: {{ disk_result.stdout }}
          Checked at: {{ ansible_date_time.iso8601 }}
        dest: "/tmp/server-report-{{ inventory_hostname }}.txt"
      become: true
```

Run it and verify the report file is created on each server.

**Verify:** SSH into a server and read `/tmp/server-report-*.txt`. Does it contain accurate information?

---

## Hints
- Variable precedence (simplified, low to high): role defaults -> group_vars/all -> group_vars/<group> -> host_vars/<host> -> playbook vars -> task vars -> extra vars (`-e`)
- `group_names` is a built-in variable containing the groups the current host belongs to
- `inventory_hostname` is the name of the host as defined in the inventory
- `when` conditions do not need `{{ }}` -- you reference variables directly: `when: app_env == "production"`
- `register` stores the entire result object including `stdout`, `stderr`, `rc` (return code), and `stdout_lines`
- `loop` replaces `with_items`, `with_dict`, `with_file` from older Ansible versions
- Use `ansible <host> -m setup -a "filter=<pattern>"` to quickly find fact names
- `debug` with `var` shows the raw variable, `msg` shows a formatted string

---

## Documentation
Create `day-70-variables-loops.md` with:
- Your `group_vars/` and `host_vars/` directory structure
- How variable precedence works with examples from your test
- Five useful Ansible facts and where you would use them
- Conditional playbook with screenshot showing skipped vs executed tasks
- Loop playbook with screenshot showing multiple iterations
- The server report output from Task 6

---

## Submission
1. Add `day-70-variables-loops.md` to `2026/day-70/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Made Ansible playbooks smart today -- variables from group_vars and host_vars, OS-based conditionals, loops for bulk operations, and facts-driven server reports. Same playbook, different behavior per host. This is how real configuration management works."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
