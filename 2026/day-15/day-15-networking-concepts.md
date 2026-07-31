Day 15 – Networking Concepts: DNS, IP, Subnets & Ports
Task
Build on Day 14 by understanding the building blocks of networking every DevOps engineer must know.

You will:

Understand how DNS resolves names to IPs
Learn IP addressing (IPv4, public vs private)
Break down CIDR notation and subnetting basics
Know common ports and why they matter
This is concept-focused — research, understand, and document in your own words.

Expected Output
A markdown file: day-15-networking-concepts.md

Challenge Tasks

Task 1: DNS – How Names Become IPs
1. Explain in 3–4 lines: what happens when you type google.com in a browser?
2. What are these record types? Write one line each:
A, AAAA, CNAME, MX, NS
3. Run: dig google.com — identify the A record and TTL from the output

**Steps to follow:**

**1. Explain in 3–4 lines: what happens when you type google.com in a browser?**

-->When you type google.com into a browser, the browser first asks a DNS server to translate the domain name into an IP address. It then establishes a TCP connection (and a TLS connection for HTTPS) with Google's server. The browser sends an HTTP request, and the server responds with the webpage's HTML, CSS, JavaScript, and other resources. Finally, the browser renders the webpage on your screen.

Simple Flow:
```
User types google.com
        │
        ▼
DNS resolves domain → IP address
        │
        ▼
TCP + HTTPS connection established
        │
        ▼
HTTP request sent
        │
        ▼
Server sends webpage
        │
        ▼
Browser displays the page
```

2. What are these record types? Write one line each:
A, AAAA, CNAME, MX, NS

<img width="757" height="310" alt="image" src="https://github.com/user-attachments/assets/804228fd-b5ac-4f3d-8ad6-e2dc3c7be58e" />

3. Run: dig google.com — identify the A record and TTL from the output

Step 1: Install dig (if needed): 
- sudo apt update
- sudo apt install dnsutils

-->And then verify: dig -v

Step 2: Run the command: dig google.com
```
you may see output: ; <<>> DiG 9.18.30 <<>> google.com
;; ANSWER SECTION:
google.com.      247     IN      A       142.250.183.14
```

Step 3: Identify the A Record: The A record is the IPv4 address.
```
Example: A Record:
142.250.183.14
```

Step 4: Identify the TTL: The number just before IN is the TTL (Time To Live).

-->TTL tells DNS resolvers how long they can cache the record before requesting it again.
<img width="687" height="232" alt="image" src="https://github.com/user-attachments/assets/cdd3f5c9-df45-488f-8b2b-a06521af42f0" />

Ex: 

1. What happens when you type google.com in a browser?

-->The browser sends a DNS query to translate google.com into an IP address. It then establishes a TCP and HTTPS connection with Google's server. An HTTP request is sent, and the server returns the webpage files. Finally, the browser renders the webpage for the user.

2. DNS Record Types:
- A: Maps a domain to an IPv4 address.
- AAAA: Maps a domain to an IPv6 address.
- CNAME: Creates an alias to another domain.
- MX: Specifies the mail server for a domain.
- NS: Specifies the authoritative DNS servers for a domain.

3. dig google.com: Run command: dig google.com
<img width="630" height="172" alt="image" src="https://github.com/user-attachments/assets/62d50b25-bde2-4ec9-aa10-3a28ac69b0ed" />
Note: Your IP address and TTL will likely be different because Google uses multiple servers and the TTL decreases as cached records age.

---

Task 2: IP Addressing
1. What is an IPv4 address? How is it structured? (e.g., 192.168.1.10)
2. Difference between public and private IPs — give one example of each
3. What are the private IP ranges?
10.x.x.x, 172.16.x.x – 172.31.x.x, 192.168.x.x
4. Run: ip addr show — identify which of your IPs are private

**1. What is an IPv4 address? How is it structured? (e.g., 192.168.1.10)**

-->An IPv4 address is a unique 32-bit number used to identify a device on an IP network. It is written as four decimal numbers (called octets) separated by dots, with each octet ranging from 0 to 255. For example, 192.168.1.10. Each device on a network needs an IP address to communicate with other devices.

<img width="682" height="377" alt="image" src="https://github.com/user-attachments/assets/bb254b71-e845-462c-a610-9b496cfce6d5" />

-->Each number called an octet, It represents 8 bits, which ranges from 0 to 255. Computers actually understand binary So the structure is:
- 192 --> Octet-->11000000
- 168 --> Octet-->10101000
- 1 --> Octet-->00000001
- 10 --> Octet-->00001010

**Types of IPv4 Addresses:**
- Public IP – used on the internet: Example: 8.8.8.8 An IPv4 address is usually divided into: Network ID → identifies the network & Host ID → identifies the device inside that network

