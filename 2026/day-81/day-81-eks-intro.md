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

<img width="400" height="782" alt="image" src="https://github.com/user-attachments/assets/c62e658b-9ab7-475d-804b-d9b8b79b667f" />

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

**Steps to follow:**

-->**Provision the EKS Cluster:** In this task, you'll use Terraform to create the complete AWS infrastructure for the AI-BankApp, including the VPC, EKS cluster, node group, add-ons, IAM roles, and ArgoCD.

**Step 1: Verify Required Tools: Check that all required tools are installed.**

-->terraform --version

-->aws --version

-->kubectl version --client

-->helm version

<img width="1747" height="396" alt="image" src="https://github.com/user-attachments/assets/75d58959-b3b3-465f-91a3-b6526fc265d7" />

Step 2: Verify AWS Permissions: 

-->To set the User identity OR Configure AWS CLI: aws configure

-->Once configuration done Test your current identity: aws sts get-caller-identity  

<img width="1727" height="291" alt="image" src="https://github.com/user-attachments/assets/3dca0d10-aff9-4070-8407-d8d2c420ca38" />

Step 3: Move to Terraform Directory: 

-->cd AI-BankApp-DevOps/terraform & verify files fir that run command: ls 

<img width="1297" height="102" alt="image" src="https://github.com/user-attachments/assets/49e204e6-02bc-4ecb-ae7e-63054c3bb9ab" />

Step 4: Initialize Terraform:

-->So inside terraform dir run command: terraform init

-->Terraform downloads: AWS provider, Helm provider, VPC module, EKS module etc.

**Note:** While terraform init faced issue:

<img width="1877" height="250" alt="image" src="https://github.com/user-attachments/assets/09e3ca58-d5a9-430a-9eb5-ecce40095a3f" />

-->This error occurs because your .terraform.lock.hcl file has locked the AWS provider to 6.40.0, but one of the modules now requires >= 6.42.0.

-->So to Fix this run command: terraform init -upgrade [This tells Terraform to ignore the locked provider version and download a newer compatible version.]

-->Verify which module requires the newer version: terraform providers

-->If terraform init -upgrade still fails: Then first Delete the Terraform cache and lock file, then reinitialize: For that run below commands:

1. rm -rf .terraform

2. rm -f .terraform.lock.hcl

3. terraform init OR terraform init -upgrade

<img width="715" height="532" alt="image" src="https://github.com/user-attachments/assets/5b63ca3c-b789-4821-b7f5-0a923920320b" />

<img width="1252" height="872" alt="image" src="https://github.com/user-attachments/assets/d53884b8-0747-48c0-a0b8-2e49ab2aade1" />

<img width="1080" height="901" alt="image" src="https://github.com/user-attachments/assets/a732dce8-9134-4b29-97d9-f04826f1e3eb" />

Step 5: Validate Configuration (Recommended):

-->Before planning: terraform validate   [Expected: Success! The configuration is valid.]

-->If validation fails: Check syntax errors, Ensure all files exist, Verify Terraform version etc.

Step 6: Review the Execution Plan: Terraform calculates everything it intends to create, The output may be very long.

-->Run command: terraform plan  

<img width="1917" height="966" alt="image" src="https://github.com/user-attachments/assets/1242909a-4bf8-40b7-b49d-ed58ff4cc5dd" />

<img width="1817" height="976" alt="image" src="https://github.com/user-attachments/assets/6b32b2eb-897d-477a-a23a-6ea997207cd8" />

**Understand What Terraform Will Create:**

<img width="527" height="712" alt="image" src="https://github.com/user-attachments/assets/86ef6d89-54f2-4984-8e0e-e8c19fcc7c30" />

<img width="402" height="752" alt="image" src="https://github.com/user-attachments/assets/b271daed-e8a8-47ef-9861-5142a7fa080c" />

<img width="632" height="587" alt="image" src="https://github.com/user-attachments/assets/123ab351-11d3-4df4-9a4f-25e655f2bf0a" />

Step 7: Apply the Infrastructure: 

-->When the plan looks correct: terraform apply OR terraform apply --auto-approve

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/cf2e8031-db22-4f2a-aded-89a9174eaac6" />

<img width="1911" height="977" alt="image" src="https://github.com/user-attachments/assets/73390d06-e863-463a-a814-4299709f83b9" />

