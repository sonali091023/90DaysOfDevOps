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

-->Create the Pod manifest: vi pod-resources.yml  [pod-resources.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-57/k8s-manifest-files/pod-resources.yml)

-->Apply the pod: kubectl apply -f pod-resources.yml

-->Inspect the pod details: kubectl describe pod resource-demo

<img width="1227" height="977" alt="image" src="https://github.com/user-attachments/assets/f29282af-8fdf-45d6-8eed-c616675722e3" />

**Request & Limit class section:**
<img width="171" height="162" alt="image" src="https://github.com/user-attachments/assets/db802edb-ef49-4893-9387-660569bf0c9e" />

**QoS [Quality of the service] class section:** **QoS Class: Burstable** 

-->Lets understand why it is burstable, So since Request is not equal to Limit thats why QoS is burstable.
<img width="673" height="181" alt="image" src="https://github.com/user-attachments/assets/a9829864-e6c6-4d44-8ecb-d5656df0c6b5" />

-->**Quick QoS cheatsheet:**
<img width="652" height="188" alt="image" src="https://github.com/user-attachments/assets/4cfa4a23-ada7-43a1-95a8-9a6f4926d4af" />

CPU is in millicores: `100m` = 0.1 CPU. Memory is in mebibytes: `128Mi`.

**Requests** = guaranteed minimum (scheduler uses this for placement). **Limits** = maximum allowed (kubelet enforces at runtime).

**Verify:** What QoS class does your Pod have?

-->Pods class is burstable because request and limit are not equal, This QoS class matters because it decides eviction priority during resource pressure, And we can see eviction order as below,

1. **BestEffort [Nothing set]:** --> killed first --> Case 1: No request/No limit -->QoS = BestEffort (lowest priority) 

2. **Burstable [Different values]:** --> can temporarily increase usage --> Requests ≠ Limits --> QoS = Burstable

3. **Guaranteed [Same values]:** --> safest --> Requests = Limits (exact same) --> QoS = Guaranteed (highest priority)

**Note:** Quality of Service (QoS) means how Kubernetes prioritizes and manages your Pod’s resources (CPU, Memory)

-->QoS tells Kubernetes How important is this Pod when resources are limited

-->When the node is under pressure (low memory/CPU): Kubernetes kills Pods in this order: **1. BestEffort 2. Burstable 3. Guaranteed**  

-->QoS (Quality of Service) is a Kubernetes mechanism that classifies Pods based on resource requests and limits to decide scheduling priority and eviction order.

-->Burstable Pods are allowed to use extra resources when available, but they are not fully guaranteed like Guaranteed Pods.

---

### Task 2: OOMKilled — Exceeding Memory Limits
1. Write a Pod manifest using the `polinux/stress` image with a memory limit of `100Mi`
2. Set the stress command to allocate 200M of memory: `command: ["stress"] args: ["--vm", "1", "--vm-bytes", "200M", "--vm-hang", "1"]`
3. Apply and watch — the container gets killed immediately

**Steps to follow:**

-->vi oom-demo.yml    [oom-demo.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-57/k8s-manifest-files/oom-demo.yml)

-->kubectl apply -f oom-demo.yml

-->kubectl get pods -w

-->kubectl describe pod oom-demo
<img width="1063" height="941" alt="image" src="https://github.com/user-attachments/assets/e0eb53c0-6d64-428c-95bd-01d8cd08dc58" />
<img width="1596" height="492" alt="image" src="https://github.com/user-attachments/assets/0dc6b477-178e-4990-8b18-3516cf2143f2" />

CPU is throttled when over limit. Memory is killed — no mercy.

Check `kubectl describe pod` for `Reason: OOMKilled` and `Exit Code: 137` (128 + SIGKILL).

**Goal:** Force a container to exceed memory → Kubernetes kills it (OOMKilled)

**Verify:** What exit code does an OOMKilled container have?
-->For OOMKilled container exit code: 137

