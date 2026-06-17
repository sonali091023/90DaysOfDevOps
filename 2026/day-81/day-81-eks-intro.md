# Day 81 -- Introduction to Amazon EKS with Terraform

## Task
You have been running Kubernetes locally with Kind. That works for learning, but the AI-BankApp needs a production environment -- managed control plane, auto-scaling nodes, persistent EBS storage, and IAM integration.

Amazon EKS (Elastic Kubernetes Service) is AWS's managed Kubernetes offering. The AI-BankApp project (https://github.com/TrainWithShubham/AI-BankApp-DevOps, branch `feat/gitops`) already has a complete Terraform configuration in its `terraform/` directory that provisions a production-grade EKS cluster. Today you understand EKS architecture, study the Terraform configs, provision the cluster, and connect to it.

---

## Expected Output
- Understanding of EKS architecture and its components
- The AI-BankApp's Terraform configs reviewed and understood
- A running EKS cluster provisioned via Terraform
- kubectl connected to the EKS cluster
- A markdown file: `day-81-eks-intro.md`

---

## Challenge Tasks

### Task 1: Understand EKS Architecture
Research and write notes on:

1. **What does "managed Kubernetes" mean?**
   - AWS manages the **control plane** (API server, etcd, scheduler, controller manager)
   - You manage the **data plane** (worker nodes where your pods run)
   - AWS handles control plane upgrades, patching, and high availability across multiple AZs

2. **EKS components:**
   - **EKS Control Plane** -- managed by AWS, runs in AWS-owned VPC, accessible via API endpoint
   - **Node Groups** -- EC2 instances that run your pods
     - **Managed Node Groups** -- AWS handles provisioning, scaling, and updates
     - **Self-Managed Nodes** -- you manage the EC2 instances yourself
     - **Fargate Profiles** -- serverless, no nodes to manage at all
   - **VPC and Networking** -- EKS runs inside your VPC with subnets across AZs
   - **IAM Integration** -- EKS uses IAM roles for cluster access and pod-level permissions (IRSA)

3. **EKS add-ons the AI-BankApp uses** (from `terraform/eks.tf`):
   - `coredns` -- DNS resolution inside the cluster
   - `kube-proxy` -- network routing for services
   - `vpc-cni` -- AWS VPC CNI plugin, assigns VPC IPs to pods
   - `eks-pod-identity-agent` -- enables pod-level IAM roles
   - `aws-ebs-csi-driver` -- allows pods to use EBS volumes (needed for MySQL and Ollama storage)
   - `metrics-server` -- enables `kubectl top` and HPA
  
**Steps to follow:**

For this task, you should focus on understanding the EKS architecture conceptually and relate it to the AI-BankApp deployment. Here are structured notes you can use.

**Task 1: Understand EKS Architecture: **

**1. What Does "Managed Kubernetes" Mean?**

-->**Self managed kubernetes:**

<img width="695" height="335" alt="image" src="https://github.com/user-attachments/assets/e117eb3c-2e19-45f0-98b4-54079a91cfaa" />

-->**EKS managed kubernetes:**

<img width="802" height="792" alt="image" src="https://github.com/user-attachments/assets/4c9c7143-a840-4da8-8254-336012163adb" />

**2. EKS Architecture Overview:**

<img width="557" height="522" alt="image" src="https://github.com/user-attachments/assets/1bd68ae6-7eef-47ba-a4ff-8ad3378ee688" />

**EKS Components:** EKS Components as below,

**A. EKS Control Plane:** The control plane is the "brain" of Kubernetes.

**Components:**

1. **API Server:** Entry point for all Kubernetes requests, It receives commands from: kubectl, Terraform, Helm, Controllers etc. **Ex:** kubectl get all & once the request send, It goes to the API Server.

2. **etcd:** Stores cluster state/data: Ex: Deployments, Services, Secrets, ConfigMaps, Node information Think of etcd as Kubernetes' database.

3. **Scheduler:** Determines where Pods should run

<img width="512" height="232" alt="image" src="https://github.com/user-attachments/assets/8bb80071-89a6-4991-9475-3c371193bb63" />

4. **Controller Manager:** Ensures desired state matches actual state.

<img width="567" height="342" alt="image" src="https://github.com/user-attachments/assets/4136d0c8-9b70-4281-b98e-10f14cb0c11a" />

**EKS Control Plane Characteristics:**

