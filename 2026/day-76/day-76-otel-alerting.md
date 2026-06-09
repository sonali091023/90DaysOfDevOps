# Day 76 -- OpenTelemetry and Alerting

## Task
You have metrics (Prometheus) and logs (Loki). Today you add the third pillar -- traces -- using OpenTelemetry, the industry-standard framework for collecting telemetry data. Then you set up alerting so your system notifies you when something goes wrong, instead of you staring at dashboards all day.

By the end of today, your observability stack covers all three pillars and actively alerts on problems.

---

## Expected Output
- OpenTelemetry Collector running and exporting metrics to Prometheus
- OTLP traces sent to the collector and visible in debug output
- Prometheus alerting rules configured for critical conditions
- Grafana alert rules with notification contacts
- A markdown file: `day-76-otel-alerting.md`

---

## Challenge Tasks

### Task 1: Understand OpenTelemetry
Research and write notes on:

1. **What is OpenTelemetry (OTEL)?**
- A vendor-neutral, open-source framework for generating, collecting, and exporting telemetry data (metrics, logs, traces)
- It is not a backend -- it collects and ships data to backends like Prometheus, Jaeger, Loki, Datadog
-->OpenTelemetry (OTEL) is an open-source observability framework that provides a standardized way to generate, collect, process, and export telemetry data from applications and infrastructure.

<img width="702" height="552" alt="image" src="https://github.com/user-attachments/assets/a08a20a1-6e69-4b9b-a4b7-7d3c0418b828" />

2. **What is the OTEL Collector?**
- A standalone service that receives, processes, and exports telemetry
- Three components in the pipeline:
- **Receivers** -- accept data (OTLP, Prometheus, Jaeger formats)
- **Processors** -- transform data (batching, filtering, sampling)
- **Exporters** -- send data to backends (Prometheus, debug console, Jaeger)
-->The OTEL Collector is a service that receives telemetry, processes it, and exports it to observability backends. Think of it as a central telemetry router.

<img width="722" height="621" alt="image" src="https://github.com/user-attachments/assets/afe7401d-89a7-4882-a6fd-e770e56b28b1" />

<img width="565" height="782" alt="image" src="https://github.com/user-attachments/assets/3d345fa5-2b04-4d28-a4a2-bfa6bcb9a5a3" />

3. **What is OTLP?**
- OpenTelemetry Protocol -- the standard wire format for sending telemetry
- Supports gRPC (port 4317) and HTTP (port 4318)
-->OTLP (OpenTelemetry Protocol) is the standard protocol used by OpenTelemetry components to exchange telemetry data. It defines how metrics, logs, and traces are transmitted.

<img width="651" height="487" alt="image" src="https://github.com/user-attachments/assets/3b5fe885-2175-4f6a-b15a-ebf260397a4b" />

4. **What are distributed traces?**
- A trace tracks a single request as it travels through multiple services
- Each step in the trace is called a **span**
- Spans have: trace ID, span ID, parent span ID, start time, duration, attributes
- Example: User request -> API Gateway (span 1) -> Auth Service (span 2) -> Database (span 3)
-->A distributed trace follows a request as it moves through multiple services.

-->It answers questions like: Where is latency occurring?, Which service failed?, Which database query is slow? etc.

<img width="437" height="667" alt="image" src="https://github.com/user-attachments/assets/d631d286-4d26-4a75-ac2c-1d4fb00e37bb" />

-->Span Information Every span contains: Trace ID, Span ID, Parent Span ID, Start Time, End Time, Duration, Attributes etc.

<img width="547" height="708" alt="image" src="https://github.com/user-attachments/assets/709f054b-890a-44f3-8c17-6a1a20741fe5" />

**Quick Interview Summary:**

**What is OpenTelemetry?** An open-source observability framework used to collect metrics, logs, and traces and send them to various backends.

**What is the OTEL Collector?** A telemetry pipeline component that receives, processes, and exports observability data.

**What is OTLP?** OpenTelemetry Protocol, the standard protocol used to send telemetry data via gRPC (4317) or HTTP (4318).

**What is a distributed trace?** A complete record of a request traveling through multiple services.

**What is a span?** A single operation or step within a trace.

---

### Task 2: Add the OpenTelemetry Collector
Create the collector configuration:

```bash
mkdir -p otel-collector
```

