# Day 16 – Shell Scripting Basics**

**Task 1: Your First Script**
1. Create a file hello.sh --> vi hello.sh
   
2. Add the shebang line #!/bin/bash at the top

<img width="552" height="178" alt="image" src="https://github.com/user-attachments/assets/49b70682-d3a9-4bd0-bac6-261793f4702c" />

3. Print Hello, DevOps! using echo

5. Make it executable and run it

   --> sudo chmod +x hello.sh

   --> ./hello.sh

<img width="635" height="207" alt="image" src="https://github.com/user-attachments/assets/5173d804-f14c-45fa-8e10-92e02c2d6f45" />

Document: What happens if you remove the shebang line?

-->By removing shebang line from  the script i have not seen any chnages.

<img width="487" height="143" alt="image" src="https://github.com/user-attachments/assets/8dc5f2c5-bec6-4638-be97-387433fb8894" />

**Task 2: Variables**

**1. Create variables.sh with: --> vi variables.sh in that A variable for your NAME, A variable for your ROLE (e.g., "DevOps Engineer") Print: Hello, I am <NAME> and I am a <ROLE>**

--> #!/bin/bash

    NAME="Sonali"
    
    ROLE="DevOps Engineer"

    echo "Hello, I am $NAME and I am a $ROLE"
    
<img width="511" height="187" alt="image" src="https://github.com/user-attachments/assets/1dfe6874-7ab6-488f-a8f3-ebc18fd56501" />

**2. Try using single quotes vs double quotes — what's the difference?**

--> Added single quotes instead of double quotes and observed that the variable value was not printed; instead, the variable name was printed.

--> <img width="582" height="186" alt="image" src="https://github.com/user-attachments/assets/9e6edc3b-ad05-4b0c-8ef8-27a37a2f8963" />

--> <img width="518" height="126" alt="image" src="https://github.com/user-attachments/assets/54e46eea-780b-4c88-b516-d69709617cd9" />

**Task 3: User Input with read**
1. Create greet.sh that: --> vi greet.sh

--> #!/bin/bash

   read -p "Enter your name: " name
   
   read -p "Enter your favourite tool: " tool

   echo "Hello $name, your favourite tool is $tool"
  
Asks the user for their name using read
   
Asks for their favourite tool
   
Prints: Hello <name>, your favourite tool is <tool>

<img width="673" height="318" alt="image" src="https://github.com/user-attachments/assets/0ed79f28-e569-4ff1-81b8-d8c08e9c9470" />

**Task 4: If-Else Conditions**

-->Create check_number.sh that: Takes a number using read, Prints whether it is positive, negative, or zero

<img width="608" height="275" alt="image" src="https://github.com/user-attachments/assets/5e7fdb87-782d-4e89-a070-e32f2d37c48e" />

<img width="877" height="725" alt="image" src="https://github.com/user-attachments/assets/b0529b15-a50a-400d-8894-ee91b23c7f78" />

--> Create file_check.sh that: Asks for a filename, Checks if the file exists using -f

Prints appropriate message

<img width="522" height="241" alt="image" src="https://github.com/user-attachments/assets/d4589597-8143-4012-a2f7-636b8b5080ef" />

<img width="727" height="320" alt="image" src="https://github.com/user-attachments/assets/c84600a1-0edd-415c-9a2a-8d4228ef1a59" />

**Task 5: Combine It All**

--> Create server_check.sh that: Stores a service name in a variable (e.g., nginx, sshd), Asks the user: "Do you want to check the status? (y/n)"

If y — runs systemctl status <service> and prints whether it's active or not

If n — prints "Skipped."

<img width="727" height="437" alt="image" src="https://github.com/user-attachments/assets/bb18560f-2d68-468e-8d42-3f1d6b4036ba" />

<img width="1527" height="681" alt="image" src="https://github.com/user-attachments/assets/58800669-e771-42f0-ae61-a8acb5dcd42b" />