Example: 192.168.1.10:

-->If the subnet mask is 255.255.255.0, then Network: 192.168.1 & Host: 10, Meaning: Device 10 inside network 192.168.1

Private IP – used inside local networks: below example ranges:
- 10.0.0.0 – 10.255.255.255
- 172.16.0.0 – 172.31.255.255
- 192.168.0.0 – 192.168.255.255

--> **Inshort:** DNS converts google.com → IP address like 142.250.70.78, Then your computer sends packets to that IPv4 address to reach Google's server.

**2. Difference between public and private IPs — give one example of each?**

-->Public IP Address: Both are IP addresses used to identify devices, but they are used in different places. A public IP address is used to identify a device on the internet. It is globally unique and assigned by your Internet Service Provider (ISP), If a server or website is accessible from the internet, it uses a public IP.

**Example:** 8.8.8.8 & **Scenario:** When you visit google.com, your computer connects to Google's public IP address.

-->Private IP Address: A private IP address is used inside a local network (home WiFi, office network, or cloud network), These addresses cannot be accessed directly from the internet.

<img width="702" height="210" alt="image" src="https://github.com/user-attachments/assets/6053adcc-8b87-4819-9722-58a035fc2d22" />

**3. What are the private IP ranges?**

--> There are three private IPv4 ranges defined by RFC 1918:

```
Range	                         CIDR Notation	    Common Use
10.0.0.0 – 10.255.255.255	     10.0.0.0/8	        Large organizations
172.16.0.0 – 172.31.255.255	     172.16.0.0/12	    Medium-sized networks
192.168.0.0 – 192.168.255.255	 192.168.0.0/16	    Home and small office networks
```

4. Run: ip addr show — identify which of your IPs are private

-->ip addr show OR ip a

<img width="717" height="707" alt="image" src="https://github.com/user-attachments/assets/60f571d7-6947-4e1a-afb8-9277694280f0" />

<img width="1605" height="921" alt="image" src="https://github.com/user-attachments/assets/159a2303-86d6-4036-ad55-b1230465e57a" />

How to Identify Whether an IP is Private:

<img width="662" height="222" alt="image" src="https://github.com/user-attachments/assets/c41bfc9b-e71a-4401-b434-45f06a7012d2" />

Q. 1. What is an IPv4 address?

-->An IPv4 address is a 32-bit numerical address used to identify a device on a network. It consists of four octets separated by dots, with each octet ranging from 0 to 255. Example: 192.168.1.10.

Q. 2. Public vs Private IP

-->Public IP: Used on the Internet and globally reachable. Example: 8.8.8.8.

-->Private IP: Used within local networks and not directly accessible from the Internet. Example: 192.168.1.10.

Q. 3. Private IP Ranges
- 10.0.0.0 – 10.255.255.255
- 172.16.0.0 – 172.31.255.255
- 192.168.0.0 – 192.168.255.255

4. Identify Your Private IP

-->Run: ip addr show [Note: Look for the line beginning with inet. If the IP starts with 10., 172.16–31., or 192.168., it is a private IP.]

**Task 3: CIDR & Subnetting**

**1. What does /24 mean in 192.168.1.0/24?**

--> Network portion: 192.168.1 & Host portion: 10

-->Formula to calculate usable Ip ranges: Hosts = 2^(32 - CIDR)

---
                                          
### Task 3: CIDR & Subnetting
1. What does `/24` mean in `192.168.1.0/24`?
2. How many usable hosts in a `/24`? A `/16`? A `/28`?
3. Explain in your own words: why do we subnet?
4. Quick exercise — fill in:

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|------|-------------|-----------|--------------|
| /24  | ?           | ?         | ?            |
| /16  | ?           | ?         | ?            |
| /28  | ?           | ?         | ?            |

**Steps to follow:**

--> So **192.168.1.0/24:** An IPv4 address has 32 bits in total, it means that divided into 4 octets (8 bits each) & /24 in 192.168.1.0/24 means 24 bits are used for the network portion, 

--> Remaining bits are for hosts, So **Host bits calculation is:** 32 - 24 = 8, So the host bits are 8, & **Total IP addresses in this subnet:** 2^8 = 256 & 

--> **Usable Ip range: 256-2=254, So we can use IP Address range from 192.168.1.1 to 192.168.1.254**, & **Ip address: 192.168.1.0 is treat as Network ip address** &

--> **ip address: 192.168.1.255 this is the Broadcast ip address.**

**2. How many usable hosts in a /24? A /16? A /28?**

--> **192.168.1.0/24** = 32 - 24 = 8 bits = 2^8 = 256 in that 256 - 2 = 254 will be usable ip address like from 192.168.1.1 to 192.168.1.254 ip's we can use but 192.168.1.0 is the network address and 192.168.1.256 is the broadcast address

