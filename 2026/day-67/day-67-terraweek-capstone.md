# Day 67 -- TerraWeek Capstone: Multi-Environment Infrastructure with Workspaces and Modules

## Task
Seven days of Terraform -- HCL, providers, resources, dependencies, variables, outputs, data sources, state management, remote backends, custom modules, registry modules, and a full EKS cluster. Today you put it all together in one production-grade project.

Build a multi-environment AWS infrastructure using custom modules and Terraform workspaces. One codebase, three environments -- dev, staging, and prod. This is how infrastructure teams operate at scale.

---

## Expected Output
- A complete Terraform project with custom modules and proper file structure
- Three separate environments (dev, staging, prod) deployed using workspaces
- Each environment with its own VPC, security group, and EC2 instance with different sizing
- A markdown file: `day-67-terraweek-capstone.md`
- Everything destroyed cleanly after verification

---

## Challenge Tasks

### Task 1: Learn Terraform Workspaces
Before building the project, understand workspaces:

```bash
mkdir terraweek-capstone && cd terraweek-capstone
terraform init

# See current workspace
terraform workspace show                    # default

# Create new workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# List all workspaces
terraform workspace list

# Switch between them
terraform workspace select dev
terraform workspace select staging
terraform workspace select prod
```
<img width="1583" height="910" alt="image" src="https://github.com/user-attachments/assets/0b1715cd-b120-45fa-8e27-2d20244fd9bf" />

Answer:
1. What does `terraform.workspace` return inside a config?
-->terraform.workspace returns the name of the currently selected Terraform workspace, It helps create environment-specific infrastructure. So Default workspace name is: default unless you create new workspace.
2. Where does each workspace store its state file?

-->In Terraform, each workspace keeps a separate state file so environments do not overwrite each other.

1. **Local Backend:**  If you are using the default local backend: default workspace: terraform.tfstate

2. **other workspaces:** Stored inside: terraform.tfstate.d/<workspace-name>/terraform.tfstate Eg: terraform.tfstate.d/dev/terraform.tfstate

3. **Remote Backend (like S3):** If using an S3 backend, Terraform stores separate state objects per workspace. Terraform automatically prefixes non-default workspaces with:
env:/<workspace-name>/
<img width="293" height="611" alt="image" src="https://github.com/user-attachments/assets/33448a9a-2782-43f0-ad53-6209a7888029" />

3. How is this different from using separate directories per environment?
-->Using Terraform workspaces and using separate directories both isolate environments, but they do it differently.

-->Using Workspaces Example: **terraform workspace new dev**, **terraform workspace new prod**, So same Terraform codebase, different state files.

<img width="311" height="547" alt="image" src="https://github.com/user-attachments/assets/638966b2-88c8-44f6-94ee-bccdd61998d9" />

-->So the benifits to use different workspases aer Strong isolation, Safer for production, Easier CI/CD pipelines, Different configs/backends/IAM per environment, Clear separation of responsibility etc.

-->And some of the non benificial things are More files/directories, Slight duplication, More setup effort etc.
<img width="717" height="761" alt="image" src="https://github.com/user-attachments/assets/3c74d6c6-655a-4596-8495-65c318c1fb05" />

---

### Task 2: Set Up the Project Structure
Create this layout:

```
terraweek-capstone/
  main.tf                   # Root module -- calls child modules
  variables.tf              # Root variables
  outputs.tf                # Root outputs
  providers.tf              # AWS provider and backend
  locals.tf                 # Local values using workspace
  dev.tfvars                # Dev environment values
  staging.tfvars            # Staging environment values
  prod.tfvars               # Prod environment values
  .gitignore                # Ignore state, .terraform, tfvars with secrets
  modules/
    vpc/
      main.tf
      variables.tf
      outputs.tf
    security-group/
      main.tf
      variables.tf
      outputs.tf
    ec2-instance/
      main.tf
      variables.tf
      outputs.tf
```

Create the `.gitignore`:
```
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
```
<img width="1222" height="557" alt="image" src="https://github.com/user-attachments/assets/d99d8ec9-94bc-41c8-b774-45d69ab747c4" />

**Document:** Why is this file structure considered best practice?
-->Using separate environment directories with reusable modules is considered best practice in Terraform because it improves:isolation, safety, maintainability, scalability etc.

