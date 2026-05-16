# Day 50 – Kubernetes Architecture and Cluster Setup

## Task
You have been building and shipping containers with Docker. But what happens when you need to run hundreds of containers across multiple servers? You need an orchestrator. Today you start your Kubernetes journey — understand the architecture, set up a local cluster, and run your first `kubectl` commands.

This is where things get real.

---

## Expected Output
- A running local Kubernetes cluster (kind or minikube)
- A markdown file: `day-50-k8s-setup.md`
- Screenshot of `kubectl get nodes` showing your cluster is ready

---

## Challenge Tasks

### Task 1: Recall the Kubernetes Story
Before touching a terminal, write down from memory:

1. Why was Kubernetes created? What problem does it solve that Docker alone cannot?

-->Kubernetes wasn’t created to replace Docker—it was created to solve the problems that appear after you start using Docker at scale.

-->Docker made it easy to Package applications into containers, Run them consistently across environments, But once companies started running dozens or hundreds of containers, things got messy.

-->Like How do you manage them across multiple servers?, What if a container crashes?, How do you scale when traffic increases?

-->And That’s where Kubernetes comes in, It was originally developed at Google based on their internal system (Name as Borg) to manage large-scale distributed systems.

-->So in docker container we can run the contaner manually, But No automatic restart if it crashes, No built-in load balancing, No easy scaling (you manually run more containers), No cluster-level management (multiple machines = pain),
No service discovery, No rolling updates etc.

-->But Kubernetes solves all of that automatically:

**a. Orchestration:** Manages containers across multiple machines (cluster)

**b. Self-healing:** If a container dies → Kubernetes restarts it

**c. Auto-scaling:** Increase/decrease pods based on traffic

**d. Load balancing:** Distributes traffic across containers

**e. Rolling updates & rollbacks:** Deploy new versions without downtime

**f. Service discovery:** Containers find each other via DNS

2. Who created Kubernetes and what was it inspired by?

4. What does the name "Kubernetes" mean?

Do not look anything up yet. Write what you remember from the session, then verify against the official docs.

**Simple analogy:** **Docker** = “I can run one app in a box” & **Kubernetes** = “I can manage 1,000 boxes across 50 servers automatically”

2. Who created Kubernetes and what was it inspired by?

-->Kubernetes was originally created by engineers [Joe Beda, Brendan Burns, Craig McLuckie] at Google.

-->They designed Kubernetes to handle containerized applications at massive scale, based on Google’s internal experience.

-->Kubernetes was inspired by Google’s internal system called Borg, Later, Google also developed Omega, These systems had been running Google’s infrastructure for years, managing billions of containers.

-->This matters because Before Kubernetes, most companies didn’t have Proven large-scale container orchestration, Automated scheduling across clusters, Self-healing distributed systems etc.

**What does the name "Kubernetes" mean?**

-->The name Kubernetes comes from the Greek word “κυβερνήτης (kubernetes)”, which means “helmsman” or “pilot”

-->It’s symbolic: Like **Containers** (like those from Docker) = ships & **Kubernetes** = the captain that navigates and manages them

-->So Kubernetes “steers” your containers: Decides where they run, Keeps them on course (healthy), Adjusts based on conditions (traffic, failures)

Do not look anything up yet. Write what you remember from the session, then verify against the official docs.

---

### Task 2: Draw the Kubernetes Architecture
From memory, draw or describe the Kubernetes architecture. Your diagram should include:

**Control Plane (Master Node):**
- API Server — the front door to the cluster, every command goes through it
- etcd — the database that stores all cluster state
- Scheduler — decides which node a new pod should run on
- Controller Manager — watches the cluster and makes sure the desired state matches reality

**Worker Node:**
- kubelet — the agent on each node that talks to the API server and manages pods
- kube-proxy — handles networking rules so pods can communicate
- Container Runtime — the engine that actually runs containers (containerd, CRI-O)

  <img width="783" height="343" alt="image" src="https://github.com/user-attachments/assets/984af8e9-0565-401e-9081-d4ccb43c3511" />

After drawing, verify your understanding:
**- What happens when you run `kubectl apply -f pod.yaml`? Trace the request through each component.**

-->Let see how request flows step by step:

1. **kubectl (client):**

-->Reads pod.yaml, converts to JSON

