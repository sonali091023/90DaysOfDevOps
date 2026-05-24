# Day 65 -- Terraform Modules: Build Reusable Infrastructure

## Task
You have been writing everything in one big `main.tf` file. That works for learning, but in real teams you manage dozens of environments with hundreds of resources. Copy-pasting configs across projects is a recipe for disaster.

Today you learn Terraform modules -- the way to package, reuse, and share infrastructure code. Think of modules as functions in programming. Write once, call many times.

---

## Expected Output
- A custom EC2 module you built from scratch
- A custom security group module wired into the EC2 module
- A VPC created using the official public registry module
- A markdown file: `day-65-modules.md`

---

## Challenge Tasks

### Task 1: Understand Module Structure
A Terraform module is just a directory with `.tf` files. Create this structure:

```
terraform-modules/
  main.tf                    # Root module -- calls child modules
  variables.tf               # Root variables
  outputs.tf                 # Root outputs
  providers.tf               # Provider config
  modules/
    ec2-instance/
      main.tf                # EC2 resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
    security-group/
      main.tf                # Security group resource definition
      variables.tf           # Module inputs
      outputs.tf             # Module outputs
```

Create all the directories and empty files. This is the standard layout every Terraform project follows.

  <img width="1112" height="555" alt="image" src="https://github.com/user-attachments/assets/58e5d052-2d34-4b15-bf97-6a3c7ac3a5bb" />

**Document:** What is the difference between a "root module" and a "child module"?

-->In Terraform, a module is simply a container for Terraform configuration files (.tf files). Modules help organize and reuse infrastructure code.

**1. Root Module :** The root module is the main Terraform configuration directory where you run commands like: terraform init, terraform plan, terraform apply etc. 
It is the entry point of your infrastructure.

<img width="316" height="147" alt="image" src="https://github.com/user-attachments/assets/ad95cfb9-eec5-4c24-b991-11c6b06191c4" />

**Note:** When you run Terraform inside the project/ directory, that directory becomes the root module.

<img width="298" height="171" alt="image" src="https://github.com/user-attachments/assets/932efc55-bb07-4724-bc79-8fde076d7976" />

**2. Child Module :** A child module is any module that is called by another module using the module block.

-->It is mainly used for: Reusability, Standardization, Cleaner code, Avoiding duplication ect.

<img width="315" height="223" alt="image" src="https://github.com/user-attachments/assets/472c1e68-4f30-4e6e-80a9-51f13117d46a" />

<img width="407" height="612" alt="image" src="https://github.com/user-attachments/assets/2729e218-393a-4592-854f-704a9d747501" />

<img width="672" height="307" alt="image" src="https://github.com/user-attachments/assets/baadca73-5769-492a-8581-e66002b6fe05" />

<img width="351" height="652" alt="image" src="https://github.com/user-attachments/assets/440d1adf-fa47-4376-ae69-08556e8d6c70" />

<img width="258" height="207" alt="image" src="https://github.com/user-attachments/assets/4dc8ca9a-8a54-4312-a81d-287b08e27880" />

<img width="785" height="535" alt="image" src="https://github.com/user-attachments/assets/70b4cb19-af3b-4f94-ab55-51edcf76659e" />

---

### Task 2: Build a Custom EC2 Module
Create `modules/ec2-instance/`:

1. **`variables.tf`** -- define inputs:
   - `ami_id` (string)
   - `instance_type` (string, default: `"t2.micro"`)
   - `subnet_id` (string)
   - `security_group_ids` (list of strings)
   - `instance_name` (string)
   - `tags` (map of strings, default: `{}`)

2. **`main.tf`** -- define the resource:
   - `aws_instance` using all the variables
   - Merge the Name tag with additional tags

<img width="231" height="812" alt="image" src="https://github.com/user-attachments/assets/a544cc94-9d33-4c4f-a7ea-2bfd84f1d10a" />
<img width="295" height="236" alt="image" src="https://github.com/user-attachments/assets/b5474685-4eea-4e56-bb56-d3383f0c1cb6" />

3. **`outputs.tf`** -- expose:
   - `instance_id`
   - `public_ip`
   - `private_ip`

Do NOT apply yet -- just write the module.

---

