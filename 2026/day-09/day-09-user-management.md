
**Day 09 – Linux User & Group Management Challenge**

**Task 1**

**useradd:** --> A system command used to create users, It does not ask questions, You must manually set options like home directory and password, We can check the created user under /home directory

--> Create user:--> sudo useradd sonali

--> Set password manually:--> sudo passwd sonali

--> Create user with home directory:--> sudo useradd -m sonali

**adduser:** --> A user-friendly script that uses useradd internally, It asks for details interactively.

-->It will ask for the password, Full name, Room number, Phone number, It also automatically Creates home directory, Sets password and Adds user to basic groups.

--> Create user:--> sudo adduser sonali--> adduser does everything in one step.

**userdel:** --> To delete the created user, We can check the user details in the home directory.

--> sudo userdel tokyo OR sudo userdel -r tokyo [Delete the user with home directory]

<img width="646" height="973" alt="user added" src="https://github.com/user-attachments/assets/6c92fc7e-de12-4b28-99e8-64911080cfea" />


**Task 2**

**groupadd:** --> To create a group in Linux, you use the groupadd command, And we can check the group under /etc/group directory

--> sudo groupadd groupname-->basic command to create group

--> sudo groupadd -g 1050 devops-->by using specific group id we can create the group

--> cat /etc/group OR cat /etc/group | grep devops OR getent group --> To verify the created group in the /etc/group directory

<img width="1871" height="586" alt="to-add-group" src="https://github.com/user-attachments/assets/f2ebd73e-53e3-4c51-8329-4bc2177ffa75" />


**Task 3**

--> sudo usermod -g developers tokyo :-->To add the user to te group

--> groups username:-->Check which groups a user belongs to

-->sudo gpasswd -d username groupname --> To remove the username from the group

<img width="601" height="197" alt="user added to the group" src="https://github.com/user-attachments/assets/263a59f2-65fa-44a7-8162-1a6c909b638c" />


**task 4**

1. Create directory: /opt/dev-project  --> sudo mkdir /opt/dev-project --> then do cd /opt after do ls -l
2. Set group owner to developers  --> sudo chown :developers /opt/dev-project --> after this do ls -l
3. Set permissions to 775 (rwxrwxr-x) --> sudo chmod 775 dev-project --> and then do ls-l

<img width="862" height="318" alt="image" src="https://github.com/user-attachments/assets/044ca1cd-bf95-4a86-adaf-b7d755df14da" />

4. Test by creating files as tokyo and berlin --> In step 3 we have added tokyo and berlin user in the developers group as developers is the owner of the /opt/dev-project directory

--> su - tokyo --> then do pwd --> cd /opt/dev-project/ --> do ll --> echo "Hello world" >> file1.txt --> cat file1.txt and we can see the text hello world in /opt/dev-project directory

--> su - berlin --> then do pwd --> cd /opt/dev-project/ --> do ll --> echo "hello berlin" >> file2.txt --> cat file2.txt and then we can see text hello berlin in /opt/dev-project directory

<img width="703" height="912" alt="image" src="https://github.com/user-attachments/assets/7acce898-5269-4000-b792-45b8167c9cfc" />

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

