
# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)

## Task
Yesterday you set resource requests and limits. Today you put that to work. Install the Metrics Server so Kubernetes can see actual resource usage, then set up a Horizontal Pod Autoscaler that scales your app up under load and back down when things calm down.

---

## Expected Output
- Metrics Server installed and `kubectl top` returning data
- An HPA that auto-scales pods under load
- A markdown file: `day-58-metrics-hpa.md`

---

## Challenge Tasks

### Task 1: Install the Metrics Server
1. Check if it is already running: `kubectl get pods -n kube-system | grep metrics-server`
2. If not, install it:
   - Minikube: `minikube addons enable metrics-server`
   - Kind/kubeadm: apply the official manifest from the metrics-server GitHub releases
3. On local clusters, you may need the `--kubelet-insecure-tls` flag (never in production)
4. Wait 60 seconds, then verify: `kubectl top nodes` and `kubectl top pods -A`

**Steps to follow:**

Step 1: Check if Metrics Server is already installed: kubectl get pods -n kube-system | grep metrics-server

Step 2: Install Metrics Server If using Minikube: minikube addons enable metrics-server

-->If using Kind / kubeadm: kubectl kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

-->Step 3: Add --kubelet-insecure-tls (Only for Local Clusters): Use this only for local development (Kind, Minikube, kubeadm lab). Do NOT use it in production. 

**Note:** Metrics Server may fail due to TLS verification in local setups, For that we need to Edit the deployment, We need to add below line of code,

-->Edit the deployment: kubectl edit deployment metrics-server -n kube-system

-->Following line of code is critical: - --kubelet-insecure-tls

<img width="665" height="557" alt="image" src="https://github.com/user-attachments/assets/db5caa29-f95a-4917-81a6-99669a745646" />

Step 4: Wait for the Pod: kubectl get pods -n kube-system

Step 5: Verify Metrics Server: 

-->Check node metrics: kubectl top nodes

-->Check pod metrics: kubectl top pods -A

**Note:** Running = container started, 0/1 = readiness probe failing, Adding --kubelet-insecure-tls fixes communication → pod becomes ready 

Troubleshooting:

<img width="722" height="406" alt="image" src="https://github.com/user-attachments/assets/12c787d3-9458-404f-8deb-3170534f69ae" />

<img width="1912" height="862" alt="image" src="https://github.com/user-attachments/assets/60cc72d0-dec6-4197-9545-4b48a5eecb79" />
<img width="1912" height="770" alt="image" src="https://github.com/user-attachments/assets/f8a3d196-8f58-467e-941b-8fe6590aaf78" />

-->First, you begin by checking whether the Metrics Server is already running in your cluster. You do this by listing the pods in the kube-system namespace and filtering for “metrics-server.” If you see a running pod, it means the service is already installed, and you can move directly to verification. If nothing appears, it simply means you need to install it.

-->Next, you install the Metrics Server depending on your environment. In a Minikube setup, this is very straightforward—you just enable it as an addon. In other environments like Kind or kubeadm, you apply the official Kubernetes manifest, which creates all the required resources such as the deployment, service, roles, and API service. The output you saw with multiple “created” messages confirms that this step completed successfully.

-->After installation, in local clusters, there is a common issue where the Metrics Server cannot securely communicate with the kubelet due to TLS certificate verification. To resolve this, you edit the Metrics Server deployment and add the --kubelet-insecure-tls flag. This allows it to bypass strict certificate checks (which is acceptable only in local or learning environments, not in production).

-->Once that is done, you wait for about a minute to allow Kubernetes to restart the Metrics Server pod and make it fully ready. During this time, the pod may show 0/1 Running, which means it has started but is not yet ready. After the fix, it should change to 1/1 Running, indicating it is fully operational.

