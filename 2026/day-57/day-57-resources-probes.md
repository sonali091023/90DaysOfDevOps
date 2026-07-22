# Day 57 – Resource Requests, Limits, and Probes

## Task
Your Pods are running, but Kubernetes has no idea how much CPU or memory they need — and no way to tell if they are actually healthy. Today you set resource requests and limits for smart scheduling, then add probes so Kubernetes can detect and recover from failures automatically.

---

## Expected Output
- A Pod with CPU and memory requests and limits
- OOMKilled observed when exceeding memory limits
- Liveness, readiness, and startup probes tested
- A markdown file: `day-57-resources-probes.md`

---

## Challenge Tasks

### Task 1: Resource Requests and Limits
1. Write a Pod manifest with `resources.requests` (cpu: 100m, memory: 128Mi) and `resources.limits` (cpu: 250m, memory: 256Mi)
2. Apply and inspect with `kubectl describe pod` — look for the Requests, Limits, and QoS Class sections
3. Since requests and limits differ, the QoS class is `Burstable`. If equal, it would be `Guaranteed`. If missing, `BestEffort`.

**Steps to follow:**

Step 1: Create the Pod manifest: vi pod-resources.yml  
```
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "250m"
        memory: "256Mi"
```
Step 2: Apply the manifest: kubectl apply -f pod-resources.yml

-->verify the pod running: kubectl get pods

Step 3: Inspect the Pod: kubectl describe pod resource-demo

<img width="572" height="232" alt="image" src="https://github.com/user-attachments/assets/68754cdc-74f9-4801-b0e9-cf9e36f2411a" />

<img width="1732" height="972" alt="image" src="https://github.com/user-attachments/assets/2c50a825-55a9-4f55-85c4-dbc36c3b46e3" />
<img width="1885" height="467" alt="image" src="https://github.com/user-attachments/assets/8d86cc04-8920-4be5-aa84-acfdbf45ab9d" />

QoS Classes: Lets understand why it is burstable, So since Request is not equal to Limit thats why QoS is burstable.

<img width="621" height="161" alt="image" src="https://github.com/user-attachments/assets/39c31fa6-1c59-4da1-8ef7-fa4ce759d7cd" />

-->Pods class is burstable because request and limit are not equal, This QoS class matters because it decides eviction priority during resource pressure, And we can see eviction order as below,

1. **BestEffort [Nothing set]:** --> killed first --> Case 1: No request/No limit -->QoS = BestEffort (lowest priority) 

2. **Burstable [Different values]:** --> can temporarily increase usage --> Requests ≠ Limits --> QoS = Burstable

3. **Guaranteed [Same values]:** --> safest --> Requests = Limits (exact same) --> QoS = Guaranteed (highest priority)

**Note:** Quality of Service (QoS) means how Kubernetes prioritizes and manages your Pod’s resources (CPU, Memory)

-->QoS tells Kubernetes How important is this Pod when resources are limited

-->When the node is under pressure (low memory/CPU): Kubernetes kills Pods in this order: **1. BestEffort 2. Burstable 3. Guaranteed**  

-->QoS (Quality of Service) is a Kubernetes mechanism that classifies Pods based on resource requests and limits to decide scheduling priority and eviction order.

-->Burstable Pods are allowed to use extra resources when available, but they are not fully guaranteed like Guaranteed Pods.

Note:
- equests = Minimum resources Kubernetes reserves.
- Limits = Maximum resources the container can use.
- Since requests and limits are different, Kubernetes assigns the Pod the Burstable QoS class.

---

### Task 2: OOMKilled — Exceeding Memory Limits
1. Write a Pod manifest using the `polinux/stress` image with a memory limit of `100Mi`
2. Set the stress command to allocate 200M of memory: `command: ["stress"] args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]`
3. Apply and watch — the container gets killed immediately

**Steps to follow:**

Step 1: Create the Pod manifest: vi oom-demo.yml    
```
apiVersion: v1
kind: Pod
metadata:
  name: oom-pod
spec:
  containers:
  - name: stress
    image: polinux/stress
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]
    resources:
      limits:
        memory: "100Mi"
```
Note: This container tries to allocate 200 MB of memory, but Kubernetes only allows 100 MiB.

Step 2: Apply the Pod: kubectl apply -f oom-demo.yml

Step 3: Watch the Pod: kubectl get pods -w