--> **192.168.1.0/16** = 32 - 16 = 16 bits = 2^16 = 65536 in that 65536 - 2 = 65534 will be usable ip address like from 198.168.0.1 to 198.168.255.254 ip's we can use but 198.168.0.0 is the network address and 198.168.255.255 is the broadcast address

--> **192.168.1.0/28** = 32 - 28 = 4 bits = 2^4 = 16 in that 16 - 2 = 14 will be usable ip address like from 192.168.1.1 to 192.168.1.14 ip's we can use but 192.168.1.0 is the network address and 192.168.1.15 is the broadcast address

**3. Explain in your own words: why do we subnet?**
--> We subnet a network to divide a large network into smaller. 

--> manageable networks, This helps to reduce network congestion[Network congestion means the network becomes slow because too many devices are sending data at the same time.], because   fewer devices share the same broadcast domain. It also improves security and organization, since different teams or services can be placed in separate subnets. Additionally, subnetting helps use IP addresses more efficiently and makes network troubleshooting easier.

-->**Example:** If 500 computers are in one network, broadcast messages go to all 500 devices, This increases traffic and can slow the network.

-->**How subnetting helps:** Subnetting splits the large network into smaller networks, for example:

Subnet 1 → 100 devices

Subnet 2 → 100 devices

Subnet 3 → 100 devices

--> Now broadcast traffic stays inside each subnet, reducing congestion and improving performance.

**4. Quick exercise — fill in:**
--> CIDR	Subnet Mask	Total IPs	Usable Hosts

/24	-->Subnet mask: 255.255.255.0, Total usable Ips: 254, usable hosts: 8, Network → 192.168.1.0, IP range: 192.168.1.1 to 192.168.1.254, Broadcast ip: 192.168.1.255

/16	-->Subnet mask: 255.255.0.0, Total usable Ips: 655360, usable hosts: 16, Network → 192.168.0.0, IP range: 192.168.0.1 to 192.168.255.254, Broadcast ip: 192.168.255.255

/28	-->Subnet mask: 255.255.255.240, Total usable Ips: 16, usable hosts: 4, Network → 192.168.1.0, IP range: 192.168.1.1 to 192.168.1.14, Broadcast ip: 192.168.1.15

---

### Task 4: Ports – The Doors to Services
1. What is a port? Why do we need them?
2. Document these common ports:

| Port | Service |
|------|---------|
| 22   | ?       |
| 80   | ?       |
| 443  | ?       |
| 53   | ?       |
| 3306 | ?       |
| 6379 | ?       |
| 27017| ?       |

3. Run `ss -tulpn` — match at least 2 listening ports to their services

**Steps to follow:**

1. What is a port? Why do we need them?

--> Port: A port is a logical communication endpoint on a computer that allows different applications or services to send and receive data over a network.

--> Port we needs to help the operating system identify which service or application should receive the incoming data. Since many services can run on the same machine (like web servers, databases, SSH), ports make sure the data goes to the correct service.

**2. Document these common ports:**

--> **Port	Service**

22	--> SSH port --> Port 22 allows users to securely connect to a remote server and manage it through the command line.

80	--> HTTP port --> Port 80 allows browsers and web servers to communicate and load websites over the internet (without encryption).

443	--> HTTPS port --> Port 443 allows browsers and web servers to communicate securely using encryption (SSL/TLS).

53	--> DNS port --> Port 53 allows devices to translate domain names into IP addresses.

3306 --> MySQL database server port --> Port 3306 allows applications and clients to connect to a MySQL database server to store, retrieve, and manage data.

6379 --> Radis default port --> Port 6379 allows applications to connect to a Redis server, which is an in-memory database used for caching, sessions, and fast data storage.

27017 --> MongosDB default port --> Port 27017 allows applications and database clients to connect to a MongoDB server to store and retrieve data.

**3. Run ss -tulpn — match at least 2 listening ports to their services**

<img width="1887" height="577" alt="image" src="https://github.com/user-attachments/assets/190e93e9-2f08-4505-af83-92419fee5181" />

22: SSH port & 80: HTTP port

---

**Task 5: Putting It Together Answer in 2–3 lines each:**

1. You run curl http://myapp.com:8080 — what networking concepts from today are involved?

--> DNS resolves myapp.com

   TCP connects to port 8080

   HTTP request sent over TCP

   IP routes packets to destination

**3. Your app can't reach a database at 10.0.1.50:3306 — what would you check first?**

--> Checks:

    Is DB service running?

    Is port 3306 open?

    Security group / firewall rules?

    Network route between app and DB?

**What I Learned (Key Points)**

--> DNS translates human-readable names into IP addresses.

    CIDR helps efficiently divide networks and control traffic.

    Ports allow multiple services to operate on a single IP.


