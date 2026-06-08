# Day 75 -- Log Management with Loki and Promtail

## Task
Metrics tell you _what_ is broken. Logs tell you _why_. Yesterday you built the metrics pipeline with Prometheus, Node Exporter, cAdvisor, and Grafana. Today you add the second pillar of observability -- logs.

You will set up Grafana Loki (a log aggregation system built by the Grafana team) and Promtail (the agent that ships logs to Loki). By the end of today, your Grafana instance will show both metrics and logs side by side.

---

## Expected Output
- Loki running as a log storage backend
- Promtail collecting Docker container logs and shipping them to Loki
- Loki added as a datasource in Grafana
- LogQL queries running in Grafana Explore
- A markdown file: `day-75-loki-promtail.md`

---

## Challenge Tasks

### Task 1: Understand the Logging Pipeline
Before writing any config, understand how the pieces fit together:

```
[Docker Containers]
       |
       | (write JSON logs to /var/lib/docker/containers/)
       v
  [Promtail]
       |
       | (reads log files, adds labels, pushes to Loki)
       v
    [Loki]
       |
       | (stores logs, indexes by labels)
       v
   [Grafana]
       |
       | (queries Loki with LogQL, displays logs)
       v
   [You]
```

Key differences from the ELK stack:
- Loki does **not** index the full text of logs -- it only indexes labels (like container name, job, filename)
- This makes Loki much cheaper to run and simpler to operate
- Think of it as "Prometheus, but for logs" -- same label-based approach

**Steps to follow:**

-->Understanding the Logging Pipeline: Your future observability architecture will look like:

<img width="443" height="522" alt="image" src="https://github.com/user-attachments/assets/cf68d702-83ca-4fad-af49-00b6e3882981" />

-->Now let see what each component does:

<img width="526" height="467" alt="image" src="https://github.com/user-attachments/assets/c27683d8-d9b5-4c81-bfe5-485296f60775" />

<img width="507" height="571" alt="image" src="https://github.com/user-attachments/assets/d7031f97-09d2-42fb-9999-fe685577f5dc" />

<img width="510" height="353" alt="image" src="https://github.com/user-attachments/assets/9298ecc4-66ed-4eb7-a4d2-c09fc755d611" />

<img width="447" height="450" alt="image" src="https://github.com/user-attachments/assets/e3c96c65-2171-47a7-b972-0ae6f7782dec" />

-->So we can search for logs from Grafana instead of SSHing into servers and running: for that use command: docker ps OR tail -f logfile.log

<img width="657" height="392" alt="image" src="https://github.com/user-attachments/assets/b7d9c3fe-e10e-478a-be2d-4f79fb51ddc3" />

<img width="506" height="408" alt="image" src="https://github.com/user-attachments/assets/7e859b64-e81b-474b-aa8a-924b50553728" />

**Document:** Why does Loki only index labels instead of full text? What is the trade-off?

-->Loki was designed to reduce the operational complexity and infrastructure cost associated with traditional log management systems such as the ELK stack. Instead of indexing the entire 
contents of every log line, Loki only indexes metadata labels such as container name, application name, host, or environment.

-->Loki uses Only Index Labels? Because Full-text indexing requires significant CPU, memory, and storage resources because every word in every log message must be analyzed and stored in an index. In 
large environments generating millions of log entries per day, maintaining these indexes becomes expensive and resource-intensive. So Loki avoids this problem by indexing only labels. The raw log 
data is stored efficiently, while labels are used to quickly narrow down which logs should be searched.

-->For example: container="notes-app", environment="production", host="app-server"

-->These labels allow Loki to identify relevant log streams without indexing every word of every log message.

-->Benefits: Lower memory consumption, Reduced storage requirements, Faster ingestion of logs, Simpler deployment and maintenance, Better scalability for cloud-native environments

**What is the Trade-Off?**

-->The main trade-off is search performance, Because Loki does not maintain a full-text index, searching for specific words inside log messages requires scanning the matching log streams after 
filtering by labels. For example: {container="notes-app"} |= "ERROR"