-->Finally, you verify that everything is working by running kubectl top nodes and kubectl top pods -A. These commands display real-time CPU and memory usage for nodes and pods. If you see actual values instead of errors, it confirms that the Metrics Server is working correctly. The CPU and memory numbers shown in kubectl top nodes are the final answer to the verification part of the task.

---

### Task 2: Explore kubectl top
1. Run `kubectl top nodes`, `kubectl top pods -A`, `kubectl top pods -A --sort-by=cpu`
2. `kubectl top` shows real-time usage, not requests or limits — these are different things
3. Data comes from the Metrics Server, which polls kubelets every 15 seconds

**Steps to follow:**

Step 1: View Node Resource Usage: kubectl top nodes

**Understanding the output:**
- CPU(cores): Current CPU usage (m = millicores; 1000m = 1 CPU)
- CPU%: Percentage of CPU currently in use.
- MEMORY(bytes): Current RAM usage.
- MEMORY%: Percentage of node memory currently in use.

Step 2: View Resource Usage of All Pods: kubectl top pods -A

Understanding the output
- NAMESPACE: Namespace where the pod is running.
- NAME: Pod name.
- CPU(cores): Current CPU usage.
- MEMORY(bytes): Current memory usage.

Step 3: Sort Pods by CPU Usage: kubectl top pods -A --sort-by=cpu [Note: This helps identify which pods are consuming the most CPU.]

-->We can also sort by memory: kubectl top pods -A --sort-by=memory

<img width="1522" height="857" alt="image" src="https://github.com/user-attachments/assets/24bcb250-ee00-49b9-8312-67ca6885db96" />

Important Concepts:

1. kubectl top shows real-time usage:
<img width="657" height="177" alt="image" src="https://github.com/user-attachments/assets/ed14c161-91d7-409c-85af-50b6aea60827" />

2. It does NOT show Requests or Limits: kubectl top reports actual usage, not the resource values configured in the pod spec.
<img width="681" height="566" alt="image" src="https://github.com/user-attachments/assets/d01b0013-9b8d-465d-8299-d85e75739c3b" />

3. Where does the data come from?:

-->The Metrics Server:
- Collects CPU and memory metrics from each node's kubelet.
- Polls the kubelets approximately every 15 seconds.
- Provides this data to the Kubernetes Metrics API.
- kubectl top retrieves and displays these metrics.
<img width="641" height="332" alt="image" src="https://github.com/user-attachments/assets/3013705b-4751-4086-909f-17aa6a7b5209" />

**Key Takeaways:**
- kubectl top nodes → Shows current CPU and memory usage for each node.
- kubectl top pods -A → Shows current CPU and memory usage for all pods across namespaces.
- kubectl top pods -A --sort-by=cpu → Helps identify CPU-intensive pods.
- kubectl top reports live usage, not configured requests or limits.
- Metrics are collected by the Metrics Server, which polls kubelets roughly every 15 seconds.

---

### Task 3: Create a Deployment with CPU Requests
1. Write a Deployment manifest using the `registry.k8s.io/hpa-example` image (a CPU-intensive PHP-Apache server)
2. Set `resources.requests.cpu: 200m` — HPA needs this to calculate utilization percentages
3. Expose it as a Service: `kubectl expose deployment php-apache --port=80`

**Steps to follow:**

