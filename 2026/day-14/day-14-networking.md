# Day 14 – Networking Fundamentals & Hands-on Checks

## Task
Get comfortable with core networking concepts and the commands you’ll actually run during troubleshooting.

You will:
- Map the **OSI vs TCP/IP models** in your own words
- Run essential connectivity commands
- Capture a mini network check for a target host/service

Keep it short, real, and repeatable.

---

## Expected Output
- A markdown file: `day-14-networking.md`
- Screenshots (optional) of key command outputs

---

## Quick Concepts (write 1–2 bullets each)
- OSI layers (L1–L7) vs TCP/IP stack (Link, Internet, Transport, Application)
- Where **IP**, **TCP/UDP**, **HTTP/HTTPS**, **DNS** sit in the stack
- One real example: “`curl https://example.com` = App layer over TCP over IP”

**Steps to follow:**

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
Note: The OSI Session, Presentation, and Application layers are combined into the TCP/IP Application layer.

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

Where Common Protocols Fit:

-->IP (Internet Protocol): Network layer (OSI L3) / Internet layer (TCP/IP) – Handles addressing and routing of packets between networks.

-->TCP / UDP: Transport layer (OSI L4) / Transport layer (TCP/IP) – Provides end-to-end communication. TCP is reliable; UDP is faster with no delivery guarantee.

-->HTTP / HTTPS: Application layer (OSI L7) / Application layer (TCP/IP) – Used for communication between web browsers and web servers. HTTPS is HTTP secured with TLS.

-->DNS (Domain Name System): Application layer (OSI L7) / Application layer (TCP/IP) – Translates domain names (e.g., example.com) into IP addresses.

One real example: “curl -I https://google.com = App layer over TCP over IP”

How it works:

-->Application Layer: curl sends an HTTPS request.

-->Transport Layer: HTTPS uses TCP (typically port 443) for reliable communication.

-->Internet Layer: IP routes packets between your computer and the server.

-->Link Layer: Ethernet or Wi-Fi transmits the data over the local network.

Simple flow: curl --> HTTPS (Application) --> TCP (Transport) --> IP (Internet/Network) --> Ethernet / Wi-Fi (Link)

---

## Hands-on Checklist (run these; add 1–2 line observations)
- **Identity:** `hostname -I` (or `ip addr show`) — note your IP.
- **Reachability:** `ping <target>` — mention latency and packet loss.
- **Path:** `traceroute <target>` (or `tracepath`) — note any long hops/timeouts.
- **Ports:** `ss -tulpn` (or `netstat -tulpn`) — list one listening service and its port.
- **Name resolution:** `dig <domain>` or `nslookup <domain>` — record the resolved IP.
- **HTTP check:** `curl -I <http/https-url>` — note the HTTP status code.
- **Connections snapshot:** `netstat -an | head` — count ESTABLISHED vs LISTEN (rough).

Pick one target service/host (e.g., `google.com`, your lab server, or a local service) and stick to it for ping/traceroute/curl where possible.

**Steps to follow:**

-->You can use the following template to complete the hands-on checklist. Replace the sample outputs with the results from your own system.

**1. Identity: hostname -I OR ip add show --> note your IP** 

**Observation:** Displays private IP address of this machine - 172.31.47.105 So This is the IP assigned to my machine on the local network.

<img width="1691" height="836" alt="image" src="https://github.com/user-attachments/assets/4360ab1b-51d4-4c82-9f4b-6f5e0aafe402" />

**2. Reachability: ping google.com --> mention latency and packet loss.**

**Observation:** --> Packets received successfully, Latency observed ~1.68–1.78 ms, No packet loss. The host is reachable and the network connection is stable.

<img width="1410" height="582" alt="image" src="https://github.com/user-attachments/assets/f905850e-3301-4bb7-a132-9eb35ea9edbb" />

**3. Path: traceroute google.com OR tracepath google.com --> note any long hops/timeouts.**

