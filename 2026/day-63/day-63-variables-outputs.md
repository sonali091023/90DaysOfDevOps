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

<img width="866" height="552" alt="image" src="https://github.com/user-attachments/assets/e8cf29be-e284-4fa9-ac26-f501a68cfba8" />

2. Replace every hardcoded value in `main.tf` with `var.<name>` references
3. Run `terraform plan` -- it should prompt you for `project_name` since it has no default
<img width="1297" height="500" alt="image" src="https://github.com/user-attachments/assets/3742eb6d-4216-4cc3-836f-8f407d2dfcb4" />

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
<img width="1821" height="917" alt="image" src="https://github.com/user-attachments/assets/b6e042de-8db0-4bd0-8728-206eb9972259" />

4. Apply with the prod file:
```bash
terraform plan -var-file="prod.tfvars"      # Uses prod.tfvars
```
<img width="1832" height="935" alt="image" src="https://github.com/user-attachments/assets/0f009514-ee73-40ce-be32-1b7c9b501f31" />

5. Override with CLI:
```bash
terraform plan -var="instance_type=t2.nano"  # CLI overrides everything
```
<img width="1822" height="912" alt="image" src="https://github.com/user-attachments/assets/c443e859-c520-4c97-88bd-f3e5dcecd8b1" />

6. Set an environment variable:
```bash
export TF_VAR_environment="staging"
terraform plan                              # env var overrides default but not tfvars
```
<img width="1802" height="906" alt="image" src="https://github.com/user-attachments/assets/1f2c2c88-d367-4059-8fcf-6575654c2b50" />

**Document:** Write the variable precedence order from lowest to highest priority.
<img width="592" height="242" alt="image" src="https://github.com/user-attachments/assets/1a6f190d-a8cf-47b6-9520-b482ae13f4a5" />

-->Default: lowest priority: Used only if nothing else is provided

<img width="127" height="60" alt="image" src="https://github.com/user-attachments/assets/9b0f6140-4135-4575-ac85-e1677d02b25e" />

-->Environment Variables: Overrides default   Eg: [export TF_VAR_env="staging"]

-->terraform.tfvars: Overrides environment variable   Eg: [env = "qa"]

-->auto.tfvars: Automatically loaded by Terraform   Eg: [prod.auto.tfvars]

-->-var-file: Overrides all above   Eg: [terraform apply -var-file="prod.tfvars"]

-->-var (highest priority): Highest priority — overrides everything   Eg: [terraform apply -var="env=prod"]
<img width="622" height="291" alt="image" src="https://github.com/user-attachments/assets/30ef8696-1852-48e0-9622-06e9bff938c4" />
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

<img width="1861" height="945" alt="image" src="https://github.com/user-attachments/assets/819c238c-da33-4e59-9d5a-2d86767b53fa" />
<img width="1005" height="156" alt="image" src="https://github.com/user-attachments/assets/b5398965-88f7-416c-ab81-ae4720361292" />
<img width="1355" height="795" alt="image" src="https://github.com/user-attachments/assets/c6f358df-1f9a-4652-bedf-1069dd9b07a8" />

**Verify:** Does `terraform output instance_public_ip` return the correct IP?
-->Yes, "13.219.249.6"

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
<img width="1872" height="947" alt="image" src="https://github.com/user-attachments/assets/33d29ba9-5521-4481-9ee1-2c2cdc277eec" />
<img width="1907" height="970" alt="image" src="https://github.com/user-attachments/assets/dfd3e05d-d000-41ac-84d0-9eb330243063" />
<img width="1887" height="947" alt="image" src="https://github.com/user-attachments/assets/499fc521-f6f6-4002-a9bf-6e770ec32f7b" />

**Document:** What is the difference between a `resource` and a `data` source?

**Resource: [Create something like EC2, VPC]** 

<img width="582" height="192" alt="image" src="https://github.com/user-attachments/assets/7c4cd826-5abf-4847-b579-892f2181f8df" />

-->Resource is Used when you want Terraform to build infrastructure

<img width="242" height="72" alt="image" src="https://github.com/user-attachments/assets/e0ab7471-5313-45b1-b1ad-bf9e888faa2a" />

-->Terraform will: Create EC2 --> Track it in state --> Update / destroy it [Full lifecycle management]

**Data: [Reading something like AMI, AZ]**

<img width="245" height="67" alt="image" src="https://github.com/user-attachments/assets/d97040f9-a849-4bbb-b778-22b1b60ce716" />

-->Used when you want to get existing info from AWS

-->Terraform will: Fetch AMI details --> NOT create anything --> NOT manage lifecycle [Read-only]

-->In simple words: resource → Build a new house & data → Find an existing house 

<img width="702" height="302" alt="image" src="https://github.com/user-attachments/assets/7777e591-8a79-4e87-a2ca-8ed69337e97a" />

**Note:** A resource in Terraform is used to create and manage infrastructure, including its lifecycle, while a data source is used to fetch and reference existing infrastructure or information without managing it.

<img width="517" height="282" alt="image" src="https://github.com/user-attachments/assets/6c2b218d-2e55-4c37-b5c4-f93355e4d24b" />

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

3. Merge common tags with resource-specific tags:
```hcl
tags = merge(local.common_tags, {
  Name = "${local.name_prefix}-server"
})
```
<img width="1836" height="941" alt="image" src="https://github.com/user-attachments/assets/34cdd8f5-ed6e-429c-a860-686ebac59593" />
<img width="1887" height="957" alt="image" src="https://github.com/user-attachments/assets/5cbfb4ae-a436-471b-88ff-61e0e6231cd1" />
<img width="1877" height="952" alt="image" src="https://github.com/user-attachments/assets/2e3732f8-85c9-4c4a-beae-00fb9c4ce423" />

Apply and check the tags in the AWS console -- every resource should have consistent tagging.
<img width="1901" height="931" alt="image" src="https://github.com/user-attachments/assets/326d8302-a1cb-4849-9c16-973dcd194503" />
<img width="832" height="267" alt="image" src="https://github.com/user-attachments/assets/fb7c2970-17cd-4985-bef2-e34f49ae41e1" />
-->Standardized Terraform tagging pattern (used in companies)

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
<img width="1167" height="562" alt="image" src="https://github.com/user-attachments/assets/0470f748-c0f2-4d88-be1f-bc9f7ca5187c" />

4. **Conditional expression** -- add this to your config:
```hcl
instance_type = var.environment == "prod" ? "t3.small" : "t2.micro"
```

Apply with `environment = "prod"` and verify the instance type changes.
<img width="1827" height="952" alt="image" src="https://github.com/user-attachments/assets/30137ed4-9862-499b-8ed0-44d2f24d8d04" />

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
