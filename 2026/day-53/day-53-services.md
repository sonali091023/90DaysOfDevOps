# Day 53 – Kubernetes Services

## Task
You have Deployments running multiple Pods, but how do you actually talk to them? Pods get random IP addresses that change every time they restart. Services solve this by giving your Pods a stable network endpoint. Today you will create different types of Services and understand when to use each one.

---

## Expected Output
- A Deployment exposed using ClusterIP, NodePort, and LoadBalancer services
- Verified Pod-to-Service communication from inside the cluster
- A markdown file: `day-53-services.md`
- Screenshot of `kubectl get services` showing your running services

---

## Why Services?

Every Pod gets its own IP address. But there are two problems:
1. Pod IPs are **not stable** — when a Pod restarts or gets replaced, it gets a new IP
2. A Deployment runs **multiple Pods** — which IP do you connect to?

A Service solves both problems. It provides:
- A **stable IP and DNS name** that never changes
- **Load balancing** across all Pods that match its selector

```
[Client] --> [Service (stable IP)] --> [Pod 1]
                                   --> [Pod 2]
                                   --> [Pod 3]
```

## Challenge Tasks

### Task 1: Deploy the Application
First, create a Deployment that you will expose with Services. Create `app-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f app-deployment.yaml
kubectl get pods -o wide
```

Note the individual Pod IPs. These will change if pods restart — that is the problem Services fix.

**Verify:** Are all 3 pods running? Note down their IP addresses.

**Steps to follow:**

-->Great! This task introduces one of the most important Kubernetes concepts: Deployments. A Deployment manages Pods for you, ensuring the desired number of replicas are always running.

Step 1: Check Your Cluster: Before creating anything, make sure your Kubernetes cluster is running: kubectl cluster-info

-->Now check existing resources: kubectl get nodes [Expected: The node should be in the Ready state.]

Step 2: Create the Deployment YAML: nano app-deployment.yaml [Here in this file add above given code]

Step 3: Understand the YAML: 

<img width="590" height="851" alt="image" src="https://github.com/user-attachments/assets/a0f06420-aaee-4e04-b44d-98913832650f" />

<img width="567" height="797" alt="image" src="https://github.com/user-attachments/assets/b630d84a-46e6-41cb-9b07-6e848cf920ca" />

<img width="607" height="701" alt="image" src="https://github.com/user-attachments/assets/8e07a225-0c3c-48ea-9bbb-0fb5d53c82d6" />

Step 4: Apply the Deployment: kubectl apply -f app-deployment.yaml

Step 5: Check the Deployment: kubectl get deployments

**Meaning:**
- READY → 3 Pods are ready
- UP-TO-DATE → Latest version is running
- AVAILABLE → All Pods are available

Step 6: View the ReplicaSet: Deployments create ReplicaSets, which in turn create Pods: kubectl get replicasets

Step 7: View the Pods: kubectl get pods

**Notice:**
- Three different Pod names
- Same Deployment
- All are running

Step 8: Get Pod IP Addresses: kubectl get pods -o wide

-->Here imp column is The important column is: IP 

**Why These IPs Are a Problem:**

<img width="772" height="615" alt="image" src="https://github.com/user-attachments/assets/5617290d-a613-444c-9bde-b07003670942" />

Step 9: Verify the Deployment: Check the status: kubectl get deployment web-app

-->We can also list only the Pods created by this Deployment using the label selector: kubectl get pods -l app=web-app

<img width="1787" height="747" alt="image" src="https://github.com/user-attachments/assets/5a2d759d-fcd2-4ddf-a420-92dc606a1939" />

---

### Task 2: ClusterIP Service (Internal Access)
ClusterIP is the default Service type. It gives your Pods a stable internal IP that is only reachable from within the cluster.

Create `clusterip-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

Key fields:
- `selector.app: web-app` — this Service routes traffic to all Pods with the label `app: web-app`
- `port: 80` — the port the Service listens on
- `targetPort: 80` — the port on the Pod to forward traffic to

```bash
kubectl apply -f clusterip-service.yaml
kubectl get services
```
You should see `web-app-clusterip` with a CLUSTER-IP address. This IP is stable — it will not change even if Pods restart.

Now test it from inside the cluster:
```bash
# Run a temporary pod to test connectivity
kubectl run test-client --image=busybox:latest --rm -it --restart=Never -- sh

