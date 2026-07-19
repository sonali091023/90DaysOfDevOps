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

**After drawing, verify your understanding:**
Q. What happens when you run `kubectl apply -f pod.yaml`? Trace the request through each component?

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

**kube-proxy Communication:** kube-proxy configures networking rules (using technologies like iptables, IPVS, or nftables depending on the environment) so traffic reaches the correct Pod.

<img width="697" height="460" alt="image" src="https://github.com/user-attachments/assets/cb24581b-43e3-4d55-8c30-9d73a2d61ec5" />

**CNI Communication:** Examples of CNI plugins include Calico, Cilium, Flannel, and Weave Net. They assign Pod IP addresses and provide pod-to-pod networking across nodes.

<img width="682" height="575" alt="image" src="https://github.com/user-attachments/assets/c9ffc743-7d8c-4d29-9c28-9ea9700c85a5" />

**Complete Communication Flow:**

<img width="677" height="712" alt="image" src="https://github.com/user-attachments/assets/b56406e8-7121-4aef-b3fc-7b5d9799d5b4" />

**Key takeaway:** The easiest way to remember Kubernetes communication is this:
- **API Server** is the central hub. Almost every control plane component (Scheduler, Controller Manager, kubelet) communicates with it rather than directly with each other.
- **etcd** never talks directly to Worker Nodes; it is accessed through the API Server.
- **Scheduler** decides where a Pod should run but does not start it.
- **kubelet** on the chosen Worker Node watches the API Server, receives the assignment, and instructs the Container Runtime to create the Pod.
- **kube-proxy** manages Service networking on each node.
- The **CNI** plugin provides pod-to-pod communication across nodes by configuring the networking layer

**Q. What happens if the API server goes down?**

-->This is an excellent interview question because it tests whether you understand that the API Server is the heart of the Kubernetes control plane.

-->If the API Server goes down, the Kubernetes cluster does not stop immediately, but it cannot be managed until the API Server is available again.

**What Stops Working?** Since almost every component communicates through the API Server:

<img width="682" height="645" alt="image" src="https://github.com/user-attachments/assets/68532ab7-20fa-4a4a-a95d-f91dbafd3881" />

**What Happens to Existing Pods?**

<img width="735" height="372" alt="image" src="https://github.com/user-attachments/assets/e5d245a0-6343-40ea-84e8-45f2875981d2" />

**Q. What Does kubelet Do?**

<img width="726" height="270" alt="image" src="https://github.com/user-attachments/assets/a23f1e91-efa1-4106-ab76-760479d3458a" />

**Q. What About the Scheduler?**

<img width="687" height="457" alt="image" src="https://github.com/user-attachments/assets/767fc939-f11f-463e-bec0-afa1d6e3dede" />

**Q. What About the Controller Manager?**

<img width="655" height="345" alt="image" src="https://github.com/user-attachments/assets/1f1b3bc5-7141-4645-a53b-0d1506d50897" />

**Q. What About etcd?**

<img width="720" height="205" alt="image" src="https://github.com/user-attachments/assets/c4033554-5789-45b0-bb53-2841348deac5" />

**Q. What About Networking?**

<img width="680" height="292" alt="image" src="https://github.com/user-attachments/assets/f8bcb0c0-0ab4-48c5-a597-c4596dfd7e4a" />

**Complete Scenario:**

<img width="692" height="711" alt="image" src="https://github.com/user-attachments/assets/1abc4df4-956d-43db-a22d-d887d0123e56" />

<img width="765" height="221" alt="image" src="https://github.com/user-attachments/assets/a287dd08-8cc2-4398-827c-fa26b64cd255" />

**Q. Why Do Production Clusters Use Multiple API Servers?**

-->Production Kubernetes clusters avoid a single point of failure by running multiple API Server instances behind a load balancer.

<img width="516" height="185" alt="image" src="https://github.com/user-attachments/assets/320584f7-c14b-46fb-a939-efc2f25b1031" />

If one API Server instance fails:

- The load balancer sends requests to another healthy API Server.

- Users and cluster components continue to operate with minimal interruption.