Step 1: Create the Deployment Manifest: vi php-apache.yaml 
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
```
<img width="701" height="320" alt="image" src="https://github.com/user-attachments/assets/fde8a25c-643b-4867-8927-25e2822e026f" />

Step 2: Apply the Deployment: kubectl apply -f php-apache.yaml

-->kubectl get pods

Step 3: Verify the Deployment: kubectl get deployment

Step 4: Expose the Deployment as a Service: kubectl expose deployment php-apache --port=80 [This creates a ClusterIP Service named php-apache.]

Step 5: Verify the Service: kubectl get svc

Step 6: Verify the CPU Request: kubectl describe pod <pod-name>

-->Alternatively, check the deployment YAML: kubectl get deployment php-apache -o yaml

<img width="1812" height="442" alt="image" src="https://github.com/user-attachments/assets/9bab903c-7467-4284-b30d-38a14df28a48" />
<img width="1477" height="975" alt="image" src="https://github.com/user-attachments/assets/2f3825cb-d13d-4f05-86bb-9f0b31176678" />
<img width="1915" height="971" alt="image" src="https://github.com/user-attachments/assets/bd599a8b-4022-4fc3-9bfa-bc5ce5aa59a6" />
<img width="1890" height="402" alt="image" src="https://github.com/user-attachments/assets/4610b985-22a1-4d84-930a-c2d2041cb2ca" />

**Verify:** What is the current CPU usage of the Pod?
<img width="1342" height="347" alt="image" src="https://github.com/user-attachments/assets/15b1c88a-df0a-4526-a048-3b452c969841" />

**Here:**
- CPU(cores): 3m means the pod is currently using 3 millicores (0.003 CPU cores).
- MEMORY(bytes): 18Mi means the pod is currently using 18 MiB of memory.

-->When the php-apache application is idle, you'll usually see a low CPU usage (for example, 1m–10m). In the next HPA task, after generating load, you'll notice the CPU usage increase, which is what the Horizontal Pod Autoscaler uses to decide when to add more replicas.

---

### Task 4: Create an HPA (Imperative)
1. Run: `kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10`
2. Check: `kubectl get hpa` and `kubectl describe hpa php-apache`
3. TARGETS may show `<unknown>` initially — wait 30 seconds for metrics to arrive

**Steps to follow:**

Step 1: Create the Horizontal Pod Autoscaler (HPA): kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

**What this command does:**
- --cpu-percent=50 → Target average CPU utilization is 50% of the CPU request.
- --min=1 → Always keep at least 1 pod running.
- --max=10 → Scale up to a maximum of 10 pods if needed.

Step 2: Verify the HPA: kubectl get hpa

-->Initially, the TARGETS column may show: <unknown>/50% This is normal because the Metrics Server may not have collected metrics yet.

Step 3: Wait for Metrics: kubectl get hpa

-->Detailed view: kubectl describe hpa php-apache
<img width="1917" height="765" alt="image" src="https://github.com/user-attachments/assets/09741489-de0e-4efa-b7d2-6c362a60fbd5" />

This scales up when average CPU exceeds 50% of requests, and down when it drops below.
<img width="236" height="137" alt="image" src="https://github.com/user-attachments/assets/7e3b0a15-dbc0-4b9a-8404-472c111ce669" />

**Verify:** What does the TARGETS column show?
-->In the target column Current cpu usage is for example 20%, And traget is set to 50%, So here usage is within limit
-->Another example where usage is high: 80%/50% → usage is high → HPA will scale up

---

### Task 5: Generate Load and Watch Autoscaling
1. Start a load generator: `kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"`
2. Watch HPA: `kubectl get hpa php-apache --watch`
3. Over 1-3 minutes, CPU climbs above 50%, replicas increase, CPU stabilizes
4. Stop the load: `kubectl delete pod load-generator`
5. Scale-down is slow (5-minute stabilization window) — you do not need to wait

**Steps to follow:**

-->Start the load generator, It Continuously sends requests to your php-apache Service: kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"

-->Watch HPA in real time: kubectl get hpa php-apache --watch

-->Observe scaling[1 to 3 minute]: Load increases CPU usage, When CPU > 50% → HPA scales up, Replicas increase gradually (1 → 2 → 3 → …), Eventually CPU stabilizes near 50% 

-->Watch pods scaling: kubectl get pods -w    [You’ll see new pods being created]

-->Stop the load: kubectl delete pod load-generator

-->Scale-down behavior: So here Pods won’t immediately reduce, Kubernetes waits ~5 minutes (stabilization window), This avoids rapid up/down scaling (thrashing) etc.