<img width="368" height="472" alt="image" src="https://github.com/user-attachments/assets/8e83377d-e9d6-423f-adec-acc12396230c" />
<img width="363" height="543" alt="image" src="https://github.com/user-attachments/assets/1a6d43e0-86f1-43ca-b904-cb301f0cf17f" />
<img width="368" height="333" alt="image" src="https://github.com/user-attachments/assets/e1023f0f-ea42-4ab8-aad2-44b2b716da5c" />
<img width="382" height="390" alt="image" src="https://github.com/user-attachments/assets/9a5ae041-1241-43c7-995d-2d53c25ec482" />
<img width="525" height="541" alt="image" src="https://github.com/user-attachments/assets/9f0dd87b-ae54-40b0-9877-1add694fdcd6" />
<img width="617" height="592" alt="image" src="https://github.com/user-attachments/assets/d0fa5ae2-f98a-4148-85b6-d474ce3e5352" />

**Note:** It follows the core Infrastructure-as-Code principle: “Reusable modules + isolated environments = maintainable infrastructure.” 

---

### Task 3: Build the Custom Modules
Create three focused modules:

**Module 1: `modules/vpc/`**
- Input: `cidr`, `public_subnet_cidr`, `environment`, `project_name`
- Resources: VPC, public subnet, internet gateway, route table, route table association
- Output: `vpc_id`, `subnet_id`
- All resources tagged with environment and project name

**Module 2: `modules/security-group/`**
- Input: `vpc_id`, `ingress_ports`, `environment`, `project_name`
- Resources: Security group with dynamic ingress rules, allow all egress
- Output: `sg_id`

**Module 3: `modules/ec2-instance/`**
- Input: `ami_id`, `instance_type`, `subnet_id`, `security_group_ids`, `environment`, `project_name`
- Resources: EC2 instance with tags
- Output: `instance_id`, `public_ip`

Write and validate each module:
```bash
terraform validate
```
<img width="1032" height="97" alt="image" src="https://github.com/user-attachments/assets/7fe379d6-ee5b-4d27-b382-e9373dd5ed26" />

---

### Task 4: Wire It All Together with Workspace-Aware Config
In the root module, use `terraform.workspace` to drive environment-specific behavior.

**`locals.tf`:**
```hcl
locals {
  environment = terraform.workspace
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    Workspace   = terraform.workspace
  }
}
```

**`variables.tf`:**
```hcl
variable "project_name" {
  type    = string
  default = "terraweek"
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ingress_ports" {
  type    = list(number)
  default = [22, 80]
}
```

**`main.tf`** -- call all three modules, passing workspace-aware names and variables.

**Environment-specific tfvars:**

`dev.tfvars`:
```hcl
vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
instance_type = "t2.micro"
ingress_ports = [22, 80]
```

`staging.tfvars`:
```hcl
vpc_cidr      = "10.1.0.0/16"
subnet_cidr   = "10.1.1.0/24"
instance_type = "t2.small"
ingress_ports = [22, 80, 443]
```

`prod.tfvars`:
```hcl
vpc_cidr      = "10.2.0.0/16"
subnet_cidr   = "10.2.1.0/24"
instance_type = "t3.small"
ingress_ports = [80, 443]
```

**Notice:** dev allows SSH, prod does not. Different CIDRs prevent overlap. Instance types scale up per environment.

-->Exactly — that is the main reason teams use separate environment configurations in Terraform. You can now customize infrastructure per environment safely.

<img width="672" height="322" alt="image" src="https://github.com/user-attachments/assets/d7de3ab7-b9dc-45fe-bd9a-c40825ac754e" />

<img width="387" height="527" alt="image" src="https://github.com/user-attachments/assets/5b5b397c-8bb5-449b-8ca9-ec34895de36a" />

<img width="405" height="491" alt="image" src="https://github.com/user-attachments/assets/ec58b61f-f301-465c-b772-4e27b6d5242d" />

---

### Task 5: Deploy All Three Environments
Deploy each environment using its workspace and tfvars file:

**Dev:**
```bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```
<img width="1220" height="272" alt="image" src="https://github.com/user-attachments/assets/49f25ee0-3acd-4164-acab-79cea7e51858" />
<img width="1673" height="982" alt="image" src="https://github.com/user-attachments/assets/38d63c96-a33d-4c75-b817-2687703fb06b" />
<img width="1577" height="987" alt="image" src="https://github.com/user-attachments/assets/64afacbf-7c6e-4731-bd33-30afb61ec0da" />
<img width="1571" height="972" alt="image" src="https://github.com/user-attachments/assets/356e5ade-1a24-4752-a53c-d70b0f9c6fd2" />
<img width="1452" height="977" alt="image" src="https://github.com/user-attachments/assets/5f45dcb2-09c2-41f4-b1d9-9a0be2c27785" />
<img width="1902" height="877" alt="image" src="https://github.com/user-attachments/assets/c6a9e1e1-caae-4951-9ad0-188641ef8c72" />
<img width="1430" height="191" alt="image" src="https://github.com/user-attachments/assets/88ed2e9b-ea40-4b1a-890d-5c9205b8129b" />