-->Fully managed by AWS

-->Runs in an AWS-owned VPC

-->Highly available across multiple Availability Zones

-->Automatically patched and upgraded

**B. Node Groups:** Node groups contain the EC2 instances where Pods run.

**1. Managed Node Groups:**

<img width="607" height="457" alt="image" src="https://github.com/user-attachments/assets/225c8b04-22f4-43e3-b4ac-6c09578b71f2" />

**2. Self-Managed Nodes:**

<img width="651" height="387" alt="image" src="https://github.com/user-attachments/assets/67fd397b-df99-424d-b515-64cdaa583bc9" />

**3. Fargate Profiles:**

<img width="637" height="422" alt="image" src="https://github.com/user-attachments/assets/795a9ffa-1e36-4b8a-9e20-4734b986e59f" />

**C. VPC and Networking: EKS runs within your AWS VPC:**

<img width="462" height="510" alt="image" src="https://github.com/user-attachments/assets/63541e0e-568c-49ef-998f-c4f045a867d6" />

1. Pod Networking: Unlike many Kubernetes distributions, EKS uses AWS networking directly.

-->Each Pod receives: A VPC IP address & Direct communication capability, So This is enabled through the AWS VPC CNI[Container network interface] plugin.

**D. IAM Integration: One of EKS's biggest advantages is integration with AWS IAM.**

**1.Cluster Access: IAM controls who can:**

-->kubectl get pods

-->kubectl apply

-->kubectl delete

**2. Pod-Level Permissions (IRSA): IRSA = IAM Roles for Service Accounts:**

<img width="432" height="192" alt="image" src="https://github.com/user-attachments/assets/f1b24c07-828a-43a6-8f3a-120ad48dbce1" />

-->No AWS access keys are required.

**Benefits:**

-->Improved security

-->Fine-grained permissions

-->Least privilege access

**3. EKS Add-ons Used by AI-BankApp:** These add-ons are typically configured in terraform/eks.tf.

1. **CoreDNS:** Pods use CoreDNS to resolve service names.

**Purpose:** Provides DNS inside Kubernetes. **Ex:** mysql.default.svc.cluster.local  

**Note:** Without CoreDNS: Frontend cannot find Backend & Backend cannot find MySQL

2. **kube-proxy:** kube-proxy routes traffic to the correct Pod.

**Purpose:** Handles service networking. **Ex:** Service → Backend Pods

**Note:** Without it Services cannot reach Pods

3. **VPC CNI:**

**Purpose:** Assigns AWS VPC IP addresses to Pods.

**Benefits:** 

-->Native AWS networking

-->Direct Pod communication

-->Better integration with AWS services

4. **EKS Pod Identity Agent:**

**Purpose:** Enables Pod Identity. 

-->Allows: Pod -->IAM Role -->AWS service acccess [this happens Without storing credentials inside containers]

5. **AWS EBS CSI Driver:**

**Purpose:** Allows Kubernetes to provision EBS volumes dynamically.

-->Used by: MySQL persistent storage & Ollama model storage Ex: PersistentVolumeClaim --> EBS Volume Created --> Mounted into Pod

-->Without it: No persistent storage available

6. **Metrics Server:**

**Purpose:** Collects CPU and memory metrics.

<img width="437" height="595" alt="image" src="https://github.com/user-attachments/assets/b96263b0-db55-4b26-9621-688003de2cd1" />

**AI-BankApp Connection:**

<img width="776" height="596" alt="image" src="https://github.com/user-attachments/assets/49d9de6e-6896-4230-b2ca-39bb81ea9ffa" />

**Key takeaway:** EKS removes the burden of managing Kubernetes control plane components while allowing you to focus on deploying and operating applications. The AI-BankApp relies on EKS add-ons such as CoreDNS, kube-proxy, VPC CNI, Pod Identity Agent, EBS CSI Driver, and Metrics Server to provide networking, storage, security, and observability capabilities.

---

### Task 2: Study the AI-BankApp Terraform Configuration
Clone the repo and examine the `terraform/` directory:

```bash
git clone -b feat/gitops https://github.com/TrainWithShubham/AI-BankApp-DevOps.git
cd AI-BankApp-DevOps/terraform
ls
```

```
argocd.tf           # ArgoCD Helm release
eks.tf              # EKS cluster + node group + IRSA
outputs.tf          # Cluster info and helper commands
provider.tf         # AWS + Helm providers, locals
terraform.tfvars    # Default variable values
variables.tf        # Input variables
vpc.tf              # VPC with public/private/intra subnets
```

