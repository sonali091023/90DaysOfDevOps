# Day 10 – File Permissions & File Operations Challenge**

## Task
Master file permissions and basic file operations in Linux.

- Create and read files using `touch`, `cat`, `vim`
- Understand and modify permissions using `chmod`

---

## Expected Output
- A markdown file: `day-10-file-permissions.md`
- Screenshots showing permission changes

---

## Challenge Tasks

### Task 1: Create Files (10 minutes)

1. Create empty file `devops.txt` using `touch`
2. Create `notes.txt` with some content using `cat` or `echo`
3. Create `script.sh` using `vim` with content: `echo "Hello DevOps"`

**Verify:** `ls -l` to see permissions

**Steps to follow:**

Step 1: Create an empty file: touch devops.txt

Step 2: Create notes.txt with content: echo "These are my DevOps notes." > notes.txt OR Use cat command: cat > notes.txt & then type the content 

Step 3: Create script.sh using vim: vim script.sh [Note: Press i to enter Insert mode, then type]

Step 4: Verify: ls -l

**Note:** script.sh is just a text file at this point. If you want to make it executable later, run: chmod +x script.sh

<img width="1772" height="690" alt="image" src="https://github.com/user-attachments/assets/6e83833e-b110-4c29-ba12-0121d9aa7cad" />

---

### Task 2: Read Files (10 minutes)

1. Read `notes.txt` using `cat`
2. View `script.sh` in vim read-only mode
3. Display first 5 lines of `/etc/passwd` using `head`
4. Display last 5 lines of `/etc/passwd` using `tail`

**Steps to follow:**

Step 1: Read notes.txt using cat: cat notes.txt

Step 2: View script.sh in Vim read-only mode: vi -R script.sh [Expected: -R opens the file in read-only mode.]

Step 3: Display the first 5 lines of /etc/passwd: head -n 5 /etc/passwd OR sudo cat /etc/passwd | head -5

Step 4: Display the last 5 lines of /etc/passwd: tail -n 5 /etc/passwd OR sudo cat /etc/passwd | tail -5

Verify: You should see:
- The contents of notes.txt.
- script.sh opened in Vim without allowing edits.
- The first 5 lines of /etc/passwd.
- The last 5 lines of /etc/passwd.

<img width="1670" height="631" alt="image" src="https://github.com/user-attachments/assets/84a2f28c-9ccc-4ac2-9eeb-7f55cd5a985e" />

<img width="1502" height="977" alt="image" src="https://github.com/user-attachments/assets/92b462f1-46d9-448e-bc6d-d120d9ffdcb0" />

---

### Task 3: Understand Permissions (10 minutes)

Format: `rwxrwxrwx` (owner-group-others)
- `r` = read (4), `w` = write (2), `x` = execute (1)

Check your files: `ls -l devops.txt notes.txt script.sh`

Answer: What are current permissions? Who can read/write/execute?

Steps to follow:

-->ls -l devops.txt notes.txt script.sh

<img width="1600" height="145" alt="image" src="https://github.com/user-attachments/assets/e27b3551-baa3-4785-8ae9-e0acb9f2a69f" />

<img width="750" height="767" alt="image" src="https://github.com/user-attachments/assets/c1a6f735-86a0-4cfe-b095-80c20c9e8ae5" />

<img width="887" height="480" alt="image" src="https://github.com/user-attachments/assets/11129086-73f7-44a1-a513-1afba853f82a" />

Format: rwxrwxrwx (owner-group-others)

•	r = read (4), w = write (2), x = execute (1)

Check your files: ls -l devops.txt notes.txt script.sh

Answer: What are current permissions? Who can read/write/execute?

-->So the answer is for all the three files such as devops.txt, notes.txt and script.sh,  The owner can read and write but cant execute the same file, Then group can also read and write to the file but cant execute the file, But others can only read the file.

### Task 4: Modify Permissions (20 minutes)

1. Make `script.sh` executable → run it with `./script.sh`
2. Set `devops.txt` to read-only (remove write for all)
3. Set `notes.txt` to `640` (owner: rw, group: r, others: none)
4. Create directory `project/` with permissions `755`

**Verify:** `ls -l` after each change

**Steps to follow:**

Step 1. Make script.sh executable: chmod +x script.sh

-->Run the script:	sudo ./script.sh

-->verify: ls -l script.sh

Step 2. Make devops.txt read-only (remove write for everyone): sudo chmod 444 devops.txt OR chmod a-w devops.txt

-->verify: ls -l devops.txt

Step 3. Set notes.txt permissions to 640: sudo chmod 640 notes.txt

-->verify: ls -l notes.txt

**Meaning:**
- Owner: Read, Write
- Group: Read
- Others: No permissions

Step 4. Create project/ directory with 755 permissions: mkdir project 

-->ls -ld project

-->chmod 755 project: sudo chmod 755 project

-->ls -ld project

<img width="826" height="262" alt="image" src="https://github.com/user-attachments/assets/8a6dc895-5a79-4e50-ac9e-3d60793a6543" />

<img width="1340" height="567" alt="image" src="https://github.com/user-attachments/assets/8e1a7f13-c221-4a10-a6a3-cfa89d45dfea" />

---
 
Task 5: Test Permissions (10 minutes)

1. Try writing to a read-only file - what happens?
2. Try executing a file without execute permission
3. Document the error messages

**Steps to follow:**

Step 1. Try writing to the read-only file: If devops.txt has permission 444, run: echo "New content" >> devops.txt [Expected: Permission denied]

Step 2. Try executing a file without execute permission: Remove execute permission from notes.txt (if it doesn't already lack it): chmod 644 notes.txt Now try to execute the file: ./notes.txt [expected: permission denied]

Step 3. Document the error messages: 

<img width="955" height="206" alt="image" src="https://github.com/user-attachments/assets/4ba13a40-5ba9-4fa4-96dc-a3b6565294bf" />

<img width="1330" height="150" alt="image" src="https://github.com/user-attachments/assets/67b7eb13-d48f-4148-b081-667cce4ed800" />

**Explanation:**
- Write denied: The file does not have the write (w) permission.
- Execute denied: The file does not have the execute (x) permission, so the shell refuses to run it.

---

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

## Hints

- Create: `touch`, `cat > file`, `vim file`
- Read: `cat`, `head -n`, `tail -n`
- Permissions: `chmod +x`, `chmod -w`, `chmod 755`

---

## Documentation

Create `day-10-file-permissions.md`:

```markdown
# Day 10 Challenge

## Files Created
[list files]

## Permission Changes
[before/after for each file]

## Commands Used
[your commands]

## What I Learned
[3 key points]
```

---

## Submission
1. Navigate to `2026/day-10/` folder
2. Add `day-10-file-permissions.md` with screenshots
3. Commit and push

---

## Learn in Public

Share on LinkedIn about mastering file permissions.

Use hashtags:
```
#90DaysOfDevOps
#DevOpsKaJosh
#TrainWithShubham
```


