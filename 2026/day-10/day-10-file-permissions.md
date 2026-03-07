**Day 10 – File Permissions & File Operations Challenge**

**Task 1: Create Files (10 minutes)**

1.	Create empty file devops.txt using touch  touch devops.txt

2.	Create notes.txt with some content using cat or echo  cat > notes.txt and then add the content and to save it click ctrl + d and see the content again cat notest.txt

3.	Create script.sh using vim with content: echo "Hello DevOps"

Verify: ls -l to see permissions

<img width="891" height="408" alt="image" src="https://github.com/user-attachments/assets/7d2f2386-074f-422f-b870-59a1d814d673" />


**Task 2: Read Files (10 minutes)**

1.  Read notes.txt using cat  cat notes.txt

2.	View script.sh in vim read-only mode  vi script.sh

3.	Display first 5 lines of /etc/passwd using head  sudo cat /etc/passwd | head -5

4.	Display last 5 lines of /etc/passwd using tail  sudo cat /etc/passwd | tail -5

<img width="521" height="285" alt="image" src="https://github.com/user-attachments/assets/331d7183-b601-429d-8950-6d28bfbc1f2b" />

<img width="896" height="490" alt="image" src="https://github.com/user-attachments/assets/2f427ed7-b019-4182-a4fa-68d9043cdcc5" />

**Task 3: Understand Permissions (10 minutes)**

Format: rwxrwxrwx (owner-group-others)

•	r = read (4), w = write (2), x = execute (1)

Check your files: ls -l devops.txt notes.txt script.sh

Answer: What are current permissions? Who can read/write/execute?

So the answer is for all the three files such as devops.txt, notes.txt and script.sh,  The owner can read and write but cant execute the same file, Then group can also read and write to the file but cant execute the file, But others can only read the file.
 
<img width="823" height="246" alt="image" src="https://github.com/user-attachments/assets/85ca4acd-abc4-4014-932c-6d75361c2873" />

**Task 4: Modify Permissions (20 minutes)**

1.	Make script.sh executable → run it with ./script.sh

-->	sudo chmod 774 script.sh 

-->	sudo ./script.sh

2.	Set devops.txt to read-only (remove write for all)

-->	sudo chmod 444 devops.txt

-->	ls -l devops.txt

3.	Set notes.txt to 640 (owner: rw, group: r, others: none)

-->	sudo chmod 640 notes.txt

-->	ls -l notes.txt

4.	Create directory project/ with permissions 755

-->	mkdir project 

-->	ls -l 

-->	sudo chmod 755 project

-->	ls -l

Verify: ls -l after each change
 
Task 5: Test Permissions (10 minutes)

1.	Try writing to a read-only file - what happens?

2.	Try executing a file without execute permission

3.	Document the error messages

<img width="715" height="869" alt="image" src="https://github.com/user-attachments/assets/647b567a-5ae2-4610-b613-4d5bffcf2306" />


**Files Created**

devops.txt

notes.txt

project (dir)

script.sh

script2.sh

Permission Changes

Default permission for all files was 664 -rw-rw-r--

script.sh was changed to 775 using chmod +x

chmod 555 devops.txt

chmod 640 notes.txt

chmod 755 project/

chmod +w devops.txt

chmod -w devops.txt

Commands Used

touch devops.txt

echo "Linux is a powerful OS" > notes.txt

vim script.sh

ls -l

cat notes.txt

head /etc/passwd

tail -n 20 /etc/passwd

ls -l notes.txt script.sh devops.txt

./script.sh

chmod +x script.sh

chmod 555 devops.txt

chmod 640 notes.txt

mkdir project

||

chmod 755 project/

echo "Writing to a file" >> devops.txt

vim script2.sh

./script2.sh

chmod +w devops.txt

chmod -w devops.txt

What I Learned

Permissions control access at a very granular level

Execute permission is mandatory to run scripts

Numeric permissions (755, 640) are faster and cleaner