-->So here pod gets stop running & that is happend because Memory is strictly enforced, CPU → slows down (throttling), Memory → immediate kill, No warning. No gradual slowdown.

-->Exit code 137 because,
<img width="252" height="147" alt="image" src="https://github.com/user-attachments/assets/bbe78ea3-ec18-4c13-a45d-a199f13b91bb" />

**Difference between CPU limit vs Memory limit?**

-->**CPU** → throttled (container slows down)

-->**Memory** → OOMKilled (container terminated immediately)

---

### Task 3: Pending Pod — Requesting Too Much
1. Write a Pod manifest requesting `cpu: 100` and `memory: 128Gi`
2. Apply and check — STATUS stays `Pending` forever
3. Run `kubectl describe pod` and read the Events — the scheduler says exactly why: insufficient resources

**Goal:** Create a Pod that asks for too much CPU & memory → it will stay Pending

**Steps to follow:**

-->Create the pod manifest: pending-pod.yml     [pending-pod.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-57/k8s-manifest-files/pending-pod.yml)

-->kubectl apply -f pending-pod.yml

-->kubectl get pods

-->kubectl describe pod pending-demo
<img width="1911" height="967" alt="image" src="https://github.com/user-attachments/assets/22cecd2f-7bce-41ed-8fea-9d2443ad0a0f" />

**Verify:** What event message does the scheduler produce?
--> Warning  FailedScheduling  36s   default-scheduler  0/1 nodes are available: 1 Insufficient cpu, 1 Insufficient memory. no new claims to deallocate, preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.

**Note:** Requests decide scheduling, So Scheduler ONLY looks at requests (not limits), If requests can't be satisfied → Pod stays Pending 

**Q. Why is Pod stuck in Pending?**
-->Because the requested resources exceed node capacity, so the scheduler cannot place the Pod. 

-->k8S says impossible for the following resource, 
<img width="582" height="262" alt="image" src="https://github.com/user-attachments/assets/e813cfe5-a4c9-4b13-93f0-2479e0382490" />

-->**What the scheduler actually does:** The scheduler doesn’t guess or adjust — it strictly checks:, “Is there any single node that can satisfy this request fully?”
<img width="712" height="328" alt="image" src="https://github.com/user-attachments/assets/c8213f3f-e8f3-4e87-bd87-b09062179f71" />

-->**Key Rule (VERY IMPORTANT):** A Pod must fit completely on ONE node, Kubernetes does NOT do this: Split CPU across nodes & Combine memory from multiple nodes

-->So what happened is, Scheduler checks Node-1 → Not enough CPU, Node-2 → Not enough memory, Node-3 → Same problem, As a Result: No node can fully satisfy the request → Pod stays Pending

-->K8S is behaves this way because Requests = guaranteed resources & Kubernetes is saying “If I schedule this Pod, I must guarantee it gets 100 CPU & 128GB RAM.”, Since it can’t guarantee, it refuses to run it.

-->Simple example:
<img width="350" height="337" alt="image" src="https://github.com/user-attachments/assets/5b6f4611-3b67-46e0-8bbc-113c5e1f5cce" />
**Note:** It’s impossible because no single node has enough resources to satisfy the Pod’s requested minimum.

---

### Task 4: Liveness Probe
A liveness probe detects stuck containers. If it fails, Kubernetes restarts the container.

1. Write a Pod manifest with a busybox container that creates `/tmp/healthy` on startup, then deletes it after 30 seconds
2. Add a liveness probe using `exec` that runs `cat /tmp/healthy`, with `periodSeconds: 5` and `failureThreshold: 3`
3. After the file is deleted, 3 consecutive failures trigger a restart. Watch with `kubectl get pod -w`

**Steps to follow:**

-->vi liveness-demo.yml    [liveness-demo.yml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-57/k8s-manifest-files/liveness-demo.yml)

-->kubectl apply -f liveness-demo.yml

-->kubectl get pods

