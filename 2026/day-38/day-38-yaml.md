# Day 38 – YAML Basics

## Task
Before writing a single CI/CD pipeline, you need to get comfortable with **YAML** — the language every pipeline is written in.

You will:
- Understand YAML syntax and rules
- Write YAML files by hand
- Validate them

---

## Expected Output
- A markdown file: `day-38-yaml.md`
- YAML files you create during the tasks

---

## Challenge Tasks

### Task 1: Key-Value Pairs

Create `person.yaml` that describes yourself with:
- `name`
- `role`
- `experience_years`
- `learning` (a boolean)

**Verify:** Run `cat person.yaml` — does it look clean? No tabs?

**Steps to follow:**

-->This task is about creating a simple YAML file using key-value pairs.

Step 1: Create person.yaml: vi person.yml

-->Add the following content (replace the values with your own information):
```
name: Sonali
role: DevOps Learner
experience_years: 1
learning: true

Explanation: 
- name → Your name (string)
- role → Your current role or goal
- experience_years → Number (no quotes)
- learning → Boolean (true or false, lowercase)

Important YAML Rules:
- Use spaces, never tabs.
- Keep one space after each colon (:).
- Booleans should be true or false (lowercase).
```

Step 2: Save the file

Step 3: Verify the file: cat person.yml
```
Expected output:

name: Sonali
role: DevOps Learner
experience_years: 1
learning: true
```
---

### Task 2: Lists
Add to `person.yaml`:
- `tools` — a list of 5 DevOps tools you know or are learning
- `hobbies` — a list using the inline format `[item1, item2]`

Write in your notes: What are the two ways to write a list in YAML?

**Steps to follow:**

Step 1: Update person.yaml: vi person.yml
```
name: Sonali
role: DevOps Learner
experience_years: 1
learning: true

tools:
  - Git
  - Docker
  - Kubernetes
  - Terraform
  - Ansible

hobbies: [Learning DevOps, Reading, Listening to music]

Explanation:
- tools uses the block list format (each item starts with -).
- hobbies uses the inline list format (items inside square brackets []).
```

Step 2: Verify: cat person.yaml
```
Expected output:

name: Sonali
role: DevOps Learner
experience_years: 1
learning: true

tools:
  - Git
  - Docker
  - Kubernetes
  - Terraform
  - Ansible

hobbies: [Learning DevOps, Reading, Listening to music]
```
Q. Write in your notes: What are the two ways to write a list in YAML?

-->There are two ways to write a list in YAML:

1. **Block List**
   - Each item starts with a hyphen (`-`).
   - Example:
     ```yaml
     tools:
       - Git
       - Docker
       - Kubernetes
     ```

2. **Inline List**
   - All items are written inside square brackets (`[]`) separated by commas.
   - Example:
     ```yaml
     hobbies: [Reading, Gaming, Music]
     ```
Key Difference:
```
Block List	                                    Inline List
One item per line	-->                        All items on one line
Easier to read for long lists	-->            Good for short lists
Uses - before each item -->	                   Uses [] and commas

```
---

### Task 3: Nested Objects
Create `server.yaml` that describes a server:
- `server` with nested keys: `name`, `ip`, `port`
- `database` with nested keys: `host`, `name`, `credentials` (nested further: `user`, `password`)

**Verify:** Try adding a tab instead of spaces — what happens when you validate it?

**Steps yo follow:**

Step 1: Create server.yaml: vi server.yml: Add the following content:
```
server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

database:
  host: db.example.com
  name: app_db
  credentials:
    user: admin
    password: secret123
```
Structure:
```
server
├── name
├── ip
└── port

database
├── host
├── name
└── credentials
    ├── user
    └── password

Notice that:
- server is a nested object (mapping).
- database is another nested object.
- credentials is nested inside database.
```

Step 2: Verify the file: cat server.yaml
```
Expected output:
server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

database:
  host: db.example.com
  name: app_db
  credentials:
    user: admin
    password: secret123
```

Step 3: Validate the YAML: 

-->If you have Python and PyYAML installed: python3 -c "import yaml; yaml.safe_load(open('server.yaml')); print('Valid YAML')"

-->Or, if you have yamllint installed: yamllint server.yaml

Step 4: What happens if you use a tab?

-->For example, if you write: 
```
server:
	name: web-server   [Note: (where name is indented with a tab instead of spaces)]
```
Expected Result: 

<img width="717" height="466" alt="image" src="https://github.com/user-attachments/assets/575d05cf-15d9-4103-b978-6383f3f2c572" />

-->Instead Always use 2 spaces (common convention), YAML only allows spaces for indentation

---

### Task 4: Multi-line Strings
In `server.yaml`, add a `startup_script` field using:
- 1. The `|` block style (preserves newlines)
- 2. The `>` fold style (folds into one line)