<img width="647" height="635" alt="image" src="https://github.com/user-attachments/assets/13754a35-b6bf-4ad5-a4ae-8748ee568a9b" />

<img width="535" height="737" alt="image" src="https://github.com/user-attachments/assets/c9d5f8ae-8517-4989-9f59-ce19b8f1af21" />

<img width="637" height="812" alt="image" src="https://github.com/user-attachments/assets/c66e453c-25e4-47ca-af6c-890f6354d463" />

**Common Issues:**

<img width="531" height="696" alt="image" src="https://github.com/user-attachments/assets/bfdce0b0-dee7-4f43-83d3-3f01a7722648" />

<img width="656" height="566" alt="image" src="https://github.com/user-attachments/assets/e6d1f00d-fd1f-4a2d-b818-738d4eac81e1" />

Step 8: Review Terraform Outputs: These outputs help you connect to the cluster and access ArgoCD.

-->After successful completion: terraform output

<img width="1872" height="397" alt="image" src="https://github.com/user-attachments/assets/d1fd9b53-9f4d-438f-9778-570881e04547" />

Step 9: Save Important Information: Record: Cluster Name, AWS Region, Node Count, ArgoCD Password Command, kubectl Configuration Command

<img width="637" height="627" alt="image" src="https://github.com/user-attachments/assets/10972b03-ff39-44cc-b4b5-f33bb3fabcef" />

**Verification Checklist:**

-->terraform init        

-->terraform validate    

-->terraform plan        

-->terraform apply      

-->terraform output  

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

**Steps to follow:**

-->Before starting, make sure terraform apply completed successfully and you can see outputs from: terraform output

<img width="1832" height="471" alt="image" src="https://github.com/user-attachments/assets/cd7f645d-2891-4d71-951c-3654dbfa92aa" />

Step 1: Configure kubectl Access: EKS does not automatically configure kubectl.

-->aws eks update-kubeconfig --name bankapp-eks --region ap-south-1

<img width="1911" height="185" alt="image" src="https://github.com/user-attachments/assets/e1285787-42bf-436e-81d4-3bb2db0cf295" />

Step 2: Verify Current Context: Check which cluster kubectl is connected to: kubectl config current-context

**Note:** If you have multiple clusters: kubectl config get-contexts

<img width="1901" height="237" alt="image" src="https://github.com/user-attachments/assets/21c0566b-684c-4948-bd63-e643479afa87" />

Step 3: Verify Cluster Connectivity: kubectl cluster-info

**Note:** If you see: connection refused or Unauthorized verify: **aws sts get-caller-identity** and ensure you're using the same AWS account that created the cluster.

<img width="1912" height="142" alt="image" src="https://github.com/user-attachments/assets/2eae42b6-fc0c-48f8-98a4-3d1bbe3adaec" />

Step 4: Verify Worker Nodes: 

-->List nodes: kubectl get nodes -o wide [Expected: You should see: 3 nodes, STATUS = Ready, Internal VPC IPs]

<img width="1917" height="101" alt="image" src="https://github.com/user-attachments/assets/b7ef8cef-39fc-41b6-b3af-869ffe42053a" />

<img width="1871" height="117" alt="image" src="https://github.com/user-attachments/assets/b66a106e-231c-4c47-b2ca-a11d123b5d0c" />

Step 5: Verify Node Instance Type: 

-->Check labels: kubectl get nodes --show-labels | grep instance-type OR kubectl get nodes -L node.kubernetes.io/instance-type

<img width="1861" height="142" alt="image" src="https://github.com/user-attachments/assets/35050281-2ed9-4a09-8612-b57e5bed5881" />

<img width="1907" height="350" alt="image" src="https://github.com/user-attachments/assets/d80e3b10-1bec-4c01-b5b0-c1604055d3e4" />

-->Expected: used instance type should be display

Step 6: Verify Availability Zones: 

-->Check node placement: kubectl get nodes -L topology.kubernetes.io/zone [Expected: This confirms the node group spans 3 Availability Zones.]

<img width="1241" height="107" alt="image" src="https://github.com/user-attachments/assets/fb5a6583-4b9a-447d-8a54-09a25d415b4c" />

Step 7: Explore System Pods: View Kubernetes system components: kubectl get pods -n kube-system

<img width="612" height="452" alt="image" src="https://github.com/user-attachments/assets/9a14e4c2-e3b7-47ab-b4e0-5d03d72faa9a" />