# Inside the test pod, run:
wget -qO- http://web-app-clusterip
exit
```

You should see the Nginx welcome page. The Service load-balanced your request to one of the 3 Pods.

**Verify:** Does the Service respond? Try running the wget command multiple times — the Service distributes traffic across all healthy Pods.

**Steps to follow:**

-->Excellent! This task introduces Services, which solve the problem of changing Pod IP addresses by providing a stable network endpoint. Let's walk through it step by step.

Q. What is a ClusterIP Service?

-->A ClusterIP Service is the default Service type in Kubernetes. So Instead of connecting directly to a Pod (whose IP may change), applications connect to the Service, which forwards requests to healthy Pods.
<img width="606" height="277" alt="image" src="https://github.com/user-attachments/assets/635b7a2c-3169-4740-a801-407150520e05" />

Step 1: Verify the Deployment Exists: Make sure your Deployment from Task 1 is still running: kubectl get deployments

-->Also check the pods: kubectl get pods

Step 2: Create the Service YAML: vi clusterip-service.yaml [Here in this file add above mention code]

Step 3: Understand the YAML: 

<img width="577" height="846" alt="image" src="https://github.com/user-attachments/assets/612afe48-54ef-467b-af51-928420f2e30e" />

<img width="581" height="526" alt="image" src="https://github.com/user-attachments/assets/19e5ec05-4aa9-4328-acdb-74e182bbfbc1" />

<img width="617" height="390" alt="image" src="https://github.com/user-attachments/assets/f9f52cdf-d010-42f1-9ea5-21867a481e8c" />

Step 4: Apply the Service: kubectl apply -f clusterip-service.yaml

Step 5: Verify the Service: kubectl get services

**Notice:**
- TYPE is ClusterIP
- CLUSTER-IP is assigned automatically
- EXTERNAL-IP is <none>, because it's only accessible inside the cluster

Step 6: Inspect the Service: kubectl describe service web-app-clusterip

**Look for:**
- Selector: app=web-app
- Port:     80/TCP
- Endpoints: 10.244.0.5:80,10.244.0.6:80,10.244.0.7:80

-->The Endpoints show the Pod IPs behind the Service.

Step 7: Test from Inside the Cluster: Since a ClusterIP isn't reachable from outside the cluster, create a temporary Pod:

-->kubectl run test-client --image=busybox:latest --rm -it --restart=Never -- sh [Expected: we are inside container]

Step 8: Access the Service: Inside container run command: wget -qO- http://web-app-clusterip

<img width="622" height="451" alt="image" src="https://github.com/user-attachments/assets/e108df80-c9ee-46d1-a104-ae3c4928e53c" />

Step 9: Verify the Endpoints: kubectl get endpoints OR kubectl get endpoints web-app-clusterip

-->This confirms which Pods are currently receiving traffic.

<img width="1847" height="781" alt="image" src="https://github.com/user-attachments/assets/da91a286-925d-4331-a763-526b430cb3e5" />

<img width="1852" height="857" alt="image" src="https://github.com/user-attachments/assets/06954aaf-1d74-4706-a353-9b7a73d8e796" />

**How Load Balancing Works:**

<img width="692" height="747" alt="image" src="https://github.com/user-attachments/assets/b9df114a-1383-4c6e-b1db-757b93fe8081" />

**Why You May Not Notice Load Balancing Yet**

-->The default Nginx page looks identical on every Pod, so repeated wget commands all return the same HTML. That doesn't mean load balancing isn't happening—it just means every Pod serves identical content. To clearly observe load balancing, each Pod would need to return something unique.

---

### Task 3: Discover Services with DNS

**Note:** Kubernetes runs CoreDNS (inside kube-system), CoreDNS watches Services, When a Service is created → DNS record is added automatically

Kubernetes has a built-in DNS server. Every Service gets a DNS entry automatically, You can see below is the **DNS format**:

```
<service-name>.<namespace>.svc.cluster.local
```
**Example:** **web-app-clusterip.default.svc.cluster.local** But usually you just use, **web-app-clusterip**

**Note:** DNS concept in the service object is necessary because, No need to remember IPs (they can change), Stable communication between services & Makes microservices architecture easy.

**Example flow:** Pod sends request [wget web-app-clusterip] --> DNS[CoreDNS] resolves service name to ClusterIP --> Service uses kube-proxy to route traffic to one of the Pods, providing load balancing.

Test this:
```bash
kubectl run dns-test --image=busybox:latest --rm -it --restart=Never -- sh

