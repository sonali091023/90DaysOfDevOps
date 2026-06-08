# Day 74 -- Node Exporter, cAdvisor, and Grafana Dashboards

## Task
Prometheus is running and you can query metrics. But right now it is only monitoring itself. In production, you need to monitor two critical things: the **host machine** (CPU, memory, disk, network) and the **Docker containers** running on it.

Today you add Node Exporter for host metrics, cAdvisor for container metrics, and set up Grafana to visualize everything in dashboards instead of raw PromQL.

---

## Expected Output
- Node Exporter running and scraped by Prometheus
- cAdvisor running and scraped by Prometheus
- Grafana running with Prometheus configured as a datasource
- At least one custom Grafana dashboard with CPU, memory, and container panels
- A markdown file: `day-74-exporters-grafana.md`

---

## Challenge Tasks

### Task 1: Add Node Exporter for Host Metrics
Node Exporter exposes Linux system metrics (CPU, memory, disk, filesystem, network) in Prometheus format.

Update your `docker-compose.yml` from Day 73 -- add the Node Exporter service:
```yaml
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--path.rootfs=/rootfs'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    restart: unless-stopped
```

**Why these volume mounts?**
- `/proc` -- kernel and process information (CPU stats, memory info)
- `/sys` -- hardware and driver details
- `/` -- filesystem usage (disk space)

All mounted read-only (`ro`) -- Node Exporter only reads, never modifies.

Add it as a scrape target in `prometheus.yml`:
```yaml
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]
```

Restart the stack:
```bash
docker compose up -d
```

Verify Node Exporter is healthy:
```bash
curl http://localhost:9100/metrics | head -20
```

Check Prometheus Targets page -- `node-exporter` should show as `UP`.

Run these queries in Prometheus to see host metrics:
```promql
# CPU: percentage of time spent idle (per core)
node_cpu_seconds_total{mode="idle"}

# Memory: total vs available
node_memory_MemTotal_bytes
node_memory_MemAvailable_bytes

# Memory usage percentage
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

# Disk: filesystem usage percentage
(1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100

# Network: bytes received per second
rate(node_network_receive_bytes_total[5m])
```

**Stesp to follow:**

Step 1: Open your vi docker-compose.yml

<img width="522" height="340" alt="image" src="https://github.com/user-attachments/assets/afd1f0a6-7518-462b-ba5a-e066920c1ff0" />

Step 2: Add Node Exporter Service in to docker-compose.yml file which is given above, Then docker-compose.yml file will look like,

<img width="650" height="392" alt="image" src="https://github.com/user-attachments/assets/398d353f-728e-4772-aebe-870f306b7334" />

<img width="762" height="521" alt="image" src="https://github.com/user-attachments/assets/a4f4b26d-2c68-4097-b782-b2c8f12d29d9" />

Step 3: Update vi prometheus.yml

<img width="487" height="657" alt="image" src="https://github.com/user-attachments/assets/6962781b-1e2f-4f58-bed1-d9975d7f2f57" />

-->docker-compose up -d

Step 4: Validate Compose File: docker-compose config

<img width="1475" height="972" alt="image" src="https://github.com/user-attachments/assets/bc287635-0662-4638-a2e8-281329c1b6ed" />

<img width="1427" height="977" alt="image" src="https://github.com/user-attachments/assets/ebe9403d-fc3b-47fe-a139-d2435404bdf8" />

<img width="1538" height="218" alt="image" src="https://github.com/user-attachments/assets/1c44ce00-e32f-4557-b67e-1a23cf11514c" />

Step 5: Recreate the Stack: 

-->docker-compose down

-->docker-compose up -d

<img width="1911" height="352" alt="image" src="https://github.com/user-attachments/assets/18f0bcfc-7ccc-44ff-a48c-3a285d19138d" />

Step 6: Verify Containers: docker ps

<img width="1905" height="177" alt="image" src="https://github.com/user-attachments/assets/8c9ef06e-a7ae-4b11-ad81-dc5f3b2b8495" />

