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

**Steps to follow:**

-->Excellent. You're now at the point where logs will actually start flowing.

<img width="333" height="521" alt="image" src="https://github.com/user-attachments/assets/91374033-59ea-4391-a2f6-abe51ae539c6" />

Step 1: Create Promtail Directory: Inside your observability-stack directory: mkdir -p promtail

-->To verify created dir use command: tree -L 2

<img width="1646" height="226" alt="image" src="https://github.com/user-attachments/assets/35563363-f8d2-4d2d-8e92-ac7bce815a72" />

Step 2: Create Promtail Configuration: vi promtail/promtail-config.yml

<img width="513" height="438" alt="image" src="https://github.com/user-attachments/assets/0f64e475-996a-427a-8c3e-9f4b60c49a80" />

Step 3: Understand the Configuration: 

<img width="475" height="821" alt="image" src="https://github.com/user-attachments/assets/caaf22b1-c68a-44ba-a811-76c2bcde3718" />

<img width="427" height="812" alt="image" src="https://github.com/user-attachments/assets/0073c121-16cd-4b49-b2c1-2919edab8524" />

Step 4: Add Promtail Service: vi docker-compose.yml

<img width="568" height="272" alt="image" src="https://github.com/user-attachments/assets/2395cb6a-2493-4326-a3cc-c3439ca9f260" />

Step 5: Validate Compose: docker-compose config

<img width="1643" height="972" alt="image" src="https://github.com/user-attachments/assets/8b26f04b-cd64-4015-acc7-24512e6c3a52" />

<img width="1468" height="971" alt="image" src="https://github.com/user-attachments/assets/e716f90b-152a-4442-b78b-726bff017bb5" />

<img width="1487" height="977" alt="image" src="https://github.com/user-attachments/assets/cfde8b71-6afc-475c-9899-287febe651a4" />

Step 6: Start Everything: docker-compose up -d

-->Once done to verify run command: docker-compose ps

<img width="1918" height="387" alt="image" src="https://github.com/user-attachments/assets/374f1846-c8a8-4dc2-9896-01dae9b66998" />

Step 7: Verify Promtail: docker logs promtail

<img width="1917" height="837" alt="image" src="https://github.com/user-attachments/assets/9395068b-de85-4f42-a2a7-6854f58b788e" />

Step 8: Generate Application Logs: Your jiohotstar app appears to be running on port 8081 according to the task. To Generate traffic: for i in {1..20}; do curl -s http://localhost:8000 > /dev/null; done

-->This creates web access logs.

Step 9: Verify Loki Receives Logs: 

-->First verify promtail logs: docker logs promtail --tail 50

-->Now check loki logs: docker logs loki --tail 50

<img width="1918" height="802" alt="image" src="https://github.com/user-attachments/assets/4cee838c-864b-4bea-8577-dd78b70fc68c" />

<img width="1827" height="907" alt="image" src="https://github.com/user-attachments/assets/3b96084e-04ac-455f-9882-66ddcca92b24" />

Step 10: Verify Log Files Exist: sudo ls /var/lib/docker/containers  [You should see many container IDs.]

<img width="1892" height="110" alt="image" src="https://github.com/user-attachments/assets/b2e13206-6497-4472-86dd-bb3fd2bbc399" />

-->For example check the following one: sudo find /var/lib/docker/containers -name "*json.log" | head

<img width="1917" height="186" alt="image" src="https://github.com/user-attachments/assets/8a3b8657-5691-4cf8-a157-f29fdad6246b" />

-->Expected: /var/lib/docker/containers/xxxxx/xxxxx-json.log This confirms Promtail has files to scrape.

-->Architecture After completation of task 3

<img width="461" height="370" alt="image" src="https://github.com/user-attachments/assets/c4d43102-c963-4d3d-9b3b-235b788160be" />

**Verification checklist:**

-->docker-compose ps

-->docker logs promtail --tail 30

-->curl http://localhost:3100/ready

-->for i in {1..20}; do curl -s http://localhost:8000 > /dev/null; done

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

**Steps to follow:**

Step 1: Open the Datasource Configuration: Go to your observability project: cd observability-stack

-->And then open datasources yml file: vi grafana/provisioning/datasources/datasources.yml

Step 2: Update the File: 

<img width="447" height="658" alt="image" src="https://github.com/user-attachments/assets/e0dcd909-b116-42a2-ae7a-e2a3f649b22c" />

Step 3: Verify YAML Formatting: cat grafana/provisioning/datasources/datasources.yml [in this file both entries are starts with - So This indicates two items in the datasource list.]

Step 4: Restart Grafana: 

-->docker-compose restart grafana OR docker-compose up -d

-->Grafana only loads provisioning files during startup.

-->And then check the status: docker-compose ps

<img width="1902" height="396" alt="image" src="https://github.com/user-attachments/assets/e174d0a8-6b78-42d3-8045-8daa646c0593" />

Step 5: Check Grafana Logs: docker logs grafana --tail 50

