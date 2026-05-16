# Day 61 -- Introduction to Terraform and Your First AWS Infrastructure

## Task
You have been deploying containers, writing CI/CD pipelines, and orchestrating workloads on Kubernetes. But who creates the servers, networks, and clusters underneath? Today you start your Infrastructure as Code journey with Terraform -- the tool that lets you define, provision, and manage cloud infrastructure by writing code.

By the end of today, you will have created real AWS resources using nothing but a `.tf` file and a terminal.

---

## Expected Output
- Terraform installed and working on your machine
- AWS CLI configured with valid credentials
- An S3 bucket and EC2 instance created and destroyed via Terraform
- A markdown file: `day-61-terraform-intro.md`

---

## Challenge Tasks

### Task 1: Understand Infrastructure as Code
Before touching the terminal, research and write short notes on:

**1. What is Infrastructure as Code (IaC)? Why does it matter in DevOps?**

-->Infrastructure as Code (IaC) is the practice of managing and provisioning infrastructure such as servers, networks, databases, etc. By using code and automation, instead of manually configuring everything through GUIs or scripts run by hand.
In IaC, you define your infrastructure in configuration files (like Terraform, AWS CloudFormation, or Ansible), and those files can be versioned, reviewed, and reused—just like application code.
<img width="532" height="307" alt="image" src="https://github.com/user-attachments/assets/60f767e4-d59c-4c6f-b724-6e091d73b6b6" />

**Why IaC matters in DevOps: ** As IaC is a core pillar of DevOps because it brings software engineering practices to infrastructure.

**1. Consistency & Repeatability**

-->You can create identical environments (dev, staging, production)

-->Eliminates “it works on my machine” problems

**2. Automation**

-->Infrastructure can be provisioned in minutes

-->Reduces manual errors and human intervention

**3. Version Control**

-->Infrastructure changes are tracked in Git

-->You can roll back to previous states easily

**4. Scalability**

-->Spin up or tear down resources on demand

-->Essential for cloud-native and microservices systems

**5. Faster Delivery (CI/CD Integration)**

-->Infrastructure can be deployed as part of pipelines

-->Enables continuous delivery of both code and environments

**6. Cost Efficiency**

-->Easily remove unused resources

-->Better visibility into infrastructure usage

**7. Disaster Recovery**

-->Quickly recreate environments from code if something fails

**Note:** In short IaC turns infrastructure into something that is: Declarative, Automated, Versioned, Reproducible. And that’s exactly what DevOps aims for: speed, reliability, and collaboration between development and operations.

**2. What problems does IaC solve compared to manually creating resources in the AWS console?**

-->Manually creating resources in the Amazon Web Services console might feel easy at first, but it breaks down quickly as systems grow. Infrastructure as Code (IaC) exists to fix those exact pain points.
Here’s what IaC solves compared to doing everything by hand:

**1. Human Errors & Inconsistency**

**Manual setup:** 

-->Easy to forget a step or misconfigure something 

-->Two engineers might create slightly different environments

**IaC:**

-->Same code → same infrastructure every time

-->Eliminates configuration drift

**2. No Repeatability**

**Manual setup:**

-->Recreating environments (dev, staging, prod) is slow and unreliable

-->Documentation often becomes outdated

**IaC:**

-->One command can recreate entire environments

-->Your code is the documentation

**3. Time-Consuming Process**

**Manual setup:**

-->Clicking through the console is slow and doesn’t scale

-->Setting up 10 servers = repeating the same steps 10 times

**IaC:**

-->Automates everything

-->Create 1 or 100 resources with minimal change

**4. No Version Control**

**Manual setup:**

-->No clear history of who changed what and why

-->Hard to roll back mistakes

**IaC:**

-->Stored in Git → full history, diffs, and rollbacks

-->Works like application code

**5. Poor Collaboration**

**Manual setup:**

-->Knowledge lives in someone’s head

-->Hard for teams to review infrastructure changes

**IaC:**

-->Changes go through pull requests

-->Teams can review and approve infra updates

**6. Slower Deployments**

**Manual setup:**

-->Infrastructure provisioning delays releases

-->Not suitable for CI/CD pipelines

**IaC:**

-->Integrates with pipelines → fully automated deployments

-->Faster and more reliable releases

**7. Weak Disaster Recovery**

**Manual setup:**

-->Rebuilding infrastructure after failure is painful and slow

**IaC:**

