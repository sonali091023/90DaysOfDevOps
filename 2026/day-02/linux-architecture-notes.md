**Day 2 - Linux, Linux Filesystem hierarchy, Linux Architecture, Processes, and systemd**

**What is Linux?**

-->Linux is an open-source, Unix-like operating system kernel created by Linus Torvalds in 1991, It manages hardware resources, processes, memory, and filesystems. It is widely used in servers, cloud computing, and DevOps environments, Linux is powerful because it is Open source, Free, Stable, Secure, Highily Customizable, Lightweight, Server-friendly etc, Linux is important because it uses in the Cloud Servers, Docker containers, Kubernetes clusters, Web servers, CI/CD pipelines etc.
Linux Architecture:

-->Applications or users interact with the Shell, Then The Shell communicates with the Kernel by sending commands through system calls, Then The Kernel theninteracts directly with the hardware to execute those commands, This is how Linux operates in a Command Line Interface (CLI) environment.
Most Linux administration and server management tasks are performed using the CLI.

<img width="882" height="441" alt="image" src="https://github.com/user-attachments/assets/a3de95a8-2125-4704-8bcc-313704ab0cf2" />

**Hardware:** It is a combination of all peripherals associated with the system. For example: RAM, CPU and Hard disk etc..

**kernel:** Linux kernel is written in the version of the C programming language. It is the core part of the operating system and manages the CPU, memory, and peripheral devices. The kernel is the "lowest" level of the OS. It is responsible for all major activities of this operating system.

**Shell:** Shell acts as a user interface, interpreting user commands and starting an application. Users typically interact with a Linux shell using a terminal emulator, however, direct operation via serial hardware connections, or networking session, are common for server systems.

**System utilities:** The system tools are built using the system libraries and enable administrators to administer the system manage processes, navigate on the file system, execute other applications, configure the network etc. The Linux OS is a collection of a number of components:

**1. Boot-loader:** It is a program that loads the Linux kernel into the computer's main memory, by being executed by the computer when it is turned on and after the firmware initialization is performed.

**2. kernal :** It is the core part of the operating system and manages the CPU, memory, and peripheral devices.

**3. Daemons :** These are background services that either startup during boot, or after you log into the desktop.

**4. Shell :** Shell is a command processor that allows you to control the computer via commands typed into a text interface.

**5. System Libraries :** System libraries are special programs that help in accessing the kernel's features. Programmers have developed a standard library of procedures to communicate with the kernel.

**6. Graphical Server :** This is the sub-system that displays the graphics on your monitor. It is commonly referred to as the X server or just "X".

**7. System Tools :** Linux OS has a set of utility tools which are usually simple commande It is a software which GNU project has written and publish under their open source license so that software is freely available to everyone.

**What is kernel?**

-->Kernel is the main core component it is lies between the shell and the hardware. It controls the activity of other hardware components.

The kernel is responsible for:

-->Memory management: Manages and allocates memory efficiently.

-->Resource allocation: Distributes system resources to different processes.

-->Device management: Controls input/output devices like printers and scanners.

-->Process management: Manages process execution and scheduling.

-->Application interaction: Bridges applications with system-level functions.

**Security:** Provides essential system-level security.

**What is systemd?**

-->**Systemd** is a system and service manager for Linux operating systems. It’s responsible for booting your computer, starting and stopping services, managing processes, and handling system shutdowns. Essentially, systemd is the first process (PID 1) that runs when your Linux system boots, and it stays active until the system shuts down.

-->**Following are the Key Features of systemd: **

1. Parallel service startup

2. Faster boot times Service dependency management

3. Ensures correct startup order Integrated logging via journald

4.  Easier troubleshooting Service monitoring & auto-restart

5.  Keeps critical services alive Resource control

6.   Limit CPU/memory usage per service

-->**How systemd Organizes Services:**  Systemd uses unit files to describe services, targets, devices, sockets, timers, and more. The most common type is the service unit (.service).

**What is Shell and there different types?**

-->Shell is the command interpreter, Common shells are bash, sh, zsh in that most used is bash, And When we open terminal bash gets start.

**Linux Filesystem hierarchy:-**

-->Everything in the linux is either a file OR directory, Everything is starts with the process.

-->Everything in the linux is treated as a file such as Hardware, process, Directory, Device all are treated as a file, for example: /dev/sda is treated as a file. Linux follows linux because, this mkaes Automation easier, Scripting Easier, System management easier etc.

How Linux represents resources internally, In Linux:

-->**Regular file** → file.txt

-->**Directory** → /home

-->**Device** → /dev/sda

-->**Keyboard** → /dev/input

-->**Hard disk** → /dev/sda

-->**Process info** → /proc/1234

-->**Null device** → /dev/null

-->Even hardware is represented as a file.

-->Linux filesystem starts from root directory /.

-->It follows Filesystem Hierarchy Standard (FHS).

-->Important directories include /etc for config, /var for logs, /home for users, /bin for commands, and /proc for process information.

**What are the Linux Flavors?**

-->So Linux Flavors also knows as Distributions or distros. In that Ubuntu is commonly used then Fedora, CentOS[Generally used by startups], RHEL[Also knows as RedHat used at enterprises level].

-->Even though they all use the same Linux kernel, they differ in:

1. Package management (APT, YUM, Pacman, etc.)

2. Default desktop environment (GNOME, KDE, XFCE)

3. Target users (beginners, developers, servers, security)

4. Stability vs cutting-edge updates

**Daily useful commands:**

-->man, pwd, ls, cd, mv, cp, touch, mkdir