# Inside the pod:
# Short name (works within the same namespace)
wget -qO- http://web-app-clusterip

# Full DNS name
wget -qO- http://web-app-clusterip.default.svc.cluster.local

# Look up the DNS entry
nslookup web-app-clusterip
exit
```

Both the short name and the full DNS name resolve to the same ClusterIP. In practice, you use the short name when communicating within the same namespace and the full name when reaching across namespaces.

**Verify:** What IP does `nslookup` return? Does it match the CLUSTER-IP from `kubectl get services`?

**Steps to follow:**

-->Excellent! This task teaches one of Kubernetes' most useful features: Service Discovery using DNS. Instead of remembering IP addresses, applications communicate using Service names.

**Q. Why Do We Need Kubernetes DNS?**

<img width="727" height="412" alt="image" src="https://github.com/user-attachments/assets/16954c87-27eb-4847-8ecf-155cebb0634b" />

Step 1: Verify the Service Exists: Before testing DNS, confirm the Service is present: kubectl get services

**Note:** the CLUSTER-IP (for example, 10.96.120.15). You'll compare it later with the DNS lookup.

Step 2: Start a Temporary Test Pod: kubectl run dns-test --image=busybox:latest --rm -it --restart=Never -- sh [Expected: We will be inside container]

-->Now you're running commands inside the Kubernetes cluster.

Step 3: Test the Short Service Name: Now run this command inside container: wget -qO- http://web-app-clusterip

<img width="677" height="487" alt="image" src="https://github.com/user-attachments/assets/575f2388-a4c5-47f7-804e-6736e2b22295" />

Step 4: Test the Full DNS Name: wget -qO- http://web-app-clusterip.default.svc.cluster.local

<img width="727" height="716" alt="image" src="https://github.com/user-attachments/assets/b7c9610b-9d01-498b-a220-bce696fbc3d5" />

Step 5: Perform a DNS Lookup: nslookup web-app-clusterip

<img width="727" height="497" alt="image" src="https://github.com/user-attachments/assets/c0fa0034-76fd-41ef-b5ea-f5bf615ed4fd" />

<img width="1855" height="957" alt="image" src="https://github.com/user-attachments/assets/ff7ab2e5-6a5c-438e-969a-73006aa757f2" />

<img width="1667" height="577" alt="image" src="https://github.com/user-attachments/assets/8218bccb-f3e8-48bf-9c46-8b91301b5cda" />

Step 6: Compare with the Service: Open another terminal (or exit the BusyBox Pod first) and run: kubectl get services

<img width="705" height="532" alt="image" src="https://github.com/user-attachments/assets/eb531606-c48c-4296-8924-3d60191b7bc3" />

<img width="1815" height="512" alt="image" src="https://github.com/user-attachments/assets/060daae4-29c9-4cc7-a786-465713c04673" />

<img width="1392" height="341" alt="t3i11" src="https://github.com/user-attachments/assets/9f0f6e59-e00d-4eb0-8074-0bf7d70b2d7b" />

**DNS Name Hierarchy:** 

<img width="712" height="337" alt="image" src="https://github.com/user-attachments/assets/de15784a-0ba4-40e8-8ed8-114705a45f25" />

**Short Name vs Full Name:**

<img width="752" height="362" alt="image" src="https://github.com/user-attachments/assets/4c1ad79c-6592-46fc-83b4-c47e3b8bd26b" />

-->Exit the Test Pod: exit [Expected: The BusyBox Pod is automatically deleted because you started it with --rm.]

Q. What IP does nslookup return? Does it match the CLUSTER-IP from kubectl get services?

A: nslookup returns the ClusterIP assigned to the Service (for example, 10.96.120.15). Yes, it should match the CLUSTER-IP shown by kubectl get services, because Kubernetes DNS resolves the Service name to its stable internal IP.

---

### Task 4: NodePort Service (External Access via Node)
-->A NodePort Service exposes your application on a port on every node in the cluster. This lets you access the Service from outside the cluster.

Create `nodeport-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-nodeport        #Name of the Service Used for DNS
spec:
  type: NodePort                #Exposes your app outside the cluster, Opens a port on every Node
  selector:
    app: web-app                #Targets Pods with label, Service will send traffic only to these Pods
  ports:
  - port: 80                    #Service’s internal port (ClusterIP access)
    targetPort: 80              #Port no of the Pod container
    nodePort: 30080             #Port exposed on each Node (external access)