**Interview Answer:**

-->The API Server is the central communication point of the Kubernetes control plane. If it goes down, clients like kubectl and components such as the Scheduler and Controller Manager cannot manage the cluster or process new changes. However, existing Pods usually continue running because the kubelet and container runtime on each worker node keep managing them locally. Networking between existing Pods also continues to work. In production, Kubernetes avoids this single point of failure by running multiple API Server instances behind a load balancer.

**Q. What happens if a worker node goes down?**

-->If a Worker Node goes down, the Pods running on that node become unavailable. The Control Plane detects the node failure and, if possible, reschedules the affected Pods onto healthy Worker Nodes to maintain the desired state.

**Let's Understand It Step by Step:**

<img width="672" height="412" alt="image" src="https://github.com/user-attachments/assets/490566a0-3a20-4314-9467-31a2cbeac371" />

Step 1: Worker Node 1 Crashes: Suppose Worker Node 1 loses power or the VM crashes.

<img width="710" height="342" alt="image" src="https://github.com/user-attachments/assets/42a4853d-e040-450d-9685-216c8915c53f" />

Step 2: API Server Stops Receiving Heartbeats: Each kubelet periodically sends a heartbeat to the API Server to indicate the node is healthy.

<img width="692" height="587" alt="image" src="https://github.com/user-attachments/assets/6b88b004-7b41-4815-b1a9-bae14f73499a" />

Step 3: Controller Manager Detects the Failure: The Node Controller (part of the Controller Manager) continuously watches node health.

<img width="672" height="236" alt="image" src="https://github.com/user-attachments/assets/eb25bf05-c78e-4a91-8bb1-3e09358a555d" />

Step 4: Scheduler Reschedules Pods: The Controller Manager sees that Pods on Worker Node 1 are no longer running. So tt creates replacement Pods. The Scheduler then chooses a healthy node.

<img width="672" height="375" alt="image" src="https://github.com/user-attachments/assets/9e907464-27a0-4e28-8b25-da21636570cd" />

Step 5: kubelet Starts the New Pods: 

<img width="662" height="321" alt="image" src="https://github.com/user-attachments/assets/3bfa71de-9718-4392-8295-917a4332c206" />

**Complete Recovery Flow:**

<img width="672" height="446" alt="image" src="https://github.com/user-attachments/assets/cf4a5c34-72b5-493f-9f01-0a123ab89312" />

**Important Scenarios:**

Case 1: Deployment (Most Common): The Deployment ensures the desired number of replicas is maintained.

<img width="655" height="507" alt="image" src="https://github.com/user-attachments/assets/aed1d4e4-7c6c-405c-8f1d-ee7ce6b3b27f" />

Case 2: Standalone Pod (No Controller): Suppose you created a Pod directly:

<img width="732" height="262" alt="image" src="https://github.com/user-attachments/assets/b7bcc731-8773-4bb5-b378-816a91f5dbb9" />

Case 3: No Remaining Capacity:

<img width="717" height="257" alt="image" src="https://github.com/user-attachments/assets/0d0ae459-1903-4486-b692-2b838bb680f7" />

**Q. What About Networking?**

-->The CNI plugin (such as Calico or Cilium) updates networking for the new Pods. Clients continue to access the application through the Service, which automatically routes traffic to healthy Pods. This is why applications usually remain accessible even though the underlying Pod IPs change.

<img width="517" height="172" alt="image" src="https://github.com/user-attachments/assets/9b638a9a-bde8-4ee0-8532-409b3ba9f4c0" />

**INterview Answer:**

-->If a Worker Node goes down, the kubelet stops sending heartbeats to the API Server, which marks the node as NotReady. The Controller Manager detects that Pods on the failed node are no longer available and creates replacement Pods if they are managed by a controller such as a Deployment. The Scheduler assigns those replacement Pods to healthy Worker Nodes, and the kubelet on those nodes starts them using the container runtime. If no controller manages the Pods or there isn't enough cluster capacity, the workloads won't be automatically restored.

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

**Steps to follow:**

