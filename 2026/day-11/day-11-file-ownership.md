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

**Task 3: Basic chgrp Operations (15 minutes)**

1. Create file team-notes.txt --> To create file run command: touch team-notes.txt

2. Check current group: ls -l team-notes.txt --> then run command: ls -l

3. Create group: sudo groupadd heist-team and then check the group at cat /etc/group

4. Change file group to heist-team --> sudo chgrp meist-team devops-file.txt

5. Verify the change -->Now to verify this chnage run command: ls -l

<img width="687" height="322" alt="task 3-1" src="https://github.com/user-attachments/assets/fa40de83-8bae-44fa-87db-d394b05e1141" />

<img width="493" height="907" alt="task 3-2" src="https://github.com/user-attachments/assets/5b52a775-a966-4be1-be0b-5f0aff14f723" />

<img width="771" height="302" alt="task 3-3" src="https://github.com/user-attachments/assets/df537464-ce32-413e-affa-121e76c979cf" />

**Task 4: Combined Owner & Group Change (15 minutes)**

Using chown you can change both owner and group together:

1. Create file project-config.yaml -->touch project-config.yml

2. Change owner to professor AND group to heist-team (one command) 

-->First create user professor if not created and then run the following command: sudo chown professor:heist-team project-config.yml

3. Create directory app-logs/ --> sudo mkdir app-logs and then run command ls -l to verify

4. Change its owner to berlin and group to heist-team -->sudo chown berlin:heist-team app-logs

**Syntax:** sudo chown owner:group filename

<img width="1148" height="967" alt="task 4-1" src="https://github.com/user-attachments/assets/45995eac-12f6-42eb-8c41-0a74b5b9d3b9" />

<img width="780" height="626" alt="task 4-2" src="https://github.com/user-attachments/assets/20266f52-7f33-47e7-a61e-54b23e9a062a" />

**Task 5: Recursive Ownership (20 minutes)**

Create directory structure:

1. mkdir -p heist-project/vault

2. mkdir -p heist-project/plans

3. touch heist-project/vault/gold.txt

4. touch heist-project/plans/strategy.conf

5. Create group planners: sudo groupadd planners

6. Change ownership of entire heist-project/ directory:

Owner: professor

Group: planners

Use recursive flag (-R)

7. Verify all files and subdirectories changed: ls -lR heist-project/

<img width="728" height="692" alt="task 5-1" src="https://github.com/user-attachments/assets/a1ba1e81-8960-4bfe-935b-077aa38598dc" />

<img width="730" height="307" alt="task 5-2" src="https://github.com/user-attachments/assets/6622c044-90a6-465e-9299-2319c43ff4ed" />

<img width="795" height="585" alt="task 5-3" src="https://github.com/user-attachments/assets/dfd0a919-d7a9-46aa-b8ae-a3734023dbc3" />

**Task 6: Practice Challenge (20 minutes)**

1. Create users: tokyo, berlin, nairobi (if not already created)

2. Create groups: vault-team, tech-team

3. Create directory: bank-heist/

4. Create 3 files inside:

touch bank-heist/access-codes.txt

touch bank-heist/blueprints.pdf

touch bank-heist/escape-plan.txt

**Set different ownership:**

5. access-codes.txt → owner: tokyo, group: vault-team --> sudo chown tokyo:vault-team bank-heist/access-codes.txt

6. blueprints.pdf → owner: berlin, group: tech-team --> sudo chown berlin:tech-team bank-heist/blueprints.pdf

7. escape-plan.txt → owner: nairobi, group: vault-team --> sudo chown nairobi:vault-team bank-heist/escape-plan.txt

8. Verify: ls -l bank-heist/

<img width="862" height="972" alt="task 6-1" src="https://github.com/user-attachments/assets/1baa60c5-ed8f-4c74-acd8-563420eb5f52" />

<img width="728" height="162" alt="task 6-2" src="https://github.com/user-attachments/assets/206330cb-8db3-4e94-b3d6-02b95118d4b6" />

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

