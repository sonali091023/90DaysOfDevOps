# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports**

**Challenge Tasks**

**Task 1: DNS – How Names Become IPs**

**1. Explain in 3–4 lines: what happens when you type google.com in a browser?**

--> You type google.com in your browser. Your computer first checks its local DNS cache to see if it already knows Google’s IP address (like checking your phone contacts).

If it doesn’t know, it asks a DNS resolver (like asking a directory service).

The resolver asks different servers: Root → .com (TLD) → Google’s authoritative DNS server to find the correct IP address.

Once it gets the IP address (for example: 142.250.183.14), your browser connects to that server and loads the Google website.

**In simple words:** DNS translates the website name (google.com) into an IP address so your computer can find the correct server on the internet.

**2. What are these record types? Write one line each: A-->IPv4 address, AAAA-->IPv6 address, CNAME-->, MX, NS**

--> Used dig command here, dig google.com A: This Maps a domain name to an IPv4 address [eg: google.com --> 142.250.183.14]

<img width="841" height="463" alt="image" src="https://github.com/user-attachments/assets/a9a7c378-6fa0-449b-ac79-194bb7829612" />

--> used dig command here, dig google.com AAAA: Maps a domain name to an IPv6 address.

<img width="912" height="560" alt="image" src="https://github.com/user-attachments/assets/5135d8c4-17b9-46ae-9a3d-6439be5461bf" />

--> Used dog command here, dig google.com CNAME: Points one domain/hostname to another domain name (alias)

-->www.google.com is an alias that points to google.com.

<img width="1348" height="513" alt="image" src="https://github.com/user-attachments/assets/9d8d18c5-35cd-41ef-8991-fd27ad70b64e" />

--> used dig command here, dig google.com MX: Specifies the mail server responsible for receiving emails for a domain, Actually This tells which mail servers handle email for gmail.com.

<img width="862" height="520" alt="image" src="https://github.com/user-attachments/assets/49a9470e-8568-46ff-8618-b5b1772f366c" />

--> Used dig command here, dig google.com NS: Specifies the authoritative name servers responsible for a domain, In simple words these servers are authoritative DNS servers for the domain.

<img width="846" height="602" alt="image" src="https://github.com/user-attachments/assets/0afe6f76-25e8-4fc6-b21b-c421eac79c7d" />

**3. Run: dig google.com — identify the A record and TTL from the output**

--> google.com. --> Is Domain name

--> TTL[Time To Live in seconds for caching]: 49 Second's     

--> IN --> internet     

--> A Record --> 142.250.70.78

<img width="837" height="525" alt="image" src="https://github.com/user-attachments/assets/7d8fde31-9947-4c61-86a0-0a409d08de29" />

**Task 2: IP Addressing**

**1. What is an IPv4 address? How is it structured? (e.g., 192.168.1.10)**

-->IPv4 address is a unique number given to a device on a network so it can communicate with other devices on the internet or local network, An IPv4 address has 4 numbers separated by dots, like 192.168.1.10.

Each number called an octet, It represents 8 bits, which ranges from 0 to 255.

-->Computers actually understand binary So the structure is:

192 --> Octet-->11000000             

168 --> Octet-->10101000       

1   --> Octet-->00000001            

10  --> Octet-->00001010

**Types of IPv4 Addresses**

**Public IP** – used on the internet: Example: 8.8.8.8

An IPv4 address is usually divided into: **Network ID** → identifies the network & **Host ID** → identifies the device inside that network

**Example:** 192.168.1.10

If the subnet mask is 255.255.255.0, then Network: 192.168.1 & Host: 10

**Meaning:** Device 10 inside network 192.168.1

**Private IP** – used inside local networks: below example ranges:

10.0.0.0 – 10.255.255.255

172.16.0.0 – 172.31.255.255

192.168.0.0 – 192.168.255.255

--> **Inshort:** DNS converts google.com → IP address like 142.250.70.78, Then your computer sends packets to that IPv4 address to reach Google's server.

**2. Difference between public and private IPs — give one example of each?**

--> Both are IP addresses used to identify devices, but they are used in different places. A public IP address is used to identify a device on the internet.

It is globally unique and assigned by your Internet Service Provider (ISP), If a server or website is accessible from the internet, it uses a public IP.

**Example:** 8.8.8.8 & **Scenario:** When you visit google.com, your computer connects to Google's public IP address.

--> A private IP address is used inside a local network (home WiFi, office network, or cloud network), These addresses cannot be accessed directly from the internet.

**3. What are the private IP ranges?**

--> **Common private IP ranges:**

    10.0.0.0 – 10.255.255.255
    
    172.16.0.0 – 172.31.255.255
     
    192.168.0.0 – 192.168.255.255

8. Run: ip addr show — identify which of your IPs are private

--> <img width="1136" height="332" alt="image" src="https://github.com/user-attachments/assets/3338d462-8059-431c-b229-bfd3f9fc8319" />

**Task 3: CIDR & Subnetting**

**1. What does /24 mean in 192.168.1.0/24?**

--> Network portion: 192.168.1 & Host portion: 10

-->Formula to calculate usable Ip ranges: Hosts = 2^(32 - CIDR)
                                          
                                          usable = host-2

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

**Task 4: Ports – The Doors to Services**
1. What is a port? Why do we need them?

--> Port: A port is a logical communication endpoint on a computer that allows different applications or services to send and receive data over a network.

--> Port we needs to help the operating system identify which service or application should receive the incoming data. Since many services can run on the same machine (like web servers, databases, SSH), ports make sure the data goes to the correct service.

**2. Document these common ports:**

--> **Port	Service**

22	--> SSH port --> Port 22 allows users to securely connect to a remote server and manage it through the command line.

80	--> HTTP port --> Port 80 allows browsers and web servers to communicate and load websites over the internet (without encryption).

443	--> HTTPS port --> Port 443 allows browsers and web servers to communicate securely using encryption (SSL/TLS).

53	--> DNS port --> Port 53 allows devices to translate domain names into IP addresses.

3306	--> MySQL database server port --> Port 3306 allows applications and clients to connect to a MySQL database server to store, retrieve, and manage data.

6379	--> Radis default port --> Port 6379 allows applications to connect to a Redis server, which is an in-memory database used for caching, sessions, and fast data storage.

27017	--> MongosDB default port --> Port 27017 allows applications and database clients to connect to a MongoDB server to store and retrieve data.

**3. Run ss -tulpn — match at least 2 listening ports to their services**

--> <img width="1817" height="333" alt="image" src="https://github.com/user-attachments/assets/186ac79e-850a-486c-a204-9d72da7bb499" />

22: SSH port & 80: HTTP port

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