-->kubectl get pods -w
<img width="1120" height="715" alt="image" src="https://github.com/user-attachments/assets/fb41f24d-6652-4481-95b9-b1adbf33b5cc" />
<img width="1357" height="970" alt="image" src="https://github.com/user-attachments/assets/f06a1a9b-6a74-403b-919a-3254ddc206f8" />
<img width="1343" height="223" alt="image" src="https://github.com/user-attachments/assets/f6320844-08d0-4a57-ba11-0988715fd6ed" />

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

-->Create the pod manifest: vi readiness-pod.yaml   [nginx-readiness.yaml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-57/k8s-manifest-files/nginx-readiness.yaml)

-->create the pod: kubectl apply -f nginx-readniss.yml

-->Check the pods: kubectl get pods

-->Expose the Pod as a Service: kubectl expose pod nginx-readiness --port=80 --name=readiness-svc

-->Check the service: kubectl get svc

-->Verify the Endpoint Exists: kubectl get endpoints readiness-svc

**Note:** Important: here we can see the Pod IP is present That means the readiness probe is passing, Kubernetes considers the Pod ready to receive traffic

-->Break the Readiness Probe by Deleting the nginx homepage file: kubectl exec nginx-readniess -- rm /usr/share/nginx/html/index.html

**Note:** Why this works: nginx serves /usr/share/nginx/html/index.html, Your readiness probe checks /, Once the file is deleted, nginx returns 404 Readiness probe fails
<img width="221" height="202" alt="image" src="https://github.com/user-attachments/assets/efb69434-f727-44db-bc23-6988b4654b30" />
-->Kubernetes periodically sends an HTTP request to: http://<pod-ip>:80/ & If nginx responds successfully, the Pod is considered Ready.

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
<img width="325" height="353" alt="image" src="https://github.com/user-attachments/assets/65fa4f6c-07f2-4b5e-8584-86cee5c5422a" />

-->Container Is NOT Restarted, Because readiness probes are NOT health-repair mechanisms, Their job is only: "Should this Pod receive traffic?" NOT: "Should this container be restarted?" That restart behavior belongs to: livenessProbe
<img width="547" height="170" alt="image" src="https://github.com/user-attachments/assets/e0fa8e6e-0c1c-411f-822f-967e7b682e15" />

-->Wait About 15 Seconds & then continuously watch the pod: kubectl get pods -w

-->Verify Endpoints Are Removed: kubectl get endpoints readiness-svc

<img width="1648" height="852" alt="image" src="https://github.com/user-attachments/assets/216c17a6-3487-4e29-986f-2e0777e2f37a" />
<img width="1512" height="967" alt="image" src="https://github.com/user-attachments/assets/01c3c5d2-9823-4f51-93ea-2f8a3b5ae043" />
<img width="1907" height="482" alt="image" src="https://github.com/user-attachments/assets/b371faa5-fd37-47af-96f2-d8d5cc66dd76" />

**Verify:** When readiness failed, was the container restarted?
-->No, Container not restarted when readniess failed.

**Readiness Probe**
-->A readiness probe answers: "Can this Pod receive traffic right now?" & If it fails: Pod is removed from Service endpoints, Traffic stops going to it & still Container keeps running.

**Liveness Probe**
-->A liveness probe answers: "Is this container unhealthy/stuck and should it be restarted?" & If it fails: Kubernetes restarts the container

**Note:** Readiness probes control traffic flow to Pods. When a readiness probe fails, Kubernetes removes the Pod from Service endpoints but does not restart the container. Liveness probes are responsible for restarting unhealthy containers.

<img width="370" height="367" alt="image" src="https://github.com/user-attachments/assets/c1bd7169-2d02-4c0c-806f-d14b13728771" />

---

### Task 6: Startup Probe
A startup probe gives slow-starting containers extra time. While it runs, liveness and readiness probes are disabled.