**Study each file and understand what it provisions:**

**`variables.tf` and `terraform.tfvars`:**
```hcl
# The defaults:
aws_region         = "us-west-2"
cluster_name       = "bankapp-eks"
cluster_version    = "1.35"
node_instance_type = "t3.medium"
node_desired_count = 3
node_max_count     = 5
```

**`vpc.tf`** -- Networking foundation:
- Uses the `terraform-aws-modules/vpc/aws` module
- 3 Availability Zones with:
  - **Public subnets** (10.0.1-3.0/24) -- for load balancers, tagged with `kubernetes.io/role/elb`
  - **Private subnets** (10.0.4-6.0/24) -- for worker nodes, tagged with `kubernetes.io/role/internal-elb`
  - **Intra subnets** (10.0.7-9.0/24) -- for EKS control plane ENIs
- NAT Gateway enabled for outbound internet from private subnets

**`eks.tf`** -- The cluster itself:
- Uses the `terraform-aws-modules/eks/aws` module (version ~> 21.0)
- AL2023 AMI for nodes (Amazon Linux 2023)
- 3x `t3.medium` instances (min 3, max 5)
- All 6 EKS add-ons installed as cluster add-ons
- IRSA configured for the EBS CSI driver
- Public + private API endpoint access

**`argocd.tf`** -- ArgoCD via Helm:
- Installs ArgoCD using the `argo-cd` Helm chart
- Exposed as a LoadBalancer service
- Depends on the EKS module (created after the cluster is ready)

**`outputs.tf`** -- Helper commands:
- Outputs the `aws eks update-kubeconfig` command
- Outputs the ArgoCD initial password retrieval command

**Document:** Draw the architecture: VPC -> Subnets -> EKS Control Plane -> Node Group -> Pods

**Steps to follow:**

-->For this task, your goal is not just to read the Terraform files but to understand how the entire AWS infrastructure is built from code and how it supports the AI-BankApp deployment.

Step 1: Clone and Explore the Repository: 

-->git clone -b feat/gitops https://github.com/TrainWithShubham/AI-BankApp-DevOps.git

-->cd AI-BankApp-DevOps/terraform

-->ls & we will get the list of files & directories

<img width="1827" height="431" alt="image" src="https://github.com/user-attachments/assets/3d731946-ca9c-422a-892f-8e539f2e82ad" />

**Understanding the Terraform Flow: Terraform provisions resources in roughly this order:**

<img width="652" height="696" alt="image" src="https://github.com/user-attachments/assets/abf15870-0d67-468f-a33f-d26ec938b1f6" />

**1. variables.tf:** Defines all configurable values used throughout the project, Think of it as the "input form" for Terraform.

<img width="612" height="630" alt="image" src="https://github.com/user-attachments/assets/704a32e0-839f-467c-a2b5-ab1bafd7878d" />

**2. terraform.tfvars:** Provides actual values for the variables.

<img width="715" height="487" alt="image" src="https://github.com/user-attachments/assets/8f5bed32-8806-4bc5-94c4-08641fb373b3" />

3. provider.tf: Configures Terraform providers, Providers are plugins that allow Terraform to communicate with AWS, Helm, Kubernetes, etc.

**Typical flow:** terraform --> AWS Provider --> AWS API

<img width="561" height="582" alt="image" src="https://github.com/user-attachments/assets/5d11dd2a-511f-4f70-96bc-86c3151a32e8" />

4. vpc.tf: Creates the networking foundation & Everything inside AWS runs within a VPC.

<img width="542" height="721" alt="image" src="https://github.com/user-attachments/assets/b2300959-efe4-4bfb-b3e4-6f327a0172ab" />

<img width="491" height="767" alt="image" src="https://github.com/user-attachments/assets/c400a696-3567-4e7d-bed7-6a6181c8b0d1" />

<img width="592" height="777" alt="image" src="https://github.com/user-attachments/assets/4f9bd356-01f1-417e-b43b-fca232483403" />

<img width="500" height="712" alt="image" src="https://github.com/user-attachments/assets/8ea64734-465a-4b01-bf25-10183bcbf527" />

<img width="522" height="802" alt="image" src="https://github.com/user-attachments/assets/3177784c-c548-42ca-9eca-41470db8d17f" />

