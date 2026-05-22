# Day 63 -- Variables, Outputs, Data Sources and Expressions

## Task
Your Day 62 config works, but it is full of hardcoded values -- region, CIDR blocks, AMI IDs, instance types, tags. Change the region and everything breaks. Today you make your Terraform configs dynamic, reusable, and environment-aware.

This is the difference between a config that works once and a config you can use across projects.

---

## Expected Output
- A fully parameterized Terraform config with no hardcoded values
- Separate `.tfvars` files for different environments
- Outputs printed after every apply
- A markdown file: `day-63-variables-outputs.md`

---

## Challenge Tasks

### Task 1: Extract Variables
Take your Day 62 infrastructure config and refactor it:

1. Create a `variables.tf` file with input variables for:
   - `region` (string, default: your preferred region)
   - `vpc_cidr` (string, default: `"10.0.0.0/16"`)
   - `subnet_cidr` (string, default: `"10.0.1.0/24"`)
   - `instance_type` (string, default: `"t2.micro"`)
   - `project_name` (string, no default -- force the user to provide it)
   - `environment` (string, default: `"dev"`)
   - `allowed_ports` (list of numbers, default: `[22, 80, 443]`)
   - `extra_tags` (map of strings, default: `{}`)

<img width="1470" height="971" alt="image" src="https://github.com/user-attachments/assets/b83ef6e9-5040-49cb-921c-11a5bcd8b129" />

2. Replace every hardcoded value in `main.tf` with `var.<name>` references
3. Run `terraform plan` -- it should prompt you for `project_name` since it has no default
<img width="1550" height="978" alt="image" src="https://github.com/user-attachments/assets/a9d52a73-a614-47b9-afba-150957d9eff5" />

**Document:** What are the five variable types in Terraform? 

-->`string: Represents text values`, 

-->`number: Represents numeric values`,

-->`bool: Represents true/false`, 

-->`list: Ordered collection of values`, 

-->`map: Key-value pairs`

---

### Task 2: Variable Files and Precedence
1. Create `terraform.tfvars`:
```hcl
project_name = "terraweek"
environment  = "dev"
instance_type = "t2.micro"
```

2. Create `prod.tfvars`:
```hcl
project_name = "terraweek"
environment  = "prod"
instance_type = "t3.small"
vpc_cidr     = "10.1.0.0/16"
subnet_cidr  = "10.1.1.0/24"
```

3. Apply with the default file:
```bash
terraform plan                              # Uses terraform.tfvars automatically
```
<img width="1347" height="967" alt="image" src="https://github.com/user-attachments/assets/e8897169-bbec-4260-9bc3-030fe2706308" />

4. Apply with the prod file:
```bash
terraform plan -var-file="prod.tfvars"      # Uses prod.tfvars
```
<img width="1661" height="971" alt="image" src="https://github.com/user-attachments/assets/32fc8bb9-45b6-4fa1-a209-b321fe7aa04c" />

5. Override with CLI:
```bash
terraform plan -var="instance_type=t2.nano"  # CLI overrides everything
```
<img width="1227" height="207" alt="image" src="https://github.com/user-attachments/assets/02844b8c-0f19-4297-ab8a-726b639b93d7" />
<img width="1552" height="972" alt="image" src="https://github.com/user-attachments/assets/9275c3dc-d03a-45a7-83da-6f75dd91f7ea" />


6. Set an environment variable:
```bash
export TF_VAR_environment="staging"
terraform plan                              # env var overrides default but not tfvars
```
<img width="1500" height="987" alt="image" src="https://github.com/user-attachments/assets/b245510b-1cfd-41d2-8681-5b8d3c3e473a" />

**Document:** Write the variable precedence order from lowest to highest priority.

-->Terraform loads variable values from multiple sources, If the same variable is defined in multiple places, Terraform follows a priority order.

<img width="818" height="376" alt="image" src="https://github.com/user-attachments/assets/a52f66e9-aa96-41dd-b9b3-f90ba8b498bd" />
<img width="591" height="316" alt="image" src="https://github.com/user-attachments/assets/44fa6292-d58d-4064-a7d1-030bac235fdb" />

-->Default: lowest priority: Used only if nothing else is provided

<img width="627" height="302" alt="image" src="https://github.com/user-attachments/assets/3baba0f6-7117-47fa-83e2-073f05df09b1" />

-->Environment Variables: Overrides default   Eg: [export TF_VAR_env="staging"]

-->terraform.tfvars: Overrides environment variable   Eg: [env = "qa"]

-->auto.tfvars: Automatically loaded by Terraform   Eg: [prod.auto.tfvars]

-->-var-file: Overrides all above   Eg: [terraform apply -var-file="prod.tfvars"]

-->-var (highest priority): Highest priority — overrides everything   Eg: [terraform apply -var="env=prod"]

**Note:**

-->terraform.tfvars is auto-loaded

-->*.auto.tfvars is also auto-loaded