-->Loki first finds all logs from the notes-app container using indexed labels, then searches those logs for the word "ERROR". In contrast, Elasticsearch can search indexed text more quickly because every word is already indexed.

Note: Loki prioritizes lower cost, simpler operations, and cloud-native scalability by indexing only labels rather than full log content. The trade-off is that text searches can be slower than systems that perform full-text indexing, but the reduction in infrastructure overhead makes Loki an attractive choice for many modern DevOps environments.

Q: Why does Loki index labels instead of full text?

A: Loki indexes only labels to reduce storage, memory, and CPU usage. This makes it much cheaper and simpler to operate than ELK. The trade-off is that text searches may be slower because Loki scans log streams after filtering by labels rather than using a full-text index.

---

### Task 2: Add Loki to the Stack
Create the Loki configuration file.

```bash
mkdir -p loki
```

Create `loki/loki-config.yml`:
```yaml
auth_enabled: false

server:
  http_listen_port: 3100

common:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: inmemory
  replication_factor: 1
  path_prefix: /loki

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: filesystem
      schema: v13
      index:
        prefix: index_
        period: 24h

storage_config:
  filesystem:
    directory: /loki/chunks
```

**What this config does:**
- `auth_enabled: false` -- single-tenant mode, no authentication needed
- `store: tsdb` -- uses Loki's time-series database for indexing
- `object_store: filesystem` -- stores log chunks on local disk
- `replication_factor: 1` -- single instance, no replication (fine for learning)

Add Loki to your `docker-compose.yml`:
```yaml
  loki:
    image: grafana/loki:latest
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/loki-config.yml
      - loki_data:/loki
    command: -config.file=/etc/loki/loki-config.yml
    restart: unless-stopped
```