<img width="435" height="825" alt="image" src="https://github.com/user-attachments/assets/83f9b960-a676-4199-b329-ef9427728d87" />

<img width="512" height="631" alt="image" src="https://github.com/user-attachments/assets/1521697a-236e-47bb-870d-5662339b350b" />

<img width="442" height="807" alt="image" src="https://github.com/user-attachments/assets/f4b3a2e3-1b11-4f3d-91a5-c9062e13c30c" />

<img width="487" height="796" alt="image" src="https://github.com/user-attachments/assets/a90c9d5b-1d75-4a03-af57-b46bded84dd0" />

<img width="442" height="532" alt="image" src="https://github.com/user-attachments/assets/87578509-83ab-4977-9cfd-d2910d5c0b9c" />

<img width="421" height="802" alt="image" src="https://github.com/user-attachments/assets/1c174cff-2106-48d8-863c-42f359af4425" />

<img width="587" height="552" alt="image" src="https://github.com/user-attachments/assets/4311a87c-2796-4892-9cdc-44d817756d81" />

**Complete Architecture Diagram:**

<img width="516" height="732" alt="image" src="https://github.com/user-attachments/assets/d301e8b1-2286-4933-a5b6-82c4e08ebb8d" />

<img width="482" height="312" alt="image" src="https://github.com/user-attachments/assets/3a0cb0b9-0f5c-4947-90fd-6e27c3905f13" />

**Key Takeaway:** The Terraform configuration creates a production-style AWS environment where:

-->**vpc.tf:** builds the network foundation.

-->**eks.tf:** creates the managed Kubernetes cluster and worker nodes.

-->**EKS add-ons:** provide networking, storage, IAM, and metrics.

-->**argocd.tf:** installs ArgoCD for GitOps deployments.

-->**outputs.tf:** provides helper commands to access and manage the cluster.

---

### Task 3: Provision the EKS Cluster
Make sure you have the required tools:
```bash
terraform --version    # >= 1.0
aws --version          # AWS CLI v2
kubectl version --client
helm version
```

Configure AWS credentials:
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-west-2), Output (json)

# Verify
aws sts get-caller-identity
```

Initialize and apply:
```bash
cd terraform

terraform init
terraform plan
```

Review the plan carefully. It will create:
- 1 VPC with 9 subnets, NAT gateway, internet gateway
- 1 EKS cluster with control plane
- 1 managed node group (3x t3.medium)
- 6 EKS add-ons
- IAM roles and policies for the cluster, nodes, and EBS CSI driver
- ArgoCD Helm release

```bash
terraform apply
```

This takes 15-20 minutes. While waiting, review the Terraform output for CloudFormation-like progress.

After completion, note the outputs:
```bash
terraform output
```

---

### Task 4: Connect to Your Cluster
Update kubeconfig using the Terraform output:
```bash
aws eks update-kubeconfig --name bankapp-eks --region us-west-2
```

Verify the connection:
```bash
# Check context
kubectl config current-context

# Cluster info
kubectl cluster-info

# List nodes
kubectl get nodes -o wide
```

You should see 3 nodes with status `Ready`, instance type `t3.medium`, spread across 3 AZs.

Explore the cluster:
```bash
# System pods
kubectl get pods -n kube-system

# All the add-ons are running
kubectl get daemonsets -n kube-system

# EBS CSI driver
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver

# Metrics server (enables kubectl top and HPA)
kubectl top nodes
```

Check ArgoCD is running:
```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

Get the ArgoCD admin password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Get the ArgoCD LoadBalancer URL:
```bash
kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Open the URL in your browser and log in with `admin` and the password from above. You will use ArgoCD on Days 84-86.

---

### Task 5: Deploy the AI-BankApp Manually (Before ArgoCD)
Before setting up GitOps, deploy the app manually to validate the cluster works.

Apply the raw manifests from the `k8s/` directory:
```bash
cd ../  # Back to the repo root

kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/pv.yml
kubectl apply -f k8s/pvc.yml
kubectl apply -f k8s/configmap.yml
kubectl apply -f k8s/secrets.yml
kubectl apply -f k8s/mysql-deployment.yml
kubectl apply -f k8s/service.yml
kubectl apply -f k8s/ollama-deployment.yml
kubectl apply -f k8s/bankapp-deployment.yml
kubectl apply -f k8s/hpa.yml
```

Watch the pods come up:
```bash
kubectl get pods -n bankapp -w
```

The startup order is:
1. MySQL starts and becomes healthy (15-30 seconds)
2. Ollama starts and pulls the TinyLlama model (2-5 minutes)
3. BankApp init containers wait for both, then the app starts (30-60 seconds after dependencies)

Check PVCs are bound to EBS volumes:
```bash
kubectl get pvc -n bankapp
kubectl get pv
```

You should see 5Gi and 10Gi EBS volumes in the correct AZs.

Once all pods are running, access the app:
```bash
kubectl port-forward svc/bankapp-service -n bankapp 8080:8080
```

Open `http://localhost:8080` -- you should see the AI-BankApp login page. Register an account, log in, and try the AI chatbot.

**Verify the HPA:**
```bash
kubectl get hpa -n bankapp
```

---

### Task 6: Understand EKS Costs and Clean Up Strategy
EKS is not free. The AI-BankApp cluster costs:

| Component | Cost (approximate) |
|-----------|-------------------|
| EKS Control Plane | $0.10/hr (~$73/month) |
| t3.medium nodes (3x) | ~$0.042/hr each (~$91/month total) |
| NAT Gateway | ~$0.045/hr + data transfer (~$33/month) |
| EBS volumes (15Gi total) | ~$1.50/month |
| LoadBalancer (ArgoCD) | ~$0.025/hr (~$18/month) |
| **Total for this lab** | **~$220/month (~$7/day)** |

**Important:** Do NOT leave the cluster running when you are not using it.

Delete the BankApp workload (keep the cluster for Days 82-83):
```bash
kubectl delete -f k8s/hpa.yml
kubectl delete -f k8s/bankapp-deployment.yml
kubectl delete -f k8s/ollama-deployment.yml
kubectl delete -f k8s/mysql-deployment.yml
kubectl delete -f k8s/service.yml
kubectl delete -f k8s/secrets.yml
kubectl delete -f k8s/configmap.yml
kubectl delete -f k8s/pvc.yml
kubectl delete -f k8s/pv.yml
kubectl delete -f k8s/namespace.yml
```

To destroy everything (do this at the end of Day 83 or if taking a break):
```bash
cd terraform
terraform destroy
```

**Document:** What are the cost components of the AI-BankApp EKS setup? Why is the NAT Gateway surprisingly expensive?

---

## Hints
- `terraform apply` for EKS takes 15-20 minutes -- the control plane provisioning is the longest step
- If Terraform fails midway, run `terraform apply` again -- it is idempotent and will resume from where it stopped
- The VPC CNI plugin gives each pod its own VPC IP -- pods are directly routable within the VPC
- `t3.medium` (2 vCPU, 4 GB RAM) can run approximately 17 pods per node (limited by ENI/IP allocation)
- The AI-BankApp's Ollama pod needs 2-2.5Gi RAM -- make sure your nodes have enough capacity
- If `kubectl` cannot connect after `terraform apply`, run the `aws eks update-kubeconfig` command from the Terraform output
- ArgoCD is installed by Terraform but the Application manifest is not applied yet -- that comes on Day 84
- Reference: https://github.com/TrainWithShubham/AI-BankApp-DevOps (branch: `feat/gitops`) -- `terraform/` directory

---

## Documentation
Create `day-81-eks-intro.md` with:
- EKS architecture diagram (VPC, subnets, control plane, node group, add-ons)
- Each Terraform file explained in your own words
- Screenshot of `kubectl get nodes` showing 3 EKS nodes across AZs
- Screenshot of `kubectl get pods -n kube-system` showing all add-ons
- Screenshot of the AI-BankApp running on EKS (login page or dashboard)
- Screenshot of `kubectl get pvc -n bankapp` showing EBS-backed volumes
- EKS cost breakdown table
- ArgoCD login URL and confirmation it is accessible

---

## Submission
1. Add `day-81-eks-intro.md` to `2026/day-81/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Provisioned a production-grade EKS cluster using the AI-BankApp's Terraform configs today -- VPC with 9 subnets across 3 AZs, managed node group, 6 EKS add-ons including EBS CSI driver and metrics server, plus ArgoCD pre-installed via Helm. Deployed the AI-BankApp with MySQL and Ollama AI chatbot on EKS. Infrastructure as Code from day one."

`#90DaysOfDevOps` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