Create `otel-collector/otel-collector-config.yml`:
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  debug:
    verbosity: detailed

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug]
```

**What this config does:**
- **Receivers:** Accepts OTLP data via gRPC (4317) and HTTP (4318)
- **Processors:** Batches data before exporting (reduces overhead)
- **Exporters:**
  - Metrics go to a Prometheus-compatible endpoint on port 8889 (Prometheus scrapes this)
  - Traces and logs go to debug output (console) -- in production you would send these to Jaeger or Tempo

Add the collector to your `docker-compose.yml`:
```yaml
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    container_name: otel-collector
    ports:
      - "4317:4317"   # OTLP gRPC
      - "4318:4318"   # OTLP HTTP
      - "8889:8889"   # Prometheus exporter
    volumes:
      - ./otel-collector/otel-collector-config.yml:/etc/otelcol-contrib/config.yaml
    restart: unless-stopped
```

Add the OTEL Collector as a Prometheus scrape target in `prometheus.yml`:
```yaml
  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

Restart everything:
```bash
docker compose up -d
```

Verify the collector is running:
```bash
docker logs otel-collector 2>&1 | tail -5
```
Check Prometheus Targets -- you should now see `otel-collector` as UP.

**Steps to follow:**

-->Great! You're now moving into OpenTelemetry (OTEL), which is the next step after metrics (Prometheus), logs (Loki), and dashboards (Grafana). Since your project structure already has an observability-stack directory, create the collector inside that directory.

Step 1: Create the Directory: inside observisibility-stack dir: mkdir -p otel-collector So once it gets create to verify use command: tree -L 2

<img width="1293" height="376" alt="image" src="https://github.com/user-attachments/assets/2ef3915f-dd3d-4b0a-8665-9540050f34a0" />

Step 2: Create OTEL Collector Config: vi otel-collector/otel-collector-config.yml

<img width="410" height="698" alt="image" src="https://github.com/user-attachments/assets/119afc7a-59df-4a1e-b0b8-a58435d894f5" />

Step 3: Add OTEL Collector Service: vi docker-compose.yml Add this service alongside your other services:

<img width="608" height="602" alt="image" src="https://github.com/user-attachments/assets/965d83fa-b3bf-4660-97bc-db15bb4b6a66" />

Step 4: Add Prometheus Scrape Job: vi prometheus.yml

<img width="417" height="620" alt="image" src="https://github.com/user-attachments/assets/3d192681-3d85-4b55-aa1d-d8b91db05f35" />

Step 5: Validate the Compose File: docker-compose config 

<img width="1667" height="977" alt="image" src="https://github.com/user-attachments/assets/a13db6a2-0eb7-4b3f-8208-3f85b157711e" />

Step 6: Start the Collector: docker-compose up -d OR docker compose up -d otel-collector

-->Then to verify use command: docker-compose ps OR docker ps

Step 7: Check Collector Logs: docker logs otel-collector --tail 20

<img width="1896" height="245" alt="image" src="https://github.com/user-attachments/assets/6b638c5a-5028-4f9b-bbdb-ec21a4996a8d" />

Step 8: Restart Prometheus: docker-compose restart prometheus

<img width="1912" height="622" alt="image" src="https://github.com/user-attachments/assets/b8733233-fc07-4fae-8031-f8561c191be4" />

Step 9: Verify Target in Prometheus: http://localhost:9090/targets

<img width="1912" height="971" alt="image" src="https://github.com/user-attachments/assets/49c9adca-3b80-4221-8d93-a76678974da8" />

Step 10: Verify Metrics Endpoint Directly: curl http://localhost:8889/metrics | head

<img width="1602" height="140" alt="image" src="https://github.com/user-attachments/assets/efd727c8-64f9-4e12-a18f-0131d7515357" />

-->You should see Prometheus metrics such as: # HELP, # TYPE, otelcol_receiver_accepted_metric_points etc.

**Why use the OpenTelemetry Collector instead of sending telemetry directly to each backend?**

-->Centralizes telemetry collection in one place, Applications send data once using OTLP. The collector can fan out data to multiple backends simultaneously.

-->Processors can batch, filter, enrich, or sample telemetry before export. Reduces application complexity because apps don't need separate integrations for Prometheus, Jaeger, Loki, Datadog, etc. Makes backend changes easier since only the collector configuration changes, not the application code.

Troubleshooting command:

-->Check if the container exists: docker ps | grep otel OR docker ps -a | grep otel