-->Recreate everything from code in minutes

-->Much stronger resilience

8. Resource Sprawl & Cost Issues

**Manual setup:**

-->Easy to forget unused resources

-->No clear visibility of what exists

**IaC:**

-->Manage lifecycle (create/update/destroy) cleanly

-->Easier to track and clean unused infra

**Note:** Bottom line is Manual AWS console work is fine for: Small experiments & Learning, But for real-world DevOps: IaC gives you speed, consistency, auditability, and scalability — things manual processes simply can’t match etc.

**3. How is Terraform different from AWS CloudFormation, Ansible, and Pulumi?**

-->All four tools—Terraform, AWS CloudFormation, Ansible, and Pulumi—fall under the Infrastructure as Code umbrella, but they solve slightly different problems and take different approaches.

**Core Difference (one-line intuition)**

**Terraform** → Cloud-agnostic infrastructure provisioning (most popular)

**CloudFormation** → AWS-only infrastructure provisioning (native & tightly integrated)

**Ansible** → Configuration management (what happens inside servers)

**Pulumi** → IaC using real programming languages instead of DSLs

**1. Terraform vs CloudFormation**

**Scope**

**Terraform: ** Multi-cloud (AWS, Azure, GCP, Kubernetes, etc.)

**CloudFormation: ** Only works with AWS

**Note:** If you want flexibility beyond AWS → Terraform wins

**Language**

**Terraform: ** Uses HCL (HashiCorp Configuration Language)

**CloudFormation: ** Uses JSON or YAML (more verbose)

**State Management**

**Terraform: ** Maintains a state file (important concept)

**CloudFormation:** State handled internally by AWS (no file to manage)

**Ecosystem**

**Terraform:** Huge provider ecosystem

**CloudFormation: ** Best support for AWS services (day-1 support)

**Summary** Terraform = flexibility + multi-cloud whereas CloudFormation = deep AWS integration + simplicity (if AWS-only)

**2. Terraform vs Ansible:**  This is where many beginners get confused.

**Purpose**

**Terraform:**  Creates infrastructure (VMs, networks, load balancers) For Example: Terraform → creates EC2 instance

**Ansible:** Configures infrastructure (install packages, setup apps) Example: Ansible → installs Nginx on that instance

**Approach**

**Terraform: ** Declarative (describe what you want)

**Ansible:** Procedural (step-by-step tasks) 

**Agent Requirement**

**Terraform: ** No agents require

**Ansible:** Agentless (uses SSH, but still executes steps)

**Summary** They both are complementary to each other, not competitors.

**3. Terraform vs Pulumi**

**Language Style**

**Terraform:**  DSL (HCL) Example: Terraform → simple, declarative

**Pulumi:** Real programming languages (Python, JavaScript, Go, etc.) Example: Pulumi → full programming power (loops, conditions, classes)

**Flexibility**

**Terraform:** Easier to learn, predictable

**Pulumi:** More powerful but can become complex

**Developer Experience**

**Terraform:** Infra-focused

**Pulumi:** Developer-friendly (feels like writing app code)

**Summary:"** Terraform = simplicity + standardization whereas Pulumi = flexibility + programming power

4. What does it mean that Terraform is "declarative" and "cloud-agnostic"? Write this in your own words -- not copy-pasted definitions.

-->When people say Terraform is declarative and cloud-agnostic, they’re describing how you think and work with it, With Terraform, you describe the end result you want, not the exact steps to get there.

-->Think of it like: “I want 2 servers, a load balancer, and a database”

-->So You don’t say: first create network, then create server, then attach storage, then configure…

-->Terraform figures out: the order, dependencies, what already exists vs what needs to change, So You focus on the destination, Terraform handles the journey

-->Real-world analogy It’s like ordering food: Declarative → “I want a pizza” whereas Procedural → “Mix flour, add sauce, bake at 220°C…”

-->So Terraform is the “pizza order,” not the recipe.

-->Now cloud-agnostic” means, Terraform is not tied to a single cloud provider. You can use the same tool to manage: AWS, Azure, GCP, Kubernetes even things like GitHub or DNS

-->You don’t have to learn a completely new system for each platform & this matters practically, 
  
  1. If your company changes cloud → you don’t start from scratch

  2. If you use multiple clouds → one tool manages everything
  
  3. Skills are transferable → big career advantage

**Declarative → “This is what I want”** & **Cloud-agnostic → “And I can do it anywhere”**