<img width="1302" height="322" alt="image" src="https://github.com/user-attachments/assets/8ee3a5e1-6a4b-49ef-a35b-692bf42e8aef" />

Step 8: Verify DaemonSets: 

-->DaemonSets ensure one pod runs on every node: kubectl get daemonsets -n kube-system

<img width="641" height="396" alt="image" src="https://github.com/user-attachments/assets/b7353f3b-babe-4411-9b0c-2a984e8bdd9a" />

<img width="1675" height="132" alt="image" src="https://github.com/user-attachments/assets/016fc733-5bad-43ca-8f89-e5d2a9522607" />

Step 9: Verify EBS CSI Driver: 

-->Check CSI controller: kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver

<img width="681" height="451" alt="image" src="https://github.com/user-attachments/assets/464d8423-0c4a-44d1-9445-c06e65a66961" />

<img width="1757" height="132" alt="image" src="https://github.com/user-attachments/assets/a64a3b4d-a56c-402d-82d4-0655b9dc8546" />

Step 10: Verify Metrics Server: kubectl top nodes

<img width="597" height="382" alt="image" src="https://github.com/user-attachments/assets/1e6d964c-f921-45a9-861b-f5fe1af83670" />

<img width="1221" height="92" alt="image" src="https://github.com/user-attachments/assets/da5e41be-cd62-4b95-b7b8-83f15e974761" />

Step 11: Verify ArgoCD Pods: 

-->Check namespace: kubectl get pods -n argocd

<img width="630" height="340" alt="image" src="https://github.com/user-attachments/assets/ac76c40a-7a80-4788-a443-18b7ee4e62d4" />

<img width="1487" height="157" alt="image" src="https://github.com/user-attachments/assets/f8d71aea-d2da-4f9b-b271-e9239dac837d" />

Step 12: Verify ArgoCD Service: 

-->Check service exposure: kubectl get svc -n argocd

**Note:** The EXTERNAL-IP or hostname may take several minutes.

<img width="1781" height="142" alt="image" src="https://github.com/user-attachments/assets/cc64447f-07e5-4f80-b0e4-a8a6bdce29bf" />

Step 13: Get ArgoCD Admin Password: 

-->Retrieve the initial password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

**Note:** Save it somewhere safe.

<img width="1912" height="77" alt="image" src="https://github.com/user-attachments/assets/37709bb9-554c-4449-af67-c7bceafaff36" />

Step 14: Get ArgoCD URL: 

-->Retrieve the LoadBalancer hostname: kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

<img width="582" height="271" alt="image" src="https://github.com/user-attachments/assets/4c1abab0-b69f-4c7e-8de7-cd20a6fc75d6" />

<img width="1907" height="82" alt="image" src="https://github.com/user-attachments/assets/be3802ba-80de-49bc-b1c7-7a5b22cbe888" />

Step 15: Open ArgoCD: 

-->Open: http://<load-balancer-hostname OR https://<load-balancer-hostname> [Login by providing UN: admin & PSWD: Password from 13th step]

Ex: http://a102287f3d8304ddfa6128b16a5290ca-1311083611.ap-south-1.elb.amazonaws.com

<img width="1912" height="967" alt="image" src="https://github.com/user-attachments/assets/978d9bf5-d4df-4124-8ef0-118dd266d3db" />

<img width="1906" height="966" alt="image" src="https://github.com/user-attachments/assets/4b2e8a3b-7e64-4b63-87e2-62f8bcdac96e" />

**Final Verification Checklist:**

-->kubectl config current-context

-->kubectl cluster-info

-->kubectl get nodes -o wide

-->kubectl get pods -n kube-system

-->kubectl get daemonsets -n kube-system

-->kubectl top nodes

-->kubectl get pods -n argocd

-->kubectl get svc -n argocd

<img width="355" height="277" alt="image" src="https://github.com/user-attachments/assets/87f278c9-a8d0-4ffa-a473-b71076647fef" />

**Note:** If any step fails use below command:

-->kubectl get nodes -o wide

-->kubectl get pods -A

-->kubectl get svc -n argocd

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
**Steps to follow:**

-->Deploy the AI-BankApp Manually (Before ArgoCD), So The goal of this task is to verify that:

-->EKS cluster is healthy

-->EBS CSI Driver works

-->Persistent Volumes can be created

-->MySQL starts successfully

