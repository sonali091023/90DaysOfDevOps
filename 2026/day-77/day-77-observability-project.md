# Day 77 -- Observability Project: Full Stack with Docker Compose

## Task
Four days of building -- Prometheus, Node Exporter, cAdvisor, Grafana, Loki, Promtail, OpenTelemetry Collector, and alerting. Today you put it all together using a production-ready reference architecture.

You will clone the observability-for-devops reference repo, spin up the complete 8-service stack in one command, validate every data flow end to end, build a unified dashboard, and document the entire setup as if you were handing it off to a teammate.

---

## Expected Output
- The full observability stack running from the reference repository
- All Prometheus targets UP and healthy
- Grafana showing metrics dashboards and log panels from a single interface
- Traces flowing through the OTEL Collector
- A unified "Production Overview" dashboard in Grafana
- A markdown file: `day-77-observability-project.md`

---

## Challenge Tasks

### Task 1: Clone and Launch the Reference Stack
Clone the reference repository that contains the complete observability setup:

```bash
git clone https://github.com/LondheShubham153/observability-for-devops.git
cd observability-for-devops
```

Examine the project structure:
```bash
tree -I 'node_modules|build|staticfiles|__pycache__'
```

```
observability-for-devops/
  docker-compose.yml                    # 8 services orchestrated together
  prometheus.yml                        # Prometheus scrape configuration
  alert-rules.yml                       # (you will add this)
  grafana/
    provisioning/
      datasources/datasources.yml       # Auto-provisioned: Prometheus + Loki
      dashboards/dashboards.yml         # Dashboard provisioning config
  loki/
    loki-config.yml                     # Loki storage and schema config
  promtail/
    promtail-config.yml                 # Docker log collection config
  otel-collector/
    otel-collector-config.yml           # OTLP receivers, processors, exporters
  notes-app/                            # Sample Django + React application
```

Launch the entire stack:
```bash
docker compose up -d
```

Wait for all containers to start:
```bash
docker compose ps
```

All 8 services should show as running:

| Service | Port | Check |
|---------|------|-------|
| Prometheus | 9090 | `http://localhost:9090` |
| Node Exporter | 9100 | `curl http://localhost:9100/metrics \| head -5` |
| cAdvisor | 8080 | `http://localhost:8080` |
| Grafana | 3000 | `http://localhost:3000` (admin/admin) |
| Loki | 3100 | `curl http://localhost:3100/ready` |
| Promtail | 9080 | Internal only |
| OTEL Collector | 4317/4318 | `docker logs otel-collector` |
| Notes App | 8000 | `http://localhost:8000` |

**Stesp to follow:**

Step 1: Clone the Repository: git clone https://github.com/LondheShubham153/observability-for-devops.git & then once clone the repo done cd observability-for-devops

<img width="1915" height="487" alt="image" src="https://github.com/user-attachments/assets/67b9468b-96c7-4367-a533-44a6a51537c7" />

Step 2: Examine the Project Structure: run the following command: tree -I 'node_modules|build|staticfiles|__pycache__'

<img width="1756" height="980" alt="image" src="https://github.com/user-attachments/assets/0b3470a2-f483-43ca-b618-7dda74634178" />

<img width="1861" height="550" alt="image" src="https://github.com/user-attachments/assets/14220111-0389-47b6-a522-61c377c6b5cb" />

Step 3: Review Docker Compose File: use command: cat docker-compose.yml OR less docker-compose.yml OR grep "^  " docker-compose.yml

<img width="1577" height="976" alt="image" src="https://github.com/user-attachments/assets/bb713f9d-f558-4062-bb61-0991dfd50a84" />

-->grep "^  " docker-compose.yml: 

<img width="727" height="710" alt="image" src="https://github.com/user-attachments/assets/45031126-10bb-476e-840c-6b066f43205b" />

<img width="778" height="746" alt="image" src="https://github.com/user-attachments/assets/10277b68-0b4d-48b7-b315-f94bf935af4b" />

-->You can even count them: docker compose config --services | wc -l Expected output: 8

-->For Docker Compose files, docker compose config --services is the recommended approach.

Step 4: Verify Docker is Running: 

-->Check docker: docker --version & If Docker is not running or installed use command to install: sudo systemctl start docker OR sudo systemctl status docker

-->Check docker-compose: docker-compose version

-->Check daemon: docker ps

Step 5: Pull Images (Optional but Recommended): This avoids waiting during startup: docker-compose pull