**Note:** Define your desired infrastructure once, and apply it across different platforms without worrying about the step-by-step process.

---

### Task 2: Install Terraform and Configure AWS
1. Install Terraform:
```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (amd64)
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows
choco install terraform
```
<img width="1822" height="442" alt="image" src="https://github.com/user-attachments/assets/91f1e979-62e2-42bb-80bb-17d888fc88ec" />

2. Verify:
```bash
terraform -version
```
<img width="592" height="103" alt="image" src="https://github.com/user-attachments/assets/179c42ad-fcdc-4ef1-b745-22d4bfedb48e" />

3. Install and configure the AWS CLI:
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, default region (e.g., ap-south-1), output format (json)
```
<img width="1083" height="367" alt="image" src="https://github.com/user-attachments/assets/e875f3f7-c193-48e4-b0b9-305980434050" />
4. Verify AWS access:
```bash
aws sts get-caller-identity
```
<img width="1083" height="367" alt="image" src="https://github.com/user-attachments/assets/296df10b-81c0-4fa1-bbab-6e107d0824c6" />
You should see your AWS account ID and ARN.

**Steps to follow:**

**To uninstall the terraform If you installed Terraform manually:**

--> which terraform

-->sudo rm -rf /usr/local/bin/terraform

**If installed via package manager:** sudo apt remove terraform

**Now lets install the terraform:**

-->wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

-->echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

-->sudo apt update && sudo apt install terraform -y

-->terraform -version
<img width="1802" height="962" alt="image" src="https://github.com/user-attachments/assets/81741159-5dc2-4c10-8f3c-c9f6cf67eddf" />

-->Install AWS CLI: curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

-->unzip awscliv2.zip

-->sudo ./aws/install

-->aws --version
<img width="940" height="82" alt="image" src="https://github.com/user-attachments/assets/82dfec2d-0aa7-4b3d-823e-84877ffd4114" />

-->configure the AWS CLI: aws configure  [Enter your Access Key ID, Secret Access Key, default region (e.g., ap-south-1), output format (json)]

-->aws sts get-caller-identity
<img width="892" height="287" alt="image" src="https://github.com/user-attachments/assets/dc31d61a-004b-4952-b97b-7f47104cb2a6" />

---

### Task 3: Your First Terraform Config -- Create an S3 Bucket
Create a project directory and write your first Terraform config:

```bash
mkdir terraform-basics && cd terraform-basics
```

Create a file called `main.tf` with:
1. A `terraform` block with `required_providers` specifying the `aws` provider
2. A `provider "aws"` block with your region
3. A `resource "aws_s3_bucket"` that creates a bucket with a globally unique name

Run the Terraform lifecycle:
```bash
terraform init      # Download the AWS provider
terraform plan      # Preview what will be created
terraform apply     # Create the bucket (type 'yes' to confirm)
```
<img width="1492" height="961" alt="image" src="https://github.com/user-attachments/assets/59f14513-268a-499a-8add-6b02b1d86ca1" />
<img width="1501" height="966" alt="image" src="https://github.com/user-attachments/assets/1da166a9-7eaf-4c2c-b43d-4ac2135a3226" />
<img width="1562" height="672" alt="image" src="https://github.com/user-attachments/assets/6de1ac7f-b9ed-469a-abfe-810a2d0b3a70" />
Go to the AWS S3 console and verify your bucket exists.
<img width="1877" height="752" alt="image" src="https://github.com/user-attachments/assets/974ea76c-3fbf-4955-9f32-9890d9975965" />

**Document:** What did `terraform init` download? What does the `.terraform/` directory contain?

-->When you run terraform init in Terraform, it prepares your project so Terraform knows how to talk to your infrastructure.

-->**Provider plugins:** Terraform downloads the AWS provider plugin: A binary that knows how to interact with Amazon Web Services APIs
Without this, Terraform cannot create resources, Think of it like: “Driver” that lets Terraform talk to AWS.

-->Modules (if used): Terraform would download those modules too
-->Backend initialization: If you configure remote state (like S3): Terraform sets up connection to that backend

.terraform/ directory is created locally after init
<img width="587" height="342" alt="image" src="https://github.com/user-attachments/assets/c261f11c-e582-4eb9-b108-488272cc46bf" />

**1. providers/** Contains downloaded provider plugins Example: AWS provider binary

**2. modules/ (if present)** Stores downloaded modules

**3. Lock file (outside folder)** You’ll also see: .terraform.lock.hcl This tracks: Exact provider versions & Ensures consistent installs across machines

**Note:** We dont have to edit .terraform/ file, It’s auto-generated, Terraform manages it. Also dont commit the .terraform/ file to github instead add them into .gitignore file 

-->We can delete .terraform/ file anytime and to recreate we just have to run the terraform init command, So our .tf file is the instructions and .terraform/ file contains downloded tools which used to execute those instructions OR we can say terraform init downloads the tools (providers/modules), and .terraform/ stores them locally so Terraform can run your code.
---

### Task 4: Add an EC2 Instance
In the same `main.tf`, add:
1. A `resource "aws_instance"` using AMI `ami-0f5ee92e2d63afc18` (Amazon Linux 2 in ap-south-1 -- use the correct AMI for your region)
2. Set instance type to `t2.micro`
3. Add a tag: `Name = "TerraWeek-Day1"`

Run:
```bash
terraform plan      # You should see 1 resource to add (bucket already exists)
terraform apply
```
<img width="1696" height="977" alt="image" src="https://github.com/user-attachments/assets/6f87e1a6-bb5c-4126-aff5-ec2f9c4827f2" />
<img width="1762" height="965" alt="image" src="https://github.com/user-attachments/assets/d3875d84-f673-457f-b5a6-70a065e7a46d" />
<img width="1731" height="957" alt="image" src="https://github.com/user-attachments/assets/6e5d01aa-15a3-45b4-87df-45d98e0f5c9a" />
<img width="1620" height="991" alt="image" src="https://github.com/user-attachments/assets/bc26a371-5ff1-48e3-8aba-bb8fcd994e10" />
Go to the AWS EC2 console and verify your instance is running with the correct name tag.
<img width="1907" height="862" alt="image" src="https://github.com/user-attachments/assets/a7ee3f22-7790-4513-b9d7-433900612a05" />

**Document:** How does Terraform know the S3 bucket already exists and only the EC2 instance needs to be created?

-->Terraform knows this by comparing its state file with your current configuration and the real infrastructure in Amazon Web Services.

-->Terraform stores everything it has created in the following file name as **terraform.tfstate** So this file contains Resource IDs (like S3 bucket name, EC2 instance ID), Current known state of infrastructure

-->While terraform plan, Terraform does a 3-way comparison like our .tf file code in which desired state is mentioned in that what we want is to create ec2-instance & s3 bucket etc. Then other file is .tfstate file known as state file here terraform compares what is exists and what need to create based on .tf desiresed state file, And lastly Your Real AWS infrastructure, So here Terraform queries AWS APIs to confirm: is S3 bucket exists & EC2 doesn’t exist based on this comparison terraform decides to create the infrastructure or not. So it concludes S3 is already there, only EC2 needs to be created.

**Note:** If we have created s3 bucket manually in aws console, And that record is not available in the .tfstate file and we tries to create the s3 bucket with same name via terraform then we may face an error like bucket is already exists. So there is one solution is to import the manually created resource for that we can use **command as follow: terraform import aws_s3_bucket.example my-bucket-name** This updates the state file so Terraform “knows” it exists.

-->Terraform determines what to create or skip by comparing the desired configuration with its state file and the actual infrastructure, and then only applies the necessary changes.

---

### Task 5: Understand the State File
Terraform tracks everything it creates in a state file. Time to inspect it.

1. Open `terraform.tfstate` in your editor -- read the JSON structure
2. Run these commands and document what each returns:
```bash
terraform show                          # Human-readable view of current state
terraform state list                    # List all resources Terraform manages
terraform state show aws_s3_bucket.<name>   # Detailed view of a specific resource
terraform state show aws_instance.<name>