Write in your notes: When would you use `|` vs `>`?

**Steps to follow:**

Step 1: Open server.yaml: vi server.yml

Step 2: Add a multi-line string using | (Literal Block Style): 
- The | symbol preserves line breaks exactly as written.

-->Now update the server.yml file
```
server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

  startup_script: |
    #!/bin/bash
    echo "Starting application..."
    systemctl start nginx
    echo "Application started"

database:
  host: db.example.com
  name: app_db
  credentials:
    user: admin
    password: secret123

Output when parsed:

#!/bin/bash
echo "Starting application..."
systemctl start nginx
echo "Application started"

Notice every newline is preserved.
```

Step 3: Add a multi-line string using > (Folded Block Style):
```

server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

  startup_script: |
    #!/bin/bash
    echo "Starting application..."
    systemctl start nginx
    echo "Application started"

  description: >
    This is a sample web server
    used for learning YAML.
    The folded style converts
    line breaks into spaces.

database:
  host: db.example.com
  name: app_db
  credentials:
    user: admin
    password: secret123

Output when parsed: This is a sample web server used for learning YAML. The folded style converts line breaks into spaces.
```

-->Notice the multiple lines become one sentence.

Step 4: Verify the file: cat server.yml
```
server:
  name: web-server
  ip: 192.168.1.10
  port: 8080

  startup_script: |
    #!/bin/bash
    echo "Starting application..."
    systemctl start nginx
    echo "Application started"

  description: >
    This is a sample web server
    used for learning YAML.
    The folded style converts
    line breaks into spaces.

database:
  host: db.example.com
  name: app_db
  credentials:
    user: admin

    password: secret123
```

Step 5: Validate the YAML: 

<img width="712" height="386" alt="image" src="https://github.com/user-attachments/assets/1cc74cb5-3336-4325-a443-61ca1244d574" />

Step 6: Add to your notes: 

[mynotest.md](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-38/notest.md')

### Task 5: Validate Your YAML
1. Install `yamllint` or use an online validator




**Steos to follow:**
-

Step 1: Install yamllint: sudo apt update && sudo apt install yamllint -y

-->verify installed yml lint version: yamllint --version

Step 2: Validate your YAML files: yamllint person.yaml && yamllint server.yaml

-->Or validate both at once: yamllint person.yaml server.yaml  [Expected output (if both files are valid): No output means your YAML files are valid.]

Step 3: Intentionally break the indentation: 

<img width="740" height="735" alt="image" src="https://github.com/user-attachments/assets/71b0ed06-8887-4bfe-9d04-5a9346ba5f93" />

Step 4: Fix the indentation: 

<img width="687" height="521" alt="image" src="https://github.com/user-attachments/assets/6bc3e719-35f3-4f6b-81d7-365942a44e92" />

---

### Task 6: Spot the Difference
Read both blocks and write what's wrong with the second one:

```yaml
# Block 1 - correct
name: devops
tools:
  - docker
  - kubernetes
```

```yaml
# Block 2 - broken
name: devops
tools:
- docker
  - kubernetes
```

-->The issue in Block 2 is incorrect indentation of the list under tools, - docker is not indented, so YAML may interpret it as a top-level list item, 
not part of tools, And - kubernetes is indented differently, making the list inconsistent.

-->YAML requires consistent indentation for all list items under a key.

**Correct version**

tools:
  - docker
  - kubernetes
---

**Steps to follow:**

<img width="712" height="657" alt="image" src="https://github.com/user-attachments/assets/37576fd5-c3fc-43a9-8ec1-85f411621331" />
<img width="687" height="197" alt="image" src="https://github.com/user-attachments/assets/f781b832-15b7-4064-b68d-537134b9aece" />

Q. Spot the Difference?

-->The second YAML block has incorrect indentation.

- The first list item (`- docker`) is not indented under the `tools` key.
- The second list item (`- kubernetes`) is indented differently from the first.
- In YAML, all items in a list must have the same indentation level under their parent key.

Correct version:

```yaml
name: devops
tools:
  - docker
  - kubernetes
```

-->Note: **Key takeaway:** YAML relies on **consistent spaces for indentation**. Even small indentation mistakes can make the file invalid or change its meaning.


## Hints
- YAML uses **spaces only** — never tabs
- Indentation is everything — 2 spaces is standard
- Strings don't need quotes unless they contain special characters (`:`, `#`, etc.)
- `true`/`false` are booleans, `"true"` is a string
- Validate online: yamllint.com

---

## Documentation
Create `day-38-yaml.md` with:
- Your YAML files
- What you learned (3 key points)

---

## Submission
1. Add your YAML files and `day-38-yaml.md` to `2026/day-38/`
2. Commit and push to your fork

---

## Learn in Public
Share your YAML "aha moment" on LinkedIn — the tab vs space mistake gets everyone.

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