<img width="1918" height="982" alt="image" src="https://github.com/user-attachments/assets/00da0888-8762-4315-b0f1-d21efadde806" />

Step 6: Open Grafana: http://localhost:3000

Step 7: Verify Datasources: Navigate: to connections --> then data sources there we can see Prometheus, Loki Two datasources.

Connections
  |
  └── Data Sources
<img width="1918" height="750" alt="image" src="https://github.com/user-attachments/assets/865a61aa-7364-4038-8874-a5535ad466c1" />

Step 8: Verify Prometheus: So select prometheus and then we can see ok or data source is working

Step 9: Verify Loki: Click: Loki & Look for: Save & Test (or Grafana may already show it as provisioned) & Expected result: Data source connected successfully

Step 10: Verify Loki Connectivity from Grafana Container: docker exec -it grafana sh

-->Here in grafana container run command: wget -qO- http://loki:3100/ready

<img width="1648" height="131" alt="image" src="https://github.com/user-attachments/assets/0fba7814-48de-4dfe-9822-7bd39ac213f6" />

Step 11: Verify Network Connectivity:

-->List containers:: docker network ls

-->Find your compose network: docker network inspect observability-stack_default

<img width="1607" height="940" alt="image" src="https://github.com/user-attachments/assets/9057b585-68f4-4dc0-b14e-e847b341b24a" />

<img width="1523" height="986" alt="image" src="https://github.com/user-attachments/assets/cb59560b-45d4-4f17-b123-b56823e4f88e" />

<img width="521" height="435" alt="image" src="https://github.com/user-attachments/assets/19f244be-3606-43d3-86fe-2989d62e5212" />

Verification Checklist:

-->docker-compose ps

-->docker-compose restart grafana

-->docker logs grafana --tail 50

-->Then in grafana container check the connectivity of the loki: To go inside grafana container use command: docker exec -it grafana sh & then inside run command: wget -qO- http://loki:3100/ready to check the lokis servers readniess

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
**Steps to follow:**

-->Excellent! This is where Loki becomes useful. Up to now you've been collecting logs; now you'll search, filter, and analyze them using LogQL.

Step 1: Open Grafana Explore: http://localhost:3000 and then select loki from  the data source

Step 2: Verify Logs Are Coming In: query: {job="docker"}

Steps to run query:

-->You run the LogQL queries inside Grafana, not in the Linux terminal. For that launch the grafana and login to it, later look for option Explore[Compass icon] option & select it and then on the next page we can find search filter click on it and select loki, Then on top right corner we can see 2 options available builder and Code in that we have to switch to Code and then in the search filter paste the above mentioned query and then simply run the query

<img width="1918" height="972" alt="image" src="https://github.com/user-attachments/assets/95eaa3ab-4f4c-4dad-93c0-6fae2db50e05" />

Step 3: Generate Fresh Logs: for i in {1..20}; do   curl -s http://localhost:8081 > /dev/null; done

<img width="1910" height="157" alt="image" src="https://github.com/user-attachments/assets/d7ab8d8f-7f06-45f2-9d25-8014d16a2cac" />

<img width="1917" height="970" alt="image" src="https://github.com/user-attachments/assets/8789bf96-9fa9-401b-ad94-8330fa306bc6" />

Step 4: Learn Basic LogQL: 

-->Show All Docker Logs: {job="docker"} -->This is queal to SELECT * FROM logs

<img width="1917" height="970" alt="image" src="https://github.com/user-attachments/assets/aefe8fed-0dbc-49ea-ad4d-94d799bf81c1" />

-->Search for a Word: {job="docker"} |= "error" -->Means Show logs containing "error" [Like for ex: database error, connection error, internal server error etc.]

<img width="1912" height="972" alt="image" src="https://github.com/user-attachments/assets/8520706c-6bce-4473-9f7f-b2bf1ed394bd" />

-->Exclude a Word: {job="docker"} != "health" -->Meaning: Show everything except lines containing "health" [Useful when health checks flood logs]

<img width="1916" height="977" alt="image" src="https://github.com/user-attachments/assets/6ecdcf29-a8ed-419e-b0ac-702ec4c6a274" />

-->Regex Search: {job="docker"} |~ "status=[45]\\d{2}" -->Matches: status=404, status=500, status=503 [Useful for finding failed requests.]

<img width="1916" height="967" alt="image" src="https://github.com/user-attachments/assets/7691aec7-7649-47f8-bc7c-7ef79b319730" />

Step 5: Discover Available Labels: 

<img width="576" height="471" alt="image" src="https://github.com/user-attachments/assets/ec1773d5-95db-4f2a-9f17-24b5ce430995" />

Step 6: Filter By Container: 

<img width="606" height="467" alt="image" src="https://github.com/user-attachments/assets/c0ab4bfe-754f-4037-b19c-4abe4527fe4f" />

Step 7: Log Metrics: Loki can turn logs into metrics.