-->Sends HTTP request (PATCH/POST) to API Server using kubeconfig

2. **API Server:**

-->Auth → who are you

-->Authorization (RBAC) → allowed or not

-->Admission Controllers → validate/mutate

-->Stores Pod spec in etcd

3. **etcd:**

-->Saves Pod as desired state (not running yet)

4. **Scheduler:**

-->Watches for unscheduled Pods

-->Selects best Node

-->Updates Pod with nodeName

5. **Kubelet (on chosen node):**

-->Detects assigned Pod

-->Pulls image & starts container via runtime

6. **Container Runtime (containerd/CRI-O):**

-->Actually runs the container

7. **Status Update:**

-->Kubelet → API Server

-->Pod moves: Pending → Running

**Note:** 

-->kubectl → API Server → etcd → Scheduler → Kubelet → Container Runtime → Status back.

-->apply = declare desired state, Kubernetes makes it happen automatically.

**- What happens if the API server goes down?**

-->Everything that depends on the control plane stops working, but running workloads are NOT killed immediately.

-->Still Existing Pods/containers keep running, Apps continue serving traffic, Kubelet on each node keeps containers alive, Basic container restarts (on crash) still happen etc.

-->What breaks is kubectl commands → fail (no API endpoint), No new Pods can be created, No scheduling (Scheduler depends on API server), No scaling, updates, or deployments, Controllers (ReplicaSet, Deployment, etc.) 
stop reconciling, Cluster state changes cannot be saved (etcd access via API server)

-->And important is Kubelet works from last known state like, If a Pod dies: It may restart locally But no new Pods will be created elsewhere

**Note:** If the API server goes down, existing workloads continue running, but the cluster becomes read-only—no new deployments, scheduling, or state changes can occur.

**- What happens if a worker node goes down?**

-->Kubernetes detects it and moves workloads elsewhere

-->lets see step-by-step

1. **Node stops responding:** Kubelet stops sending heartbeats to API Server

2. **API Server marks node unhealthy:** Status changes → NotReady

3. **Node Controller reacts:** Waits (default ~5 minutes), Marks Pods on that node as lost/unknown

4. **Pods are evicted:** Pods on failed node are removed from desired state

5. **Rescheduling happens:**  Scheduler places new Pods on healthy nodes

6. **New Pods start:** Kubelet on other nodes pulls images and runs containers

-->So existing pods will get delete and New Pods are created on other nodes, And in case of Deployment / ReplicaSet Pods are recreated automatically.

-->In short Node fails → Pods die → Controller creates new Pods → Scheduler assigns new node

---

### Task 3: Install kubectl
`kubectl` is the CLI tool you will use to talk to your Kubernetes cluster.

Install it:
```bash
# macOS
brew install kubectl

# Linux (amd64)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Windows (with chocolatey)
choco install kubernetes-cli
```

Verify:
```bash
kubectl version --client
```

<img width="1566" height="247" alt="image" src="https://github.com/user-attachments/assets/f4714273-fa4d-4094-b218-146326576856" />

---

### Task 4: Set Up Your Local Cluster
Choose **one** of the following. Both give you a fully functional Kubernetes cluster on your machine.

**Option A: kind (Kubernetes in Docker)**
```bash
# Install kind
# macOS
brew install kind

# Linux
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create a cluster
kind create cluster --name devops-cluster

# Verify
kubectl cluster-info
kubectl get nodes
```

**Option B: minikube**
```bash
# Install minikube
# macOS
brew install minikube

# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start a cluster
minikube start

# Verify
kubectl cluster-info
kubectl get nodes
```

Write down: Which one did you choose and why?
-->I have selected kind because it is lightweight, easy to set up, and ideal for local development and learning. It allows me to quickly create and delete Kubernetes clusters without needing heavy resources or complex configuration. Since it runs inside Docker containers, it integrates well with my existing DevOps workflow and helps me practice Kubernetes concepts efficiently on my local machine.

<img width="1270" height="747" alt="image" src="https://github.com/user-attachments/assets/5b22cf95-3cf5-4934-9d2b-c39508dccd08" />

---

### Task 5: Explore Your Cluster
Now that your cluster is running, explore it:

