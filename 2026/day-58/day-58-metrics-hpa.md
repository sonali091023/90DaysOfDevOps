
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

-->Check if Metrics Server is already running: kubectl get pods -n kube-system | grep metrics-server

-->Install Metrics Server If using Minikube: minikube addons enable metrics-server

-->If using Kind / kubeadm: kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

-->Fix TLS issue (only for local clusters): 

**Note:** Metrics Server may fail due to TLS verification in local setups, For that we need to Edit the deployment, We need to add below line of code,
<img width="386" height="191" alt="image" src="https://github.com/user-attachments/assets/49a4ef8d-b679-485a-8f5f-9c751996173f" />

-->Following line of code is critical: - --kubelet-insecure-tls

-->Save this chnages and exit from the file & Kubernetes will automatically restart the pod.

-->Wait and check again after some time: kubectl get pods -n kube-system | grep metrics-server

-->Now Verify metrics check the node usage: kubectl top nodes 

-->Now Verify metrics check the pod usage: kubectl top pods -A 

<img width="1907" height="862" alt="image" src="https://github.com/user-attachments/assets/81bde262-bbfb-4191-ac3f-603c4e315319" />
<img width="1910" height="866" alt="image" src="https://github.com/user-attachments/assets/03271269-6c9b-4e10-85c8-28eeac8338fc" />


**Note:** Running = container started, 0/1 = readiness probe failing, Adding --kubelet-insecure-tls fixes communication → pod becomes ready 

-->First, you begin by checking whether the Metrics Server is already running in your cluster. You do this by listing the pods in the kube-system namespace and filtering for “metrics-server.” If you see a running pod, it means the service is already installed, and you can move directly to verification. If nothing appears, it simply means you need to install it.

-->Next, you install the Metrics Server depending on your environment. In a Minikube setup, this is very straightforward—you just enable it as an addon. In other environments like Kind or kubeadm, you apply the official Kubernetes manifest, which creates all the required resources such as the deployment, service, roles, and API service. The output you saw with multiple “created” messages confirms that this step completed successfully.

-->After installation, in local clusters, there is a common issue where the Metrics Server cannot securely communicate with the kubelet due to TLS certificate verification. To resolve this, you edit the Metrics Server deployment and add the --kubelet-insecure-tls flag. This allows it to bypass strict certificate checks (which is acceptable only in local or learning environments, not in production).

-->Once that is done, you wait for about a minute to allow Kubernetes to restart the Metrics Server pod and make it fully ready. During this time, the pod may show 0/1 Running, which means it has started but is not yet ready. After the fix, it should change to 1/1 Running, indicating it is fully operational.

-->Finally, you verify that everything is working by running kubectl top nodes and kubectl top pods -A. These commands display real-time CPU and memory usage for nodes and pods. If you see actual values instead of errors, it confirms that the Metrics Server is working correctly. The CPU and memory numbers shown in kubectl top nodes are the final answer to the verification part of the task.

**Verify:** What is the current CPU and memory usage of your node?
<img width="1262" height="111" alt="image" src="https://github.com/user-attachments/assets/ee244bef-e1c8-4e8c-baf3-48ff4cb11eaf" />

---

### Task 2: Explore kubectl top
1. Run `kubectl top nodes`, `kubectl top pods -A`, `kubectl top pods -A --sort-by=cpu`
2. `kubectl top` shows real-time usage, not requests or limits — these are different things
3. Data comes from the Metrics Server, which polls kubelets every 15 seconds

**Steps to follow:**

-->First, now that your Metrics Server is working, you can start exploring how to monitor resource usage using kubectl top. You begin by running kubectl top nodes, which shows CPU and memory usage of each node in your cluster. This gives you a high-level view of how heavily your cluster is being utilized.

-->Check node resource usage: kubectl top nodes  [Note: This shows CPU and memory usage of your cluster node(s)]

-->Next, you run kubectl top pods -A, where -A means “all namespaces.” This command shows resource usage for every pod running in the cluster. You’ll see CPU usage (in millicores like 50m) and memory usage (in Mi or Gi). This helps you understand which applications are consuming resources.

-->Check all pod usage: kubectl top pods -A      [Note: This lists CPU and memory usage for all pods across all namespaces]

-->Then, to make analysis easier, you run kubectl top pods -A --sort-by=cpu. This sorts all pods by CPU usage, from highest to lowest. Instead of scanning manually, this immediately shows you the most CPU-consuming pod at the top of the list.

-->Find highest CPU-consuming pod: kubectl top pods -A --sort-by=cpu   [Note: This sorts pods by CPU usage (highest at top)]

-->It’s important to understand that kubectl top shows real-time usage, not what you configured in your manifests (requests and limits). Requests/limits are what you allocate, while kubectl top shows what is actually being used. The data you see comes from the Metrics Server, which collects metrics from kubelets approximately every 15 seconds, so values may slightly change each time you run the command.

-->Verify the metrics server is working fine or not: kubectl get pods -n kube-system | grep metrics-server

**Verify:** Which pod is using the most CPU right now?

-->Following pod "kube-apiserver-devops-cluster-control-plane" is using most of the cpu.
<img width="1707" height="707" alt="image" src="https://github.com/user-attachments/assets/4111db0a-3190-4722-969b-a33688f9477d" />

---

### Task 3: Create a Deployment with CPU Requests
1. Write a Deployment manifest using the `registry.k8s.io/hpa-example` image (a CPU-intensive PHP-Apache server)
2. Set `resources.requests.cpu: 200m` — HPA needs this to calculate utilization percentages
3. Expose it as a Service: `kubectl expose deployment php-apache --port=80`

**Steps to follow:**

-->Create the Deployment manifest: vi php-apache.yaml [php-apache.yaml](https://github.com/sonali091023/90DaysOfDevOps/blob/main/2026/day-58/k8s-manifest-file/php-apache.yaml)

-->Apply the Deployment: kubectl apply -f php-apache.yaml

-->kubectl get pods

-->Expose it as a Service: kubectl expose deployment php-apache --port=80

-->Check the service: kubectl get svc

-->Check CPU usage: kubectl top pods

-->Ensure Metrics Server is running: kubectl get pods -n kube-system | grep metrics-server

<img width="1702" height="632" alt="image" src="https://github.com/user-attachments/assets/5eab9bbf-15aa-495f-a2e5-b1eecfbae8ad" />

Without CPU requests, HPA cannot work — this is the most common HPA setup mistake.

**Verify:** What is the current CPU usage of the Pod?
<img width="1235" height="71" alt="image" src="https://github.com/user-attachments/assets/84af1470-0e6f-4fe9-8b56-7559bb34d3d0" />

---

### Task 4: Create an HPA (Imperative)
1. Run: `kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10`
2. Check: `kubectl get hpa` and `kubectl describe hpa php-apache`
3. TARGETS may show `<unknown>` initially — wait 30 seconds for metrics to arrive

**Steps to follow:**

-->Create HPA: kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

-->Check HPA status: kubectl get hpa

-->Wait for metrics

-->Check HPA status again: kubectl get hpa

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