-->This may take a few minutes because it downloads: Grafana, Prometheus, Loki, Promtail, cAdvisor, Node Exporter, OTEL Collector Notes App dependencies etc.

Step 6: Start the Entire Stack: docker-compose up -d

<img width="371" height="695" alt="image" src="https://github.com/user-attachments/assets/4aa13cbd-5a98-4138-b26e-e82276476b24" />

Step 7: Verify All Containers: docker ps [We'll get the list of all the containers]

Step 8: Check Prometheus: Open browser: http://localhost:9090 You should see the Prometheus UI.

-->To Test targets: Navigate: Status → Targets Expected: node-exporter UP, cadvisor UP, prometheus UP, otel-collector UP etc.

Step 9: Check Node Exporter: In Terminal: curl http://localhost:9100/metrics | head -5

<img width="357" height="182" alt="image" src="https://github.com/user-attachments/assets/78b7e4a3-7652-46c9-b432-b0e55d1fa543" />

Step 10: Check cAdvisor: Browser: http://localhost:8080 You should see: Container statistics Click: Docker Containers, You'll see CPU, Memory, Network metrics for all containers.

Step 11: Check Grafana: 

<img width="437" height="572" alt="image" src="https://github.com/user-attachments/assets/252e6797-834c-48c7-94ee-ed3b408d5023" />

Step 12: Check Loki: 

<img width="443" height="425" alt="image" src="https://github.com/user-attachments/assets/4e071721-b1c5-4cb9-9b08-fe24cc39e75d" />

Step 13: Check Promtail: 

<img width="397" height="327" alt="image" src="https://github.com/user-attachments/assets/5da43229-f1a3-4377-bd9d-ab3ba8773cdd" />

Step 14: Check OTEL Collector: 

<img width="542" height="293" alt="image" src="https://github.com/user-attachments/assets/9012805b-0f95-42e7-9b05-f1cd09b0d988" />

<img width="428" height="415" alt="image" src="https://github.com/user-attachments/assets/45b2a609-2a38-4162-b9cf-bba45a993f0b" />

Step 16: Final Health Check: docker-compose ps [All services should show: Up No container should be: Exited, Restarting, Unhealthy ]

**Some Troubleshooting Commands:** If something fails, these are the first commands to run:

-->docker-compose ps

-->docker-compose logs

-->Single service: docker logs grafana OR docker logs prometheus OR docker logs loki OR docker logs otel-collector

---

### Task 2: Validate the Metrics Pipeline
Confirm Prometheus is scraping all targets:

1. Open `http://localhost:9090/targets`
2. Verify all 4 scrape jobs are UP:
   - `prometheus` (self-monitoring)
   - `node-exporter` (host metrics)
   - `docker` / `cadvisor` (container metrics)
   - `otel-collector` (OTLP metrics)

Run these validation queries:
```promql
# All targets are healthy
up

# Host CPU usage
100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

# Container CPU per container
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100

# Top 3 memory-hungry containers
topk(3, container_memory_usage_bytes{name!=""})
```

Compare the `prometheus.yml` from the reference repo with the one you built over days 73-76. Note the scrape jobs and intervals.

**Steps to follow:**

Step 1: Open the Prometheus Targets Page: on browser launch: http://localhost:9090/targets

<img width="602" height="533" alt="image" src="https://github.com/user-attachments/assets/8c65959c-3c58-4108-8378-f2b6096d26e0" />

<img width="350" height="817" alt="image" src="https://github.com/user-attachments/assets/e5a597d1-a4eb-4228-a74d-be3ffa7694d8" />

<img width="1915" height="971" alt="image" src="https://github.com/user-attachments/assets/ef165059-69cd-465e-b43a-357054540514" />

Step 2: Verify "up" Metric: http://localhost:9090 -->Click: Graph[Is nothing but query] → Execute Query: up & then click on Execute.

<img width="512" height="443" alt="image" src="https://github.com/user-attachments/assets/15e79829-f00c-45b4-9623-797dccbf3213" />

<img width="1911" height="865" alt="image" src="https://github.com/user-attachments/assets/f71e3bd8-894a-400f-9808-022fae96e5bc" />

Step 3: Validate CPU Metrics: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

<img width="542" height="782" alt="image" src="https://github.com/user-attachments/assets/728b9e84-6b23-44a6-b19b-6c1508b40838" />

<img width="1917" height="442" alt="image" src="https://github.com/user-attachments/assets/53918d30-5b8b-410c-b23b-1dc2984f7358" />

<img width="677" height="462" alt="image" src="https://github.com/user-attachments/assets/203bee42-adf8-47c1-b3c6-f170a11a41f9" />

Step 4: Validate Memory Usage: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

<img width="537" height="782" alt="image" src="https://github.com/user-attachments/assets/496248bb-22fd-4332-85ee-3ff620a1fc55" />

<img width="1910" height="530" alt="image" src="https://github.com/user-attachments/assets/4cdef466-2dd1-4a52-b2ef-39cd7ae34c6d" />

<img width="597" height="472" alt="image" src="https://github.com/user-attachments/assets/93f271e3-6afb-41b0-8d70-b458209e38d8" />

Step 5: Container CPU Usage: rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100 [This query returns no data]

<img width="516" height="675" alt="image" src="https://github.com/user-attachments/assets/e564786e-f668-4354-b432-eca57cdb7280" />

<img width="637" height="332" alt="image" src="https://github.com/user-attachments/assets/b048cbce-f42a-44e2-98a8-625ed1d461f3" />

-->Running other Query: container_cpu_usage_seconds_total

<img width="1912" height="967" alt="image" src="https://github.com/user-attachments/assets/ca3ee863-7663-4b1a-8f1e-d83c91beab04" />

Step 6: Top Memory Consumers: topk(3, container_memory_usage_bytes{name!=""}) [This query return no data]

<img width="401" height="650" alt="image" src="https://github.com/user-attachments/assets/fc4df744-08e5-4833-972b-afbdc2504b0e" />

<img width="605" height="317" alt="image" src="https://github.com/user-attachments/assets/b19bedf1-005f-4fbd-b481-06f58f755663" />

Step 7: Switch to Graph View: 

<img width="460" height="477" alt="image" src="https://github.com/user-attachments/assets/b45b905b-b7ca-46ee-b7f8-57dbeb55667e" />

Step 8: Inspect the Reference Prometheus Configuration: cat prometheus.yml

<img width="1153" height="517" alt="image" src="https://github.com/user-attachments/assets/69e90f3d-04e8-491e-bf81-2603f2610330" />

Step 9: Compare with Your Day 73–76 Setup: Open your old Prometheus configuration. Example: cat ~/90DaysOfDevOps/.../prometheus.yml Compare: Day 73–76 Stack
Typically:

<img width="502" height="703" alt="image" src="https://github.com/user-attachments/assets/2884d8de-6b0d-4cac-a13a-43becb8787bc" />

<img width="630" height="461" alt="image" src="https://github.com/user-attachments/assets/8cab8c8a-b954-4c36-ac47-98f7bf7f38a4" />

Step 10: Document Findings: Create a validation note:

<img width="682" height="512" alt="image" src="https://github.com/user-attachments/assets/b954ac39-7cd9-4ea8-a7e2-e122225b5b50" />

---

### Task 3: Validate the Logs Pipeline
Generate traffic so there are logs to see:

```bash
for i in $(seq 1 50); do
  curl -s http://localhost:8000 > /dev/null
  curl -s http://localhost:8000/api/ > /dev/null
done
```

Open Grafana (`http://localhost:3000`) and go to Explore:

1. Select Loki as the datasource
2. Run these LogQL queries:

```logql
# All container logs
{job="docker"}

# Only notes-app logs
{container_name="notes-app"}

# Errors across all containers
{job="docker"} |= "error"

# HTTP request logs from the app
{container_name="notes-app"} |= "GET"

# Rate of log lines per container
sum by (container_name) (rate({job="docker"}[5m]))
```

Check Promtail's targets to see which log files it is watching:
```bash
curl -s http://localhost:9080/targets | head -30
```

Compare `promtail/promtail-config.yml` from the reference repo with yours from Day 75.

**Step to follow:**

Step 1: Verify Loki and Promtail Containers: Run command: docker ps OR docker-compose ps [So i can see al the containers prometheus, grafana, loki, promtail, node-exporter
cadvisor, otel-collector, notes-app etc.

<img width="1917" height="830" alt="image" src="https://github.com/user-attachments/assets/83fd023e-39d5-4b48-9189-71cfc3eb8ebd" />

Step 2: Generate Application Traffic: for this run following program: This creates log entries for the application.
for i in $(seq 1 50); do   curl -s http://localhost:8000 > /dev/null; curl -s http://localhost:8000/api/ > /dev/null; done

Step 3: Verify the App Is Producing Logs: Before checking Grafana, verify Docker logs exist:

-->Find your app container: docker ps

-->Check docker logs: docker logs notes-app --tail 20

<img width="1917" height="830" alt="image" src="https://github.com/user-attachments/assets/f128edf6-decf-4718-b6ab-6c124b5ec7b1" />

Step 4: Verify Promtail Targets: Run the following command: curl -s http://localhost:9080/targets OR curl -s http://localhost:9080/targets | head -30

-->Look for something similar: Ready, Labels: job="docker" OR job="containers"

Step 5: Verify Loki Datasource: In browser open url: http://localhost:3000& login to it by providing creds admin as un & pswd.

-->Navigate: Connections → Data Sources Confirm: Loki Status = OK

<img width="1897" height="540" alt="image" src="https://github.com/user-attachments/assets/69a5453f-befe-4cd7-88f3-7327bba8aca4" />

<img width="1907" height="975" alt="image" src="https://github.com/user-attachments/assets/be171f91-31c1-4428-98ed-b7a8b21e3501" />

Step 6: Open Grafana Explore: Navigate: Explore Select datasource: Loki

<img width="1912" height="662" alt="image" src="https://github.com/user-attachments/assets/77ec4cac-deee-4cd7-b361-b3c5e60f5c73" />

Step 7: Discover Existing Labels: Instead of immediately running the assignment queries, start with: {job="docker"} & then click on run query

<img width="1912" height="971" alt="image" src="https://github.com/user-attachments/assets/231e38a2-4b04-4b64-8bbf-ba6c9dbf7927" />

Step 8: Check Available Labels: Any of the label is ot available as mentioned in the below screenshot,

<img width="435" height="726" alt="image" src="https://github.com/user-attachments/assets/e167e645-2577-4c44-8b07-572c55c86430" />

Step 9: Assignment Queries: Following label: {container_name="notes-app"} is not exist

<img width="426" height="727" alt="image" src="https://github.com/user-attachments/assets/839d9ae4-321d-43c8-8c14-0b41e95732cd" />

Step 10: If Queries Return Nothing:

-->docker logs promtail --tail 50

-->docker logs loki --tail 50

-->curl -s http://localhost:9080/targets | head -30

-->cat promtail/promtail-config.yml

---

### Task 4: Validate the Traces Pipeline
Send OTLP traces to the collector:

```bash
curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "notes-app" }
        }]
      },
      "scopeSpans": [{
        "spans": [{
          "traceId": "aaaabbbbccccdddd1111222233334444",
          "spanId": "1111222233334444",
          "name": "GET /api/notes",
          "kind": 2,
          "startTimeUnixNano": "1700000000000000000",
          "endTimeUnixNano": "1700000000150000000",
          "attributes": [{
            "key": "http.method",
            "value": { "stringValue": "GET" }
          },
          {
            "key": "http.route",
            "value": { "stringValue": "/api/notes" }
          },
          {
            "key": "http.status_code",
            "value": { "intValue": "200" }
          }],
          "status": { "code": 1 }
        },
        {
          "traceId": "aaaabbbbccccdddd1111222233334444",
          "spanId": "5555666677778888",
          "parentSpanId": "1111222233334444",
          "name": "SELECT notes FROM database",
          "kind": 3,
          "startTimeUnixNano": "1700000000020000000",
          "endTimeUnixNano": "1700000000120000000",
          "attributes": [{
            "key": "db.system",
            "value": { "stringValue": "sqlite" }
          },
          {
            "key": "db.statement",
            "value": { "stringValue": "SELECT * FROM notes" }
          }]
        }]
      }]
    }]
  }'
```

This simulates a two-span trace: an HTTP request that calls a database query.

Check the debug output:
```bash
docker logs otel-collector 2>&1 | grep -A 20 "GET /api/notes"
```

You should see both spans with their attributes, the parent-child relationship, and timing data.

Compare `otel-collector/otel-collector-config.yml` from the reference repo with yours from Day 76.

---

### Task 5: Build a Unified "Production Overview" Dashboard
Create a single Grafana dashboard that gives a complete picture of your system.

Go to Dashboards > New Dashboard. Add these panels:

**Row 1 -- System Health (Node Exporter + Prometheus):**

| Panel | Type | Query |
|-------|------|-------|
| CPU Usage | Gauge | `100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` |
| Memory Usage | Gauge | `(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100` |
| Disk Usage | Gauge | `(1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100` |
| Targets Up | Stat | `sum(up)` / `count(up)` |

**Row 2 -- Container Metrics (cAdvisor):**

| Panel | Type | Query |
|-------|------|-------|
| Container CPU | Time series | `rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100` (legend: `{{name}}`) |
| Container Memory | Bar chart | `container_memory_usage_bytes{name!=""} / 1024 / 1024` (legend: `{{name}}`) |
| Container Count | Stat | `count(container_last_seen{name!=""})` |

**Row 3 -- Application Logs (Loki):**

| Panel | Type | Query (Loki datasource) |
|-------|------|-------|
| App Logs | Logs | `{container_name="notes-app"}` |
| Error Rate | Time series | `sum(rate({job="docker"} \|= "error" [5m]))` |
| Log Volume | Time series | `sum by (container_name) (rate({job="docker"}[5m]))` |

**Row 4 -- Service Overview:**

| Panel | Type | Query |
|-------|------|-------|
| Prometheus Scrape Duration | Time series | `prometheus_target_interval_length_seconds{quantile="0.99"}` |
| OTEL Metrics Received | Stat | `otelcol_receiver_accepted_metric_points` (if available) |

Save the dashboard as "Production Overview -- Observability Stack".

Set the dashboard time range to "Last 30 minutes" and enable auto-refresh (every 10s).

---

### Task 6: Compare Your Stack with the Reference and Document
Now compare what you built over days 73-76 with the reference repository.

| Component | Your Version | Reference Repo | Differences |
|-----------|-------------|----------------|-------------|
| `prometheus.yml` | Day 73-74 | Root directory | Compare scrape jobs |
| `loki-config.yml` | Day 75 | `loki/` directory | Compare storage config |
| `promtail-config.yml` | Day 75 | `promtail/` directory | Compare scrape configs |
| `otel-collector-config.yml` | Day 76 | `otel-collector/` directory | Compare pipelines |
| `datasources.yml` | Day 74 | `grafana/provisioning/` | Compare provisioned sources |
| `docker-compose.yml` | Days 73-76 | Root directory | Compare all 8 services |

**Reflect and document:**

1. Map each observability concept to the day you learned it:

| Day | What You Built |
|-----|---------------|
| 73 | Prometheus, PromQL, metrics fundamentals |
| 74 | Node Exporter, cAdvisor, Grafana dashboards |
| 75 | Loki, Promtail, LogQL, log-metric correlation |
| 76 | OTEL Collector, traces, alerting rules |
| 77 | Full stack integration, unified dashboard |

2. What would you add for production?
   - Alertmanager for routing alerts to Slack/PagerDuty
   - Grafana Tempo for trace storage (replacing debug exporter)
   - HTTPS/TLS for all endpoints
   - Authentication on Grafana and Prometheus
   - Log retention policies and storage limits
   - High availability (multiple Prometheus/Loki replicas)

3. How does this stack compare to managed solutions like Datadog, New Relic, or AWS CloudWatch?

**Clean up when done:**
```bash
docker compose down -v
```

The `-v` flag removes named volumes (Prometheus data, Grafana data, Loki data). Only use this if you are done exploring.

---

## Hints
- If a service fails to start, check logs: `docker compose logs <service-name>`
- The reference repo uses a shared `monitoring` network -- all services can communicate by container name
- `restart: unless-stopped` ensures containers come back after a Docker daemon restart
- Grafana dashboard JSON can be exported (Share > Export) and saved as code for dashboard-as-code workflows
- If Grafana shows "No data" for Loki panels, make sure you generated traffic first (`curl` the notes app) and check the time range
- The notes-app is a Django REST API -- browse `http://localhost:8000/api/` for the API endpoints
- Reference repo: https://github.com/LondheShubham153/observability-for-devops

---

## Documentation
Create `day-77-observability-project.md` with:
- Architecture diagram showing all 8 services and their data flows (metrics, logs, traces)
- Screenshot of Prometheus Targets with all jobs UP
- Screenshot of Grafana Explore showing logs from Loki
- Screenshot of your "Production Overview" dashboard
- Screenshot of OTEL trace in collector debug output
- Comparison table: your configs vs reference repo configs
- What you would add for production readiness
- Key takeaways from the 5-day observability block
- All config files: `docker-compose.yml`, `prometheus.yml`, `loki-config.yml`, `promtail-config.yml`, `otel-collector-config.yml`

---

## Submission
1. Add `day-77-observability-project.md` to `2026/day-77/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Completed the observability block -- 5 days from zero to a full production-style monitoring stack. Prometheus for metrics, Grafana for visualization, Loki and Promtail for logs, OpenTelemetry Collector for traces, Node Exporter and cAdvisor for infrastructure monitoring, plus alerting rules that fire when things go wrong. All running in Docker Compose, all wired into a single unified dashboard. This is what production observability looks like."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