```

- `nodePort: 30080` — the port opened on every node (must be in range 30000-32767)
- Traffic flow: `<NodeIP>:30080` -> Service -> Pod:80
- port: 80
Service’s internal port (ClusterIP access)
targetPort: 80
Port on the Pod container

**Note:** NodePort range: 30000–32767, Works even if Pod IPs change, Good for testing, not ideal for production (use LoadBalancer/Ingress)

```bash
kubectl apply -f nodeport-service.yaml
kubectl get services
```
--> **How traffic flows:** User-->NodeIP:30080-->Service (port 80)-->Pod (containers port 80), **For example:** http://<NodeIP>:30080 

-->Via labels and selectors concept Service exposes Pods labeled app=web-app on port 80 and makes them accessible externally via NodeIP:30080 using NodePort.

Access the service:
```bash
# If using Minikube
minikube service web-app-nodeport --url

# If using Kind, get the node IP first
kubectl get nodes -o wide
# Then curl <node-internal-ip>:30080

# If using Docker Desktop
curl http://localhost:30080
```

**Verify:** Can you see the Nginx welcome page from your browser or terminal using the NodePort?

**Steps to follow:**

-->Excellent! This task introduces the NodePort Service, which makes your application accessible from outside the Kubernetes cluster.Since you've been using Kind in your previous Kubernetes exercises, I'll focus on the Kind workflow and also explain what to do if NodePort doesn't work immediately.

Q. What is a NodePort Service?

-->A NodePort Service exposes an application on a fixed port on every Kubernetes node. Unlike a ClusterIP Service, a NodePort can be reached from outside the cluster.

<img width="627" height="337" alt="image" src="https://github.com/user-attachments/assets/3e19e6d0-0363-45fe-bb08-348eef869caa" />

Step 1: Create the Service YAML: vi nodeport-service.yaml [Paste the above mentioned code here]

Step 2: Understand the YAML:

<img width="692" height="657" alt="image" src="https://github.com/user-attachments/assets/2b1f7936-accf-4bb1-b76a-24e0486a235f" />

<img width="726" height="762" alt="image" src="https://github.com/user-attachments/assets/e914e11d-2e73-41ce-89cf-a07397f86c63" />

Step 3: Create the Service: kubectl apply -f nodeport-service.yaml

Step 4: Verify the Service: kubectl get services

<img width="712" height="330" alt="image" src="https://github.com/user-attachments/assets/393d06bc-11b1-4c69-80ca-1ac9ff803389" />

Step 5: Verify the Endpoints: kubectl describe svc web-app-nodeport

<img width="697" height="282" alt="image" src="https://github.com/user-attachments/assets/69f05b52-99bf-42da-b6aa-aeb6dbc8c8e0" />

Step 6: Find Your Kubernetes Node: kubectl get nodes -o wide

<img width="676" height="110" alt="image" src="https://github.com/user-attachments/assets/b2ef9a46-f4a0-4110-b6d1-f5f1600e3dc4" />

**Note:** If you're using Kind, you'll often see an internal Docker network IP like 172.x.x.x.

Step 7: Test the NodePort: 

Option 1: If you're using Docker Desktop: curl http://localhost:30080

Option 2: If you're using Minikube: minikube service web-app-nodeport --url

Option 3: If you're using Kind: curl http://<NODE-IP>:30080 Ex: curl http://172.18.0.2:30080 [Expected: If you receive the Nginx welcome page, the Service is working.]

<img width="1762" height="577" alt="image" src="https://github.com/user-attachments/assets/f5ca965b-7d0a-4c1b-a6f2-f24ab09c30dc" />

<img width="1877" height="867" alt="image" src="https://github.com/user-attachments/assets/732fe850-c664-4863-a67e-c1c8adf57e63" />

**Important Note About Kind:** Kind runs Kubernetes nodes as Docker containers. By default, a NodePort inside the Kind node is not automatically exposed to your host machine.

<img width="750" height="281" alt="image" src="https://github.com/user-attachments/assets/302f2b0d-9816-4c58-9fcb-1f98e24c5e47" />

**Check Your Kind Cluster:**

-->kind get clusters

-->docker ps

<img width="697" height="150" alt="image" src="https://github.com/user-attachments/assets/a1edd070-f2a2-4123-af45-e34c8a77eda0" />

**Alternative Test (Works Regardless of Host Port Mapping)**

<img width="711" height="302" alt="image" src="https://github.com/user-attachments/assets/77838dc4-2c24-4101-8bec-a80a1113789b" />

---

### Task 5: LoadBalancer Service (Cloud External Access)
In a cloud environment (AWS, GCP, Azure), a LoadBalancer Service provisions a real external load balancer that routes traffic to your nodes.

Create `loadbalancer-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-loadbalancer
spec:
  type: LoadBalancer
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```

-->By using labels and selectors concept deployment object and service object connects with each other in k8s

```bash
kubectl apply -f loadbalancer-service.yaml
kubectl get services
```
On a local cluster (Minikube, Kind, Docker Desktop), the EXTERNAL-IP will show `<pending>` because there is no cloud provider to create a real load balancer. This is expected.

If you are using Minikube:
```bash
# Minikube can simulate a LoadBalancer
minikube tunnel
# In another terminal, check again:
kubectl get services
```
In a real cloud cluster, the EXTERNAL-IP would be a public IP address or hostname provisioned by the cloud provider.

**Verify:** What does the EXTERNAL-IP column show? Why is it `<pending>` on a local cluster?
-->On a local cluster (Minikube, Kind, Docker Desktop), the EXTERNAL-IP will show `<pending>` because there is no cloud provider to create a real load balancer. This is expected, In a real cloud cluster, the EXTERNAL-IP would be a public IP address or hostname provisioned by the cloud provider.

**Steps to follow:**

-->Great! This task teaches the LoadBalancer Service, which is the standard way to expose applications to the internet in managed Kubernetes services like Amazon EKS, Google GKE, and Azure AKS.

Q. What is a LoadBalancer Service?

-->A LoadBalancer Service builds on top of a NodePort Service. In cloud environments, Kubernetes asks the cloud provider to create a real load balancer.

<img width="647" height="336" alt="image" src="https://github.com/user-attachments/assets/607b3fb2-fab7-48bc-bf2a-e11e6f7efafc" />

Step 1: Create the YAML: vi loadbalancer-service.yaml Here paste the above mentioned line of code in this file

Step 2: Understand the YAML:

<img width="655" height="802" alt="image" src="https://github.com/user-attachments/assets/efbdc7e1-7686-4f06-b9f8-ac32d921fc33" />

Step 3: Apply the Service: kubectl apply -f loadbalancer-service.yaml

Step 4: View the Service: kubectl get services

<img width="692" height="241" alt="image" src="https://github.com/user-attachments/assets/d54794c2-e19c-4188-bf00-75059e02c41c" />

Step 5: Inspect the Service: kubectl describe svc web-app-loadbalancer

**Note:** On a local cluster, the LoadBalancer Ingress field is usually empty because no external load balancer has been created.

Q. Why Is EXTERNAL-IP <pending>?

<img width="696" height="445" alt="image" src="https://github.com/user-attachments/assets/1e459cef-6945-4a61-a33d-55dc0670db4d" />

<img width="1712" height="882" alt="image" src="https://github.com/user-attachments/assets/5cb01782-a839-4e90-a673-47991a03f38f" />

Q. What Happens in Different Environments?

<img width="612" height="302" alt="image" src="https://github.com/user-attachments/assets/5634b342-e7dd-43bd-80de-72502e955d43" />

**Minikube Special Case:**

<img width="687" height="536" alt="image" src="https://github.com/user-attachments/assets/da344310-ac10-4f52-9486-a491c3bd076b" />

**How This Looks in AWS (EKS):**

<img width="651" height="242" alt="image" src="https://github.com/user-attachments/assets/14b6fc2f-2913-4171-ba00-9c1be3e226fb" />

Q: What does the EXTERNAL-IP column show? Why is it <pending> on a local cluster?

-->On a local cluster like Kind, the EXTERNAL-IP column shows <pending>. This is because a LoadBalancer Service requires a cloud provider (such as AWS, GCP, or Azure) to provision an external load balancer. Local Kubernetes clusters do not have built-in cloud integration, so Kubernetes cannot create an external load balancer and leaves the EXTERNAL-IP in the pending state.

---

### Task 6: Understand the Service Types Side by Side
Check all three services:

```bash
kubectl get services -o wide
```
<img width="1408" height="187" alt="image" src="https://github.com/user-attachments/assets/5be83919-d1e1-471d-83f7-e63cb9c22a94" />

Compare them:

| Type | Accessible From | Use Case |
|------|----------------|----------|
| ClusterIP | Inside the cluster only | Internal communication between services |
| NodePort | Outside via `<NodeIP>:<NodePort>` | Development, testing, direct node access |
| LoadBalancer | Outside via cloud load balancer | Production traffic in cloud environments |

Each type builds on the previous one:
- LoadBalancer creates a NodePort, which creates a ClusterIP
- So a LoadBalancer service also has a ClusterIP and a NodePort

Verify this:
```bash
kubectl describe service web-app-loadbalancer
```

<img width="1893" height="566" alt="image" src="https://github.com/user-attachments/assets/863e808c-7703-4ffa-9751-e3a4578137ee" />

You should see all three: a ClusterIP, a NodePort, and the LoadBalancer configuration.

**Verify:** Does the LoadBalancer service also have a ClusterIP and NodePort assigned?
yes, I can see ClusterIP: 10.96.7.142, NodePort: 31813/TCP & type: LoadBalancer, So the conclusion is Loadbalancer has both ClusterIP [internal access] and NodePort [node-level access], So we can say this is expected behavious, A LoadBalancer Service automatically creates a ClusterIP + NodePort under the hood.

**Note:** As we know kind cluster is the node wihch is created inside docker so in case of loadBalancer service we dont have External-IP, So kind does NOT support real cloud LoadBalancers. So in case if wanted to launch the application we need to run URL: localhiost:8080, But before that we need to perform Port-Forwarding: kubectl port-forward service/web-app-loadbalancer 8080:80, then we can launch the web application.

-->Yes, the LoadBalancer service has both a ClusterIP and a NodePort, but in kind it won’t get an external IP.

---

### Task 7: Clean Up
```bash
kubectl delete -f app-deployment.yaml
kubectl delete -f clusterip-service.yaml
kubectl delete -f nodeport-service.yaml
kubectl delete -f loadbalancer-service.yaml

