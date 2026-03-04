**Day 2 - Linux, Linux Filesystem hierarchy, Linux Architecture, Processes, and systemd**

**What is Linux?**

-->Linux is an open-source, Unix-like operating system kernel created by Linus Torvalds in 1991, It manages hardware resources, processes, memory, and filesystems. It is widely used in servers, cloud computing, and DevOps environments, Linux is powerful because it is Open source, Free, Stable, Secure, Highily Customizable, Lightweight, Server-friendly etc, Linux is important because it uses in the Cloud Servers, Docker containers, Kubernetes clusters, Web servers, CI/CD pipelines etc.

**What is kernel?**

-->Kernel is the main core component it is lies between the shell and the hardware. It controls the activity of other hardware components.
**The kernel is responsible for:**

Memory management: Manages and allocates memory efficiently. 

Resource allocation: Distributes system resources to different processes. 

Device management: Controls input/output devices like printers and scanners. 

Process management: Manages process execution and scheduling. 

Application interaction: Bridges applications with system-level functions. 

Security: Provides essential system-level security.

**What is systemd?**

-->Systemd is a system and service manager for Linux operating systems. It’s responsible for booting your computer, starting and stopping services, managing processes, and handling system shutdowns. Essentially, systemd is the first process (PID 1) that runs when your Linux system boots, and it stays active until the system shuts down.

**Following are the Key Features of systemd:**  Parallel service startup — Faster boot times Service dependency management — Ensures correct startup order Integrated logging via journald – Easier troubleshooting Service monitoring & auto-restart — Keeps critical services alive Resource control — Limit CPU/memory usage per service

**How systemd Organizes Services:**  Systemd uses unit files to describe services, targets, devices, sockets, timers, and more. The most common type is the service unit (.service).

**Linux Architecture:**

-->Applications or users interact with the Shell, Then The Shell communicates with the Kernel by sending commands through system calls, Then The Kernel theninteracts directly with the hardware to execute those commands, This is how Linux operates in a Command Line Interface (CLI) environment.
Most Linux administration and server management tasks are performed using the CLI.

**What is Shell and there different types?**

-->Shell is the command interpreter, Common shells are bash, sh, zsh in that most used is bash, And When we open terminal bash gets start.

**Linux Filesystem hierarchy:-**

-->Everything in the linux is either a file OR directory, Everything is starts with the process.

-->Everything in the linux is treated as a file such as Hardware, process, Directory, Device all are treated as a file, for example: /dev/sda is treated as a file. Linux follows linux because, this mkaes Automation easier, Scripting Easier, System management easier etc.

**How Linux represents resources internally,**

In Linux:

Regular file → file.txt

Directory → /home

Device → /dev/sda

Keyboard → /dev/input

Hard disk → /dev/sda

Process info → /proc/1234

Null device → /dev/null

Even hardware is represented as a file.

-->Linux filesystem starts from root directory /.

-->It follows Filesystem Hierarchy Standard (FHS).

-->Important directories include /etc for config, /var for logs, /home for users, /bin for commands, and /proc for process information.

**What are the Linux Flavors?**

-->So Linux Flavors also knows as Distributions. In that Ubuntu is commonly used then Fedora, CentOS[Generally used by startups], RHEL[Also knows as RedHat used at enterprises level].

**Daily useful commands:**

-->man, pwd, ls, cd, mv, cp, touch, mkdir