1. Write a Pod manifest where the container takes 20 seconds to start (e.g., `sleep 20 && touch /tmp/started`)
2. Add a `startupProbe` checking for `/tmp/started` with `periodSeconds: 5` and `failureThreshold: 12` (60 second budget)
3. Add a `livenessProbe` that checks the same file — it only kicks in after startup succeeds

**Goal of This Exercise:** You will learn: why startup probes exist, how they protect slow-starting containers, how startup probes interact with liveness probes, why improper probe timing causes restart loops etc.
<img width="461" height="251" alt="image" src="https://github.com/user-attachments/assets/56c08115-ede4-4441-a0c8-e48e8e60b410" />
-->Scenario: Your container will sleep for 20 seconds then create a file: /tmp/started, The startup probe checks for this file.

**Steps to follow:**

-->Create the Pod Manifest: vi startup-probe.yaml  [startup-probe.yaml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-57/k8s-manifest-files/startup-probe.yaml)

-->Understand the Container Command
<img width="345" height="530" alt="image" src="https://github.com/user-attachments/assets/f8a85bfd-07ae-4a6a-b1ad-b470585c5866" />

-->Application Becomes Ready: touch /tmp/started Now the file exists, This represents: Application finished startup

-->Keep Container Running: sleep 3600 [Otherwise container would exit immediately.]

-->Understand the Startup Probe
<img width="253" height="392" alt="image" src="https://github.com/user-attachments/assets/c1f105b8-f79d-400f-89a0-9918478fbefc" />

-->Calculate the Startup Budget: 
<img width="386" height="391" alt="image" src="https://github.com/user-attachments/assets/b8a8469e-428a-4d4d-8e75-5e2e3368735c" />

-->Apply the Manifest: kubectl apply -f startup-probe.yaml

-->Watch the Pod: kubectl get pods -w

-->Wait ~20 Seconds: /tmp/started the startup probe succeeds, Now Kubernetes says: Startup complete, At this moment: startup probe stops running, liveness probe becomes active, readiness probe would become active (if present) & Pod becomes: 1/1 Running
<img width="526" height="530" alt="image" src="https://github.com/user-attachments/assets/7071678c-8a54-428b-a78a-25958e1733ea" />

--> Verify Startup Probe Events: kubectl describe pod startup-demo [So here Look at Events section Initially you may see: Startup probe failed for the first few checks. That is expected because: /tmp/started does not exist yet. After 20 seconds: probe succeeds. Container is NOT restarted because failures stayed within the allowed budget.

**Why Startup Probes Exist** Without startup probes: liveness probe starts immediately, slow apps appear "dead", Kubernetes restarts them repeatedly This creates: CrashLoopBackOff even though the app is healthy but slow.
Startup probes prevent this.

**Note:** A startup probe is used for slow-starting applications. While the startup probe is running, Kubernetes disables liveness and readiness probes. If the startup probe succeeds, normal probes begin. If failureThreshold is too low, Kubernetes may restart the container before startup completes, causing restart loops or CrashLoopBackOff.

**Verify:** What would happen if `failureThreshold` were 2 instead of 12?
-->If failureThreshold were 2 instead of 12, Kubernetes would give the container only 10 seconds to start because the startup probe runs every 5 seconds. However, the application needs 20 seconds to finish startup and create the /tmp/started file. Since the file would still not exist after 10 seconds, the startup probe would fail twice, Kubernetes would think the container failed to start, and it would restart the container. After restarting, the 20-second startup process begins again from the beginning, causing the container to restart repeatedly and eventually enter CrashLoopBackOff.

<img width="1260" height="407" alt="image" src="https://github.com/user-attachments/assets/6a72c960-10d2-486c-bddc-12e280cc399f" />
  
---

### Task 7: Clean Up
Delete all pods and services you created.
<img width="1067" height="477" alt="image" src="https://github.com/user-attachments/assets/5a9a2ec2-2671-4282-9037-3d2cc8b44dc9" />

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