**Q. What is kubectl?**
-->kubectl is the official Kubernetes command-line tool. It allows you to communicate with the Kubernetes API Server to deploy applications, inspect resources, and manage your cluster.

<img width="662" height="412" alt="image" src="https://github.com/user-attachments/assets/9295a1e9-5eb1-4d93-92b8-489910d4ef0c" />

Step 1: Check if kubectl is already installed: kubectl version --client OR kubectl version --client --output=yaml

<img width="650" height="285" alt="image" src="https://github.com/user-attachments/assets/f63523d6-24d5-455b-8a4d-31ebe0e1f11a" />

Step 2: Download the latest stable kubectl: 

-->Download latest stable kubectl binary: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

Step 3: Make it executable: chmod +x kubectl

-->And then to verify: ls -l kubectl [expected: You should see executable permissions, for example:]

Step 4: Move it to your PATH: sudo mv kubectl /usr/local/bin/ [Expected: Now you can run kubectl from any directory.]

Step 5: Verify the installation: kubectl version --client

<img width="650" height="317" alt="image" src="https://github.com/user-attachments/assets/41af7560-2f5a-41df-89e7-8b2ab62235fa" />

Step 6: Check the current Kubernetes context (optional): If you already have a cluster configured (Kind, Minikube, EKS, etc.), run:

-->kubectl config current-context

<img width="681" height="316" alt="image" src="https://github.com/user-attachments/assets/b263f5c9-8b57-4111-8ac9-9a49425c1620" />

Step 7: View cluster information (optional): Once connected to a cluster, you can run:

-->kubectl cluster-info

<img width="607" height="147" alt="image" src="https://github.com/user-attachments/assets/870d3943-af98-4251-bf38-a4528b62381d" />

**Common kubectl Commands:**

<img width="737" height="362" alt="image" src="https://github.com/user-attachments/assets/ade88975-c190-498c-b143-c59d60c82e59" />

**How kubectl Works:**

<img width="627" height="445" alt="image" src="https://github.com/user-attachments/assets/bdd04d60-6dcf-4100-afd5-c1c2fc35f06c" />

- kubectl does not talk directly to worker nodes.
- It sends requests to the API Server.
- The API Server validates the request and coordinates with the appropriate control plane components.

**Interview Questions:**

Q. What is kubectl?
- kubectl is the official Kubernetes CLI.
- It communicates with the Kubernetes API Server to manage cluster resources.

**Q. How did you install it (Linux)?**

-->curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

-->chmod +x kubectl

-->sudo mv kubectl /usr/local/bin/

**Q. How did you verify the installation?**

-->kubectl version --client

-->If you're using the same Ubuntu environment from your previous Kubernetes exercises, there's a good chance kubectl is already installed. You can confirm by running: kubectl version --client

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

**Steps to follow:**

**Reasons to Kind Cluster:** Uses Docker containers as Kubernetes nodes.
- Lightweight and starts quickly.
- Great for local development and learning.
- No virtual machine required.
-  Widely used for testing and CI/CD pipelines.

-->For someone already familiar with Docker, Kind is usually the easiest choice.

**Set Up a Local Kubernetes Cluster Using Kind:**

Step 1: Check Prerequisites: 

-->Verify Docker is installed docker --version

-->Check docker is running: docker ps

-->Verify kubectl: kubectl version --client

Step 2: Check if Kind is Already Installed: kind version

Step 3: Install Kind (Ubuntu/Linux): Download the latest Kind binary: curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

-->Make it executable: chmod +x ./kind

-->Move it into your PATH: sudo mv ./kind /usr/local/bin/kind

-->Now to verify: kind version

Step 4: Create Your Cluster: kind create cluster --name devops-cluster

<img width="662" height="342" alt="image" src="https://github.com/user-attachments/assets/0a946a07-beb1-4f83-b85d-890fc509e013" />

Step 5: Verify the Cluster: Check cluster information: kubectl cluster-info

-->Check the nodes: kubectl get nodes

-->Check all Pods: kubectl get pods -A

Step 6: View the Cluster: kind get clusters