-->Check your compose file: docker-compose config | grep otel

-->Check Prometheus configuration: cat prometheus.yml & then restart it: docker compose restart prometheus & then check logs: docker logs prometheus --tail 20

-->Verify the collector logs: docker logs otel-collector

-->Also verify Prometheus can see the target: docker exec -it prometheus wget -qO- http://otel-collector:8889/metrics | head OR use command: docker exec -it prometheus sh & then inside run command: wget -qO- http://otel-collector:8889/metrics | head




---

### Task 3: Send Test Traces to the Collector
Send a sample OTLP trace using curl:

```bash
curl -X POST http://localhost:4318/v1/traces \
  -H "Content-Type: application/json" \
  -d '{
    "resourceSpans": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "my-test-service" }
        }]
      },
      "scopeSpans": [{
        "spans": [{
          "traceId": "5b8efff798038103d269b633813fc60c",
          "spanId": "eee19b7ec3c1b174",
          "name": "test-span",
          "kind": 1,
          "startTimeUnixNano": "1544712660000000000",
          "endTimeUnixNano": "1544712661000000000",
          "attributes": [{
            "key": "http.method",
            "value": { "stringValue": "GET" }
          },
          {
            "key": "http.status_code",
            "value": { "intValue": "200" }
          }]
        }]
      }]
    }]
  }'
```

Check the collector debug output to see the trace:
```bash
docker logs otel-collector 2>&1 | grep -A 10 "test-span"
```

You should see the span details printed to the console. In a production setup, you would send these to a trace backend like Jaeger or Grafana Tempo for storage and visualization.

**Send OTLP metrics too:**
```bash
curl -X POST http://localhost:4318/v1/metrics \
  -H "Content-Type: application/json" \
  -d '{
    "resourceMetrics": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": { "stringValue": "my-test-service" }
        }]
      },
      "scopeMetrics": [{
        "metrics": [{
          "name": "test_requests_total",
          "sum": {
            "dataPoints": [{
              "asInt": "42",
              "startTimeUnixNano": "1544712660000000000",
              "timeUnixNano": "1544712661000000000"
            }],
            "aggregationTemporality": 2,
            "isMonotonic": true
          }
        }]
      }]
    }]
  }'
```

Now query it in Prometheus:
```promql
test_requests_total
```

The metric traveled: your curl command -> OTEL Collector (OTLP receiver) -> Prometheus exporter -> Prometheus scraped it. This is how OTEL bridges different telemetry formats.

---

### Task 4: Set Up Prometheus Alerting Rules
Alerts notify you when something is wrong. Prometheus evaluates alerting rules and fires alerts when conditions are met.

Create an alerting rules file `alert-rules.yml`:
```yaml
groups:
  - name: system-alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage has been above 80% for more than 2 minutes. Current value: {{ $value }}%"

      - alert: HighMemoryUsage
        expr: (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 > 85
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85%. Current value: {{ $value }}%"

      - alert: ContainerDown
        expr: absent(container_last_seen{name="notes-app"})
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Container is down"
          description: "The notes-app container has not been seen for over 1 minute"

      - alert: TargetDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Scrape target is down"
          description: "{{ $labels.job }} target {{ $labels.instance }} is unreachable"

      - alert: HighDiskUsage
        expr: (1 - node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space running low"
          description: "Root filesystem usage is above 90%. Current value: {{ $value }}%"
```

**What each alert does:**
- `expr` -- the PromQL condition that triggers the alert
- `for` -- how long the condition must be true before firing (avoids flapping)
- `labels` -- metadata for routing (severity: warning vs critical)
- `annotations` -- human-readable description

Update `prometheus.yml` to load the rules:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/alert-rules.yml

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node-exporter"
    static_configs:
      - targets: ["node-exporter:9100"]

  - job_name: "cadvisor"
    static_configs:
      - targets: ["cadvisor:8080"]

  - job_name: "otel-collector"
    static_configs:
      - targets: ["otel-collector:8889"]
