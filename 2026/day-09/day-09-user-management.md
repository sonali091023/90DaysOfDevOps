# Day 09 – Linux User & Group Management Challenge

## Task
Today's goal is to **practice user and group management** by completing hands-on challenges.

Figure out how to:
- Create users and set passwords
- Create groups and assign users
- Set up shared directories with group permissions

Use what you learned from Days 1-7 to find the right commands!

---

## Expected Output
- A markdown file: `day-09-user-management.md`
- Screenshots of command outputs
- List of commands used

---

## Challenge Tasks

### Task 1: Create Users (20 minutes)

Create three users with home directories and passwords:
- `tokyo`
- `berlin`
- `professor`

**Verify:** Check `/etc/passwd` and `/home/` directory

Steps to follow:

**useradd:** A system command used to create users, It does not ask questions, You must manually set options like home directory and password, We can check the created user under /home directory. 

-->Eg: sudo useradd tokyo

-->Eg: Create user with home directory: sudo useradd -m sonali

-->Eg: Set password manually: sudo passwd sonali

**1. Create 3 users:** Enter a password for each user, Press Enter to skip optional details (Full Name, Room Number, etc.).

**adduser:** A user-friendly script that uses useradd internally, It asks for details interactively. It will ask for the password, Full name, Room number, Phone number, It also automatically Creates home directory, Sets password and Adds user to basic groups.

-->sudo adduser tokyo

-->sudo adduser berlin

-->sudo adduser professor

**2. Verify users in /etc/passwd:** grep -E "tokyo|berlin|professor" /etc/passwd 

<img width="1637" height="972" alt="t1i1" src="https://github.com/user-attachments/assets/3e3e41aa-45ba-42fe-b8f1-75aa1b52a72d" />

<img width="1681" height="897" alt="t1i2" src="https://github.com/user-attachments/assets/c0b30aa6-ad74-459a-a9a2-fbf6fc524448" />

**userdel:** --> To delete the created user, We can check the user details in the home directory. Eg: sudo userdel tokyo OR sudo userdel -r tokyo [Delete the user with home directory]

**3. Verify home directories:** ls -l /home

4. Verify each user exists: [Expected: If these commands return user details, the users were created successfully.]

<img width="1466" height="477" alt="image" src="https://github.com/user-attachments/assets/bdefdc51-d63f-49f4-aeca-3893e1be5b64" />

**Task 2**

**groupadd:** --> To create a group in Linux, you use the groupadd command, And we can check the group under /etc/group directory

Step 1: Create the developers group: sudo groupadd developers

Step 2: Create the admins group: sudo groupadd admins

Step 3: Verify the groups: grep -E "developers|admins" /etc/group

-->To check the entire created group in the file: cat /etc/group

-->Check a specific group: getent group developers [Expected: If the commands return group details, the groups were created successfully.]

<img width="1447" height="957" alt="image" src="https://github.com/user-attachments/assets/6deb949a-fe21-4d09-a847-941e6a29ffaa" />

<img width="1575" height="956" alt="image" src="https://github.com/user-attachments/assets/4d59a2d6-467a-4591-9f50-f79d6b95eb9c" />

**Task 3**

Step 1: Add tokyo to developers: sudo usermod -aG developers tokyo

Step 2: Add berlin to both developers and admins: sudo usermod -aG developers,admins berlin

Step 3: Add professor to admins: sudo usermod -aG admins professor