<img width="1900" height="977" alt="image" src="https://github.com/user-attachments/assets/62465e97-367a-4487-a500-4917e4397b14" />
<img width="1917" height="612" alt="image" src="https://github.com/user-attachments/assets/08acedab-e061-4653-bcfb-13df1f14061c" />


**Verify:** How many replicas did HPA scale to under load?
<img width="1451" height="112" alt="image" src="https://github.com/user-attachments/assets/74f671a4-7e7a-4e4f-a628-b206d91d67d3" />

---

### Task 6: Create an HPA from YAML (Declarative)
1. Delete the imperative HPA: `kubectl delete hpa php-apache`
2. Write an HPA manifest using `autoscaling/v2` API with CPU target at 50% utilization
3. Add a `behavior` section to control scale-up speed (no stabilization) and scale-down speed (300 second window)
4. Apply and verify with `kubectl describe hpa`

**Steps to follow:**

-->Delete the old (imperative) HPA: kubectl delete hpa php-apache     [This ensures you don’t have conflicting configurations]

-->Create HPA YAML manifest: vi hpa.yml       [hpa.yaml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-58/k8s-manifest-file/hpa.yaml)

-->kubectl apply -f hpa.yml

-->Verify configuration: kubectl describe hpa php-apache     [Here Look for Metrics (CPU 50%) & Behavior section (scaleUp / scaleDown rules)]

<img width="1192" height="292" alt="image" src="https://github.com/user-attachments/assets/a69c0345-444e-4839-b81c-824c5a26b9ee" />

`autoscaling/v2` supports multiple metrics and fine-grained scaling behavior that the imperative command cannot configure.

**Verify:** What does the `behavior` section control?

-->The behavior section controls how quickly HPA scales up or down.

**More specifically:**

-->scaleUp → how aggressively pods are added when load increases

-->scaleDown → how slowly pods are removed when load decreases

-->stabilizationWindowSeconds → delay to prevent rapid fluctuations

-->policies → limits on how many pods can be added/removed per time

**Note:** Without behavior → default scaling rules & With behavior → you control speed + stability of scaling



---

### Task 7: Clean Up
Delete the HPA, Service, Deployment, and load-generator pod. Leave the Metrics Server installed.

**Steps to follow:**

-->kubectl get hpa php-apache

-->kubectl delete hpa php-apache

-->kubectl get svc php-apache

-->kubectl delete svc php-apache

-->kubectl get deployment

-->kubectl delete deployment php-apache

-->kubectl delete pod load-generator

-->kubectl get pods

-->kubectl get all

-->kubectl get pods -n kube-system | grep metrics-serve
<img width="1416" height="517" alt="image" src="https://github.com/user-attachments/assets/5dcde24a-264d-4d7e-98e9-c29e0b9ca7c9" />

---

## Hints
- HPA requires `resources.requests` — without them TARGETS shows `<unknown>`
- `kubectl top` = actual usage. `kubectl describe pod` = configured requests/limits
- HPA checks every 15 seconds. Scale-up is fast, scale-down has a 5-minute stabilization window
- `autoscaling/v1` = CPU only. `autoscaling/v2` = CPU + memory + custom metrics
- Formula: `desiredReplicas = ceil(currentReplicas * (currentUsage / targetUsage))`
- HPA works with Deployments, StatefulSets, and ReplicaSets

---

## Documentation
Create `day-58-metrics-hpa.md` with:
- What the Metrics Server is and why HPA needs it
- How HPA calculates desired replicas
- The difference between `autoscaling/v1` and `v2`
- Screenshots of `kubectl top`, HPA events, and pod scaling

---

## Submission
1. Add `day-58-metrics-hpa.md` to `2026/day-58/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Set up Kubernetes HPA today. Watched my app auto-scale from 1 to multiple replicas under load, then scale back down. This is how production handles variable traffic."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