**Staging:**
```bash
terraform workspace select staging
terraform plan -var-file="staging.tfvars"
terraform apply -var-file="staging.tfvars"
```
<img width="1348" height="302" alt="image" src="https://github.com/user-attachments/assets/36f4b6f3-a44f-4d57-b37c-a3e18a714d1c" />
<img width="1605" height="973" alt="image" src="https://github.com/user-attachments/assets/3c1b708f-71d1-4cae-a820-fe4542a2d710" />
<img width="1752" height="981" alt="image" src="https://github.com/user-attachments/assets/3382eb50-f108-4c37-bdc4-30c69ac66751" />
<img width="1702" height="978" alt="image" src="https://github.com/user-attachments/assets/94571028-7ed4-4824-8df0-a26c35fdb840" />
<img width="1678" height="977" alt="image" src="https://github.com/user-attachments/assets/c876c20f-9fd1-4eeb-87a2-d9841adfba05" />
<img width="1902" height="877" alt="image" src="https://github.com/user-attachments/assets/9acfbd9a-1f50-4add-9469-24b73a6bb994" />
<img width="1435" height="187" alt="image" src="https://github.com/user-attachments/assets/2725584c-0a52-4642-b0f7-d6bba96527bf" />

**Prod:**
```bash
terraform workspace select prod
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```
<img width="1337" height="265" alt="image" src="https://github.com/user-attachments/assets/58e615f1-e1a9-4b4d-b8f0-8999063b4ace" />
<img width="1692" height="980" alt="image" src="https://github.com/user-attachments/assets/ffc86564-7f83-46e6-a4ad-123aa10307cd" />
<img width="1716" height="973" alt="image" src="https://github.com/user-attachments/assets/d154b5fd-b32b-4d9e-88f0-349ff210bf41" />
<img width="1696" height="972" alt="image" src="https://github.com/user-attachments/assets/32984417-616d-4d01-b40c-7532a2d4b1db" />
<img width="1632" height="977" alt="image" src="https://github.com/user-attachments/assets/b4773ac0-5e9f-47bc-8a6b-8a4a526f82d8" />
<img width="1897" height="858" alt="image" src="https://github.com/user-attachments/assets/430ea2e9-7150-4af9-89d2-fefa45840853" />
<img width="1597" height="182" alt="image" src="https://github.com/user-attachments/assets/da65c828-51c1-4807-9f48-79b7fb14c99f" />

After all three are deployed, verify:
```bash
# Check each workspace's resources
terraform workspace select dev && terraform output
terraform workspace select staging && terraform output
terraform workspace select prod && terraform output
```
<img width="1542" height="208" alt="image" src="https://github.com/user-attachments/assets/fa9d41b9-825b-44b5-b914-1014b1f0d76e" />

Go to the AWS console and verify:
- Three separate VPCs with different CIDR ranges
<img width="1912" height="762" alt="image" src="https://github.com/user-attachments/assets/46f6be29-a2f4-47da-8bd7-5d5a72aab5b3" />

- Three EC2 instances with different instance types
<img width="1913" height="832" alt="image" src="https://github.com/user-attachments/assets/17d91189-8fbc-4044-aa9d-8dae0ae7c90f" />

- Different Name tags per environment: `terraweek-dev-server`, `terraweek-staging-server`, `terraweek-prod-server`
<img width="1901" height="842" alt="image" src="https://github.com/user-attachments/assets/f19164d6-a869-4662-8991-4df7661388f1" />

**Verify:** Are all three environments completely isolated from each other?
-->Yes!!!

---

### Task 6: Document Best Practices
Write down everything you have learned this week as a Terraform best practices guide:

1. **File structure** -- separate files for providers, variables, outputs, main, locals

-->Keep Terraform code organized instead of putting everything in one main.tf file. This we used to Easier maintenance, Better readability, Easier teamwork, Cleaner debugging etc.
<img width="182" height="327" alt="image" src="https://github.com/user-attachments/assets/f293ddd2-ad10-45d6-8297-dbcb3ac31ee1" />

2. **State management** -- always use remote backend, enable locking, enable versioning

-->Terraform state is critical. Never store important state locally in teams. Use: Remote backend, State locking, Versioning etc.

-->We use s3 bucket because of Team collaboration, Prevent state corruption, Backup history, Secure storage etc.

<img width="347" height="236" alt="image" src="https://github.com/user-attachments/assets/ed91b5bc-9c54-4c94-865a-ea9d16e36887" />

<img width="471" height="213" alt="image" src="https://github.com/user-attachments/assets/1ca37211-2374-4ecc-83b9-3e6f5f2301d0" />

3. **Variables** -- never hardcode the value, use tfvars per environment like dev.tfvars, prod.tfvars , validate with `validation` blocks
<img width="470" height="253" alt="image" src="https://github.com/user-attachments/assets/98fe808f-9935-4b31-ba6c-352b7dd749e5" />