Add `loki_data` to your volumes section:
```yaml
volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

Start Loki:
```bash
docker compose up -d loki
```

Verify Loki is running:
```bash
curl http://localhost:3100/ready
```

You should see `ready`.

**Steps to follow:**

-->Excellent. You're now extending your observability stack from Metrics (Prometheus) to Logs (Loki).

<img width="312" height="281" alt="image" src="https://github.com/user-attachments/assets/64827368-6800-48b3-8f33-4e7293f27fbf" />

Step 1: Move into Your Observability Directory: cd observability-stack and once go inside dir run command: pwd [To check current working dir]

Step 2: Create Loki Directory: mkdir -p loki       

-->Once loki dir gets create check it for that use command: tree -L 2

<img width="983" height="307" alt="image" src="https://github.com/user-attachments/assets/f3130ed2-b3a6-4758-a638-888eb400ed96" />

Step 3: Create Loki Configuration File: vi loki/loki-config.yml

<img width="341" height="557" alt="image" src="https://github.com/user-attachments/assets/1b654889-e1bc-40c4-ab99-2009e4c0e888" />

Step 4: Understand the Configuration: 

<img width="371" height="742" alt="image" src="https://github.com/user-attachments/assets/86072d34-d4c4-41bd-9342-8ed37693f4e5" />

<img width="371" height="742" alt="image" src="https://github.com/user-attachments/assets/7bfbaf70-5a35-4ace-8f9b-3f141decf6f0" />

<img width="332" height="732" alt="image" src="https://github.com/user-attachments/assets/bd324ff1-bc96-415f-b961-cdff9f7c0d81" />

<img width="240" height="341" alt="image" src="https://github.com/user-attachments/assets/d8c37dd3-eb49-40a4-868f-9a041a17593a" />

Step 5: Add Loki Service to vi docker-compose.yml

<img width="522" height="283" alt="image" src="https://github.com/user-attachments/assets/3d64f16d-bd1d-48d7-8d50-42b8cab43c98" />

Step 6: Add Persistent Storage: 

<img width="418" height="355" alt="image" src="https://github.com/user-attachments/assets/ce9e5bf0-507e-4ef8-bbfa-9b377947ff29" />

Step 7: Validate Compose File: docker-compose config

<img width="1358" height="977" alt="image" src="https://github.com/user-attachments/assets/73326992-6449-4e82-a508-3e54169aa9e2" />

<img width="1347" height="975" alt="image" src="https://github.com/user-attachments/assets/f16b0e9d-046d-4a96-a6a3-71e2903a5418" />

<img width="1376" height="972" alt="image" src="https://github.com/user-attachments/assets/7bf53731-4175-4d5a-a098-0447b782cca3" />

Step 8: Pull and Start Loki: docker-compose up -d loki 

-->To verify run command: docker-compose ps also run docker ps

<img width="1918" height="423" alt="image" src="https://github.com/user-attachments/assets/e324088b-8ac4-4221-9e58-e3a2522e4ae1" />

Step 9: Check Loki Logs: docker logs loki

<img width="1918" height="972" alt="image" src="https://github.com/user-attachments/assets/53cde2b7-58a8-452e-b7a0-45f99772acbe" />

Step 10: Verify Health Endpoint: curl http://localhost:3100/ready

<img width="1153" height="97" alt="image" src="https://github.com/user-attachments/assets/7bc9d412-8671-4f24-8190-f8c7e045de03" />

<img width="377" height="331" alt="image" src="https://github.com/user-attachments/assets/8e19420a-ae2a-413a-9cdc-95ea2b1868a2" />

Step 11: Verify Loki API: curl http://localhost:3100/metrics | head

<img width="417" height="236" alt="image" src="https://github.com/user-attachments/assets/7525ce7a-b6e5-4fb8-aae3-866aee0134b7" />

<img width="1905" height="318" alt="image" src="https://github.com/user-attachments/assets/6bb0ad51-54a9-4326-9134-9eb384024e09" />

Step 12: Confirm Stack Status: docker-compose ps

<img width="1877" height="176" alt="image" src="https://github.com/user-attachments/assets/448332e6-2c1b-4a86-acf4-3473a038e089" />

**Verification Checklist:**

-->docker compose config

-->docker compose ps

-->curl http://localhost:3100/ready [here we test the readiness endpoint]

-->docker logs loki

-->To check loki is really running: docker ps | grep loki

<img width="1741" height="117" alt="image" src="https://github.com/user-attachments/assets/1d963d89-89c0-49ff-a9fc-c5374af3fd46" />

---

### Task 3: Add Promtail to Collect Container Logs
Promtail is the log collection agent. It reads Docker container log files from the host and pushes them to Loki.

```bash
mkdir -p promtail
```

Create `promtail/promtail-config.yml`:
```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*-json.log
    pipeline_stages:
      - docker: {}
```

**What this config does:**
- `positions` -- tracks which log lines have already been shipped (like a bookmark)
- `clients` -- where to send logs (Loki endpoint)
- `__path__` -- the glob pattern to find Docker JSON log files on the host
- `pipeline_stages: docker: {}` -- parses the Docker JSON log format and extracts timestamp, stream (stdout/stderr), and the log message

Add Promtail to your `docker-compose.yml`:
```yaml
  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    volumes:
      - ./promtail/promtail-config.yml:/etc/promtail/promtail-config.yml
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    command: -config.file=/etc/promtail/promtail-config.yml
    restart: unless-stopped
```

**Why these volume mounts?**
- `/var/lib/docker/containers` -- where Docker stores container log files (read-only)
- `/var/run/docker.sock` -- lets Promtail discover container metadata (names, labels)

Restart the stack:
```bash
docker compose up -d
```

Generate some logs by hitting the notes app:
```bash
for i in $(seq 1 20); do curl -s http://localhost:8000 > /dev/null; done
```

---

### Task 4: Add Loki as a Grafana Datasource
You can add it manually through the UI or auto-provision it with YAML.

**Option A -- Provision via YAML (recommended):**

Update `grafana/provisioning/datasources/datasources.yml`:
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
```

Restart Grafana to pick up the new datasource:
```bash
docker compose restart grafana
```

**Option B -- Manual UI setup:**
1. Go to Connections > Data Sources > Add data source
2. Select Loki
3. URL: `http://loki:3100`
4. Save & Test