```

Mount the rules file in `docker-compose.yml` under the Prometheus service:
```yaml
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert-rules.yml:/etc/prometheus/alert-rules.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped
```

Restart Prometheus:
```bash
docker compose up -d prometheus
```

Check the rules in the Prometheus UI: go to Status > Rules. You should see all five alert rules listed.

Go to Alerts -- they should be in `inactive` state (green). If any condition is true, the alert moves to `pending`, then `firing` after the `for` duration.

**Test it:** Stop the notes-app container and watch the `TargetDown` alert fire:
```bash
docker compose stop notes-app
```

Wait 1-2 minutes, then check Alerts in the Prometheus UI. Start it back up when done:
```bash
docker compose start notes-app
```

---

### Task 5: Set Up Grafana Alerts
Grafana can also evaluate alerts and send notifications to Slack, email, PagerDuty, and more.

1. **Create a contact point:**
   - Go to Alerting > Contact points > Add contact point
   - Name: "DevOps Team"
   - Integration: Choose email (or Slack webhook if you have one)
   - For email: just enter your email address
   - Save

2. **Create an alert rule in Grafana:**
   - Go to Alerting > Alert rules > New alert rule
   - Name: "High Container Memory"
   - Query: `container_memory_usage_bytes{name="notes-app"} / 1024 / 1024`
   - Condition: IS ABOVE 100 (fire if container uses more than 100MB)
   - Evaluation: every 1m, for 2m
   - Add label: severity = warning
   - Link to the "DevOps Team" contact point
   - Save

3. **Create a notification policy:**
   - Go to Alerting > Notification policies
   - Set the default contact point to "DevOps Team"
   - Add a nested policy: match label `severity=critical` -> route to a different contact point (or the same one with different settings)

4. **View alert state:**
   - Go to Alerting > Alert rules
   - You should see your rule in Normal, Pending, or Firing state

**Document:** What is the difference between Prometheus alerts and Grafana alerts? When would you use each?

---

### Task 6: Review the Full Stack Architecture
Your observability stack now covers all three pillars. Map out what you have built:

```
                    METRICS PIPELINE
[Node Exporter] -----> [Prometheus] -----> [Grafana Dashboards]
[cAdvisor] ----------> [Prometheus] -----> [Grafana Dashboards]
[OTEL Collector:8889]> [Prometheus] -----> [Grafana Dashboards]
                                    -----> [Alert Rules -> Notifications]

                    LOGS PIPELINE
[Docker Containers] -> [Promtail] -> [Loki] -> [Grafana Explore/Dashboards]

                    TRACES PIPELINE
[curl/App OTLP] -----> [OTEL Collector] -> [Debug Output / Future: Jaeger/Tempo]
```

**Services running:**

| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics storage and querying |
| Node Exporter | 9100 | Host system metrics |
| cAdvisor | 8080 | Container metrics |
| Grafana | 3000 | Visualization and alerting |
| Loki | 3100 | Log storage |
| Promtail | 9080 | Log collection agent |
| OTEL Collector | 4317/4318/8889 | Telemetry collection |
| Notes App | 8000 | Sample application |

Verify all services are running:
```bash
docker compose ps
```

All 8 containers should be healthy and running.

---

## Hints
- The OTEL Collector contrib image (`otel/opentelemetry-collector-contrib`) includes more receivers and exporters than the core image -- always use contrib for learning
- Prometheus alerts without Alertmanager will show in the UI but will not send notifications -- Grafana alerting is simpler for getting started with notifications
- `for: 2m` in alert rules prevents alerts from firing on brief spikes -- this is called the pending period
- `absent()` in PromQL fires when a time series disappears entirely -- useful for detecting dead containers
- OTLP JSON format is verbose -- in production, applications use OTEL SDKs (Python, Go, Java) that handle serialization automatically
- The debug exporter prints to the collector's stdout -- use `docker logs otel-collector` to see trace output
- Reference repo: https://github.com/LondheShubham153/observability-for-devops -- check `otel-collector/` for the collector config

---

## Documentation
Create `day-76-otel-alerting.md` with:
- OpenTelemetry architecture: receivers, processors, exporters
- Your `otel-collector-config.yml` with explanations
- Screenshot of a trace appearing in the collector debug logs
- Your `alert-rules.yml` with explanations for each alert
- Screenshot of Prometheus Alerts page showing alert states
- Screenshot of Grafana Alerting showing your custom alert rule
- The full architecture diagram with all three pillars

---

## Submission
1. Add `day-76-otel-alerting.md` to `2026/day-76/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Added OpenTelemetry and alerting to the observability stack today. Sent OTLP traces and metrics through the OTEL Collector, set up Prometheus alerting rules for CPU, memory, disk, and container health, and configured Grafana notifications. All three pillars of observability -- metrics, logs, and traces -- are now wired up."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
