# Day 14 – Networking Fundamentals & Hands-on Checks**

**OSI Model:** The OSI Model is a 7-layer conceptual framework used to understand how data travels through a network. It helps engineers troubleshoot network problems by separating communication into layers.

| OSI Model    | TCP/IP Model   | What It Means Practically                |  Purpose                                    |
| ------------ | -------------- | ---------------------------------------- |---------------------------------------------|
| Application  | Application    | User-level protocols like HTTP, SSH, DNS | User interacts with network services        |
| Presentation | Application    | Data formatting, encryption              | Data formatting, encryption, compression    |
| Session      | Application    | Managing sessions between apps           | Manages sessions between systems            |
| Transport    | Transport      | End-to-end communication using TCP/UDP   | Reliable data delivery                      |
| Network      | Internet       | IP addressing and routing                | Routing and IP addressing                   |
| Data Link    | Network Access | MAC addresses, switching                 | MAC addressing, switching                   |
| Physical     | Network Access | Cables, hardware, signals                | Hardware signals, cables                    |

**TCP/IP Model Layers:** The TCP/IP Model is a networking framework that explains how data moves across the internet. It is the practical model used in real-world networking, unlike the theoretical OSI Model.

| Layer          | Purpose                                | Examples                                                    |
| -------------- | -------------------------------------- | ------------------------------------------------------------|
| Application    | Provides services to user applications | HTTP, HTTPS, FTP, DNS, SSH                                  |
| Transport      | Ensures reliable or fast data delivery | TCP(used for browsing), UDP(used for streaming media)       |
| Internet       | Handles IP addressing and routing      | IP, ICMP                                                    |
| Network Access | Manages hardware communication         | Ethernet, Wi-Fi                                             |

**[Open Systems Interconnection] OSI = Conceptual model (7 layers) used for understanding networking.**

**[Transmission Control Protocol / Internet Protocol] TCP/IP = Real-world implementation (4 layers) used on the internet.**

**When troubleshooting:**

Application issue → HTTP/SSH

Transport issue → TCP/UDP

Network issue → IP routing

Link issue → NIC or cables


One real example: “curl -I https://google.com = App layer over TCP over IP”

--> Application layer [HTTP] --> TCP --> IP --> Link

<img width="1915" height="622" alt="image" src="https://github.com/user-attachments/assets/48476d96-f2d2-4fc2-8e89-5bd31647b518" />

**Hands-on Checklist**

**1. Identity: hostname -I OR ip add show --> note your IP** 

**Observation:** Displays private IP address of this machine - 172.31.47.105  

<img width="1168" height="353" alt="image" src="https://github.com/user-attachments/assets/a50e0849-91e9-40c8-8f5a-37c562e2e714" />

**2. Reachability: ping google.com --> mention latency and packet loss.**

**Observation:** --> Packets received successfully, Latency observed ~1.68–1.78 ms, No packet loss.

<img width="961" height="687" alt="image" src="https://github.com/user-attachments/assets/8cc0bf00-a9e6-475b-8143-313d16c917e2" />

**3. traceroute google.com OR tracepath google.com --> note any long hops/timeouts.**

**Observation:** Multiple hops shown, Some hops may show * * * (ICMP blocked), Final destination reachable.

<img width="1470" height="172" alt="image" src="https://github.com/user-attachments/assets/9f932289-28ce-4e2b-bbb4-3dbcda7b63a4" />

**4. ss -tulpn OR netstat -tulpn --> list one listening service and its port**

**Observation:** ssh listening on port 22, systemd-resolved on port 53, Shows which services are actively listening.

<img width="1767" height="537" alt="image" src="https://github.com/user-attachments/assets/bf6393b3-6065-441d-a5e9-772125fef8a3" />

**5. dig google.com OR nslookup google.com --> record the resolved IP**

**Observation:** Resolved to public IP 142.250.76.206, DNS response received successfully.

<img width="725" height="587" alt="image" src="https://github.com/user-attachments/assets/96358954-467e-4171-bf7e-46b333db7546" />

**6. curl -I https://google.com --> note the HTTP status code**

**Observation:** HTTP/1.1 200 OK, Shows headers only, Confirms application layer working.

<img width="1918" height="318" alt="image" src="https://github.com/user-attachments/assets/3473308c-4308-472c-85df-9931864f37a4" />

**7. netstat -an | head --> count ESTABLISHED vs LISTEN (rough)**

Observation: LISTEN – services waiting for connection, ESTABLISHED – active connections, Quick view of connection state.

<img width="807" height="217" alt="image" src="https://github.com/user-attachments/assets/72ab71b0-cea8-476d-8dc9-5a26bb9f443f" />

Pick one target service/host (e.g., google.com, your lab server, or a local service) and stick to it for ping/traceroute/curl where possible.

**Mini Task: Port Probe & Interpret**

**1. Identify one listening port from ss -tulpn (e.g., SSH on 22 or a local web app).**

<img width="1788" height="253" alt="image" src="https://github.com/user-attachments/assets/f7bfd1b2-5b8a-43dc-97a3-57386685081d" />

**2. From the same machine, test it: nc -zv localhost 22 (or curl -I http://localhost:22).**

<img width="671" height="107" alt="image" src="https://github.com/user-attachments/assets/099e0792-4788-42d7-a2fa-b1256e2980aa" />

**3. Write one line: is it reachable? If not, what’s the next check? (e.g., service status, firewall).**

Result: Connection successful, If not reachable:

Next checks: systemctl status ssh

**Reflection (add to your markdown)**

**1. Which command gives you the fastest signal when something is broken?**

--> ping command or curl -I it will quickly tells you If the host is reachable, If there is packet loss, network latency OR whether the network layer is working etc, 

--> Ping command gives instance connectivity check. And if ping command fails then problem may be in Network connectivity, Routing, DNS [If hostname cant resolve].

**2. What layer (OSI/TCP-IP) would you inspect next if DNS fails? If HTTP 500 shows up?**

-->DNS (Domain Name System) is an application-layer protocol that translates a domain name into an IP address. If DNS fails, the issue is usually related to:

   DNS server not responding

   Incorrect DNS records

   Misconfigured /etc/resolv.conf

   Network firewall blocking DNS (port 53)

--> Check Application layer first (DNS service). Then verify UDP/TCP 53 at Transport layer.
    
    HTTP 500: Application layer issue.
    
    Next checks:
    
    Service logs
   
    Application logs
   
   Backend service health

**3. Two follow-up checks during a real incident**

--> ping domain.com -->dig domain.com -->curl -I https://domain.com --> nslookup domain.com -->Purpose to verify the domain --> IP resolution and check the logs

-->ss -tulpn --> purpose to verify if web server is running, Also confirms poer 80 or 443 is open, Also check the firewall settings

-->Checks the security rules, Inspect service logs[journalctl or app logs] 


