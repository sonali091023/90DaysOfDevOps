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

**Document:** What is the difference between Node Exporter and cAdvisor? When would you use each?

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

**Document:** Why is provisioning datasources via YAML better than configuring them manually through the UI?

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
