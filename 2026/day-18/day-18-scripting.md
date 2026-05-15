**Day 18 – Shell Scripting: Functions & intermediate Concepts**

**Task 1: Basic Functions**

**1. Create functions.sh with:**

A function greet that takes a name as argument and prints Hello, <name>!

A function add that takes two numbers and prints their sum

Call both functions from the script

<img width="467" height="373" alt="image" src="https://github.com/user-attachments/assets/ed1c3935-ca15-4922-b28d-e2d13aa785f2" />

<img width="702" height="242" alt="image" src="https://github.com/user-attachments/assets/4fa99ab9-ca4d-4453-bd2f-9babe66411fb" />

**Task 2: Functions with Return Values**

**1. Create disk_check.sh with:**

A function check_disk that checks disk usage of / using df -h

A function check_memory that checks free memory using free -h

A main section that calls both and prints the results

<img width="1016" height="936" alt="image" src="https://github.com/user-attachments/assets/dc061585-5439-4d11-97d9-066258fb89d9" />

**Task 3: Strict Mode — set -euo pipefail**

1. Create strict_demo.sh with set -euo pipefail at the top

2. Try using an undefined variable — what happens with set -u?

3. Try a command that fails — what happens with set -e?

4. Try a piped command where one part fails — what happens with set -o pipefail?

<img width="861" height="245" alt="image" src="https://github.com/user-attachments/assets/a866d318-6263-4456-b11d-5bb6e10ec186" />

<img width="977" height="337" alt="image" src="https://github.com/user-attachments/assets/71b294a6-a4c5-4583-b6f0-a9870f4a2d7e" />

**Document: What does each flag do?**

**Documentation**

**set -e →** Stop script on command error OR Exit the script immediately if any command returns a non-zero (error) status.

**Example:** Stop script if an undefined variable is used OR If ls /not_existing_directory fails, the script stops right there.

**set -u →** Pipeline fails if any command in the pipe fails OR Treat undefined variables as errors and exit the script.

**Example:** Using $name without defining it will produce an error like:

unbound variable

**set -o pipefail →** Makes a pipeline fail if any command in the pipeline fails, not just the last command.

**Example:** cat file.txt | grep "hello" | wc -l

If cat file.txt fails (file missing), the entire pipeline fails instead of returning 0 from wc.

**Task 4: Local Variables**

**1. Create local_demo.sh with:**

A function that uses local keyword for variables

Show that local variables don't leak outside the function

Compare with a function that uses regular variables

<img width="772" height="596" alt="image" src="https://github.com/user-attachments/assets/029aa273-a64a-4212-87d2-ca6b001367a6" />

<img width="733" height="422" alt="image" src="https://github.com/user-attachments/assets/eaa65708-8d13-4e91-a810-1ae1442134f0" />

**Task 5: Build a Script — System Info Reporter**

**Create system_info.sh that uses functions for everything:**

**1. A function to print hostname and OS info**

**2. A function to print uptime**

**3. A function to print disk usage (top 5 by size)**

**4. A function to print memory usage**

**5. A function to print top 5 CPU-consuming processes**

**6. A main function that calls all of the above with section headers**

**7. Use set -euo pipefail at the top**

Output should look clean and readable.

<img width="432" height="788" alt="image" src="https://github.com/user-attachments/assets/85048d05-c421-4563-8320-390fbfded426" />

<img width="1188" height="542" alt="image" src="https://github.com/user-attachments/assets/57a8a2b0-c692-4350-839b-e4b1a28f2108"/>

**What I learned**

Making reusable & modular scripts using functions

How to build a System Info Reporter script

local variables

set -euo pipefail to handle errors within a script