Step 7: Test Node Exporter Directly: curl http://localhost:9100/metrics | head -20

<img width="1913" height="652" alt="image" src="https://github.com/user-attachments/assets/25e8e919-32d5-48cb-ad6a-04ba2d0876ce" />

Step 8: Verify Prometheus Can Scrape It: http://localhost:9090

<img width="1915" height="913" alt="image" src="https://github.com/user-attachments/assets/aca30c8b-d8c0-4164-a863-53b0d9dd305b" />

Step 9: Run First Query: You should get a large number representing total RAM.

<img width="1917" height="665" alt="image" src="https://github.com/user-attachments/assets/c0f90921-f7c8-4e5c-a205-f25c494f3adb" />

Step 10: Check Available Memory: 

<img width="1910" height="591" alt="image" src="https://github.com/user-attachments/assets/f9fce720-4345-4a9b-b3cc-b53253c1d415" />

Step 11: Memory Usage %: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

-->This shows current RAM utilization.

<img width="1915" height="587" alt="image" src="https://github.com/user-attachments/assets/c9f30a5e-0953-406b-bcbf-913067fed159" />

Step 12: CPU Metrics: node_cpu_seconds_total{mode="idle"}

-->You should see multiple entries: Each represents a CPU core.

<img width="1917" height="922" alt="image" src="https://github.com/user-attachments/assets/236aff79-09e9-4f23-a758-4496240d5cbe" />

