# Day 66 -- Provision an EKS Cluster with Terraform Modules

## Task
You built Kubernetes clusters manually in the Kubernetes week. Today you provision one the DevOps way -- fully automated, repeatable, and destroyable with a single command. You will use Terraform registry modules to create an AWS EKS cluster with a managed node group, connect kubectl, and deploy a workload.

This is what infrastructure teams do every day in production.

---

## Expected Output
- A running EKS cluster on AWS provisioned entirely through Terraform
- kubectl connected to the cluster with nodes visible
- An Nginx deployment running on the cluster
- A markdown file: `day-66-eks-terraform.md`
- Everything destroyed cleanly after the exercise

---

## Challenge Tasks

### Task 1: Project Setup
Create a new project directory with proper file structure:

```
terraform-eks/
  providers.tf        # Provider and backend config
  vpc.tf              # VPC module call
  eks.tf              # EKS module call
  variables.tf        # All input variables
  outputs.tf          # Cluster outputs
  terraform.tfvars    # Variable values
```

In `providers.tf`:
1. Pin the AWS provider to `~> 5.0`
2. Pin the Kubernetes provider (you will need it later)
3. Set your region

In `variables.tf`, define:
- `region` (string)
- `cluster_name` (string, default: `"terraweek-eks"`)
- `cluster_version` (string, default: `"1.31"`)
- `node_instance_type` (string, default: `"t3.medium"`)
- `node_desired_count` (number, default: `2`)
- `vpc_cidr` (string, default: `"10.0.0.0/16"`)
---
<img width="1198" height="287" alt="image" src="https://github.com/user-attachments/assets/05ed0a59-7265-43bf-8989-aa715c306227" />

### Task 2: Create the VPC with Registry Module
EKS requires a VPC with both public and private subnets across multiple availability zones.

In `vpc.tf`, use the `terraform-aws-modules/vpc/aws` module:
1. CIDR: `var.vpc_cidr`
2. At least 2 availability zones
3. 2 public subnets and 2 private subnets
4. Enable NAT gateway (single NAT to save cost): `enable_nat_gateway = true`, `single_nat_gateway = true`
5. Enable DNS hostnames: `enable_dns_hostnames = true`
6. Add the required EKS tags on subnets:
```hcl
public_subnet_tags = {
  "kubernetes.io/role/elb" = 1
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = 1
}
```

Run `terraform init` and `terraform plan` to verify the VPC config before moving on.

<img width="1826" height="978" alt="image" src="https://github.com/user-attachments/assets/f2194010-eb47-4de7-9730-7dd948a1e3cd" />
<img width="1427" height="978" alt="image" src="https://github.com/user-attachments/assets/0e78ff50-e98d-481b-8fae-ceaf2bcceb08" />
<img width="1621" height="978" alt="image" src="https://github.com/user-attachments/assets/936ef224-9428-4655-a9e8-4a97058ce350" />

**Document:** Why does EKS need both public and private subnets? What do the subnet tags do?

**Public Subnets:** Public subnets are used for: Load balancers, Internet-facing services & NAT Gateway. These subnets have routes to the Internet Gateway.

Example: 

-->A public application Load Balancer (ALB)

-->External traffic entering the cluster

**Public Subnet Tag:** "kubernetes.io/role/elb" = 1

-->This public subnet tells EKS: “This subnet can host public Elastic Load Balancers." then Kubernetes automatically places public load balancers here.

**Private Subnets:** Private subnets are used for: EKS worker nodes, Internal services & Pods and workloads. These subnets do NOT have direct internet access.

Instead:

-->Outbound internet access goes through the NAT Gateway

-->Inbound traffic from the internet is blocked

**Note:** This improves security.

**Private Subnet Tag:** "kubernetes.io/role/internal-elb" = 1

-->This tells EKS: “This subnet can host internal/private load balancers.”

-->Which is Used for: Internal applications, Private services, Internal traffic only etc.

<img width="607" height="377" alt="image" src="https://github.com/user-attachments/assets/81da665a-f602-4a29-9c33-0796945feaa9" />

---