<img width="682" height="210" alt="image" src="https://github.com/user-attachments/assets/79071b07-95a2-4074-b8d6-de500b3002e8" />

Step 4: Verify the reason: kubectl describe pod oom-demo

<img width="656" height="265" alt="image" src="https://github.com/user-attachments/assets/b860a45b-5b25-487d-abe2-66a955ed42fa" />

<img width="1757" height="967" alt="image" src="https://github.com/user-attachments/assets/211bd798-5862-4e9a-8ccd-ef975a61996d" />

<img width="1900" height="962" alt="image" src="https://github.com/user-attachments/assets/97547fd2-90d7-499d-a3b5-53e945636558" />

Note:
- Memory limit: 100Mi
- Memory requested by the application: 200M
- Result: Container is OOMKilled because it exceeded its memory limit.

CPU is throttled when over limit. Memory is killed — no mercy.

Check `kubectl describe pod` for `Reason: OOMKilled` and `Exit Code: 137` (128 + SIGKILL).

**Goal:** Force a container to exceed memory → Kubernetes kills it (OOMKilled)

**Verify:** What exit code does an OOMKilled container have?
-->For OOMKilled container exit code: 137. So here pod gets stop running & that is happend because Memory is strictly enforced, CPU → slows down (throttling), Memory → immediate kill, No warning. No gradual slowdown.

**Q. Difference between CPU limit vs Memory limit?**

-->**CPU** → throttled (container slows down) & **Memory** → OOMKilled (container terminated immediately)

---

### Task 3: Pending Pod — Requesting Too Much
1. Write a Pod manifest requesting `cpu: 100` and `memory: 128Gi`
2. Apply and check — STATUS stays `Pending` forever
3. Run `kubectl describe pod` and read the Events — the scheduler says exactly why: insufficient resources

**Goal:** Create a Pod that asks for too much CPU & memory → it will stay Pending

**Steps to follow:**

Step 1: Create the Pod manifest: pending-pod.yml     
```
apiVersion: v1
kind: Pod
metadata:
  name: pending-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        cpu: "100"
        memory: "128Gi"
```
Note: This Pod requests 100 CPU cores and 128 GiB RAM, which is much more than a typical cluster has.

Step 2: Apply the manifest: kubectl apply -f pending-pod.yml

Step 3: Check the Pod status: kubectl get pods [Expected: The Pod remains Pending because Kubernetes cannot find a node with enough resources.]

Step 4: Find the reason: kubectl describe pod pending-demo

<img width="546" height="136" alt="image" src="https://github.com/user-attachments/assets/cc117dde-7978-40a9-9c06-70792f5adb4d" />

<img width="1902" height="971" alt="image" src="https://github.com/user-attachments/assets/96411b2b-0e93-44ca-9750-51917ff03485" />

Note:
- The Pod requests more resources than the cluster has.
- The scheduler cannot place the Pod on any node.
- The Pod stays in the Pending state until enough resources become available.

**Verify:** What event message does the scheduler produce?
--> Warning  FailedScheduling  36s   default-scheduler  0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory. no new claims to deallocate, preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.

**Note:** Requests decide scheduling, So Scheduler ONLY looks at requests (not limits), If requests can't be satisfied → Pod stays Pending 

**Q. Why is Pod stuck in Pending?**
-->Because the requested resources exceed node capacity, so the scheduler cannot place the Pod. 

-->**Key Rule (VERY IMPORTANT):** A Pod must fit completely on ONE node, Kubernetes does NOT do this: Split CPU across nodes & Combine memory from multiple nodes

-->So what happened is, Scheduler checks Node-1 → Not enough CPU, Node-2 → Not enough memory, Node-3 → Same problem, As a Result: No node can fully satisfy the request → Pod stays Pending

-->K8S is behaves this way because Requests = guaranteed resources & Kubernetes is saying “If I schedule this Pod, I must guarantee it gets 100 CPU & 128GB RAM.”, Since it can’t guarantee, it refuses to run it.

---

### Task 4: Liveness Probe
A liveness probe detects stuck containers. If it fails, Kubernetes restarts the container.

1. Write a Pod manifest with a busybox container that creates `/tmp/healthy` on startup, then deletes it after 30 seconds
2. Add a liveness probe using `exec` that runs `cat /tmp/healthy`, with `periodSeconds: 5` and `failureThreshold: 3`
3. After the file is deleted, 3 consecutive failures trigger a restart. Watch with `kubectl get pod -w`

