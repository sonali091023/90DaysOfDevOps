Process management Commands:

-->ps: Shows processes running in the current shell session.
   
   eg:
   
   ps aux - Display all running processes on your system
   
   ps -ef | grep "PATTERN" - Display all the running processes matching with "PATTERN"

-->top: is used to monitor system processes in real time, It continuously updates the process list

-->htop:htop is the improved version of the top, htop is an interactive, real-time process viewer for Linux.

-->grep: grep stands for [Global Regular Expression Print], It is used to search for a pattern inside files or command output.

-->pgrep: pgrep is[Process grep], It is used to find process IDs (PIDs) by process name or other attributes, Alternet to grep.
  
  eg:
  
  ps -ef | grep "PATTERN" - Display all the running processes matching with "PATTERN"


-->kill: kill is used to send signals to a process [usually to stop or terminate it]

-->pkill: pkill is[process kill], It is used to kill processes by name or other attributes, instead of specifying the PID manually.

-->killall: killall is used to terminate processes by name — similar to pkill, It sends a signal to all processes matching a given name.
   
   eg:
   
   kill <process_id> - terminate/kill the process by process id, you can kill multiple processes using multiple P_id's in the same command
   
   kill -9 <process_id> - force kill a process by its process id, you can kill multiple processes using multiple P_id's in the same command

-->nohup script.sh &: run a program in background & keep it running even after you close the shell session


File System Commands:

-->pwd: Shows Present working directory

-->ls: Shows the list of files and directories

-->cd: This is used to chnage the directory

-->mkdir: To create the directory

-->rmdir: To remove the directory

-->rm: To remove the file

-->rm -r:To remove directory

-->cp: Used to copy the file

-->mv: Is used to move OR rename the file

-->touch: Is used to create the file

-->cat: Is used to read the content of the file

-->less: is used to view the large files

-->head -n 10 file.txt - shows the first 10 lines of a file

-->tail -n 50 file.txt - shows the last 50 lines of a file

-->chmod - modify file or directory permissions

-->chown - change ownership of a file or directory


Networking troubleshooting Commands:

-->ping google.com - test reachability and measure latency to a host

-->curl -I https://example.com - fetch data from a URL, useful for testing APIs or websites

-->traceroute - show the path packets take to reach a destination

-->lsof -i :80 - find which process is listening on a specific port (e.g., port 80)

-->ifconfig - configure or view network interfaces

-->dig - query DNS records for a domain

-->ip addr show - display IP addresses assigned to interfaces

-->ip route: 

-->netstat: To check the open ports

-->telnet: Test the port Connectivity

-->wget: 

-->nslookup: 