-->Count Logs: count_over_time({job="docker"}[5m]) -->[Meaning: How many log lines appeared in the last 5 minutes?]

<img width="1897" height="963" alt="image" src="https://github.com/user-attachments/assets/6f792fb2-a01f-4faf-b5da-de3e15527885" />

-->Log Rate: rate({job="docker"}[5m]) -->[Meaning:, Logs per second ]

-->Top Log Producers: 

<img width="1915" height="982" alt="image" src="https://github.com/user-attachments/assets/ae41080d-e036-4961-848a-7644826f1aae" />

**Exercise:** Write a LogQL query that finds all error logs from the notes-app container in the last 1 hour. Then write another query that counts how many error lines per minute.

<img width="531" height="696" alt="image" src="https://github.com/user-attachments/assets/c6fe596d-20ba-4c4e-8310-69a097f49ab6" />

**Useful Queries for Your Project:**

-->Show Flask App Logs: {container_name="jiohotstar"}

-->Show PostgreSQL Logs: {container_name="db"}

-->Show Grafana Logs: {container_name="grafana"}

-->Show Prometheus Logs: {container_name="prometheus"}

-->Show Only HTTP Errors: {container_name="jiohotstar"} |~ "40[0-9]|50[0-9]"

-->Count All Logs Per Minute: count_over_time({job="docker"}[1m])

**Quick Troubleshooting:**

-->Run command: {job="docker"} returns No logs found, check: docker logs promtail --tail 50 & docker logs loki --tail 50

-->Also verify that Promtail is reading Docker logs: docker exec -it promtail cat /tmp/positions.yaml & If the file contains entries, Promtail is actively tracking log files.

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

**Steps to follow:**

-->Great! This task is more about understanding observability workflows than configuring new components. Since your Promtail setup does not expose container_name labels, we'll slightly adapt the tutorial queries to match your environment.

Step 1: Open Your Existing Dashboard: In Grafana: Dashboards → DevOps Observability Overview

Step 2: Add a Logs Panel: Click: Edit Dashboard  → Add → Visualization there Select datasource: Loki & then run the Query {job="docker"}

-->Visualization: Here Select: Logs then Set: Title: Container Logs & then Click: Apply

<img width="1918" height="968" alt="image" src="https://github.com/user-attachments/assets/a0c134c0-10dd-44c4-a78d-4ccde996beaa" />

<img width="1918" height="962" alt="image" src="https://github.com/user-attachments/assets/62628243-be07-4c64-b06e-a56bae7282b9" />

Step 3: Save Dashboard: here we can see CPU Usage, Memory Usage, Container CPU, Container Memory, Disk Usage, Container Logs on one dashboard.

Step 4: Explore Split View: Go to: Explore Click the: Split button (two panels side-by-side)

<img width="455" height="830" alt="image" src="https://github.com/user-attachments/assets/9ba97046-8a6d-4195-8a7e-1da07ea1b1a1" />

<img width="1912" height="967" alt="image" src="https://github.com/user-attachments/assets/0e6b8bb0-fe06-418d-89c1-5637019904fa" />

Step 5: Generate Activity: for i in {1..50}; do   curl -s http://localhost:8081 > /dev/null; done

--?This creates: Web requests, Application logs, Container activity etc.

Step 6: Observe Correlation: 

<img width="307" height="282" alt="image" src="https://github.com/user-attachments/assets/90758329-9748-43c1-87df-196dbe492c65" />

Step 7: Time Synchronization: 

<img width="1913" height="970" alt="image" src="https://github.com/user-attachments/assets/49f462b6-ccfa-43a3-a6a2-28e8322a778b" />

-->One of Grafana's biggest strengths: Suppose you see: CPU spike at 13:45 You can: Select that time range in the metric graph then Grafana automatically updates the log panel & Logs now show only entries around: 13:45 Instead of searching manually through thousands of log lines.

<img width="377" height="706" alt="image" src="https://github.com/user-attachments/assets/f953cc69-a6f5-414b-917a-905d9e456b7a" />

**Document:** How does having metrics and logs in the same tool (Grafana) help during incident response compared to checking separate systems?
-->Having metrics and logs available in the same Grafana interface significantly reduces troubleshooting time during incidents. Metrics help identify when and where a problem occurred, such as high CPU usage, memory pressure, increased error rates, or abnormal traffic patterns. Logs provide the detailed context needed to understand why the issue happened.

With Grafana's correlation capabilities, engineers can move directly from a metric anomaly to the corresponding logs within the same time range. This eliminates the need to switch between separate monitoring and logging tools, reduces context switching, and accelerates root cause analysis.

For example, if a CPU spike is observed at a specific timestamp, Grafana allows the user to immediately view container logs from that exact period. This helps teams quickly determine whether the spike was caused by application errors, increased traffic, database issues, or infrastructure problems.

As a result, having metrics and logs in the same platform improves operational visibility, shortens incident resolution time, and enhances overall system reliability.

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