-->Ollama can pull the TinyLlama model

-->BankApp can connect to both services

-->HPA is created successfully

Step 1: Verify You're Connected to EKS: Before deploying, make sure you're NOT on the old Kind cluster.

-->kubectl config current-context

-->Check the nodes: kubectl get nodes  [Expected: You should see EKS worker nodes in Ready state.]

 Step 2: Move to Repository Root: We are currently inside AI-BankApp-DevOps/terraform dir, So go back one step cd .. and then run command pwd & after that run command: ls k8s

<img width="1271" height="177" alt="image" src="https://github.com/user-attachments/assets/125619f9-ab25-4cde-9499-958a5eae585a" />

Step 3: Create Namespace: kubectl apply -f k8s/namespace.yml

-->then verify created namespace: kubectl get ns

<img width="1290" height="242" alt="image" src="https://github.com/user-attachments/assets/4518d80d-0a25-4adf-b02b-401cf7e08d43" />

Step 4: Deploy Storage Resources: Apply PV and PVC definitions:

-->Apply pv: kubectl apply -f k8s/pv.yml

-->apply pvc: kubectl apply -f k8s/pvc.yml

-->To verify created pv: kubectl get pv

-->To verify created pvc: kubectl get pvc

<img width="1371" height="892" alt="image" src="https://github.com/user-attachments/assets/5245d856-e22a-4d1d-b068-73099bed3ca1" />

**Note:** Initially: Pending is normal.Once EBS volumes are provisioned: Bound should appear.

<img width="677" height="630" alt="image" src="https://github.com/user-attachments/assets/e74122f6-9ab3-4feb-aafa-c7cf9fdea965" />

Step 5: Deploy Configuration: 

-->kubectl apply -f k8s/configmap.yml

-->kubectl apply -f k8s/secrets.yml

-->verify configmap: kubectl get configmap -n bankapp

-->verify secret: kubectl get secrets -n bankapp

<img width="1492" height="236" alt="image" src="https://github.com/user-attachments/assets/fe1750c7-6729-4e81-b02e-766ae0754ace" />

Step 6: Deploy MySQL: kubectl apply -f k8s/mysql-deployment.yml

-->To verify: kubectl get pods -n bankapp -w

<img width="1217" height="122" alt="image" src="https://github.com/user-attachments/assets/5803a52a-52ca-46bd-9ad1-b4398c0af64c" />

**And if MySQL isn't starting:** 

-->To check the deployment logs use command: kubectl logs -n bankapp deployment/mysql

-->To check the pod details: kubectl describe pod <mysql-pod-name> -n bankapp

Step 7: Deploy Services: kubectl apply -f k8s/service.yml

-->To verify: kubectl get svc -n bankapp

<img width="1320" height="185" alt="image" src="https://github.com/user-attachments/assets/36e7f809-8faf-4581-9903-315438b2fa01" />

Step 8: Deploy Ollama: kubectl apply -f k8s/ollama-deployment.yml  [Expected: This may take several minutes, This is usually the longest step.]

-->To verify: kubectl get pods -n bankapp -w

<img width="1292" height="180" alt="image" src="https://github.com/user-attachments/assets/6c06a717-39d3-4bdc-ade8-dec9091ed557" />

**Monitor Ollama Model Download:**

-->Check logs: kubectl logs -f deployment/ollama -n bankapp   [Expected: You should see TinyLlama being downloaded.]

<img width="1917" height="970" alt="image" src="https://github.com/user-attachments/assets/e166a194-5eb6-4fc6-abd8-5a9477e1809f" />

Step 9: Deploy BankApp: kubectl apply -f k8s/bankapp-deployment.yml

-->The BankApp uses init containers, **Startup sequence:** MySQL --> Ollama --> BankApp Init Containers --> BankApp

-->once deployment is complete check the status: kubectl get pods -n bankapp -w

<img width="1467" height="265" alt="image" src="https://github.com/user-attachments/assets/dddfb37f-d1a8-4924-b8fe-9ca82d38a47c" />

Step 10: Deploy HPA: kubectl apply -f k8s/hpa.yml

-->verify: kubectl get hpa -n bankapp

<img width="1612" height="115" alt="image" src="https://github.com/user-attachments/assets/bed7dd51-35c8-4c93-b45a-7767d02ac10e" />

Step 11: Verify All Pods: kubectl get pods -n bankapp  [Expected: all should running]