```bash
# See cluster info
  kubectl cluster-info

# List all nodes
kubectl get nodes

# Get detailed info about your node
kubectl describe node <node-name>

# List all namespaces
kubectl get namespaces

# See ALL pods running in the cluster (across all namespaces)
kubectl get pods -A
```

Look at the pods running in the `kube-system` namespace:
```bash
kubectl get pods -n kube-system
```

<img width="1913" height="967" alt="image" src="https://github.com/user-attachments/assets/a784ddac-cb9e-44d5-89e5-196ddc2d8d84" />
<img width="1882" height="966" alt="image" src="https://github.com/user-attachments/assets/d10aaee4-a004-4c2c-bca0-175442ba8c29" />
<img width="1431" height="687" alt="image" src="https://github.com/user-attachments/assets/c6f3f888-0062-4416-876f-6e75b1f10d21" />

You should see pods like `etcd`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, `coredns`, and `kube-proxy`. These are the architecture components you drew in Task 2 — running as pods inside the cluster.

**Verify:** Can you match each running pod in `kube-system` to a component in your architecture diagram?

-->you can directly map each pod in the kube-system namespace to a Kubernetes architecture component.

-->**Control Plane Components:**

1. etcd-* --> etcd --> Stores cluster state

2. kube-apiserver-* --> API Server --> Entry point for all requests

3. kube-scheduler-* --> Scheduler --> Assigns Pods to nodes

4. kube-controller-manager-* --> Controller Manager --> Maintains desired state

-->**Cluster Add-ons:**

1. coredns-* --> DNS --> Service discovery inside cluster

-->**Node Component (runs as DaemonSet):**

1. kube-proxy-*	kube-proxy	Handles networking & service routing

**Note:** In kind, control plane components (like API server, etcd, scheduler) run as pods inside the control-plane container, In real clusters, they may run as systemd services or static pods.

-->To verify use command: kubectl get pods -n kube-system

-->Yes, each pod in the kube-system namespace corresponds to a Kubernetes component like API server, etcd, scheduler, controller manager, DNS, and kube-proxy, matching the cluster architecture.

---

### Task 6: Practice Cluster Lifecycle
Build muscle memory with cluster operations:

```bash
# Delete your cluster
kind delete cluster --name devops-cluster
# (or: minikube delete)

# Recreate it
kind create cluster --name devops-cluster
# (or: minikube start)

# Verify it is back
kubectl get nodes
```

Try these useful commands:
```bash
# Check which cluster kubectl is connected to
kubectl config current-context

# List all available contexts (clusters)
kubectl config get-contexts

# See the full kubeconfig
kubectl config view
```
<img width="1913" height="883" alt="image" src="https://github.com/user-attachments/assets/0506d8f9-5405-4c8b-9ac6-3af3ce8fed4b" />
<img width="676" height="752" alt="image" src="https://github.com/user-attachments/assets/b2bd4a31-5fe7-4024-97b9-c7c68ef9870e" />

Write down: What is a kubeconfig? Where is it stored on your machine?
-->A kubeconfig is a configuration file used by kubectl to connect to a Kubernetes cluster. It contains details such as the cluster API server address, user credentials (certificates or tokens), and context information (which cluster and user to use).

-->By default, the kubeconfig file is stored on the local machine at: **~/.kube/config**

-->This file allows kubectl to authenticate and communicate with the correct Kubernetes cluster.

---

## Hints
- kind requires Docker to be running (it creates clusters using containers)
- minikube can use Docker, VirtualBox, or other drivers
- The default kubeconfig file is at `~/.kube/config`
- `kubectl get pods -A` is short for `kubectl get pods --all-namespaces`
- If `kubectl` cannot connect, check if your cluster is running: `kind get clusters` or `minikube status`
- `-o wide` flag gives extra details: `kubectl get nodes -o wide`

---

## Documentation
Create `day-50-k8s-setup.md` with:
- Kubernetes history in your own words (3-4 sentences)
- Your architecture diagram (text-based or image)
- Which tool you chose (kind/minikube) and why
- Screenshot of `kubectl get nodes` and `kubectl get pods -n kube-system`
- What each kube-system pod does

---

## Submission
1. Add `day-50-k8s-setup.md` to `2026/day-50/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Started my Kubernetes journey today. Set up a local cluster, explored the architecture, and saw the control plane components running as actual pods. The orchestration chapter begins."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
