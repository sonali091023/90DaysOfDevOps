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

Task 1: Understand EKS Architecture: 

1. What Does "Managed Kubernetes" Mean?

-->Self managed kubernetes:

<img width="695" height="335" alt="image" src="https://github.com/user-attachments/assets/e117eb3c-2e19-45f0-98b4-54079a91cfaa" />

-->EKS managed kubernetes:

<img width="802" height="792" alt="image" src="https://github.com/user-attachments/assets/4c9c7143-a840-4da8-8254-336012163adb" />

2. EKS Architecture Overview:

<img width="557" height="522" alt="image" src="https://github.com/user-attachments/assets/1bd68ae6-7eef-47ba-a4ff-8ad3378ee688" />

**EKS Components:** EKS Components as below,

**A. EKS Control Plane:** The control plane is the "brain" of Kubernetes.

**Components:**

1. **API Server:** Entry point for all Kubernetes requests, It receives commands from: kubectl, Terraform, Helm, Controllers etc. **Ex:** kubectl get all & once the request send, It goes to the API Server.

2. **etcd:** Stores cluster state/data: Ex: Deployments, Services, Secrets, ConfigMaps, Node information Think of etcd as Kubernetes' database.

3. **Scheduler:** Determines where Pods should run

<img width="512" height="232" alt="image" src="https://github.com/user-attachments/assets/8bb80071-89a6-4991-9475-3c371193bb63" />

4. Controller Manager: Ensures desired state matches actual state.

<img width="567" height="342" alt="image" src="https://github.com/user-attachments/assets/4136d0c8-9b70-4281-b98e-10f14cb0c11a" />

**EKS Control Plane Characteristics:**

-->Fully managed by AWS

-->Runs in an AWS-owned VPC

-->Highly available across multiple Availability Zones

-->Automatically patched and upgraded

**B. Node Groups:** Node groups contain the EC2 instances where Pods run.

1. Managed Node Groups:

<img width="607" height="457" alt="image" src="https://github.com/user-attachments/assets/225c8b04-22f4-43e3-b4ac-6c09578b71f2" />

2. Self-Managed Nodes:

<img width="651" height="387" alt="image" src="https://github.com/user-attachments/assets/67fd397b-df99-424d-b515-64cdaa583bc9" />

3. Fargate Profiles:

<img width="637" height="422" alt="image" src="https://github.com/user-attachments/assets/795a9ffa-1e36-4b8a-9e20-4734b986e59f" />

C. VPC and Networking: EKS runs within your AWS VPC

<img width="462" height="510" alt="image" src="https://github.com/user-attachments/assets/63541e0e-568c-49ef-998f-c4f045a867d6" />

1. Pod Networking: Unlike many Kubernetes distributions, EKS uses AWS networking directly.

-->Each Pod receives: A VPC IP address & Direct communication capability, So This is enabled through the AWS VPC CNI[Container network interface] plugin.

D. IAM Integration: One of EKS's biggest advantages is integration with AWS IAM.







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