**Steps to follow:**

Step 1: Create the Pod manifest: vi liveness-demo.yml 
```
apiVersion: v1
kind: Pod
metadata:
  name: liveness-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command:
      - sh
      - -c
      - |
        touch /tmp/healthy
        sleep 30
        rm -f /tmp/healthy
        while true; do sleep 5; done
    livenessProbe:
      exec:
        command:
          - cat
          - /tmp/healthy
      periodSeconds: 5
      failureThreshold: 3
```
Step 2: Apply the manifest: kubectl apply -f liveness-demo.yml

Step 3: Watch the Pod: kubectl get pods -w

<img width="647" height="367" alt="image" src="https://github.com/user-attachments/assets/97b9ebe7-fba3-41c2-bab4-051b6498cac8" />

-->kubectl get pods

<img width="1461" height="477" alt="image" src="https://github.com/user-attachments/assets/da70b47c-7c7a-4f58-9bfa-2b996c8e2f5d" />

Step 4: Verify the restart: kubectl describe pod liveness-pod

<img width="1712" height="962" alt="image" src="https://github.com/user-attachments/assets/9259549e-2ef2-4604-a472-e62be416c51f" />
<img width="1895" height="447" alt="image" src="https://github.com/user-attachments/assets/8cee73e6-25f0-4862-ba4a-f829a8c163e4" />

Note: 
- Liveness Probe checks whether the container is still healthy.
- If the probe fails 3 consecutive times (failureThreshold: 3), Kubernetes restarts the container automatically.
- This is useful for recovering applications that become stuck or unresponsive.

**Note:** Restart count will keep increasing (1, 2, 3...) every time the probe fails again after restart. 
-->Liveness probe = “Is container alive?”, If failed → Kubernetes restarts container

**Verify:** How many times has the container restarted?
-->container restarted for 3 times

Q. When do we use liveness probe?
-->To detect stuck or dead containers and automatically restart them.

---

### Task 5: Readiness Probe
A readiness probe controls traffic. Failure removes the Pod from Service endpoints but does NOT restart it.

1. Write a Pod manifest with nginx and a `readinessProbe` using `httpGet` on path `/` port `80`
2. Expose it as a Service: `kubectl expose pod <name> --port=80 --name=readiness-svc`
3. Check `kubectl get endpoints readiness-svc` — the Pod IP is listed
4. Break the probe: `kubectl exec <pod> -- rm /usr/share/nginx/html/index.html`
5. Wait 15 seconds — Pod shows `0/1` READY, endpoints are empty, but the container is NOT restarted

**Steps to follow:**

Step 1: Create the Pod manifest: vi readiness-pod.yaml   
```
apiVersion: v1
kind: Pod
metadata:
  name: readiness-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    readinessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 5
      failureThreshold: 3
```
Step 2: Apply the manifest: kubectl apply -f nginx-readiness.yml

-->Check the pods: kubectl get pods

Step 3: Expose the Pod as a Service: kubectl expose pod nginx-readiness --port=80 --name=readiness-svc

-->Verify the Endpoint Exists: kubectl get endpoints readiness-svc

-->Check the service: kubectl get svc

**Note:** Important: here we can see the Pod IP is present That means the readiness probe is passing, Kubernetes considers the Pod ready to receive traffic

Step 4: Break the Readiness Probe by Deleting the nginx homepage file: kubectl exec nginx-readiness -- rm /usr/share/nginx/html/index.html

Step 5: Wait about 15 seconds: kubectl get pods

-->Check the endpoints again: kubectl get endpoints readiness-svc

-->verify: kubectl describe pod readiness-pod

**Note:** Why this works: nginx serves /usr/share/nginx/html/index.html, Your readiness probe checks /, Once the file is deleted, nginx returns 404 Readiness probe fails
-->Kubernetes periodically sends an HTTP request to: http://<pod-ip>:80/ & If nginx responds successfully, the Pod is considered Ready.

<img width="1752" height="971" alt="image" src="https://github.com/user-attachments/assets/339e3b09-43cf-48bc-8c95-d941160fdc94" />
<img width="1672" height="967" alt="image" src="https://github.com/user-attachments/assets/0550f89b-3ed8-46db-b7a4-439c2fcf4b11" />
<img width="1907" height="221" alt="image" src="https://github.com/user-attachments/assets/66499834-9df7-43d8-9aab-5e13a3244e02" />

