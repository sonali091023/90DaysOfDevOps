# Day 17 – Shell Scripting: Loops, Arguments & Error Handling**

**Task 1: For Loop**

1. Create for_loop.sh that:

Loops through a list of 5 fruits and prints each one

<img width="628" height="175" alt="image" src="https://github.com/user-attachments/assets/b42fb74b-a83e-49cb-92bc-411977894db2" />

<img width="832" height="470" alt="image" src="https://github.com/user-attachments/assets/91e5f00a-3436-4353-a4ca-413815cba0ac" />

2. Create count.sh that: --> vi count.sh

Prints numbers 1 to 10 using a for loop

<img width="387" height="322" alt="image" src="https://github.com/user-attachments/assets/7d36dbdc-aa35-4360-b329-1721180c1ff8" />

**Task 2: While Loop**

**1. Create countdown.sh that: Takes a number from the user--> Counts down to 0 using a while loop--> Prints "Done!" at the end**

<img width="358" height="192" alt="image" src="https://github.com/user-attachments/assets/4cb3a168-a6d4-4af1-922f-5dc5f25998c9" />

<img width="682" height="965" alt="image" src="https://github.com/user-attachments/assets/fb158396-16df-4872-a4c9-7cefdc6eef4e" />

**Task 3: Command-Line Arguments**

**1. Create greet.sh that: Accepts a name as $1--> Prints Hello, <name>!--> If no argument is passed, prints "Usage: ./greet.sh "**

<img width="436" height="208" alt="image" src="https://github.com/user-attachments/assets/72e6df9b-f07b-4cd8-83d3-a5e10428af0c" />

<img width="822" height="357" alt="image" src="https://github.com/user-attachments/assets/47dab9ef-626e-406e-bd3d-04880c9adc2b" />

**2. Create args_demo.sh that: Prints total number of arguments ($#)--> Prints all arguments ($@)--> Prints the script name ($0)**

<img width="470" height="202" alt="image" src="https://github.com/user-attachments/assets/9951f64f-10b1-4949-90b1-430ba5fe8a7f" />

<img width="1015" height="367" alt="image" src="https://github.com/user-attachments/assets/bae88551-99f9-49f9-84bc-ef36ddc32a93" />

**Task 4: Install Packages via Script**

1. Create install_packages.sh that:

Defines a list of packages: nginx, curl, wget

Loops through the list

Checks if each package is installed (use dpkg -s or rpm -q)

Installs it if missing, skips if already present

Prints status for each package

Run as root: sudo -i or sudo su

<img width="717" height="462" alt="image" src="https://github.com/user-attachments/assets/a018d06d-f89d-419c-a7d3-588d88f429b2" />

<img width="893" height="171" alt="image" src="https://github.com/user-attachments/assets/847bfebf-19f5-4b72-8892-ffeaf4234ee2" />

<img width="1000" height="378" alt="image" src="https://github.com/user-attachments/assets/aa7f2fb1-d93c-4725-a3a4-893ca2b4d4d4" />

**Task 5: Error Handling**
1. Create safe_script.sh that:
Uses set -e at the top (exit on error)
Tries to create a directory /tmp/devops-test
Tries to navigate into it
Creates a file inside
Uses || operator to print an error if any step fails
Example:

<img width="1142" height="293" alt="image" src="https://github.com/user-attachments/assets/64857bb5-39d5-4388-a812-a1d83cda2bab" />

<img width="738" height="211" alt="image" src="https://github.com/user-attachments/assets/09628b73-8a95-49d5-aa7a-e189a531a38d" />

<img width="762" height="191" alt="image" src="https://github.com/user-attachments/assets/1a6798f4-16fc-48ae-bf63-e5b393211057" />

mkdir /tmp/devops-test || echo "Directory already exists"

2. Modify your install_packages.sh to check if the script is being run as root — exit with a message if not.

<img width="747" height="83" alt="image" src="https://github.com/user-attachments/assets/8a0c5f95-9e8e-4b6e-8d9c-4afcd528ec3c" />

<img width="842" height="587" alt="image" src="https://github.com/user-attachments/assets/21fe7ca8-2399-4bde-bb78-a7f40757ca71" />

**What I learned (key points)**

For loop, while loop, if-elif-else

Pass arguments in scripts

Error handling using set -e & ||

Installing multiple packages using shell script


