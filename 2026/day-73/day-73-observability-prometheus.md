# Day 73 -- Introduction to Observability and Prometheus

## Task
You have built infrastructure with Terraform, configured servers with Ansible, and containerized applications with Docker. But once everything is running -- how do you know it is healthy? How do you find out why something broke at 3 AM?

That is where observability comes in. Today you learn the three pillars of observability -- metrics, logs, and traces -- and set up Prometheus, the most widely used metrics collection tool in the DevOps ecosystem.

---

## Expected Output
- Clear understanding of observability vs traditional monitoring
- Prometheus running in a Docker container
- A working `prometheus.yml` with scrape targets
- Prometheus scraping its own metrics and responding to PromQL queries
- A markdown file: `day-73-observability-prometheus.md`

---

## Challenge Tasks

### Task 1: Understand Observability
Research and write short notes on:

1. What is observability? How is it different from traditional monitoring?

-->Observability is the ability to understand the internal state of a system by analyzing the data it produces (metrics, logs, traces).

- **Monitoring** tells you _when_ something is wrong (Uses predefined alerts and thresholds) Example: CPU > 90% → alert triggered

- **Observability** tells you _why_ something is wrong (Allows deep investigation using logs, metrics, and traces) Example: Why CPU is high? → check logs + request traces

-->Key difference: Monitoring = Reactive (detect issue) & Observability = Investigative (find root cause)

3. The three pillars of observability:
   - **Metrics** -- numerical measurements over time, Used for performance tracking and alerting (Eg: CPU usage, Memory usage, Request rate/count, error rate). Tools: Prometheus, Datadog, [AWS]CloudWatch
   - **Logs** -- timestamped text records of events, Helps debug errors and failures (Eg: application output/logs, Error stack traces OR Error messages, Access logs). Tools: Grafana Loki, ELK Stack, Fluentd
   - **Traces** -- the journey of a single request across multiple services, Shows request flow and latency (Eg: User request → API → DB → payment service) Tools: Open Telemetry, Jaeger, Zipkin

4. Why do DevOps engineers need all three?
-->So Each pillar answers a different question:
   - Metrics tell you _what_ is broken (Eg: high error rate on /api/users, /api/orders)
   - Logs tell you _why_ it broke (Eg: stack trace showing a database timeout, Database timeout error in logs)
   - Traces tell you _where_ it broke (Eg: Payment service taking 12 seconds)

6. Draw or describe this architecture -- this is what you will build over the next 5 days:
   ```
   [Your App] --> metrics --> [Prometheus] --> [Grafana Dashboards]
   [Your App] --> logs    --> [Promtail]   --> [Loki] --> [Grafana]
   [Your App] --> traces  --> [OTEL Collector] --> [Grafana/Debug]
   [Host]     --> metrics --> [Node Exporter] --> [Prometheus]
   [Docker]   --> metrics --> [cAdvisor] --> [Prometheus]
   ```
<img width="617" height="302" alt="image" src="https://github.com/user-attachments/assets/0e4f708f-9e81-4225-ac48-9893551a0331" />

<img width="1086" height="737" alt="image" src="https://github.com/user-attachments/assets/aa365ce3-3ecb-4703-bbd7-a93e4f405efe" />

**Simple Summary:**

-->Monitoring = alerts when something breaks

-->Observability = understanding why and where it broke

-->3 pillars = Metrics + Logs + Traces

-->Together = full visibility into systems

---

### Task 2: Set Up Prometheus with Docker
Create a project directory for this entire observability block -- you will keep adding to it over the next 5 days.

```bash
mkdir observability-stack && cd observability-stack
```

Create a `prometheus.yml` configuration file:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
```

This tells Prometheus to scrape its own metrics every 15 seconds.

Create a `docker-compose.yml` to run Prometheus:
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped

volumes:
  prometheus_data:
```

Start Prometheus:
```bash
docker-compose up -d
```