-->CLI flags always win

-->Terraform variable precedence starts with default values, followed by environment variables, then tfvars files, auto-loaded tfvars files, CLI var-file options, and finally CLI -var arguments having the highest priority.

---

### Task 3: Add Outputs
Create an `outputs.tf` file with outputs for:

1. `vpc_id` -- the VPC ID
2. `subnet_id` -- the public subnet ID
3. `instance_id` -- the EC2 instance ID
4. `instance_public_ip` -- the public IP of the EC2 instance
5. `instance_public_dns` -- the public DNS name
6. `security_group_id` -- the security group ID

Apply your config and verify the outputs are printed at the end:
```bash
terraform apply

# After apply, you can also run:
terraform output                          # Show all outputs
terraform output instance_public_ip       # Show a specific output
terraform output -json                    # JSON format for scripting
```
<img width="1642" height="972" alt="image" src="https://github.com/user-attachments/assets/bd5e930f-ac07-4219-85af-c4a4d7b1510c" />
<img width="1656" height="980" alt="image" src="https://github.com/user-attachments/assets/42f081a9-d5a7-408a-984f-e32ce1ea588f" />
<img width="1656" height="980" alt="image" src="https://github.com/user-attachments/assets/03ed4667-36e3-4cb3-8c85-887cfef19533" />
<img width="1447" height="707" alt="image" src="https://github.com/user-attachments/assets/2bf76125-e764-4b9b-9657-090e5f203930" />

**Verify:** Does `terraform output instance_public_ip` return the correct IP?
-->Yes, "44.247.114.48"

---

### Task 4: Use Data Sources
Stop hardcoding the AMI ID. Use a data source to fetch it dynamically.

1. Add a `data "aws_ami"` block that:
   - Filters for Amazon Linux 2 images
   - Filters for `hvm` virtualization and `gp2` root device
   - Uses `owners = ["amazon"]`
   - Sets `most_recent = true`

2. Replace the hardcoded AMI in your `aws_instance` with `data.aws_ami.amazon_linux.id`

3. Add a `data "aws_availability_zones"` block to fetch available AZs in your region

4. Use the first AZ in your subnet: `data.aws_availability_zones.available.names[0]`

Apply and verify -- your config now works in any region without changing the AMI.
<img width="811" height="392" alt="image" src="https://github.com/user-attachments/assets/703674de-7c1c-4c0c-808f-e55cd754351f" />
<img width="985" height="772" alt="image" src="https://github.com/user-attachments/assets/e7da7e48-119b-4b41-9669-ac8dfa7cfcbe" />
<img width="1536" height="975" alt="image" src="https://github.com/user-attachments/assets/5860ca0c-21c9-4cda-9258-cf5652975e47" />
<img width="1731" height="975" alt="image" src="https://github.com/user-attachments/assets/071a5fe4-ca5a-4331-a71d-ff8d96a9c5ab" />
<img width="1892" height="677" alt="image" src="https://github.com/user-attachments/assets/955c9890-4cde-4c79-9974-a3ccd0100a16" />

**Document:** What is the difference between a `resource` and a `data` source?

**Resource: [Create something like EC2, VPC, & then update, delete, manage actual infrastructure.]** 

<img width="285" height="165" alt="image" src="https://github.com/user-attachments/assets/e7940363-c15f-45d8-8e21-27fccad5e96c" />

-->Resource is Used when you want Terraform to build infrastructure

<img width="686" height="823" alt="image" src="https://github.com/user-attachments/assets/00b3a635-472c-49f2-90f5-c2ede28d8a06" />

-->Terraform will: Create EC2 --> Track it in state --> Update / destroy it [Full lifecycle management]

**Data: [Reading something like AMI, AZ]** Fetch Existing Information, A data block is used to: read existing resources, fetch information, lookup dynamic values etc.

<img width="415" height="365" alt="image" src="https://github.com/user-attachments/assets/82f9193e-77eb-45c8-90c4-70687d68fc63" />

-->Used when you want to get existing info from AWS

-->Terraform will: Fetch AMI details --> NOT create anything --> NOT manage lifecycle [Read-only]

-->In simple words: resource → Build a new house & data → Find an existing house 

<img width="377" height="482" alt="image" src="https://github.com/user-attachments/assets/01750dc4-e6b6-40d4-ba76-0f8f22e57e91" />

**Note:** A resource in Terraform is used to create and manage infrastructure, including its lifecycle, while a data source is used to fetch and reference existing infrastructure or information without managing it.

---