### Task 3: Create the EKS Cluster with Registry Module
In `eks.tf`, use the `terraform-aws-modules/eks/aws` module:

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    terraweek_nodes = {
      ami_type       = "AL2_x86_64"
      instance_types = [var.node_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = var.node_desired_count
    }
  }

  tags = {
    Environment = "dev"
    Project     = "TerraWeek"
    ManagedBy   = "Terraform"
  }
}
```

Run:
```bash
terraform init      # Download EKS module and its dependencies
terraform plan      # Review -- this will create 30+ resources
```
<img width="1666" height="968" alt="image" src="https://github.com/user-attachments/assets/71571110-3caf-46fe-b061-81f1566d9aa1" />
<img width="1797" height="981" alt="image" src="https://github.com/user-attachments/assets/3dd9453e-2e35-4eff-9735-a6a3bcbf2384" />
<img width="1892" height="977" alt="image" src="https://github.com/user-attachments/assets/6aa55874-306d-4ac6-b79b-23aa1bec28a1" />

Review the plan carefully before applying. You should see: EKS cluster, IAM roles, node group, security groups, and more.

---

### Task 4: Apply and Connect kubectl
1. Apply the config:
```bash
terraform apply
```
This will take 10-15 minutes. EKS cluster creation is slow -- be patient.

2. Add outputs in `outputs.tf`:
```hcl
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_region" {
  value = var.region
}
```

3. Update your kubeconfig:
```bash
aws eks update-kubeconfig --name terraweek-eks --region <your-region>
```
<img width="1918" height="972" alt="image" src="https://github.com/user-attachments/assets/adda0421-2491-41cd-b7ad-b2ff45af8105" />
<img width="1702" height="977" alt="image" src="https://github.com/user-attachments/assets/7231a8f5-d796-4303-9f2a-69f6615861d3" />
<img width="1641" height="982" alt="image" src="https://github.com/user-attachments/assets/0529648b-1b5d-4520-a1c6-0caacb5e41bf" />
<img width="1918" height="962" alt="image" src="https://github.com/user-attachments/assets/30df0b00-eee9-4909-9c73-2787c7e57d65" />

4. Verify:
```bash
kubectl get nodes
kubectl get pods -A
kubectl cluster-info

```
Note: After destroying and re-creating the cluster with terraform destroy + terraform apply, kubectl stopped working again with a new error:
"Unable to connect to the server: dial tcp: lookup 1D86A33DEF483A641CC4CE1E68DF555E.gr7.ap-south-1.eks.amazonaws.com on 10.255.255.254:53: no such host"

-->So the Root Cause is: This is completely different from Issue #1. Every time you destroy and re-create an EKS cluster, AWS assigns it a brand new unique endpoint URL. The local kubeconfig file at ~/.kube/config still pointed to the old. cluster's endpoint, which no longer existed — causing the DNS lookup to fail
[Think of it like a restaurant that moved to a new address. Your saved address (kubeconfig) still points to the old
location.]

-->To fix it run command: aws eks update-kubeconfig --region ap-south-1 --name terraweek-eks  [Note: This fetches the new cluster endpoint and updates ~/.kube/config automatically.]

<img width="1762" height="330" alt="image" src="https://github.com/user-attachments/assets/4f00cf76-96f2-4069-a4b8-e7ceb0debd1d" />

**Verify:** Do you see 2 nodes in `Ready` state? Can you see the kube-system pods running?
-->Yes instances got launch successfully, And i can see cube-system pod running successfully

---

### Task 5: Deploy a Workload on the Cluster
Your Terraform-provisioned cluster is live. Deploy something on it.

1. Create a file `k8s/nginx-deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-terraweek
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

2. Apply:
```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

3. Wait for the LoadBalancer to get an external IP:
```bash
kubectl get svc nginx-service -w
```

4. Access the Nginx page via the LoadBalancer URL

5. Verify the full picture:
```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc
```

**Verify:** Can you access the Nginx welcome page through the LoadBalancer URL?

---

### Task 6: Destroy Everything
This is the most important step. EKS clusters cost money. Clean up completely.

1. First, remove the Kubernetes resources (so the AWS LoadBalancer gets deleted):
```bash
kubectl delete -f k8s/nginx-deployment.yaml
```

2. Wait for the LoadBalancer to be fully removed (check EC2 > Load Balancers in AWS console)

3. Destroy all Terraform resources:
```bash
terraform destroy
```
This will take 10-15 minutes.

4. Verify in the AWS console:
   - EKS clusters: empty
   - EC2 instances: no node group instances
   - VPC: the terraweek VPC should be gone
   - NAT Gateways: deleted
   - Elastic IPs: released

**Verify:** Is your AWS account completely clean? No leftover resources?

---

## Hints
- EKS creation takes 10-15 minutes, destruction takes about the same -- plan your time
- Always delete Kubernetes LoadBalancer services before `terraform destroy`, otherwise the ELB will block VPC deletion
- If `terraform destroy` gets stuck, check for leftover ENIs or security groups in the VPC
- `t3.medium` is the minimum recommended instance type for EKS nodes
- The EKS module creates IAM roles automatically -- you don't need to create them manually
- If you see `Unauthorized` with kubectl, re-run the `aws eks update-kubeconfig` command
- Use `kubectl get events --sort-by=.metadata.creationTimestamp` to debug pod issues
- Cost warning: NAT Gateway charges ~$0.045/hour. Destroy when done.

---

## Documentation
Create `day-66-eks-terraform.md` with:
- Your complete file structure and key config files
- Screenshot of `terraform apply` completing
- Screenshot of `kubectl get nodes` showing the managed node group
- Screenshot of Nginx running on the cluster
- How many resources Terraform created in total (check the apply output)
- The destroy process and verification
- Reflection: compare this to manually setting up a cluster with kind/minikube (Day 50)

---

## Submission
1. Add `day-66-eks-terraform.md` to `2026/day-66/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Provisioned a full AWS EKS cluster with Terraform modules today -- VPC, subnets, NAT gateway, IAM roles, node groups, the works. 30+ resources created with one command, deployed Nginx on it, and destroyed everything cleanly. This is real-world infrastructure as code."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