kubectl get pods
kubectl get services
```

Only the built-in `kubernetes` service in the default namespace should remain.

<img width="1487" height="923" alt="image" src="https://github.com/user-attachments/assets/c368cc78-bef0-43a1-94c8-4a68e611a64e" />

**Verify:** Is everything cleaned up?
-->Yes, All the created services such as ClusterIP, NodePort & Loadbalancer all got deleted, And also deployment object is got deleted.

---

## Hints
- `selector` in a Service must match `labels` on the Pods — if they do not match, the Service routes traffic to nothing
- `kubectl get endpoints <service-name>` shows which Pod IPs a Service is currently routing to
- `port` is what the Service listens on; `targetPort` is what the Pod listens on — they do not have to be the same number
- NodePort range is 30000-32767; if you do not specify `nodePort`, Kubernetes picks one automatically
- Use `kubectl describe service <name>` to see the full configuration including Endpoints
- `kubectl get services -o wide` shows the selector each service uses
- To test ClusterIP services, you must test from inside the cluster (use a temporary pod)

---

## Documentation
Create `day-53-services.md` with:
- What problem Services solve and how they relate to Pods and Deployments
- Your three Service manifests with an explanation of each type
- The difference between ClusterIP, NodePort, and LoadBalancer
- How Kubernetes DNS works for service discovery
- What Endpoints are and how to inspect them
- Screenshot of your services and the test output

---

## Submission
1. Add `day-53-services.md` and your YAML files to `2026/day-53/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Learned Kubernetes Services today — ClusterIP for internal traffic, NodePort for node-level access, and LoadBalancer for production. Services give Pods a stable identity and load balancing."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
