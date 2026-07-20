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

<img width="1602" height="232" alt="image" src="https://github.com/user-attachments/assets/4d431c0e-f54f-464c-a8be-758727f93b78" />

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




Step 1: Make sure your Service exists: kubectl get svc



-->wget -qO- http://web-app-clusterip [used short dns name here]
<img width="1918" height="820" alt="image" src="https://github.com/user-attachments/assets/db19a4f6-211e-4169-923e-b8752686cabc" />
-->wget -qO- http://web-app-clusterip.default.svc.cluster.local [used full dns name here]
<img width="957" height="565" alt="image" src="https://github.com/user-attachments/assets/e26122b8-f8dd-4d53-b1f5-83e15fa0404a" />
-->nslookup web-app-clusterip [used short dns name here]
<img width="832" height="512" alt="image" src="https://github.com/user-attachments/assets/148e4692-702e-4900-9a33-0009336c7547" />

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

<img width="1397" height="967" alt="image" src="https://github.com/user-attachments/assets/f05a8fbf-d9de-47a9-8dfe-060f7c958e62" />  
<img width="1543" height="298" alt="image" src="https://github.com/user-attachments/assets/e883bda2-1f86-4832-924d-846a4e0dbc35" />

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

-->Via terminal by using nodeport i can see nginx page like below, **curl 172.19.0.2:30080**
<img width="1918" height="702" alt="image" src="https://github.com/user-attachments/assets/4c4b0b0c-1079-4e53-bfc5-8b2ff120c95d" />

-->But by using, http://<NodeIP>:30080 i cant see the nginx page on the browser, That is because how kind networking works, not your Service, In kind (Kubernetes in Docker) Nodes are Docker containers, So Their “NodeIP” is NOT directly accessible from your host browser due to that it Works inside cluster / terminal & Fails in browser. It works in terminal because, When you tested from inside a Pod Traffic stays inside Docker network so works fine.

-->So to handle this we have best way to use Port-Forwarding like below, here we are using port-forwarding, which creates: Local port (8080) → forwarded to → Service port (80)

**kubectl port-forward service/web-app-nodeport 8080:80**
<img width="1736" height="155" alt="image" src="https://github.com/user-attachments/assets/326e615c-88d4-4392-9279-625d26855cfd" />
-->So once the port forwarding is done we can run the following url in the browser, **http://localhost:8080**
<img width="1911" height="637" alt="image" src="https://github.com/user-attachments/assets/709bb2b2-7bac-4722-b458-cfe3f7aff84d" />

**Note:** Here we are using port 8080 instead of 30080 that is because port 30080 = NodePort (used when accessing via Node IP). OR Use 8080 in the browser because port-forward maps your local port 8080 to the Service port 80.

-->**Now Flow is:** Browser → localhost:8080 → Service (port 80) → Pod

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
<img width="1462" height="857" alt="image" src="https://github.com/user-attachments/assets/6728bc65-0faf-4c73-8859-93c9d49b2626" />


```bash
kubectl apply -f loadbalancer-service.yaml
kubectl get services
```

On a local cluster (Minikube, Kind, Docker Desktop), the EXTERNAL-IP will show `<pending>` because there is no cloud provider to create a real load balancer. This is expected.

<img width="1562" height="366" alt="image" src="https://github.com/user-attachments/assets/5b8f9cc2-49e8-4232-81ca-50ee2113b9f2" />

If you are using Minikube:
```bash
# Minikube can simulate a LoadBalancer
minikube tunnel
# In another terminal, check again:
kubectl get services
```
<img width="1146" height="332" alt="image" src="https://github.com/user-attachments/assets/8cf3b47b-9cd9-446e-a453-6eebcb8f9489" />

In a real cloud cluster, the EXTERNAL-IP would be a public IP address or hostname provisioned by the cloud provider.

**Verify:** What does the EXTERNAL-IP column show? Why is it `<pending>` on a local cluster?
-->On a local cluster (Minikube, Kind, Docker Desktop), the EXTERNAL-IP will show `<pending>` because there is no cloud provider to create a real load balancer. This is expected, In a real cloud cluster, the EXTERNAL-IP would be a public IP address or hostname provisioned by the cloud provider.

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