Step 7: Delete the Cluster (When Finished): kind delete cluster --name devops-cluster

**Q. What Happens Internally?**

-->kind create cluster --name devops-cluster

<img width="656" height="381" alt="image" src="https://github.com/user-attachments/assets/bbf5e32a-64a1-4e03-8468-28afdc4a59f2" />

**Architecture of a Kind Cluster:** In a default Kind cluster, the control plane itself also acts as a worker node unless you create a multi-node cluster.

<img width="547" height="467" alt="image" src="https://github.com/user-attachments/assets/fcbef328-6c85-4011-9ed4-a924ed213678" />

**Q. Why did you choose Kind?**

-->I chose Kind because it is lightweight, runs Kubernetes nodes as Docker containers, starts quickly, and is ideal for local development and learning. Since I already have Docker installed and have experience using it, Kind provides a simple way to create and manage a local Kubernetes cluster without needing a virtual machine. It is also commonly used for testing and CI/CD environments.

Bonus: Create a Multi-Node Kind Cluster: Once you're comfortable with the default cluster, you can create a more realistic setup with one control plane and two worker nodes.

Create a file named kind-config.yaml:

<img width="587" height="192" alt="image" src="https://github.com/user-attachments/assets/70b92dc7-cf1c-4e60-8e6f-e65a469d78c3" />

-->Then create cluster: kind create cluster --name devops-cluster --config kind-config.yaml

-->to verify: kubectl get nodes

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

**Steps to follow:**

This task is one of the most important because it connects the theory (Kubernetes architecture) with the actual running cluster. By the end, you'll see that the components you drew in Task 2 are real processes running inside your cluster.

**Explore Your Kubernetes Cluster:**

Step 1: Check Cluster Information: kubectl cluster-info:

**Q. What does this tell us?**
- Kubernetes control plane → The API Server endpoint where kubectl sends requests.
- CoreDNS → Provides DNS service inside the cluster.

Step 2: List the Nodes: kubectl get nodes

<img width="701" height="452" alt="image" src="https://github.com/user-attachments/assets/922edb1f-2768-4685-8735-e36ee83b2cfe" />

Step 3: Describe a Node: 

-->To get node details: kubectl get nodes

-->Now run: kubectl describe node devops-cluster-control-plane

<img width="617" height="732" alt="image" src="https://github.com/user-attachments/assets/911f2b87-36d5-49c7-8e69-1e6fd042f1ee" />
<img width="657" height="165" alt="image" src="https://github.com/user-attachments/assets/e1acf3ae-4cba-4878-a173-03051ea61994" />

Step 4: List Namespaces: kubectl get namespaces

**Q. What is Namespace?**

<img width="727" height="292" alt="image" src="https://github.com/user-attachments/assets/84474ad9-c90c-406c-b85c-e118279a8e06" />

Step 5: View All Pods: kubectl get pods -A

<img width="715" height="590" alt="image" src="https://github.com/user-attachments/assets/377f45d1-75b8-4596-aec4-b86ae2c305d2" />

Step 6: Explore the kube-system Namespace: kubectl get pods -n kube-system

<img width="602" height="375" alt="image" src="https://github.com/user-attachments/assets/7cfad7ca-dfe4-4249-ae44-a6ec63c5bfef" />

**Match Each Pod to Your Architecture Diagram:**

<img width="751" height="347" alt="image" src="https://github.com/user-attachments/assets/fb6ad24f-a3b8-457d-8ea8-8d02380679b5" />

Relating This to Your Architecture: 

<img width="665" height="736" alt="image" src="https://github.com/user-attachments/assets/a1e08aab-dd0e-4fad-9536-032183331ad5" />

**Note:** In Kind, the control plane components (kube-apiserver, etcd, kube-scheduler, and kube-controller-manager) run as static Pods managed by the kubelet on the control-plane node. The kubelet itself is not a Pod—it is a system service running directly on the node.

**Verify Your Understanding:** Use the table below to check whether you can identify each component in your cluster.

<img width="742" height="447" alt="image" src="https://github.com/user-attachments/assets/2dde3a99-c5e8-4099-802d-446cfeb6f6b3" />