### Task 3: Build a Custom Security Group Module
Create `modules/security-group/`:

1. **`variables.tf`** -- define inputs:
   - `vpc_id` (string)
   - `sg_name` (string)
   - `ingress_ports` (list of numbers, default: `[22, 80]`)
   - `tags` (map of strings, default: `{}`)
  
<img width="523" height="227" alt="image" src="https://github.com/user-attachments/assets/dba7ad46-d538-4dcc-84dd-7ecb16a78c3e" />

2. **`main.tf`** -- define the resource:
   - `aws_security_group` in the given VPC
   - Use `dynamic "ingress"` block to create rules from the `ingress_ports` list
   - Allow all egress

<img width="358" height="663" alt="image" src="https://github.com/user-attachments/assets/bfce3609-5284-4b29-93c1-2777d5e3b037" />

-->Creates a security group inside the given VPC. Then Uses Dynamic Ingress Rules so here Terraform automatically creates one ingress block per port.

<img width="280" height="805" alt="image" src="https://github.com/user-attachments/assets/8164d26f-6c7e-432b-a6f8-a2aad4cd80ba" />

<img width="256" height="655" alt="image" src="https://github.com/user-attachments/assets/d286eb5c-896d-48fb-a4b8-dc18ff466416" />

<img width="428" height="345" alt="image" src="https://github.com/user-attachments/assets/497d5c54-1955-416e-b4a1-16f04a06c906" />

3. **`outputs.tf`** -- expose:
   - `sg_id`

-->This allows other modules (like EC2) to use the security group ID.

<img width="281" height="72" alt="image" src="https://github.com/user-attachments/assets/94d7b30c-1b51-4aeb-8016-50b4a4224a08" />

**Note:** Outputs allow the root module or other modules to use values created inside a child module.

This is your first time using a `dynamic` block -- it loops over a list to generate repeated nested blocks.

---

### Task 4: Call Your Modules from Root
In the root `main.tf`, wire everything together:

1. Create a VPC and subnet directly (or reuse your Day 62 config)
2. Call the security group module:
```hcl
module "web_sg" {
  source        = "./modules/security-group"
  vpc_id        = aws_vpc.main.id
  sg_name       = "terraweek-web-sg"
  ingress_ports = [22, 80, 443]
  tags          = local.common_tags
}
```

3. Call the EC2 module -- deploy **two instances** with different names using the same module:
```hcl
module "web_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-web"
  tags               = local.common_tags
}

module "api_server" {
  source             = "./modules/ec2-instance"
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_ids = [module.web_sg.sg_id]
  instance_name      = "terraweek-api"
  tags               = local.common_tags
}
```

4. Add root outputs that reference module outputs:
```hcl
output "web_server_ip" {
  value = module.web_server.public_ip
}

output "api_server_ip" {
  value = module.api_server.public_ip
}
```

5. Apply:
```bash
terraform init    # Downloads/links the local modules
terraform plan    # Should show all resources from both module calls
terraform apply
```

**Verify:** Two EC2 instances running, same security group, different names. Check the AWS console.
<img width="1897" height="882" alt="image" src="https://github.com/user-attachments/assets/589530fa-07e8-4883-b48c-e8f46c4648b9" />
<img width="1750" height="977" alt="image" src="https://github.com/user-attachments/assets/9bcfe363-c3ed-4f3e-99da-05686843c869" />
<img width="1685" height="980" alt="image" src="https://github.com/user-attachments/assets/c11adf59-a093-4e58-bbd0-270de50bfeaf" />

---

### Task 5: Use a Public Registry Module
Instead of building your own VPC from scratch, use the official module from the Terraform Registry.

