# Day 11 – File Ownership Challenge (chown & chgrp)

## Task
Master file and directory ownership in Linux.

- Understand file ownership (user and group)
- Change file owner using `chown`
- Change file group using `chgrp`
- Apply ownership changes recursively

---

## Expected Output
- A markdown file: `day-11-file-ownership.md`
- Screenshots showing ownership changes

---

## Challenge Tasks

### Task 1: Understanding Ownership (10 minutes)

1. Run `ls -l` in your home directory
2. Identify the **owner** and **group** columns
3. Check who owns your files

**Format:** `-rw-r--r-- 1 owner group size date filename`

**Document:** What's the difference between owner and group?

**Steps to follow:**

Step 1: Open the terminal: Navigate to your home directory: cd ~

-->Verify your current directory: pwd [Expected: /home/your-username]

Step 2: List files with detailed information: ls -l

Step 3: Understand each column: 

<img width="772" height="677" alt="image" src="https://github.com/user-attachments/assets/503bd1ab-3f7a-485a-ae65-22d169900f4b" />

Step 4: Identify the owner and group: 

<img width="747" height="327" alt="image" src="https://github.com/user-attachments/assets/0a39158f-1619-440d-a7d0-5c9b0e2d096d" />

Step 5: Check who owns your files: whoami

<img width="772" height="681" alt="image" src="https://github.com/user-attachments/assets/1c4a75a0-8aab-4846-926a-41cf8f098c3d" />

Q. What is the difference between Owner and Group?

**Owner:**
- The owner is the user who created the file or has ownership of it.
- The owner has their own set of permissions (read, write, execute).

**Group:**
- A group is a collection of users.
- Users who belong to the file's group receive the permissions assigned to the group.
- This makes it easy to share files among multiple users without changing ownership.

<img width="820" height="335" alt="image" src="https://github.com/user-attachments/assets/bcbd4e50-939c-45e6-ab80-61cf804e3a12" />

<img width="1457" height="927" alt="image" src="https://github.com/user-attachments/assets/d3f1e73e-ed8c-4461-9be0-40be1f9ccf87" />

---

### Task 2: Basic chown Operations (20 minutes)

1. Create file `devops-file.txt`
2. Check current owner: `ls -l devops-file.txt`
3. Change owner to `tokyo` (create user if needed)
4. Change owner to `berlin`
5. Verify the changes

**Try:**
```bash
sudo chown tokyo devops-file.txt
```

**Steps to follow:**

Step 1: Create the file: touch devops-file.txt

-->ls

Step 2: Check the current owner: ls -l devops-file.txt  [Here: Owner → sona, Group → sona]

Step 3: Check whether user tokyo exists: id tokyo & if not exist then create new user

-->Create the user: sudo useradd -m tokyo

-->verify created user: id tokyo

Step 4: Change the owner to tokyo: sudo chown tokyo devops-file.txt

-->And then to verify use commands: ls -l devops-file.txt

**Notice:**
- Owner changed to tokyo
- Group is still sona (because only the owner was changed)

Step 5: Check whether user berlin exists: id berlin And create if not exists: sudo useradd -m berlin

-->Then verify: id berlin

Step 6: Change the owner to berlin: sudo chown berlin devops-file.txt

-->verify: ls -l devops-file.txt [Expected: The owner is now berlin.]

Optional: Change both owner and group: sudo chown berlin:berlin devops-file.txt

then verify: ls -l devops-file.txt

Now:
- Owner → berlin
- Group → berlin

-->Verify the changes: ls -l devops-file.txt

<img width="1695" height="496" alt="image" src="https://github.com/user-attachments/assets/fc77e275-8f20-44b6-ad85-3b906779f545" />

---

### Task 3: Basic chgrp Operations (15 minutes)

1. Create file `team-notes.txt`
2. Check current group: `ls -l team-notes.txt`
3. Create group: `sudo groupadd heist-team`
4. Change file group to `heist-team`
5. Verify the change

**Steps to follow:**

-->Learn how to change the group ownership of a file using the chgrp command.

Step 1: Create the file: touch team-notes.txt

-->To verify: ls

Step 2: Check the current group: ls -l team-notes.txt

**Breakdown:**
- Owner → sona
- Group → sona
The 4th column is the current group.