Note: 
- The Pod is still Running.
- The READY column changes to 0/1.
- The Service has no endpoints, so it won't send traffic to the Pod.
- RESTARTS remains 0 because a readiness probe does not restart the container.

Note: 
- Readiness Probe determines whether a Pod is ready to receive traffic.
- On failure, the Pod is removed from the Service endpoints.
- The container continues running and is not restarted.

**Step-by-Step Internal Flow:**

--> 1. Pod Starts: Container -> nginx starts -->nginx listens on: port 80 --> and serves files from: /usr/share/nginx/html

--> 2. Default nginx Website [Inside that folder, nginx already has:index.html so this is the default welcome page ] to verify use cmd: kubectl exec readiness-nginx -- ls /usr/share/nginx/html

--> 3. What Happens When Probe Hits / -->So here readniess probe requests GET / --> nginx interprets / [ / -> look inside document root & -> search for index.html] --> So nginx internally serves: /usr/share/nginx/html/index.html --> and returns: HTTP/1.1 200 OK

--> 4. Kubernetes Interprets HTTP Status 200 ok, It means Pod is READY, Then Kubernetes: adds Pod IP to Service endpoints, allows traffic

--> 5. What You Expected After Deleting index.html --> When we run the cmd: kubectl exec readiness-nginx -- rm /usr/share/nginx/html/index.html -->expectation was: No index.html, nginx cannot serve /, nginx returns 404 & readiness probe fails This logic is reasonable, BUT nginx behavior is slightly more complicated.

-->6. That is endpoints are still exists: Even after deleting index.html, nginx may STILL return success. Why? Because nginx can still do one of these: Possibility:
Possibility A — Another Index File Exists
Possibility B — Directory Handling

--> In this case By  Moving the Entire Directory Works: So here nginx loses its entire document root, So when probe requests: GET / nginx tries: open /usr/share/nginx/html but the directory no longer exists. Now nginx returns: 404 Not Found OR sometimes 403 Forbidden

-->And then Kubernetes Marks Pod Unready After repeated failures, Then we can see READY status = 0/1

-->What Happens Internally After Failure is, Kubernetes does NOT kill the container, Instead It only changes routing state
Before failure

-->Container Is NOT Restarted, Because readiness probes are NOT health-repair mechanisms, Their job is only: "Should this Pod receive traffic?" NOT: "Should this container be restarted?" That restart behavior belongs to: livenessProbe

-->Wait About 15 Seconds & then continuously watch the pod: kubectl get pods -w

-->Verify Endpoints Are Removed: kubectl get endpoints readiness-svc

**Verify:** When readiness failed, was the container restarted?
-->No, Container not restarted when readniess failed.

**Readiness Probe**
-->A readiness probe answers: "Can this Pod receive traffic right now?" & If it fails: Pod is removed from Service endpoints, Traffic stops going to it & still Container keeps running.

**Liveness Probe**
-->A liveness probe answers: "Is this container unhealthy/stuck and should it be restarted?" & If it fails: Kubernetes restarts the container

**Note:** Readiness probes control traffic flow to Pods. When a readiness probe fails, Kubernetes removes the Pod from Service endpoints but does not restart the container. Liveness probes are responsible for restarting unhealthy containers.

---

### Task 6: Startup Probe
A startup probe gives slow-starting containers extra time. While it runs, liveness and readiness probes are disabled.

Write a Pod manifest where the container takes 20 seconds to start (e.g., sleep 20 && touch /tmp/started)
Add a startupProbe checking for /tmp/started with periodSeconds: 5 and failureThreshold: 12 (60 second budget)
Add a livenessProbe that checks the same file — it only kicks in after startup succeeds
Verify: What would happen if failureThreshold were 2 instead of 12?

**Steps to follow:**

Step 1: Create the Pod manifest: vi startup-probe.yaml  
```
apiVersion: v1
kind: Pod
metadata:
  name: startup-probe-pod
spec:
  containers:
  - name: app
    image: busybox
    command:
      - sh
      - -c
      - |
        sleep 20
        touch /tmp/started
        while true; do sleep 5; done

    startupProbe:
      exec:
        command:
        - cat
        - /tmp/started
      periodSeconds: 5
      failureThreshold: 12

    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/started
      periodSeconds: 5
      failureThreshold: 3
```