**Steps to follow:**

STEP 1: Create Observability Folder (Inside your project): 

-->cd ~/ansible-docker-project

-->mkdir observability-stack && cd observability-stack

STEP 2: Create Prometheus config file:

-->touch prometheus.yml & then open it vi prometheus.yml then save above line of code into this file.

STEP 3: Confirm structure: tree

<img width="1095" height="975" alt="image" src="https://github.com/user-attachments/assets/8a5e5108-4b00-45cd-b89f-cef3bbba12f0" />

<img width="835" height="563" alt="image" src="https://github.com/user-attachments/assets/c05d6cf8-ad5b-4852-a6be-282beac32db3" />

STEP 5:  Create docker-compose.yml under observability-stack dir: vi docker-compose.yml & to verify run command: ls

Step 6: Validate Docker Compose syntax: docker-compose config

<img width="1292" height="737" alt="image" src="https://github.com/user-attachments/assets/857fa258-109f-4bb4-85a9-47e4181503b2" />

Step 7: Start Prometheus: docker-compose up -d

<img width="1268" height="146" alt="image" src="https://github.com/user-attachments/assets/56b799c7-53d9-4487-b811-3efc3c5f9c25" />

Step 8: Check container status: sudo docker ps

<img width="1828" height="67" alt="image" src="https://github.com/user-attachments/assets/5e931851-81f1-442f-ad49-c68cb8618dda" />

Step 8: Check logs: docker logs prometheus: Look for messages like: Server is ready to receive web requests.

<img width="1917" height="533" alt="image" src="https://github.com/user-attachments/assets/3c7c5139-d4b5-4ddd-b6b4-a2eb79027095" />

Step 9: Open Prometheus UI:  Open `http://localhost:9090` in your browser. You should see the Prometheus web UI

<img width="1910" height="602" alt="image" src="https://github.com/user-attachments/assets/74494774-5b8f-4cce-b202-71f6f46965f6" />


**Verify:** Go to Status > Targets. You should see one target (`prometheus`) with state `UP`.

<img width="1912" height="657" alt="image" src="https://github.com/user-attachments/assets/591391eb-8788-46e5-bbc3-485db1976eaf" />

---

### Task 3: Understand Prometheus Concepts
Explore the Prometheus UI and understand these concepts:

1. **Scrape targets** -- endpoints that Prometheus pulls metrics from at regular intervals (pull-based model)
2. **Metrics types:**
   - `Counter` -- only goes up (total requests served, total errors)
   - `Gauge` -- goes up and down (current CPU usage, memory in use, active connections)
   - `Histogram` -- distribution of values in buckets (request duration: how many took <100ms, <500ms, <1s)
   - `Summary` -- similar to histogram but calculates percentiles on the client side
3. **Labels** -- key-value pairs that add dimensions to metrics (e.g., `http_requests_total{method="GET", status="200"}`)
4. **Time series** -- a unique combination of metric name + labels

Go to the Prometheus UI graph page (`http://localhost:9090/graph`) and run these queries:

```
# How many metrics is Prometheus collecting about itself?
count({__name__=~".+"})

# How much memory is Prometheus using?
process_resident_memory_bytes

# Total HTTP requests to the Prometheus server
prometheus_http_requests_total

# Break it down by handler
prometheus_http_requests_total{handler="/api/v1/query"}
```

**Document:** What is the difference between a counter and a gauge? Give one real-world example of each.

---

### Task 4: Learn PromQL Basics
PromQL (Prometheus Query Language) is how you ask questions about your metrics. Run these queries in the Prometheus UI:

1. **Instant vector** -- current value of a metric:
```promql
up
```
This returns 1 (up) or 0 (down) for each scrape target.

2. **Range vector** -- values over a time window:
```promql
prometheus_http_requests_total[5m]
```
Returns all values from the last 5 minutes.