**Observation:** Traffic passed through multiple routers before reaching the destination. One or two hops may show * * *, which is normal because some routers block ICMP responses.

Note: This traceroute & tracepath is bydefault is not available so we have to install it separately:
- sudo apt install inetutils-traceroute -y
- sudo apt install traceroute -y
- sudo apt install iputils-tracepath -y

<img width="1806" height="962" alt="image" src="https://github.com/user-attachments/assets/9e8dda11-f474-4bad-b3f4-044e038d827c" />

<img width="1832" height="562" alt="image" src="https://github.com/user-attachments/assets/4cad7901-ed7d-43c2-ab01-274c68269688" />

<img width="1892" height="842" alt="image" src="https://github.com/user-attachments/assets/e06f19fe-0bd0-4b44-9bf2-5149235837a4" />

<img width="1312" height="537" alt="image" src="https://github.com/user-attachments/assets/ca33c596-f3d7-42b4-baab-ea697ddbbf7b" />

**4. Listening Ports:  ss -tulpn OR netstat -tulpn --> list one listening service and its port**

**Observation:** ssh listening on TCP port 22, This indicates the SSH service is ready to accept incoming connections, & systemd-resolved on port 53, Shows which services are actively listening.

<img width="1891" height="532" alt="image" src="https://github.com/user-attachments/assets/cd005e02-d4b6-4f94-b39e-5ab6c15c3939" />

<img width="1807" height="605" alt="image" src="https://github.com/user-attachments/assets/320605c9-98e1-4364-89de-15fbde32d624" />

**5. Name Resolution: dig google.com OR nslookup google.com --> record the resolved IP**

**Observation:** The Domain Resolved to one or more public IP's successfully, DNS response received successfully.

<img width="1605" height="702" alt="image" src="https://github.com/user-attachments/assets/90523f3d-b586-40b7-8b93-7f916b2e9c5a" />

**6. HTTP Check: Our target is Target: https://google.com & we have to run command curl -I https://google.com --> note the HTTP status code**

**Observation:** HTTP/1.1 200 OK (or 301 Moved Permanently, depending on the site)., Shows headers only, Confirms application layer OR we can say Web server is working.

<img width="1900" height="355" alt="image" src="https://github.com/user-attachments/assets/7f12ebf3-125a-4eb7-a15e-918d76f9896e" />

**7. Connections Snapshot: netstat -an | head **

Observation: Example: 2 ESTABLISHED connections and 5 LISTEN sockets were observed. LISTEN sockets are waiting for incoming connections, while ESTABLISHED indicates active communication.

<img width="1596" height="262" alt="image" src="https://github.com/user-attachments/assets/cacc2fa8-b30e-4261-aed7-48e2b9be9e24" />

Pick one target service/host (e.g., google.com, your lab server, or a local service) and stick to it for ping/traceroute/curl where possible.




**Mini Task: Port Probe & Interpret**

1. Identify a Listening Port: ss -tulpn (e.g., Here, SSH is listening on port 22. OR a local web app)

<img width="1865" height="577" alt="image" src="https://github.com/user-attachments/assets/6414fe18-ab19-406f-b105-2be972d2a96a" />

2. Test the Port: nc -zv localhost 22 (OR curl -I http://localhost:22)

<img width="1567" height="117" alt="image" src="https://github.com/user-attachments/assets/6750caa9-8cca-4f97-9052-902306820bfa" />

Note: Results indicate that nothing is accepting connections on port 22.

**Interpretation:**
- Connection refused means your machine is reachable, but no service is listening on port 22.
- This is different from a timeout. A timeout often suggests a firewall or network issue, while "connection refused" usually means the service isn't running or isn't listening on that port.

-->Verify if SSH is Listening:

Run: ss -tulpn | grep :22 OR sudo ss -tulpn | grep :22
If nothing is returned: SSH is not listening on port 22.
If you see an sshd entry: SSH is running, and we can investigate why the connection failed.



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