Step 12: Verify PVCs: kubectl get pvc -n bankapp [Expected: status should be bound]

-->Also check volume: kubectl get pv   [Expected: 5Gi, 10Gi bound]

Step 13: Verify EBS Volumes: 

-->List AWS-backed volumes: kubectl describe pvc -n bankapp  [Expected: StorageClass, Volume, Capacity]

<img width="1772" height="902" alt="image" src="https://github.com/user-attachments/assets/fa480127-bdc5-4923-9551-fcef3e6a2ccb" />

Step 14: Access the Application: 

-->Forward the service: kubectl port-forward svc/bankapp-service -n bankapp 8080:8080

-->here keep the terminal open & then in browser launch URL: http://localhost:8080  [Expected: AI-BankApp Login Page]

<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/66b68ee1-04e0-483d-8471-f8e5d6a93ef4" />

Step 15: Test the Application: 

<img width="597" height="752" alt="image" src="https://github.com/user-attachments/assets/698ba67d-4a34-40a1-8315-6ffcab72e182" />

<img width="1912" height="972" alt="image" src="https://github.com/user-attachments/assets/497b39bf-a265-45ad-9682-60743b06c20e" />

<img width="1917" height="977" alt="image" src="https://github.com/user-attachments/assets/1dc266b9-61f4-4088-96e9-f6b9a24cd591" />

<img width="1907" height="952" alt="image" src="https://github.com/user-attachments/assets/21a58409-8334-4694-af32-02cbc2650e43" />

<img width="1912" height="967" alt="image" src="https://github.com/user-attachments/assets/f258456f-1cd8-4042-89d7-0f511297c307" />

**Troubleshooting Commands:**

-->Check all resources: kubectl get all -n bankapp

-->View events: kubectl get events -n bankapp --sort-by=.metadata.creationTimestamp

-->Describe pod: kubectl describe pod <pod-name> -n bankapp

-->View logs MySQL: kubectl logs deployment/mysql -n bankapp

-->View logs Ollama: kubectl logs deployment/ollama -n bankapp

-->View logs BankApp: kubectl logs deployment/bankapp -n bankapp

**Expected Final State:**

-->kubectl get pods -n bankapp

-->kubectl get pvc -n bankapp

-->kubectl get hpa -n bankapp

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

**Steps to follow:**

-->**Understand EKS Costs and Clean-Up Strategy:** This task is important because EKS is one of the most expensive services you'll use during the 90 Days of DevOps journey. Unlike Kind or Minikube, resources continue billing even when you're not actively using the cluster.

<img width="876" height="452" alt="image" src="https://github.com/user-attachments/assets/156c8a6c-e589-4443-8588-027ab0ea3bbf" />

**Q. Why is the NAT Gateway Surprisingly Expensive?**

-->The NAT Gateway often surprises people because: It does Your EKS worker nodes are deployed in private subnets for security.

**Flow:** Internet --> NAT Gateway --> Private Subnets -->Worker Nodes

-->When pods need to: Pull Docker images, Download packages, Access AWS APIs, Download Ollama models they route traffic through the NAT Gateway.

**Q. Why it costs so much?**

-->Unlike EC2, you're charged:

<img width="711" height="516" alt="image" src="https://github.com/user-attachments/assets/1255ba25-9a41-4aec-be58-4dc782c9fcd8" />

**Clean Up the Application (Keep Cluster):**

-->kubectl delete -f k8s/hpa.yml

-->kubectl delete -f k8s/bankapp-deployment.yml

-->kubectl delete -f k8s/ollama-deployment.yml

-->kubectl delete -f k8s/mysql-deployment.yml

-->kubectl delete -f k8s/service.yml

-->kubectl delete -f k8s/secrets.yml

-->kubectl delete -f k8s/configmap.yml

-->kubectl delete -f k8s/pvc.yml

-->kubectl delete -f k8s/pv.yml

-->kubectl delete -f k8s/namespace.yml

-->Verify cleanup: kubectl get all -A

Note: you should still see: kube-system resources, ArgoCD resources, EKS add-ons but no BankApp resources.

-->Destroy Everything: 

-->cd terraform

-->terraform destroy

**Verification After Destroy:**

-->Check cluster: aws eks list-clusters

-->Check VPC: aws ec2 describe-vpcs  [Expected: Ensure the bankapp-eks VPC is gone.]





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