```
<img width="1297" height="960" alt="image" src="https://github.com/user-attachments/assets/75addd86-56a6-45c6-b787-1bd2c1ff3d88" />
<img width="1340" height="962" alt="image" src="https://github.com/user-attachments/assets/a06afde0-f54c-4b14-8f26-e0264709ca5c" />
<img width="1917" height="972" alt="image" src="https://github.com/user-attachments/assets/af60a058-415c-4018-966f-81a60bbca4a5" />
<img width="1607" height="966" alt="image" src="https://github.com/user-attachments/assets/5238b8c4-867c-44f6-b2d7-edfe996a1de8" />
<img width="1407" height="972" alt="image" src="https://github.com/user-attachments/assets/f30b02f9-3225-4dc0-8b6a-0faff9a0d8b4" />


3. Answer these questions in your notes:

**- What information does the state file store about each resource?**

-->In Terraform, the state file (terraform.tfstate) is basically the source of truth that maps your configuration to real-world infrastructure. For each resource, it stores a lot more than just “this exists.

**1. Resource Identity:** Type (e.g., aws_instance, aws_s3_bucket)   [This tells Terraform what the resource is and where it belongs.]

-->Name (as defined in your .tf files)

-->Provider used (AWS, Azure, etc.)  

**2. Resource ID (Critical):** The unique ID assigned by the provider, For Example: EC2 instance ID like i-0abc123...

-->This is how Terraform knows which real resource to update/delete.

**3. Attributes (Actual State):** All the current values of the resource such as Public IP, Instance type, Tags, Bucket name, DNS, endpoints, etc.

-->This reflects the real-world configuration, not just what’s in your .tf files.

**4. Metadata:** Dependencies (what depends on what), Creation/update timestamps (internal), Schema version etc.

-->Helps Terraform decide the correct order of operations.

**5. Sensitive Data (Important):** May include: Passwords, Access keys, Connection strings etc.

-->That’s why: You should never commit state files to GitHub, Also Use remote backends (like S3 + locking)

**6. Resource Relationships:** Links between resources, For Example: EC2 instance using a specific security group

-->Terraform builds a dependency graph from this.

**7. Outputs:** Values defined in output blocks, For Example: instance_ip, db_endpoint Stored so you can reuse them across modules or commands.
<img width="325" height="360" alt="image" src="https://github.com/user-attachments/assets/1e8bd718-6543-4b82-a176-06eaccbd6dcd" />

**Note:** Terraform does NOT query cloud providers every time — it relies on the state file to: Detect changes, Plan updates, Avoid recreating resources  unnecessarily etc.

**- Why should you never manually edit the state file?**

-->You can open a Terraform state file—but editing it manually is a fast way to break your infrastructure in subtle, painful ways.

**1. You Can Corrupt the Source of Truth:** Terraform treats the state file as the single source of truth about real infrastructure.

-->If you change something incorrectly: Terraform may think a resource doesn’t exist → tries to recreate it Or think it exists when it doesn’t → fails on apply

-->As a Result: unexpected resource creation, deletion, or drift etc.

**2. IDs and Mappings Can Break:** Each resource has a unique provider ID (like an EC2 instance ID). If you accidentally modify or delete it: Terraform loses track of the real resource, It may try to create duplicates or fail to destroy existing ones.

**3. Dependency Graph Gets Messed Up:**  The state file tracks relationships between resources. So Manual edits can: Break dependencies, So it Cause Terraform to run things in the wrong order

-->This can lead to failed deployments or partial infrastructure.

**4. Schema & Format Are Strict:** The state file has a specific JSON structure expected by Terraform. Even a small formatting mistake can make it unreadable, Terraform may refuse to run or crash

**5. Sensitive Data Risk:** State files often contain: Passwords, Secrets, API keys Editing manually increases the risk of: Accidentally exposing or corrupting sensitive data

**6. No Safety Checks:** Terraform CLI commands (like terraform state rm, mv, import) include validations and safeguards.

-->Manual editing has: No validation, No rollback, No warning etc.

**What You Should Do Instead:** Use Terraform’s built-in commands:

-->terraform state list → see resources

-->terraform state show <resource> → inspect

-->terraform state rm → safely remove

-->terraform state mv → rename/move

-->terraform import → bring existing resources under Terraform

Note: In a simple way we can say Editing the state file manually is like: Changing database records directly in production without validation, It might work… but one wrong edit can break everything.

-->Manual editing is only done in extreme edge cases, and even then: Take a backup first, Know exactly what you're doing
  
**- Why should the state file not be committed to Git?**

-->Committing the Terraform state file (terraform.tfstate) to Git sounds convenient—but it’s actually risky and can break both security and workflows. Here’s why you should avoid it:

1. **It Contains Sensitive Data:** Such as Passwords, API keys, Database connection strings, Private IPs / endpoints etc. Data may export to outside world here.

2. **It Changes Frequently:** The state file updates every time you run terraform apply, In Git, this leads to: Constant noisy commits, Huge diffs that are hard to review, No real value in versioning it line-by-line etc.

**3. High Risk of Merge Conflicts:** If multiple team members run Terraform: Each gets a slightly different state version, Git merges can conflict, It causes A bad merge can corrupt the state → Terraform stops working properly.

**4. No Safe Collaboration:** Git is not designed for: State locking, Concurrent updates Two people applying changes at the same time can: Overwrite each other’s state, Also can Cause infrastructure drift or duplication

**5. Risk of Infrastructure Damage:** If an outdated or incorrect state file is committed and pulled: Terraform may think resources don’t exist → recreate them
Or think they exist → skip creation, So This can lead to data loss or duplicate resources.

-->Best Practice Instead Use a remote backend for state storage: AWS S3 (with DynamoDB locking), Terraform Cloud, Azure Storage, Google Cloud Storage etc.

-->Benefits: Secure storage (encryption, IAM), State locking (prevents concurrent runs), Centralized and consistent state etc.

**Note:** Committing terraform.tfstate to Git is like: Sharing your production database dump with secrets and letting everyone edit it freely, So add this filoe to.gitignore

---

### Task 6: Modify, Plan, and Destroy
1. Change the EC2 instance tag from `"TerraWeek-Day1"` to `"TerraWeek-Modified"` in your `main.tf`
2. Run `terraform plan` and read the output carefully:
   - What do the `~`, `+`, and `-` symbols mean?

    -->The **~ update in-place** means Terraform will modify an existing resource, not create or delete it. It means Your EC2 instance will be updated without            being destroyed. Only the tag name is changing, So Final Summary is Plan: 0 to add, 1 to change, 0 to destroy

    --> **+** sign means Terraform will CREATE a new resource, It does not exist yet in your infrastructure.

    --> **-** sign means Terraform will DESTROY a created resource, whcih is exist yet in your infrastructure.

      --> **-/+** Terraform will destroy the existing resource and then create a new one

**Quick meaning of the Symbols:**
   <img width="567" height="232" alt="image" src="https://github.com/user-attachments/assets/b5573175-12db-453b-bad1-4712367c2e28" />

   - Is this an in-place update or a destroy-and-recreate?
   -->It’s an in-place update [The ~ symbol means modify existing resource, not replace it]
4. Apply the change
5. Verify the tag changed in the AWS console
<img width="1287" height="902" alt="image" src="https://github.com/user-attachments/assets/2ed27b2f-ac37-4bd9-9c62-7fcce2389223" />
<img width="1910" height="755" alt="image" src="https://github.com/user-attachments/assets/bfe0996b-2577-482a-8632-077efb0c48a6" />

6. Finally, destroy everything:
```bash
terraform destroy
```
<img width="1292" height="972" alt="image" src="https://github.com/user-attachments/assets/147d3d06-f8bf-4e78-976e-bc628e0c59d3" />
<img width="1081" height="977" alt="image" src="https://github.com/user-attachments/assets/46080cf2-2e45-4b3c-816f-315858c7330f" />

6. Verify in the AWS console -- both the S3 bucket and EC2 instance should be gone
<img width="1917" height="747" alt="image" src="https://github.com/user-attachments/assets/67552525-24da-4904-a644-5cab820fa5b8" />
<img width="1917" height="812" alt="image" src="https://github.com/user-attachments/assets/b6c110bf-bf10-49cf-b31f-8db82652bd5a" />

---

## Hints
- S3 bucket names must be globally unique -- use something like `terraweek-<yourname>-2026`
- AMI IDs are region-specific -- search "Amazon Linux 2 AMI" in your region's EC2 launch wizard
- `terraform fmt` auto-formats your `.tf` files -- run it before committing
- `terraform validate` checks for syntax errors without connecting to AWS
- The `.terraform/` directory contains downloaded provider plugins
- Add `*.tfstate`, `*.tfstate.backup`, and `.terraform/` to your `.gitignore`

---

## Documentation
Create `day-61-terraform-intro.md` with:
- IaC explanation in your own words (3-4 sentences)
- Screenshot of `terraform apply` creating your S3 bucket and EC2 instance
- Screenshot of the resources in the AWS console
- What each Terraform command does (init, plan, apply, destroy, show, state list)
- What the state file contains and why it matters

---

## Submission
1. Add `day-61-terraform-intro.md` to `2026/day-61/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Started the TerraWeek Challenge -- installed Terraform, created my first S3 bucket and EC2 instance using code, and destroyed it all with one command. Infrastructure as Code just clicked."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
