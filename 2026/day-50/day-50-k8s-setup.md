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
2. Who created Kubernetes and what was it inspired by?
3. What does the name "Kubernetes" mean?

Do not look anything up yet. Write what you remember from the session, then verify against the official docs.

**Steps to follow:**

**1. Why was Kubernetes created? What problem does it solve that Docker alone cannot?**

-->Kubernetes was created to solve the challenges of running containers at scale. It was not created to replace Docker, but to manage and orchestrate containers when applications grow.

-->Docker makes it easy to package applications into containers and run them consistently across environments. However, when organizations start running dozens or hundreds of containers across multiple servers, management becomes difficult.

**Some common challenges with Docker alone are:**
- Managing containers across multiple machines.
- Manually restarting crashed containers.
- Manually scaling applications when traffic increases.
- No built-in load balancing.
- No cluster-level management.
- No service discovery.
- No rolling updates or easy rollbacks.

-->Kubernetes, originally developed at Google and inspired by its internal system Borg, solves these problems by automating container management. It provides:
- **Orchestration:** Manages containers across a cluster of machines.
- **Self-healing:** Automatically restarts failed containers.
- **Auto-scaling:** Increases or decreases application instances based on demand.
- **Load balancing:** Distributes traffic across multiple containers.
- **Rolling updates & rollbacks:** Deploys new versions with little or no downtime and can revert if needed.
- **Service discovery:** Allows containers to communicate with each other using DNS.

-->In short Docker is used to build, package, and run containers, while Kubernetes automates the deployment, scaling, networking, and management of containerized applications across a cluster.

-->Simple analogy is **Docker** = “I can run one app in a box” & **Kubernetes** = “I can manage 1,000 boxes across 50 servers automatically”

**2. Who created Kubernetes and what was it inspired by?**

-->Kubernetes was originally created at Google by engineers Joe Beda, Brendan Burns, and Craig McLuckie. They designed it to manage containerized applications at massive scale based on Google's real-world experience.

-->It was inspired by Google's internal cluster management systems, Borg (and later Omega), which had been used for years to manage Google's large-scale infrastructure and billions of containers.

-->Kubernetes brought these proven ideas—such as container orchestration, automated scheduling across clusters, and self-healing distributed systems—to the open-source community. Today, Kubernetes is an open-source project maintained by the Cloud Native Computing Foundation (CNCF).

**3. What does the name "Kubernetes" mean?**

-->The name Kubernetes comes from the Greek word "κυβερνήτης (kubernetes)", which means "helmsman" or "pilot"—a person who steers[guides/directs] a ship.

-->The name is symbolic because containers are like ships, and Kubernetes is the captain that steers and manages them. Just as a helmsman keeps a ship on course, Kubernetes decides where containers run, keeps them healthy, and automatically adjusts to changes such as increased traffic or container failures. In short, the name reflects Kubernetes' role of steering and managing containerized applications.

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

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/7c6aebab-8b43-4ad0-a785-15e6b99c0c10" />

**Explaination:**

-->API Server as the central communication hub. Almost every component communicates through the API Server, not directly with each other.

**Step-by-Step Communication:**

Step 1: User sends a request:

<img width="682" height="431" alt="image" src="https://github.com/user-attachments/assets/21a1fa10-64c2-402f-97a2-ee6a6bc3aaa4" />

Step 2: API Server stores desired state: 

<img width="657" height="401" alt="image" src="https://github.com/user-attachments/assets/112f04ae-5f11-4a0d-a72e-6134fa073dd7" />

Step 3: Scheduler notices a new Pod:

<img width="687" height="447" alt="image" src="https://github.com/user-attachments/assets/7f3dbd33-74b1-4012-8eeb-9bf2a934e29b" />

Step 4: kubelet watches the API Server:

<img width="682" height="465" alt="image" src="https://github.com/user-attachments/assets/09ee2189-f556-4104-b3a3-85fd8618d14e" />

Step 5: kubelet starts the Pod: 

<img width="672" height="355" alt="image" src="https://github.com/user-attachments/assets/72bd3778-cff3-49fd-859b-a5c25a8a9610" />

Step 6: kubelet reports status back:

<img width="682" height="407" alt="image" src="https://github.com/user-attachments/assets/921dd611-f00a-4af7-97ce-e00cd297518c" />

**Controller Manager Communication:** The Controller Manager constantly watches the API Server.

<img width="671" height="402" alt="image" src="https://github.com/user-attachments/assets/87519e90-80d5-4b05-a784-231469b5c5c4" />

**kube-proxy Communication:** 





After drawing, verify your understanding:
- What happens when you run `kubectl apply -f pod.yaml`? Trace the request through each component.
- What happens if the API server goes down?
- What happens if a worker node goes down?

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

You should see pods like `etcd`, `kube-apiserver`, `kube-scheduler`, `kube-controller-manager`, `coredns`, and `kube-proxy`. These are the architecture components you drew in Task 2 — running as pods inside the cluster.

**Verify:** Can you match each running pod in `kube-system` to a component in your architecture diagram?

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

Write down: What is a kubeconfig? Where is it stored on your machine?

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