Step 13: Disk Usage: (1 - node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100

-->This shows filesystem utilization.

<img width="1918" height="977" alt="image" src="https://github.com/user-attachments/assets/2eb8c4b2-a90d-4c91-bd9c-ae5e5f5e3a8d" />

Step 14: Network Traffic: rate(node_network_receive_bytes_total[5m])

-->This shows incoming network traffic per second.

<img width="1913" height="655" alt="image" src="https://github.com/user-attachments/assets/ad549f42-f783-4566-8299-cfc4f3fce9f9" />

Step 15: Verify Everything: docker ps 

<img width="1902" height="172" alt="image" src="https://github.com/user-attachments/assets/aae00b15-8a5d-489c-8d1f-88b5248d1d9c" />

-->curl http://localhost:9100/metrics | head -20

<img width="1918" height="656" alt="image" src="https://github.com/user-attachments/assets/ad93c7ba-60e9-4227-bdc3-4ae5905265a4" />

### Task 2: Add cAdvisor for Container Metrics
cAdvisor (Container Advisor) monitors resource usage and performance of running Docker containers.

Add it to your `docker-compose.yml`:
```yaml
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    restart: unless-stopped
```

**Why these volume mounts?**
- Docker socket (`docker.sock`) -- lets cAdvisor discover and query running containers
- `/sys` -- kernel-level container stats (cgroups)
- `/var/lib/docker/` -- container filesystem information

Add cAdvisor as a Prometheus scrape target:
```yaml
  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]
```

Restart and verify:
```bash
docker compose up -d
```

Open `http://localhost:8080` to see the cAdvisor web UI. Click on Docker Containers to see per-container stats.

Run these queries in Prometheus:
```promql
# CPU usage per container (in seconds)
rate(container_cpu_usage_seconds_total{name!=""}[5m])

# Memory usage per container
container_memory_usage_bytes{name!=""}

# Network received bytes per container
rate(container_network_receive_bytes_total{name!=""}[5m])

# Which container is using the most memory?
topk(3, container_memory_usage_bytes{name!=""})
```

The `{name!=""}` filter removes aggregated/system-level entries and shows only named containers.

**Steps to follow:**

<img width="671" height="736" alt="image" src="https://github.com/user-attachments/assets/0bea9714-16b9-4d19-9bea-8bb7e866210e" />

Step 1: Add cAdvisor to vi docker-compose.yml: Add this service below node-exporter:

<img width="518" height="371" alt="image" src="https://github.com/user-attachments/assets/4f49f24d-79b1-4103-988e-21919344f6e2" />

Step 2: Your services section should now look like: 

<img width="290" height="190" alt="image" src="https://github.com/user-attachments/assets/1495ebc2-10a8-4d98-9e73-40b88f45da01" />

Step 3: Update vi prometheus.yml:

<img width="402" height="497" alt="image" src="https://github.com/user-attachments/assets/9e7bbea1-5541-4ac0-a8eb-3bc5492e62f2" />

Step 4: Validate Compose: docker-compose config

<img width="1631" height="982" alt="image" src="https://github.com/user-attachments/assets/fa5883ac-25dd-41d2-8dde-1f6f5c1fea30" />

<img width="1533" height="981" alt="image" src="https://github.com/user-attachments/assets/b6d4de19-cf95-4218-8e8a-d59276b94200" />

<img width="1692" height="815" alt="image" src="https://github.com/user-attachments/assets/69bd2263-5543-4d0b-98e2-ea02c203a3f9" />

Step 5: Restart Everything: 

-->docker-compose down

-->docker-compose up -d

<img width="1232" height="176" alt="image" src="https://github.com/user-attachments/assets/6289cee6-1076-4461-8e35-5feb020cda7f" />

<img width="1382" height="197" alt="image" src="https://github.com/user-attachments/assets/1f023eae-3413-4529-81ee-467c807ef66c" />

Step 6: Verify Containers: docker ps: [5 containers should be running.]

<img width="1911" height="268" alt="image" src="https://github.com/user-attachments/assets/0823d437-10ec-4497-885b-07089164703b" />

Step 7: Test cAdvisor Directly: http://localhost:8080 [You should see the cAdvisor UI.]

-->Click: Docker Containers You should see: jiohotstar, db, prometheus, node-exporter, cadvisor with CPU and memory statistics.

<img width="1907" height="891" alt="image" src="https://github.com/user-attachments/assets/f902f3f0-8f6e-4874-9b83-bc1cd6ca5822" />

Step 8: Verify Prometheus Targets: http://localhost:9090/targets [Here all services should be up]

<img width="1912" height="945" alt="image" src="https://github.com/user-attachments/assets/e47d53df-df89-42da-b846-4bd29e676db0" />

Step 9: Test Container Metrics: In Prometheus run: CPU per container: rate(container_cpu_usage_seconds_total{name!=""}[5m])

-->To run this query go to query section:

<img width="1917" height="702" alt="image" src="https://github.com/user-attachments/assets/16462eaa-e25f-4721-ae71-a57204bbc273" />

-->Faced issue: So when i run the above quesry i did get any data against to it, That is because newer versions of cAdvisor on some Docker/cgroup setups don't expose the name label.

<img width="616" height="516" alt="image" src="https://github.com/user-attachments/assets/f07c1dc3-a3cb-4e76-8037-985b62c698da" />

-->To handle this make chnages in vi docker-compose.yml file

<img width="460" height="510" alt="image" src="https://github.com/user-attachments/assets/d73bc9ec-c908-4962-b61b-2e005bf8bb29" />

-->Now again run the same query: rate(container_cpu_usage_seconds_total{name!=""}[5m])

<img width="1907" height="972" alt="image" src="https://github.com/user-attachments/assets/8620cbfe-936d-4b4e-9a84-d70affb7fb8b" />

-->Memory per container: container_memory_usage_bytes{name!=""}

<img width="1917" height="965" alt="image" src="https://github.com/user-attachments/assets/6912dcf7-ab5e-4f63-85ae-a4d03b8ed93e" />

-->Network per container: rate(container_network_receive_bytes_total{name!=""}[5m])

<img width="1908" height="970" alt="image" src="https://github.com/user-attachments/assets/b1117c4e-9c42-47bc-8ca3-18de1cb86d78" />

Top 3 memory consumers: topk(3, container_memory_usage_bytes{name!=""})

<img width="1917" height="876" alt="image" src="https://github.com/user-attachments/assets/8d673d39-5eba-49f4-b7e8-ffa8e7441b46" />

**Document:** What is the difference between Node Exporter and cAdvisor? When would you use each?

<img width="808" height="298" alt="image" src="https://github.com/user-attachments/assets/77cfa994-6757-4be5-884d-27342d63c44f" />

**When to use Node Exporter?**

-->Use Node Exporter when you want: Server CPU usage, RAM usage, Disk utilization, Network traffic, Filesystem metrics **Example:** node_memory_MemAvailable_bytes

**When to use cAdvisor?**

-->Use cAdvisor when you want: Which container uses most RAM, Which container consumes CPU, Container network traffic, Container filesystem usage **Example:** container_memory_usage_bytes

Note: Node Exporter monitors the host machine, while cAdvisor monitors Docker containers running on that machine. Together they provide complete visibility into infrastructure and container performance.

---

### Task 3: Set Up Grafana
Grafana is the visualization layer. It connects to Prometheus (and later Loki) and lets you build dashboards, set alerts, and share views with your team.

Add Grafana to your `docker-compose.yml`:
```yaml
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
```

Add the volume at the bottom of your compose file:
```yaml
volumes:
  prometheus_data:
  grafana_data:
```

Restart:
```bash
docker compose up -d
```

Open `http://localhost:3000`. Log in with `admin` / `admin123`.

**Add Prometheus as a datasource:**
1. Go to Connections > Data Sources > Add data source
2. Select Prometheus
3. Set URL to `http://prometheus:9090` (use the container name, not localhost -- they are on the same Docker network)
4. Click Save & Test -- you should see "Successfully queried the Prometheus API"

**Steps to follow:**

Step 1: Update vi docker-compose.yml

<img width="582" height="411" alt="image" src="https://github.com/user-attachments/assets/fecaf891-ad81-4df8-a109-f5f9b8482aa9" />

Step 2: Update Volumes Section: 

<img width="456" height="386" alt="image" src="https://github.com/user-attachments/assets/a1457cf3-aae4-4942-8cd8-12cc2c38c0f4" />

Step 3: Validate YAML: docker-compose config

<img width="1323" height="972" alt="image" src="https://github.com/user-attachments/assets/3ed450a2-6213-4bac-8eed-457f9f7d72b1" />

<img width="1365" height="980" alt="image" src="https://github.com/user-attachments/assets/19b6be4c-7169-4b47-b3e4-abbfc6320a51" />

<img width="1262" height="977" alt="image" src="https://github.com/user-attachments/assets/b17bc449-d15b-4a07-8f5a-14089d34fd1b" />

Step 4: Start Grafana: docker-compose up -d

-->Then verify the containers: docker ps

<img width="1637" height="346" alt="image" src="https://github.com/user-attachments/assets/b2b58682-3d85-4cd0-847d-8370a58e7e4b" />

Step 5: Verify Grafana Logs: docker logs grafana

<img width="1911" height="982" alt="image" src="https://github.com/user-attachments/assets/cc9ec376-5e67-4d6c-97a9-f2f0e0957995" />

Step 6: Open Grafana: http://localhost:3000

-->Login: Username: admin & Password: admin123, Grafana may ask you to change the password. You can: Skip or set a new one.

<img width="1891" height="957" alt="image" src="https://github.com/user-attachments/assets/96aebb16-a96d-4187-a574-df4fef842ee2" />

<img width="1916" height="967" alt="image" src="https://github.com/user-attachments/assets/29cb9a7f-3d46-4c21-8f59-49ce7f8f2d8f" />

Step 7: Add Prometheus Datasource

<img width="493" height="402" alt="image" src="https://github.com/user-attachments/assets/a7bcc7a1-cd51-4751-bc98-0343f16f2295" />

Step 8: Select Prometheus: Prometheus

<img width="1917" height="922" alt="image" src="https://github.com/user-attachments/assets/3f75ff8e-ebb4-4047-8624-2c1a5fe9c5d2" />

Step 9: Configure URL: 

-->Very important: Use http://prometheus:9090 NOT http://localhost:9090

-->Why? --> Because Grafana runs inside a Docker container and talks to Prometheus through Docker networking. Docker service names act like DNS names: grafana ---> prometheus, So:

http://prometheus:9090 is correct. But If we're getting "This site can't be reached" for: http://prometheus:9090 that's actually expected from your browser.

-->Important distinction about prometheus is a Docker service name, not a hostname your Windows browser knows about. So Use: http://localhost:9090 in your browser to access Prometheus.
& Use: http://prometheus:9090 inside Grafana's datasource configuration, because Grafana and Prometheus are on the same Docker network.

<img width="1911" height="797" alt="image" src="https://github.com/user-attachments/assets/3af8bd0d-3750-414a-ba39-8987f2ef3230" />

<img width="1912" height="763" alt="image" src="https://github.com/user-attachments/assets/1b6fcf64-01fa-469a-aa5a-812d6b9494e7" />

Step 10: Save & Test: Expected: Successfully queried the Prometheus API, It means Grafana and Prometheus are connected successfully.

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/188535ef-8d6c-437f-ac7c-aab5fef09426" />

<img width="838" height="577" alt="image" src="https://github.com/user-attachments/assets/cf3cff3b-36b8-4bf7-84ad-f8aa8e61137d" />

<img width="1907" height="970" alt="image" src="https://github.com/user-attachments/assets/e1480a12-7a4c-4ae9-9300-563f6bec653c" />

Step 11: Verify Metrics: Go to: Explore & Select datasource: Select Code tab form right top corner: Prometheus Run: up, You should see: prometheus, node-exporter, cadvisor with value: 1 which means UP.

<img width="1918" height="972" alt="image" src="https://github.com/user-attachments/assets/bbb09d2b-d43b-4b82-8131-128afd92d64f" />

<img width="1902" height="346" alt="image" src="https://github.com/user-attachments/assets/8524fe17-1bcf-4f04-8953-495bfbec17a5" />

-->we can see prometheus, node-exporter, cadvisor with value: 1 which means UP.

Step 12: Test Node Exporter Metrics: node_memory_MemTotal_bytes [You should get a graph.]

<img width="1918" height="962" alt="image" src="https://github.com/user-attachments/assets/a1c63216-e33f-4800-af8d-51d6a539e97b" />

Step 13: Test cAdvisor Metrics: container_memory_usage_bytes [You should get container metrics.]

<img width="1910" height="968" alt="image" src="https://github.com/user-attachments/assets/4b811a03-f0ee-4e8a-8e32-9cdf36651b51" />

Step 14: Create Your First Dashboard: Click: Dashboards → New Dashboard → Add Visualization then select Datasource: Prometheus & there Query:

(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 & then Click: Run Query [You should see memory usage % of your machine.] Save dashboard: Host Monitoring

<img width="1915" height="962" alt="image" src="https://github.com/user-attachments/assets/8c8fb3fe-6d82-48c5-82f7-c8528b5478d0" />

<img width="1903" height="960" alt="image" src="https://github.com/user-attachments/assets/cd53da62-8a77-4b22-9038-610b7131a5ed" />

<img width="901" height="747" alt="image" src="https://github.com/user-attachments/assets/89830ce4-c9dd-40fd-9095-852ca5130bbc" />

---

### Task 4: Build Your First Dashboard
Create a dashboard that shows the health of your system at a glance.

1. Go to Dashboards > New Dashboard > Add Visualization
2. Select Prometheus as the datasource

**Panel 1 -- CPU Usage (Gauge):**
```promql
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```
- Visualization: Gauge
- Title: "CPU Usage %"
- Set thresholds: green < 60, yellow < 80, red >= 80

**Panel 2 -- Memory Usage (Gauge):**
```promql
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
```
- Visualization: Gauge
- Title: "Memory Usage %"

**Panel 3 -- Container CPU Usage (Time Series):**
```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100
```
- Visualization: Time series
- Title: "Container CPU Usage"
- Legend: `{{name}}`

**Panel 4 -- Container Memory Usage (Bar Chart):**
```promql
container_memory_usage_bytes{name!=""} / 1024 / 1024
```
- Visualization: Bar chart
- Title: "Container Memory (MB)"
- Legend: `{{name}}`

**Panel 5 -- Disk Usage (Stat):**
```promql
(1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100
```
- Visualization: Stat
- Title: "Disk Usage %"

Save the dashboard as "DevOps Observability Overview".

**Steps to follow:**

Step 1: Create a New Dashboard: In Grafana: Dashboards → New Dashboard Click: Add Visualization then Select: prometheus-1 (your Prometheus datasource)

<img width="430" height="356" alt="image" src="https://github.com/user-attachments/assets/5d55a990-16d2-4f36-b2e3-d1a01dc8dea2" />

Step 2: Create a New Dashboard:

Panel 1: CPU Usage % Run the quesry: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

<img width="407" height="662" alt="image" src="https://github.com/user-attachments/assets/b83e2675-04ed-4783-a26d-e50ee15cb6a8" />

-->Select Prometheus first & then Visualization On the right side: Visualization → Gauge

-->Configure Unit: Under: Standard options & then Set: Unit → Percent (0-100)

-->Apply

<img width="441" height="667" alt="image" src="https://github.com/user-attachments/assets/c7b21642-7d4e-45f2-87c6-b22b39181049" />

<img width="1915" height="967" alt="image" src="https://github.com/user-attachments/assets/32cf1bd2-b6e1-4ca5-abbe-66880280bb95" />

Panel 2: Memory Usage %: Top right: Add → Visualization Datasource: prometheus-1 then run the Query: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

<img width="317" height="460" alt="image" src="https://github.com/user-attachments/assets/a960a3b4-545c-49d4-8906-1de4ae4c96b9" />

<img width="1911" height="962" alt="image" src="https://github.com/user-attachments/assets/ee93e48a-7113-4e27-9f9b-65e86c27fa0f" />

-->Select Prometheus first & then Visualization On the right side: Visualization → Gauge

-->Panel Title: Memory Usage %: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

-->Configure Unit: Under: Standard options & then Set: Unit → Percent (0-100)

-->Optional Threshold: Green < 70, Yellow < 85, Red >= 85 etc.

-->Apply

<img width="1918" height="967" alt="image" src="https://github.com/user-attachments/assets/44ca9a12-a1fd-40c6-aaf3-1809a4401b92" />

Panel 3: Container CPU Usage: So this uses cAdvisor metrics: rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100

-->Select Prometheus first & then Visualization On the right side: Visualization → Time series

-->Title: Container CPU Usage

-->Legend: Under Query Options: Legend Enter: {{name}} So This shows: grafana, prometheus, cadvisor, node-exporter instead of long labels.

-->Apply

<img width="1916" height="968" alt="image" src="https://github.com/user-attachments/assets/2ad76795-720d-4659-b937-758ab556ded6" />

Panel 4: Container Memory Usage: container_memory_usage_bytes{name!=""} / 1024 / 1024

-->Add Visualization in that Select: Prometheus & then on top right side select Visualization: Bar chart

-->Title: Container Memory (MB)

-->Legend: {{name}} & Unit: Megabytes (MB) 

-->Apply

<img width="1913" height="967" alt="image" src="https://github.com/user-attachments/assets/4dd6823a-64b6-4477-85b0-a9d6231daa83" />

Panel 5: Disk Usage %: (1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100

--> Add Visualization Select: Prometheus & then form top right corner select visualization: Stat

-->Title: Disk Usage %

-->Unit: Percent (0-100)

-->Apply

<img width="1918" height="970" alt="image" src="https://github.com/user-attachments/assets/1110180a-2d84-448d-a8ba-4152cae2a6a7" />

Step 3: Arrange the Dashboard: 

<img width="412" height="393" alt="image" src="https://github.com/user-attachments/assets/240af038-dabe-4a73-8e1b-d828b0d9a4a9" />

Step 4: Save Dashboard: Click: Save Dashboard (top-right floppy disk icon) Name: DevOps Observability Overview Click: Save

<img width="1918" height="971" alt="image" src="https://github.com/user-attachments/assets/b04901c0-8020-433c-acbe-ba75a6be3585" />

Step 5: Verify Metrics: Generate some load on your server and watch the dashboard change.

-->CPU Load Test: Install first: sudo apt install stress -y & then run: **stress --cpu 2 --timeout 60** You should see: CPU Usage % ↑

-->Memory Load Test: run: **stress --vm 1 --vm-bytes 500M --timeout 60** You should see: Memory Usage % ↑

<img width="473" height="622" alt="image" src="https://github.com/user-attachments/assets/c31cd66e-72ec-43db-9043-75a9bd715be0" />

<img width="1918" height="965" alt="image" src="https://github.com/user-attachments/assets/348ef279-c12e-47b7-acdc-65d674bd115b" />

-->Your dashboard should now display: Overall CPU usage, Overall memory usage, Per-container CPU usage, Per-container memory usage & Disk usage etc.

---

### Task 5: Auto-Provision Datasources with YAML
In production, you do not click through the UI to add datasources. You provision them with configuration files so the setup is repeatable.

Create the provisioning directory structure:
```bash
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards
```

Create `grafana/provisioning/datasources/datasources.yml`:
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
```

Update the Grafana service in `docker-compose.yml` to mount the provisioning directory:
```yaml
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped
```

Restart Grafana:
```bash
docker compose up -d grafana
```

Check Connections > Data Sources -- Prometheus should already be there without any manual setup.

-->Excellent. You're now moving from a manual Grafana setup to Infrastructure as Code for observability, which is exactly how production environments work.

-->Task 5 is about making Grafana automatically configure itself whenever the stack starts.

**Steps to follow:**

Step 1: Create Grafana Provisioning Structure: On your app server where the docker-compose.yml exists:

-->mkdir -p grafana/provisioning/datasources

-->mkdir -p grafana/provisioning/dashboards & then to verify use command: tree grafana

<img width="271" height="137" alt="image" src="https://github.com/user-attachments/assets/f958cefd-f6c0-4d99-8135-8595c46644cb" />

Step 2: Create Datasource Configuration: vi grafana/provisioning/datasources/datasources.yml

<img width="351" height="272" alt="image" src="https://github.com/user-attachments/assets/1be1ed98-c18f-4755-9a06-fdcbb07c2d6a" />

Step 3: Understand What Each Field Means: 

<img width="592" height="815" alt="image" src="https://github.com/user-attachments/assets/afef9098-ebf6-4074-ba92-d710b92a348d" />

<img width="567" height="818" alt="image" src="https://github.com/user-attachments/assets/9b5fc593-7629-4624-b4d9-c54ca7765d0b" />

Step 4: Update Docker Compose: vi docker-compose.yml

<img width="611" height="841" alt="image" src="https://github.com/user-attachments/assets/47606671-7bb1-4ac1-a8e4-534f2464d531" />

Step 5: Validate Compose File: docker-compose config

<img width="1687" height="982" alt="image" src="https://github.com/user-attachments/assets/6abd876c-57ed-435f-a543-bc73b15bf5c6" />

<img width="1380" height="986" alt="image" src="https://github.com/user-attachments/assets/8542f837-669c-41fc-a7d3-f4491655fa57" />

Step 6: Restart Grafana: docker-compose up -d grafana OR docker-compose restart grafana & then check logs: docker logs grafana --tail 50

<img width="1887" height="973" alt="image" src="https://github.com/user-attachments/assets/3043ccc1-7a9a-43c8-a2fa-15f171f6a832" />

Step 7: Verify Auto-Provisioning: So here when we open http://localhost:3000 & login with it Navigate: Connections → Data Sources

-->You should already see: Prometheus without manually adding it.

Step 8: Test the Datasource: Click: Prometheus Then: Save & Test Expected: Successfully queried the Prometheus API

<img width="1912" height="968" alt="image" src="https://github.com/user-attachments/assets/877766a0-255b-46ce-8f1b-168fca561caa" />

Step 9: Prove It Really Works: Delete Grafana container: docker-compose down & then run: docker-compose up -d

-->Once the docker up login again to the grafana dashboard & there we can see Datasource automatically exists. No manual clicks required. That's the entire goal of provisioning.

<img width="1917" height="977" alt="image" src="https://github.com/user-attachments/assets/0e242523-d56f-4802-93e5-386aa373ede5" />

<img width="525" height="411" alt="image" src="https://github.com/user-attachments/assets/0cf584b5-8a0c-4795-9821-572192a51ebe" />

**Document:** Why is provisioning datasources via YAML better than configuring them manually through the UI?

-->### [Provisioning Datasources via YAML Better Than Configuring Manual](https://github.com/sonali091023/90DaysOfDevOps/blob/master/2026/day-74/Provisioning%20Datasources%20via%20YAML%20Better%20Than%20Configuring%20manual)

---

### Task 6: Import a Community Dashboard
The Grafana community maintains thousands of pre-built dashboards. Import one for Node Exporter:

1. Go to Dashboards > New > Import
2. Enter dashboard ID: **1860** (Node Exporter Full)
3. Select your Prometheus datasource
4. Click Import

Explore the imported dashboard. It has dozens of panels covering CPU, memory, disk, network, and more -- all built on the same Node Exporter metrics you queried manually.

**Try another one:** Import dashboard ID **193** (Docker monitoring via cAdvisor). Select Prometheus as the datasource and explore container-level stats.

**Your full `docker-compose.yml` should now have these services:**
- `prometheus`
- `node-exporter`
- `cadvisor`
- `grafana`
- `notes-app` (from Day 73)

Verify all are running:
```bash
docker compose ps
```

---

## Hints
- Node Exporter metrics start with `node_` -- use this prefix to explore in Prometheus
- cAdvisor metrics start with `container_` -- filter with `{name!=""}` to skip aggregated entries
- Grafana uses `http://prometheus:9090` (container name) not `http://localhost:9090` because containers communicate over Docker's internal network
- If Grafana panels show "No data", check: is the datasource configured? Is the PromQL query valid? Try the same query in Prometheus UI first
- Dashboard ID 1860 is the gold standard Node Exporter dashboard -- almost every team uses it
- On macOS with Docker Desktop, some Node Exporter metrics may be limited because Docker runs in a Linux VM, not directly on the host
- Reference repo: https://github.com/LondheShubham153/observability-for-devops -- check `grafana/provisioning/` for provisioning examples

---

## Documentation
Create `day-74-exporters-grafana.md` with:
- Your updated `docker-compose.yml` and `prometheus.yml` with all services
- Difference between Node Exporter and cAdvisor (when to use which)
- Screenshot of Prometheus Targets page with all 3+ targets UP
- Screenshot of your custom Grafana dashboard
- Screenshot of the imported Node Exporter Full dashboard (ID 1860)
- PromQL queries for CPU, memory, disk, and container metrics
- How datasource provisioning works via YAML

---

## Submission
1. Add `day-74-exporters-grafana.md` to `2026/day-74/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Added Node Exporter for host metrics and cAdvisor for container metrics to my observability stack. Built my first Grafana dashboard from scratch -- CPU, memory, disk, and per-container resource usage all in one view. Imported the community Node Exporter dashboard (ID 1860) and it is packed with insights."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