Either way, you should now have two datasources in Grafana: Prometheus and Loki.

---

### Task 5: Query Logs with LogQL
LogQL is Loki's query language -- similar to PromQL but for logs.

Go to Grafana > Explore (compass icon). Select Loki as the datasource.

1. **Stream selector** -- filter logs by labels:
```logql
{job="docker"}
```
This shows all Docker container logs.

2. **Filter by container name:**
```logql
{container_name="prometheus"}
```

3. **Keyword search** -- filter log lines by content:
```logql
{job="docker"} |= "error"
```
`|=` means "line contains". This finds all log lines with the word "error".

4. **Negative filter:**
```logql
{job="docker"} != "health"
```
Excludes lines containing "health" (useful to filter out health check noise).

5. **Regex filter:**
```logql
{job="docker"} |~ "status=[45]\\d{2}"
```
Finds lines with HTTP 4xx or 5xx status codes.

6. **Log metric queries** -- count log lines over time:
```logql
count_over_time({job="docker"}[5m])
```

7. **Rate of logs per second:**
```logql
rate({job="docker"}[5m])
```

8. **Top containers by log volume:**
```logql
topk(5, sum by (container_name) (rate({job="docker"}[5m])))
```

**Exercise:** Write a LogQL query that finds all error logs from the notes-app container in the last 1 hour. Then write another query that counts how many error lines per minute.

---

### Task 6: Correlate Metrics and Logs in Grafana
The real power of observability is correlation -- seeing metrics and logs together.

1. **Add a logs panel to your dashboard:**
   - Open the dashboard you built on Day 74
   - Add a new panel
   - Select Loki as the datasource
   - Query: `{job="docker"}`
   - Visualization: Logs
   - Title: "Container Logs"

2. **Use the Explore split view:**
   - Go to Explore
   - Click the split button (two panels side by side)
   - Left panel: Prometheus -- `rate(container_cpu_usage_seconds_total{name="notes-app"}[5m])`
   - Right panel: Loki -- `{container_name="notes-app"}`
   - Now you can see CPU spikes and the corresponding log output at the same time

3. **Time sync:** Click on a spike in the metrics graph and both panels will zoom to that time range. This is how you debug in production -- you see a metric anomaly and immediately check the logs from that exact moment.

**Document:** How does having metrics and logs in the same tool (Grafana) help during incident response compared to checking separate systems?

---

## Hints
- Loki labels are like Prometheus labels -- keep cardinality low (container name and job are good; user ID or request ID as labels would kill performance)
- `|=` is case-sensitive. Use `|~ "(?i)error"` for case-insensitive matching
- If you see no logs in Grafana, check: is Promtail running? Is it reading from the correct path? Check Promtail targets at `http://localhost:9080/targets`
- On macOS with Docker Desktop, the Docker log path (`/var/lib/docker/containers/`) is inside the Docker VM -- Promtail needs to run as a container to access it
- Loki is not a replacement for full-text search engines (Elasticsearch). It trades search power for simplicity and cost
- `positions.yaml` tracks read progress -- if you delete it, Promtail re-reads all logs
- Reference repo: https://github.com/LondheShubham153/observability-for-devops -- check `loki/` and `promtail/` directories

---

## Documentation
Create `day-75-loki-promtail.md` with:
- Architecture diagram: Docker containers -> Promtail -> Loki -> Grafana
- Your `loki-config.yml` and `promtail-config.yml` with explanations
- Updated `docker-compose.yml` with all services so far
- Screenshot of Grafana Explore showing logs from Loki
- Five LogQL queries you ran and what they returned
- Screenshot showing metrics and logs side by side in Grafana
- Comparison: Loki vs ELK stack (when would you use each?)

---

## Submission
1. Add `day-75-loki-promtail.md` to `2026/day-75/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Added the second pillar of observability today -- logs. Set up Loki and Promtail to collect all Docker container logs, queried them with LogQL in Grafana, and correlated metrics with logs side by side. When a CPU spike happens, I can now instantly see the exact log lines from that moment."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