1. Replace your hand-written VPC resources with:
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "terraweek-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = false
  enable_dns_hostnames = true

  tags = local.common_tags
}
```

2. Update your EC2 and SG module calls to reference `module.vpc.vpc_id` and `module.vpc.public_subnets[0]`

3. Run:
```bash
terraform init     # Downloads the registry module
terraform plan
terraform apply
```

<img width="1821" height="980" alt="image" src="https://github.com/user-attachments/assets/cbb7b48f-4de7-417d-ab11-c416a3f04193" />
<img width="1788" height="973" alt="image" src="https://github.com/user-attachments/assets/b41b74c3-fdac-467d-81bb-20c5c70e7356" />
<img width="1898" height="988" alt="image" src="https://github.com/user-attachments/assets/d879859c-e0ab-4724-8af3-30752f0771c7" />
<img width="1787" height="987" alt="image" src="https://github.com/user-attachments/assets/e591dbce-2406-4d3e-a203-ca3d1191ea27" />
<img width="1856" height="985" alt="image" src="https://github.com/user-attachments/assets/5462dbb7-d1a2-4656-a854-f04134bbf303" />

4. Compare: how many resources did the VPC module create vs your hand-written VPC from Day 62?

-->The Terraform Registry VPC module creates many more resources than a simple hand-written VPC setup.

<img width="467" height="587" alt="image" src="https://github.com/user-attachments/assets/fd1a8f41-568c-4673-931a-bc7d8bd18066" />

<img width="486" height="833" alt="image" src="https://github.com/user-attachments/assets/839aae22-4f31-45c7-b1b3-0d272b7e3da1" />

-->Registory module creates so Many Resources, Because the module handles: networking best practices, multi-AZ architecture, route table management, subnet associations, tagging, optional NAT gateways, DNS support, scalability automatically.
<img width="373" height="832" alt="image" src="https://github.com/user-attachments/assets/9fdac3f6-9ea1-43e3-874e-8c143b643685" />
<img width="456" height="192" alt="image" src="https://github.com/user-attachments/assets/e95c0006-93ee-476e-b7af-8360edd504bb" />


**Document:** Where does Terraform download registry modules to? Check `.terraform/modules/`.
<img width="345" height="303" alt="image" src="https://github.com/user-attachments/assets/060d2d94-8fe4-49cc-9a97-1b41178b276a" />
<img width="1286" height="107" alt="image" src="https://github.com/user-attachments/assets/190169bc-265b-4573-8c11-cc0d0e99a1bd" />

---

### Task 6: Module Versioning and Best Practices
1. Pin your registry module version explicitly:
   - `version = "5.1.0"` -- exact version
   - `version = "~> 5.0"` -- any 5.x version
   - `version = ">= 5.0, < 6.0"` -- range

2. Run `terraform init -upgrade` to check for newer versions
<img width="1301" height="646" alt="image" src="https://github.com/user-attachments/assets/af1fa393-1e2f-46ec-a05e-24f19ebea234" />

3. Check the state to see how modules appear:
```bash
terraform state list
```
Notice the `module.vpc.`, `module.web_server.`, `module.web_sg.` prefixes.

<img width="1262" height="207" alt="image" src="https://github.com/user-attachments/assets/d14af538-5323-4f2e-b870-15114ba2358f" />

4. Destroy everything:
```bash
terraform destroy
```
<img width="1855" height="983" alt="image" src="https://github.com/user-attachments/assets/02ab8157-a60b-4f1d-88fa-97b2a683ea36" />


**Document:** Write down five module best practices:
- Always pin versions for registry modules
- Keep modules focused -- one concern per module
- Use variables for everything, hardcode nothing
- Always define outputs so callers can reference resources
- Add a README.md to every custom module

---

## Hints
- `terraform init` must be re-run after adding a new module source
- Module outputs are accessed as `module.<name>.<output>`
- `dynamic` blocks use `content {}` inside to define the repeated block
- Registry modules document all inputs and outputs on registry.terraform.io
- Local modules use `source = "./modules/<name>"`, registry modules use `source = "<org>/<name>/<provider>"`
- `terraform get` downloads modules without full init

---

## Documentation
Create `day-65-modules.md` with:
- Your custom module structure (directory tree)
- The `variables.tf`, `main.tf`, and `outputs.tf` for your EC2 module
- Root `main.tf` showing how you call both custom and registry modules
- Screenshot of both EC2 instances running from the same module
- Comparison: hand-written VPC vs registry VPC module (resources created)
- Five module best practices in your own words

---

## Submission
1. Add `day-65-modules.md` to `2026/day-65/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Built my first custom Terraform modules today -- EC2 and security group modules called multiple times with different configs. Then replaced 50 lines of VPC code with one registry module. Modules are the key to scalable infrastructure as code."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