### Task 5: Use Locals for Dynamic Values
1. Add a `locals` block:
```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

2. Replace all Name tags with `local.name_prefix`:
   - VPC: `"${local.name_prefix}-vpc"`
   - Subnet: `"${local.name_prefix}-subnet"`
   - Instance: `"${local.name_prefix}-server"`

**Note:** We use locals because without it we have to mention name like this under tag "${var.project_name}-${var.environment}" and with locals local.name_prefix which is Cleaner and reusable.
<img width="570" height="271" alt="image" src="https://github.com/user-attachments/assets/b69c0dae-5fe0-4b15-a139-d27e42b88008" />
<img width="501" height="375" alt="image" src="https://github.com/user-attachments/assets/7b8edfae-d485-4f5e-9c46-7c8a8fbbe539" />
<img width="337" height="848" alt="image" src="https://github.com/user-attachments/assets/888f74c2-7e95-47f2-93df-a0c8d0df3755" />
<img width="1500" height="971" alt="image" src="https://github.com/user-attachments/assets/73b44d74-ee4c-4efe-a221-9585ee48ad24" />
<img width="1900" height="855" alt="image" src="https://github.com/user-attachments/assets/3660a376-0d29-4231-b3d3-56b14f9e568a" />

3. Merge common tags with resource-specific tags:
```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```
<img width="1539" height="976" alt="image" src="https://github.com/user-attachments/assets/b4267f67-9dc6-4dff-b4a3-d5e325dae7a2" />
<img width="357" height="823" alt="image" src="https://github.com/user-attachments/assets/bce24191-1b42-42a3-a4ef-14820d3db082" />

**Note:** We can repeat the same tags in every resource. & with merge we can define common tags once and reuse everywhere, Cleaner and production-standard.

-->merge() combines multiple maps into a single map. If duplicate keys exist, the last value overrides previous ones.

Apply and check the tags in the AWS console -- every resource should have consistent tagging.

-->Standardized Terraform tagging pattern (used in companies)
<img width="1858" height="847" alt="image" src="https://github.com/user-attachments/assets/4a0c74d6-eead-470d-92be-f124f27aa574" />

---

### Task 6: Built-in Functions and Conditional Expressions
Practice these in `terraform console`:
```bash
terraform console
```

1. **String functions:**
   - `upper("terraweek")` -> `"TERRAWEEK"`
   - `join("-", ["terra", "week", "2026"])` -> `"terra-week-2026"`
   - `format("arn:aws:s3:::%s", "my-bucket")`

2. **Collection functions:**
   - `length(["a", "b", "c"])` -> `3`
   - `lookup({dev = "t2.micro", prod = "t3.small"}, "dev")` -> `"t2.micro"`
   - `toset(["a", "b", "a"])` -> removes duplicates

3. **Networking function:**
   - `cidrsubnet("10.0.0.0/16", 8, 1)` -> `"10.0.1.0/24"`
<img width="956" height="337" alt="image" src="https://github.com/user-attachments/assets/6acdab75-8c5f-458e-8b3c-9fd6eceb2862" />

4. **Conditional expression** -- add this to your config:
```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
```

Apply with `environment = "prod"` and verify the instance type changes.
<img width="1827" height="952" alt="image" src="https://github.com/user-attachments/assets/30137ed4-9862-499b-8ed0-44d2f24d8d04" />
<img width="1432" height="985" alt="image" src="https://github.com/user-attachments/assets/83b6b649-8dee-41bc-b548-8f12cf688d4d" />

**Document:** Pick five functions you find most useful and explain what each does.

-->Five Useful Terraform Functions as below,

**1. upper():** Converts a string to uppercase. Example: upper("terraweek") → "TERRAWEEK"

**2. join():** Combines list elements into a single string. Example: join("-", ["terra", "week"]) → "terra-week"

**3. lookup():** Fetches value from a map using a key. Example: lookup({dev="t2.micro"}, "dev") → "t2.micro"

**4. length():** Returns number of elements in a list or string. Example: length(["a","b"]) → 2

**5. cidrsubnet():** Creates subnets from a CIDR block. Example: cidrsubnet("10.0.0.0/16", 8, 1) → "10.0.1.0/24"

---

## Hints
- `terraform.tfvars` is loaded automatically. Any other `.tfvars` file needs `-var-file`
- Variable precedence (low to high): default -> `terraform.tfvars` -> `*.auto.tfvars` -> `-var-file` -> `-var` flag -> `TF_VAR_*` env vars
- `terraform console` is an interactive REPL for testing expressions and functions
- Data sources are read-only -- they fetch information, they don't create resources
- `merge()` combines two maps -- great for tags
- `terraform output -json` is useful when piping output into other scripts

---

## Documentation
Create `day-63-variables-outputs.md` with:
- Your `variables.tf` with all variable types
- Both `.tfvars` files (dev and prod)
- Screenshot of outputs after `terraform apply`
- Explanation of variable precedence with examples
- Five built-in functions you found most useful
- The difference between `variable`, `local`, `output`, and `data`

---

## Submission
1. Add `day-63-variables-outputs.md` to `2026/day-63/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Made my Terraform configs fully dynamic today -- variables for every environment, data sources for AMI lookups, locals for consistent tagging, and conditional expressions for environment-specific sizing. Zero hardcoded values."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