**Q. What did we observe?**
- The kube-system namespace contains the core Kubernetes components required to operate the cluster.
- The control plane components (kube-apiserver, etcd, kube-scheduler, and kube-controller-manager) are visible as static Pods.
- kube-proxy provides Service networking on each node.
- CoreDNS enables DNS-based service discovery inside the cluster.
- The CNI plugin (such as kindnet in Kind) enables pod-to-pod communication across the cluster.
- The components from the Kubernetes architecture diagram are not just concepts—they are running workloads that you can inspect with kubectl.

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

**Steps to follow:**

-->This task helps you understand that Kubernetes clusters are temporary resources (especially local clusters like Kind) and teaches you how kubectl knows which cluster to communicate with.

**Practice Cluster Lifecycle:**

**Q. What is the Cluster Lifecycle?** 

-->The lifecycle of a Kubernetes cluster includes:

<img width="645" height="312" alt="image" src="https://github.com/user-attachments/assets/97af9f27-8367-45ed-a9ed-2d5096164244" />

Step 1: Check Existing Clusters: Before deleting anything, see what Kind clusters exist: kind get clusters

Step 2: Delete the Cluster: kind delete cluster --name devops-cluster

**Q. What Happens Internally?**

<img width="532" height="206" alt="image" src="https://github.com/user-attachments/assets/1ec4065c-4a9f-4ac4-8414-8b3e879e0f9a" />

-->Verify it's gone:: kind get clusters [Expected: No kind clusters found.]

Step 3: Recreate the Cluster: kind create cluster --name devops-cluster

<img width="722" height="292" alt="image" src="https://github.com/user-attachments/assets/63784aaa-6263-4a9c-831c-6da38e791e7e" />

Step 4: Verify the Cluster: kubectl get nodes

Step 5: Check the Current Context: kubectl config current-context

<img width="622" height="432" alt="image" src="https://github.com/user-attachments/assets/5722e5fe-5c71-4ac3-9db5-2569e1642d82" />

Step 6: List All Contexts: kubectl config get-contexts

<img width="687" height="420" alt="image" src="https://github.com/user-attachments/assets/4fa751d9-9cfd-4731-a6dc-6452265a2583" />

Step 7: View the kubeconfig: kubectl config view

<img width="681" height="462" alt="image" src="https://github.com/user-attachments/assets/0571bd2d-6ca3-4d5d-beba-8f69a13287e4" />

**Understanding kubeconfig:** Think of kubeconfig as an address book for Kubernetes clusters. A kubeconfig is a configuration file used by kubectl to connect to Kubernetes clusters. It stores information about clusters, user credentials, contexts, and the currently selected context, allowing kubectl to know where to send requests and how to authenticate.

<img width="617" height="192" alt="image" src="https://github.com/user-attachments/assets/aa03dde1-9ddb-4a95-97df-a891c440a7b1" />

**kubeconfig Structure:**

<img width="612" height="256" alt="image" src="https://github.com/user-attachments/assets/42cb8586-957f-4262-99bc-9d343fb56272" />

**Q. Where is kubeconfig Stored?**

<img width="672" height="565" alt="image" src="https://github.com/user-attachments/assets/95270b6c-e117-4f8a-a445-129a749deb04" />

**Q. How kubectl Uses kubeconfig?**

-->When we run: kubectl get pods

<img width="656" height="292" alt="image" src="https://github.com/user-attachments/assets/103cefab-81f8-439e-b0cd-e12500ca5e36" />

**Context Switching Example:**

<img width="627" height="457" alt="image" src="https://github.com/user-attachments/assets/299f8d4e-8f4f-43f8-bb86-8e63253be7f9" />

**Complete Flow:**

<img width="597" height="282" alt="image" src="https://github.com/user-attachments/assets/49dc7c58-2863-44d3-adce-13db0af91fb3" />

**Summary of Commands:**

<img width="702" height="377" alt="image" src="https://github.com/user-attachments/assets/bfa5954a-27ed-4842-aafc-00dff6e8e514" />

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
