**Day 06 – Linux Fundamentals: Read and Write Text Files**

<img width="1457" height="381" alt="image" src="https://github.com/user-attachments/assets/e73bb553-8832-4375-8a07-18ea505f45d0" />


**1 touch notes.txt**

Creates an empty file named notes.txt if it doesn’t exist.

If it already exists, it updates the timestamp.

**2 echo "Line 1" > notes.txt**

Writes "Line 1" into the file.

--> overwrites the file (deletes previous content).

**After this:**

Line 1

**3 echo "Line 2" >> notes.txt**

--> appends to the file (does NOT overwrite).

Now the file contains:

Line 1

Line 2

**4 echo "Line 3" | tee -a notes.txt**

tee writes output to a file and prints to terminal.

-a means append.

**Terminal output:**

Line 3

File now contains:

Line 1

Line 2

Line 3

**5 cat notes.txt**

Displays full file:

Line 1

Line 2

Line 3

**6 head -n 2 notes.txt**

Shows first 2 lines:

Line 1

Line 2

**7 tail -n 2 notes.txt**

Shows last 2 lines:

Line 2

Line 3

**Command	Purpose**

--> Following symbol is used to Override the file content >	

--> Following symbol is used to Append the file content>>

tee -a	Append + display

head	View top lines

tail	View bottom lines
