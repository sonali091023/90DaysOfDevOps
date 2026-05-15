# Day 11 – File Ownership Challenge (chown & chgrp)**

**Task 1: Understanding Ownership (10 minutes)**

1. Run ls -l in your home directory

2. Identify the owner and group columns

3. Check who owns your files

Format: -rw-r--r-- 1 owner group size date filename

Document: What's the difference between owner and group?

-->So the difference is Owner can Read, Write and execute the file whereas group can only read and execute the file.

<img width="757" height="401" alt="img1" src="https://github.com/user-attachments/assets/ab9ef51d-b7f7-42c7-a134-6d41915c9762" />


**Task 2: Basic chown Operations (20 minutes)**

1. Create file devops-file.txt -->touch devops-file.txt

2. Check current owner: ls -l devops-file.txt -->and the do ls -l

3. Change owner to tokyo (create user if needed) 

-->As tokyo user was not created by using adduser command created it first and then run the command: sudo chown tokyo docker-file.txt and then do ls -l 

4. Change owner to berlin

-->As berlin user was not created by using adduser command created it first and then run the command: sudo chown berlin docker-file.txt and then do ls -l

5. Verify the changes by running command: ls -l

<img width="872" height="923" alt="img2" src="https://github.com/user-attachments/assets/7c0fecce-ec00-4865-ba17-1b3983066c51" />

<img width="757" height="401" alt="home-file-permissions" src="https://github.com/user-attachments/assets/bc96163b-45d6-43ad-903a-650ccf5c27d0" />

**Try:**

sudo chown tokyo devops-file.txt

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