Note: The -aG option is important:
- -a = append (don't remove existing groups)
- -G = specify supplementary groups

Step 4: Verify group membership: 
- groups tokyo OR id tokyo
- groups berlin OR id berlin
- groups professor OR id professor

Expected output: 

<img width="1637" height="316" alt="image" src="https://github.com/user-attachments/assets/45f87209-8415-49ab-a0a5-e7db479f3f11" />

**task 4**

Step 1: Create the directory: sudo mkdir /opt/dev-project 

Step 2: Change the group owner to developers: sudo chown :developers /opt/dev-project

Step 3: Set permissions to 775: sudo chmod 775 /opt/dev-project 

Step 4: Verify permissions: ls -ld /opt/dev-project

Step 5: Test as tokyo: In task 3 we have added tokyo and berlin user in the developers group as developers is the owner of the /opt/dev-project directory

-->sudo -u tokyo touch /opt/dev-project/tokyo.txt

Step 6: Test as berlin: sudo -u berlin touch /opt/dev-project/berlin.txt

Step 7: Verify the files: ls -l /opt/dev-project

<img width="1526" height="352" alt="image" src="https://github.com/user-attachments/assets/42c3d5af-e5cc-4687-93d0-770fb23b6d7b" />

**Verification complete if:**
- ls -ld /opt/dev-project shows drwxrwxr-x and group developers.
- Both tokyo and berlin can create files in /opt/dev-project successfully.

**Task 5**
1. Create user nairobi with home directory

2. Create group project-team

<img width="612" height="721" alt="image" src="https://github.com/user-attachments/assets/49d36357-4e72-4917-9bac-ec0e902dca30" />

3. Add nairobi and tokyo to project-team

<img width="618" height="163" alt="image" src="https://github.com/user-attachments/assets/7f6e3846-418b-4923-bcff-ef8ab38b0e48" />

4. Create /opt/team-workspace directory

5. Set group to project-team, permissions to 775

<img width="647" height="37" alt="image" src="https://github.com/user-attachments/assets/9fe958c6-fe9c-4183-ad02-74cebc0c7300" />

<img width="687" height="293" alt="image" src="https://github.com/user-attachments/assets/b8374b75-020b-4fd5-b31c-c7afc498ecf7" />

6. Test by creating file as nairobi

<img width="800" height="505" alt="image" src="https://github.com/user-attachments/assets/eeff0be8-6ada-4330-9eb4-925c09d3b20a" />

**Conclusion:**

--> sudo useradd -m nairobi

--> sudo useradd -m tokyo

--> sudo groupadd project-team

--> sudo usermod -aG project-team nairobi

--> sudo usermod -aG project-team tokyo

--> sudo mkdir /opt/team-workspace

--> sudo chown :project-team /opt/team-workspace

--> sudo chmod 775 /opt/team-workspace

--> su - nairrobi

--> echo "hello nairobi " >> file.txt

--> cat gile.txt

**Users & Groups Created**

Users: tokyo, berlin, professor, nairobi

Groups: developers, admins, project-team

**Group Assignments**

admins: berlin, rofessor

developers: tokyo, berlin

project-team: nairobi, tokyo

**Directories Created**

directory: /opt/team-workspace , permission: 775 , owner: project-team

directory: /opt/dev-project , permission: 775 , owner: developers

**Commands Used**

cat group

cat passwd

chown :developers /opt/dev-project

chown :project-team /opt/team-workspace

getent group

getent group admins

getent group developers

getent group project-team

ll

ls -l /home

ls -ld dev-project/

man chown

mkdir /opt/team-workspace

mkdir dev-project

su - nairobi

su - tokyo

sudo chmod 775 /opt/team-workspace

sudo addgroup admins

sudo addgroup developers

sudo addgroup project-team

sudo adduser berlin

sudo adduser berlin admins

sudo adduser berlin developers

sudo adduser nairobi

sudo adduser nairobi project-team

sudo adduser professor

sudo adduser professor admins

sudo adduser tokyo

sudo adduser tokyo developers

sudo chmod 775 dev-project

sudo chown :developers /opt/dev-project

sudo chown :project-team /opt/team-workspace

sudo mkdir /opt/team-workspace

sudo mkdir dev-project

sudo passwd ubuntu

sudo usermod -aG project-team tokyo

What I Learned

**[3 key points]**

User & Group creation

Manage Group memberships

Create workspace directory for team

Switch between users in Linux