Step 3: Create a new group: 

-->First, check if the group already exists: getent group heist-team

-->If no output appears, create the group: sudo groupadd heist-team

-->Verify it was created: getent group heist-team

Step 4: Change the file's group: sudo chgrp heist-team devops-file.txt

-->Alternatively, you can use chown to change only the group: sudo chown :heist-team team-notes.txt [Note: Both commands achieve the same result for changing the group.]

Step 5: Verify the change: ls -l team-notes.txt

**Notice:**
- Owner remains sona
- Group has changed to heist-team

**Understanding what changed:**

<img width="725" height="257" alt="image" src="https://github.com/user-attachments/assets/32b2f010-847c-46f8-968e-46057e03e0da" />

<img width="1605" height="445" alt="image" src="https://github.com/user-attachments/assets/f84c3eff-6d24-488a-9d3f-8aa6f4b37f5d" />

**Common Errors:**

Error 1: Group already exists: sudo chgrp heist-team team-notes.txt

<img width="685" height="221" alt="image" src="https://github.com/user-attachments/assets/80042352-a9ff-4203-aa31-1fede1d88f7c" />

Error 2: Invalid group: getent group heist-team

-->sudo groupadd heist-team

<img width="717" height="362" alt="image" src="https://github.com/user-attachments/assets/7cf00ef1-2c1e-434d-8f8f-65b051616e59" />

Error 3: Operation not permitted: sudo chgrp heist-team team-notes.txt

<img width="697" height="246" alt="image" src="https://github.com/user-attachments/assets/27dbce4e-f0c3-4e8b-af9d-af0f58b37c95" />

---

### Task 4: Combined Owner & Group Change (15 minutes)

Using `chown` you can change both owner and group together:

1. Create file `project-config.yaml`
2. Change owner to `professor` AND group to `heist-team` (one command)
3. Create directory `app-logs/`
4. Change its owner to `berlin` and group to `heist-team`

**Syntax:** `sudo chown owner:group filename`

**Steps to follow:**

-->Learn how to change both the owner and group in a single command using chown. Syntax: sudo chown owner:group filename

Step 1: Create the file: touch project-config.yml

-->verify: ls -l project-config.yml

**Current:**
- Owner → sona
- Group → sona

Step 2: Check if the user professor exists: id professor

-->If not exists then create: sudo useradd -m professor

-->then verify: id professor

Step 3: Check if the group heist-team exists: getent group heist-team & if not output appears then create: sudo groupadd heist-team

Step 4: Change both owner and group (one command): sudo chown professor:heist-team project-config.yml

-->verify: ls -l project-config.yml

Now:
- Owner → professor
- Group → heist-team

Step 5: Create the directory: mkdir app-logs

-->verify: ls -ld app-logs

Step 6: Check if user berlin exists: id berlin & if not exists create first: sudo useradd -m berlin

Step 7: Change the directory owner and group: sudo chown berlin:heist-team app-logs

-->verify: ls -ld app-logs

Now:
- Owner → berlin
- Group → heist-team

<img width="1681" height="657" alt="image" src="https://github.com/user-attachments/assets/c601b802-1fdb-4e4f-8c72-cd0980c87363" />

---

### Task 5: Recursive Ownership (20 minutes)

1. Create directory structure:
   ```
   mkdir -p heist-project/vault
   mkdir -p heist-project/plans
   touch heist-project/vault/gold.txt
   touch heist-project/plans/strategy.conf
   ```

2. Create group `planners`: `sudo groupadd planners`

3. Change ownership of entire `heist-project/` directory:
   - Owner: `professor`
   - Group: `planners`
   - Use recursive flag (`-R`)

4. Verify all files and subdirectories changed: `ls -lR heist-project/`

**Steps to follow:**

-->Learn how to change the ownership of a directory and everything inside it using the -R (recursive) option.

Step 1: Create the directory structure:

-->mkdir -p heist-project/vault

-->mkdir -p heist-project/plans

-->touch heist-project/vault/gold.txt

-->touch heist-project/plans/strategy.conf

-->verify the structure: tree heist-project & if tree is not installed: ls -R heist-project

Step 2: Check the current ownership: ls -lR heist-project [Note: At this point, everything is owned by sona.]