4. **Modules** -- one concern per module, always define inputs/outputs, pin registry module versions

-->A module should handle ONE responsibility. for example VPC module, EC2 module, EKS module, Security group module etc.

-->Good module design is Inputs defined, Outputs exposed, Reusable, Independent etc.
<img width="197" height="331" alt="image" src="https://github.com/user-attachments/assets/7aa8e29e-20d4-43e9-a1fa-1587731ff2fe" />

5. **Workspaces** -- use for environment isolation, reference `terraform.workspace` in configs

-->Used for environment isolation.
<img width="282" height="582" alt="image" src="https://github.com/user-attachments/assets/2ab30504-e76b-4aa2-8df7-53fc661728b8" />

6. **Security** -- .gitignore for state, secrets and tfvars, encrypt state at rest, restrict backend access Use IAM policies: Only Terraform users/roles can access state bucket.

7. **Commands** -- always run `plan` before `apply`, use `fmt` and `validate` before committing

-->terraform plan                [Preview changes. It Prevents accidental infrastructure damage.]

-->terraform apply               [terraform apply --auto-approve]

-->terraform fmt                 [Formats code]

-->terraform validate            [Checks syntax.]

8. **Tagging** -- tag every resource with project, environment, and managed-by

-->Always tag resources. Benefits: Cost tracking, Resource filtering, Governance, Automation etc.
<img width="243" height="93" alt="image" src="https://github.com/user-attachments/assets/e37f24b1-b83f-484a-bdc4-f9ea595f0252" />

9. **Naming** -- consistent prefix pattern: `<project>-<environment>-<resource>`

-->Naming conventation is used for Easier identification, Cleaner AWS console, Better automation etc.

-->Keep resource names predictable. For example: expense-dev-vpc, expense-prod-eks, expense-stage-db

10. **Cleanup** -- always `terraform destroy` non-production environments when not in use

-->Destroy unused non-production environments.

-->Example: terraform destroy -var-file="dev.tfvars"

-->This is used because to Save cloud cost, Avoid forgotten resources, Cleaner infrastructure etc.
<img width="487" height="200" alt="image" src="https://github.com/user-attachments/assets/c198b617-26f7-497c-a915-40961ad6c6df" />

---

### Task 7: Destroy All Environments
Clean up all three environments in reverse order:

```bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"

terraform workspace select staging
terraform destroy -var-file="staging.tfvars"

terraform workspace select dev
terraform destroy -var-file="dev.tfvars"
```

Verify in the AWS console -- all VPCs, instances, security groups, and gateways should be gone.

Delete the workspaces:
```bash
terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod
```
<img width="1458" height="538" alt="image" src="https://github.com/user-attachments/assets/bc7a0658-ea70-487e-aed9-106e24c552bd" />

**Verify:** Is your AWS account completely clean?
-->Yes verified it is totally clean.

---

## Hints
- Each workspace has its own state file -- `terraform.tfstate.d/<workspace>/terraform.tfstate`
- `terraform.workspace` is a built-in variable available in any config
- You cannot delete a workspace you are currently on -- switch to `default` first
- Different VPC CIDRs per environment prevent accidental peering conflicts
- `terraform plan -var-file` does NOT auto-load `terraform.tfvars` when you specify `-var-file`
- If you forget which workspace you are on: `terraform workspace show`
- Workspaces work with remote backends too -- S3 key becomes `env:/<workspace>/terraform.tfstate`

---

## Documentation
Create `day-67-terraweek-capstone.md` with:
- Your complete project structure (directory tree)
- All three custom module configs
- Root `main.tf` showing workspace-aware module calls
- All three tfvars files with the differences highlighted
- Screenshot of all three environments running simultaneously in AWS
- Screenshot of `terraform output` from each workspace
- Your Terraform best practices guide (Task 6)
- A table mapping each TerraWeek day to the concepts learned:

| Day | Concepts |
|-----|----------|
| 61 | IaC, HCL, init/plan/apply/destroy, state basics |
| 62 | Providers, resources, dependencies, lifecycle |
| 63 | Variables, outputs, data sources, locals, functions |
| 64 | Remote backend, locking, import, drift |
| 65 | Custom modules, registry modules, versioning |
| 66 | EKS with modules, real-world provisioning |
| 67 | Workspaces, multi-env, capstone project |

---

## Submission
1. Add `day-67-terraweek-capstone.md` to `2026/day-67/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Completed the TerraWeek Challenge -- seven days from terraform init to a full multi-environment infrastructure project. Custom modules for VPC, security groups, and EC2. Three environments deployed with workspaces. One codebase, three isolated environments, zero console clicks."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