-->Understand the Container Command
- Application Becomes Ready: touch /tmp/started Now the file exists, This represents: Application finished startup
- Keep Container Running: sleep 3600 [Otherwise container would exit immediately.]

Step 2: Apply the manifest: kubectl apply -f startup-probe.yaml

Step 3: Watch the Pod: kubectl get pods -w

<img width="640" height="240" alt="image" src="https://github.com/user-attachments/assets/bc3ed769-3efe-4da3-99b0-0dd1b2653164" />
<img width="1305" height="402" alt="image" src="https://github.com/user-attachments/assets/8d3a414f-4b28-4a8c-9592-f9ff330ef4e4" />
  
Note:
- Startup Probe gives slow-starting applications extra time.
- Liveness and Readiness probes are disabled until the startup probe succeeds.
- In this task:
  - failureThreshold: 12 with periodSeconds: 5 gives a 60-second startup window (12 × 5 = 60), so a 20-second startup succeeds.
  - failureThreshold: 2 gives only a 10-second startup window, causing repeated restarts and a CrashLoopBackOff.

-->Wait ~20 Seconds: /tmp/started the startup probe succeeds, Now Kubernetes says: Startup complete, At this moment: startup probe stops running, liveness probe becomes active, readiness probe would become active (if present) & Pod becomes: 1/1 Running

Step 4: Verify: kubectl describe pod startup-probe-pod [You'll see the Startup Probe succeeds first. Only after that does the Liveness Probe begin running.]

--> Verify Startup Probe Events: kubectl describe pod startup-demo [So here Look at Events section Initially you may see: Startup probe failed for the first few checks. That is expected because: /tmp/started does not exist yet. After 20 seconds: probe succeeds. Container is NOT restarted because failures stayed within the allowed budget.

**Why Startup Probes Exist** Without startup probes: liveness probe starts immediately, slow apps appear "dead", Kubernetes restarts them repeatedly This creates: CrashLoopBackOff even though the app is healthy but slow.
Startup probes prevent this.

**Note:** A startup probe is used for slow-starting applications. While the startup probe is running, Kubernetes disables liveness and readiness probes. If the startup probe succeeds, normal probes begin. If failureThreshold is too low, Kubernetes may restart the container before startup completes, causing restart loops or CrashLoopBackOff.

**Verify:** What would happen if `failureThreshold` were 2 instead of 12?

-->If failureThreshold were 2 instead of 12, Kubernetes would give the container only 10 seconds to start because the startup probe runs every 5 seconds. However, the application needs 20 seconds to finish startup and create the /tmp/started file. Since the file would still not exist after 10 seconds, the startup probe would fail twice, Kubernetes would think the container failed to start, and it would restart the container. After restarting, the 20-second startup process begins again from the beginning, causing the container to restart repeatedly and eventually enter CrashLoopBackOff.

<img width="652" height="527" alt="image" src="https://github.com/user-attachments/assets/03fcedea-1de3-45da-ac00-e15f51c39d76" />
  
---

### Task 7: Clean Up
Delete all pods and services you created.

<img width="1500" height="822" alt="image" src="https://github.com/user-attachments/assets/986adc7c-0581-4f9c-b334-305df84c8458" />
<img width="1541" height="557" alt="image" src="https://github.com/user-attachments/assets/4034cb43-f7ab-43e1-8275-205568c09c4e" />

---

## Hints
- CPU is compressible (throttled); memory is incompressible (OOMKilled)
- CPU: `1` = 1 core = `1000m`. Memory: `Mi` (mebibytes), `Gi` (gibibytes)
- QoS: Guaranteed (requests == limits), Burstable (requests < limits), BestEffort (none set)
- Probe types: `httpGet`, `exec`, `tcpSocket`
- Liveness failure = restart. Readiness failure = remove from endpoints. Startup failure = kill.
- `initialDelaySeconds`, `periodSeconds`, `failureThreshold` control probe timing
- Exit code 137 = OOMKilled (128 + SIGKILL)

---

## Documentation
Create `day-57-resources-probes.md` with:
- Requests vs limits (scheduling vs enforcement)
- What happens when CPU or memory limits are exceeded
- Liveness vs readiness vs startup probes
- Screenshots of OOMKilled, Pending, and probe events

---

## Submission
1. Add `day-57-resources-probes.md` to `2026/day-57/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Set resource requests and limits in Kubernetes today, watched a pod get OOMKilled, and added liveness, readiness, and startup probes for self-healing."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