Step 3: Create the planners group: First check whether it already exists: getent group planners

-->If nothing is returned, create it: sudo groupadd planners

-->verify: getent group planners

Step 4: Ensure the professor user exists: id professor

-->if it does not exists create it: sudo useradd -m professor

Step 5: Change ownership recursively: Use the -R option to apply the change to the directory, all subdirectories, and all files: sudo chown -R professor:planners heist-project

**Breakdown:**
- sudo → Run with administrator privileges.
- chown → Change owner.
- -R → Apply recursively.
- professor → New owner.
- planners → New group.
- heist-project → Target directory.

Step 6: Verify the changes: ls -lR heist-project

Notice that every file and directory now has:
- Owner: professor
- Group: planners

Before vs After: 

<img width="762" height="405" alt="image" src="https://github.com/user-attachments/assets/ccef79a5-9b3a-43e4-a7ca-a84bb8dd60d5" />

<img width="1737" height="792" alt="image" src="https://github.com/user-attachments/assets/1de44d2f-37a5-41a0-9b02-40395e9e8342" />

<img width="1705" height="751" alt="image" src="https://github.com/user-attachments/assets/5300f7cd-2d8a-4d5b-ad97-c0a3e01a59b0" />

---

### Task 6: Practice Challenge (20 minutes)

1. Create users: `tokyo`, `berlin`, `nairobi` (if not already created)
2. Create groups: `vault-team`, `tech-team`
3. Create directory: `bank-heist/`
4. Create 3 files inside:
   ```
   touch bank-heist/access-codes.txt
   touch bank-heist/blueprints.pdf
   touch bank-heist/escape-plan.txt
   ```

5. Set different ownership:
   - `access-codes.txt` → owner: `tokyo`, group: `vault-team`
   - `blueprints.pdf` → owner: `berlin`, group: `tech-team`
   - `escape-plan.txt` → owner: `nairobi`, group: `vault-team`

**Verify:** `ls -l bank-heist/`

**Steps to follow:**

-->Create users and groups, create files, assign different owners and groups, and verify the changes.

Step 1: Create the users: 

-->First, check if each user already exists: id tokyo & if not exists create: sudo useradd -m tokyo

-->check if each user already exists: id berlin & if not exists create: sudo useradd -m berlin

-->check if each user already exists: id nairobi & if not exists create: sudo useradd -m nairobi

Step 2: Create the groups: 

-->Check whether the groups exist: getent group vault-team && getent group tech-team

-->If they don't exist, create them: sudo groupadd vault-team && sudo groupadd tech-team

-->verify: getent group vault-team && getent group tech-team

Step 3: Create the directory: mkdir bank-heist

-->verify: ls

Step 4: Create the files: 

-->touch bank-heist/access-codes.txt

-->touch bank-heist/blueprints.pdf

-->touch bank-heist/escape-plan.txt

-->verify: ls bank-heist

Step 5: Check current ownership: ls -l bank-heist

Step 6: Change ownership: 

-->File 1: Change access-codes.txt: sudo chown tokyo:vault-team bank-heist/access-codes.txt

-->File 2: Change blueprints.pdf: sudo chown berlin:tech-team bank-heist/blueprints.pdf

-->File 3: Change escape-plan.txt: sudo chown nairobi:vault-team bank-heist/escape-plan.txt

Step 7: Verify: ls -l bank-heist

<img width="812" height="267" alt="image" src="https://github.com/user-attachments/assets/2f2b01bf-0490-4749-8109-a54d2bef8cb0" />

Common Errors:





**Key Commands Reference**

# View ownership

ls -l filename

# Change owner only

sudo chown newowner filename

# Change group only

sudo chgrp newgroup filename

# Change both owner and group

sudo chown owner:group filename

# Recursive change (directories)

sudo chown -R owner:group directory/

# Change only group with chown

sudo chown :groupname filename

**Hints**

Most chown/chgrp operations need sudo

Use -R flag for recursive directory changes

Always verify with ls -l after changes

User must exist before using in chown

Group must exist before using in chgrp/chown

**Why This Matters for DevOps**

In real DevOps scenarios, you need proper file ownership for:

Application deployments

Shared team directories

Container file permissions

CI/CD pipeline artifacts

Log file management