3. **Rate** -- per-second rate of a counter over a time window:
```promql
rate(prometheus_http_requests_total[5m])
```
This is the most common function you will use. Counters always go up -- `rate()` converts them to a useful per-second speed.

4. **Aggregation** -- sum across all label combinations:
```promql
sum(rate(prometheus_http_requests_total[5m]))
```

5. **Filter by label:**
```promql
prometheus_http_requests_total{code="200"}
prometheus_http_requests_total{code!="200"}
```

6. **Arithmetic:**
```promql
process_resident_memory_bytes / 1024 / 1024
```
This converts bytes to megabytes.

7. **Top-K:**
```promql
topk(5, prometheus_http_requests_total)
```

**Try this exercise:** Write a PromQL query that shows the per-second rate of non-200 HTTP requests to Prometheus over the last 5 minutes. (Hint: use `rate()` with a label filter on `code!="200"`)

---

### Task 5: Add a Sample Application as a Scrape Target
Prometheus needs something to monitor. Add a simple metrics-generating service.

Update your `docker-compose.yml` to include a sample app that exposes Prometheus metrics:
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    restart: unless-stopped

  notes-app:
    image: trainwithshubham/notes-app:latest
    container_name: notes-app
    ports:
      - "8000:8000"
    restart: unless-stopped

volumes:
  prometheus_data:
```

Update `prometheus.yml` to scrape the app:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "notes-app"
    static_configs:
      - targets: ["notes-app:8000"]
```

Restart the stack:
```bash
docker compose up -d
```

Go back to Status > Targets. You should now see two targets. Generate some traffic to the app:
```bash
curl http://localhost:8000
curl http://localhost:8000
curl http://localhost:8000
```

**Note:** Not all applications expose Prometheus metrics natively. In later days you will learn how Node Exporter, cAdvisor, and OTEL Collector act as metric exporters for systems that do not have built-in Prometheus support.

---

### Task 6: Explore Data Retention and Storage
Understand how Prometheus stores data:

1. Check how much disk space Prometheus is using:
```bash
docker exec prometheus du -sh /prometheus
```

2. Prometheus stores data in a local time-series database (TSDB). Default retention is 15 days. You can change it:
```yaml
command:
  - '--config.file=/etc/prometheus/prometheus.yml'
  - '--storage.tsdb.retention.time=30d'
  - '--storage.tsdb.retention.size=1GB'
```

3. Check the TSDB status in the UI: Status > TSDB Status

**Document:** What happens when retention is exceeded? Why is a volume mount important for Prometheus data?

---

## Hints
- Prometheus uses a **pull model** -- it scrapes targets at regular intervals, unlike push-based systems
- The `up` metric is automatically created for every scrape target -- 1 means healthy, 0 means the target is unreachable
- `rate()` only works on counters, not gauges -- applying rate to a gauge gives meaningless results
- Always use `rate()` before `sum()` when aggregating counters: `sum(rate(...))` not `rate(sum(...))`
- If a target shows as DOWN in Status > Targets, check: is the container running? Is the port correct? Are they on the same Docker network?
- `prometheus.yml` changes require a restart or a POST to `/-/reload` (if `--web.enable-lifecycle` flag is set)
- Reference repo for the full stack: https://github.com/LondheShubham153/observability-for-devops

---

## Documentation
Create `day-73-observability-prometheus.md` with:
- The three pillars of observability in your own words
- Your `prometheus.yml` and `docker-compose.yml`
- Screenshot of Prometheus Targets page showing all targets UP
- Five PromQL queries you ran and what they returned
- Explanation of counter vs gauge with examples
- Architecture diagram of what you will build over days 73-77

---

## Submission
1. Add `day-73-observability-prometheus.md` to `2026/day-73/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Started the observability block today -- learned the three pillars (metrics, logs, traces), set up Prometheus in Docker, wrote my first PromQL queries, and started monitoring a sample app. Observability is what separates running services from actually understanding them."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
