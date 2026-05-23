# Day 64 -- Terraform State Management and Remote Backends

## Task
The state file is the single most important thing in Terraform. It is the source of truth -- the map between your `.tf` files and what actually exists in the cloud. Lose it and Terraform forgets everything. Corrupt it and your next apply could destroy production.

Today you learn to manage state like a professional -- remote backends, locking, importing existing resources, and handling drift.

---

## Expected Output
- Terraform state migrated from local to S3 remote backend with DynamoDB locking
- An existing AWS resource imported into Terraform state
- State drift simulated and reconciled
- A markdown file: `day-64-state-management.md`

---

## Challenge Tasks

### Task 1: Inspect Your Current State
Use your Day 63 config (or create a small config with a VPC and EC2 instance). Apply it and then explore the state:

```bash
terraform show                                    # Full state in human-readable format
terraform state list                              # All resources tracked by Terraform
terraform state show aws_instance.<name>          # Every attribute of the instance
terraform state show aws_vpc.<name>               # Every attribute of the VPC
```
<img width="1227" height="975" alt="image" src="https://github.com/user-attachments/assets/43314195-e78a-4233-8ff3-c8801d979205" />
<img width="1192" height="215" alt="image" src="https://github.com/user-attachments/assets/93fbad40-7192-4855-9a98-e5c50d4acc45" />
<img width="1503" height="972" alt="image" src="https://github.com/user-attachments/assets/f19f2a90-faf0-4249-8047-15b9442ac694" />
<img width="1270" height="691" alt="image" src="https://github.com/user-attachments/assets/cd5e8e62-4e5a-4da7-a52e-89e46d7acb36" />
<img width="1890" height="803" alt="image" src="https://github.com/user-attachments/assets/32275ab3-d08b-4003-8e67-d65e912ddadf" />

Answer:
**1. How many resources does Terraform track?**

--> 7 resources traced by terraform they are as below,

1. aws_instance.TerraWeek_Server

2. aws_internet_gateway.igw

3. aws_route_table.public_rt

4. aws_route_table_association.public_rt_association

5. aws_security_group.ec2_sg

6. aws_subnet.public_subnet

7. aws_vpc.vpc

**2. What attributes does the state store for an EC2 instance? (hint: way more than what you defined)**

-->In Terraform, the state file (terraform.tfstate) stores a complete snapshot of every resource it manages — not just what you defined in your .tf files.

-->Key categories of attributes stored in state:

1. Basic identifiers: id (instance ID, e.g., i-0abc123), arn, instance_type, ami

2. Networking details: public_ip, private_ip, public_dns, private_dns, subnet_id, vpc_security_group_ids 

3. Instance configuration: key_name, associate_public_ip_address, availability_zone, tenancy

4. Storage (EBS volumes): root_block_device, ebs_block_device, volume IDs, sizes, types, encryption flags 

5. Tags & metadata: tags (what you defined), tags_all (includes inherited/default tags)

6. Runtime / computed attributes (you DID NOT define): instance_state (running/stopped), cpu_core_count, cpu_threads_per_core, launch_time, monitoring,
placement_group, hypervisor, credit_specification (for burstable instances)

7. Security & IAM: iam_instance_profile, attached security groups (expanded details)

8. Misc AWS-provided details: metadata_options, enclave_options, hibernation, capacity_reservation_specification

-->Terraform state will still store 50+ attributes returned by AWS, Because Terraform needs full state to detect drift, It compares desired config vs actual remote state, It uses these extra attributes for planning updates

**Note:** Your .tf file = what you asked for & Terraform state = what AWS actually created

-->State file can contain sensitive data (IPs, IDs, sometimes secrets), Thats why we dont have to push the terraform.tfstate file to the github, For that use Use remote backends (S3 + DynamoDB lock)

**3. Open `terraform.tfstate` in an editor -- find the `serial` number. What does it represent?**

-->The serial number in terraform.tfstate is Terraform’s way of versioning the state file. Serial number increases by 1 everytime when the state file gets update. This terraform uses because to Prevents overwriting newer state, It Works with locking systems such as S3 + DynamoDB locking, Also terraform ensures Only one update at a time &
Serial increases safely.
<img width="1452" height="981" alt="image" src="https://github.com/user-attachments/assets/326498a8-3305-4fd4-a4b8-abc0d90c9cb2" />

---

### Task 2: Set Up S3 Remote Backend
Storing state locally is dangerous -- one deleted file and you lose everything. Time to move it to S3.

1. First, create the backend infrastructure (do this manually or in a separate Terraform config):
```bash
# Create S3 bucket for state storage
aws s3api create-bucket \
  --bucket terraweek-state-<yourname> \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning (so you can recover previous state)
aws s3api put-bucket-versioning \
  --bucket terraweek-state-<yourname> \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraweek-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1
```

**Note:** Creating s3 bucket to store the tfstate file, For that used region: us-east-1 For this particular region there is one issue we may face: aws: [ERROR]: An error occurred (InvalidLocationConstraint) when calling the CreateBucket operation: The specified location-constraint is not valid Additional error details: LocationConstraint: us-east-1 

-->To fix it use command remove LocationConstraint from the Create S3 bucket for state storage,

aws s3api create-bucket --bucket terraweek-state-file-store-in-s3 --region us-east-1 

**Note:** When using us-east-1 do not use LocationContraint & in case Any other region (like ap-south-1) MUST use LocationConstraint 

-->This is happen in case we use region us-east-1, So us-east-1 is the default & oldest AWS region, AWS treats it differently for historical reasons, So when 
creating an S3 bucket there:, It assumes the location automatically, You must not explicitly specify it

2. Add the backend block to your Terraform config:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraweek-state-<yourname>"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraweek-state-lock"
    encrypt        = true
  }
}
```

3. Run:
```bash
terraform init
```
Terraform will ask: "Do you want to copy existing state to the new backend?" -- say yes.

4. Verify:
  ** - Check the S3 bucket -- you should see `dev/terraform.tfstate`**
   <img width="1367" height="222" alt="image" src="https://github.com/user-attachments/assets/5e713580-e480-418a-b010-0787ec4bd833" />

   ** - Your local `terraform.tfstate` should now be empty or gone**
  -->
   {

   "version": 4,

    "terraform_version": "1.15.2",

    "serial": 16,

    "lineage": "fbfe3371-1c78-3c40-a72a-f891c4c950b8",

    "outputs": {},

    "resources": [],

    "check_results": null

 }
   
   -->In local system terraform.tfstate file is not managing any infrastructure right now, As we have initialized backend before creating resources, But So state got created in S3, but nothing added yet, Also Terraform stops using local state Because after backend setup
     
  ** - Run `terraform plan` -- it should show no changes (state migrated correctly)**
   <img width="1480" height="686" alt="image" src="https://github.com/user-attachments/assets/07933912-6c34-421c-9883-8adb79dc5afc" />

**Steps to follow:**

-->In case reagion: us-east-1: aws s3api create-bucket --bucket terraweek-state-file-store-in-s3 --region us-east-1 OR,

-->if any other region then  use command: aws s3api create-bucket --bucket terraweek-state-to-store-in-s3 --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1

-->aws s3api put-bucket-versioning --bucket terraweek-state-file-store-in-s3 --versioning-configuration Status=Enabled

-->aws dynamodb create-table --table-name terraweek-state-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region us-east-1

-->Then add following block of code in main.tf file,

terraform {

  backend "s3" {
  
    bucket         = "terraweek-state-file-store-in-s3"
    
    key            = "dev/terraform.tfstate"
    
    region         = "us-east-1"
    
    dynamodb_table = "terraweek-state-lock"
    
    encrypt        = true
  }
  
}

-->After this run command terraform init

-->terraform validate & then terraform plan

-->terraform apply --auto-approve

-->Check S3 for file terraform.tfstate file: aws s3 ls s3://terraweek-state-file-store-in-s3/dev/ 

-->To check DynamoDB table state: aws dynamodb describe-table --table-name terraweek-state-lock --region us-east-1
  
<img width="1401" height="132" alt="image" src="https://github.com/user-attachments/assets/ec6b5bc4-3f1e-42dc-bf5a-a8914f2eb9b2" />
<img width="1432" height="891" alt="image" src="https://github.com/user-attachments/assets/3ed3bdf3-adbf-44d9-b402-eb471f73d75e" />
<img width="1866" height="947" alt="image" src="https://github.com/user-attachments/assets/4feac30f-d7e6-491d-9eca-13a6f363f1db" />
<img width="1895" height="875" alt="image" src="https://github.com/user-attachments/assets/afc5f58c-e44b-4036-9a90-4314fee9e27b" />

**Note:** Terraform immediately: Connected to S3-->Created state file there-->But no resources existed yet

---

### Task 3: Test State Locking
State locking prevents two people from running `terraform apply` at the same time and corrupting the state.

1. Open **two terminals** in the same project directory
2. In Terminal 1, run:
```bash
terraform apply
```
3. While Terminal 1 is waiting for confirmation, in Terminal 2 run:
```bash
terraform plan
```
4. Terminal 2 should show a **lock error** with a Lock ID

**Document:** What is the error message? Why is locking critical for team environments?

5. After the test, if you get stuck with a stale lock:
```bash
terraform force-unlock <LOCK_ID>
```

---

### Task 4: Import an Existing Resource
Not everything starts with Terraform. Sometimes resources already exist in AWS and you need to bring them under Terraform management.

1. Manually create an S3 bucket in the AWS console -- name it `terraweek-import-test-<yourname>`
2. Write a `resource "aws_s3_bucket"` block in your config for this bucket (just the bucket name, nothing else)
3. Import it:
```bash
terraform import aws_s3_bucket.imported terraweek-import-test-<yourname>
```
4. Run `terraform plan`:
   - If you see "No changes" -- the import was perfect
   - If you see changes -- your config does not match reality. Update your config to match, then plan again until you get "No changes"

5. Run `terraform state list` -- the imported bucket should now appear alongside your other resources

**Document:** What is the difference between `terraform import` and creating a resource from scratch?

---

### Task 5: State Surgery -- mv and rm
Sometimes you need to rename a resource or remove it from state without destroying it in AWS.

1. **Rename a resource in state:**
```bash
terraform state list                              # Note the current resource names
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket
```
Update your `.tf` file to match the new name. Run `terraform plan` -- it should show no changes.

2. **Remove a resource from state (without destroying it):**
```bash
terraform state rm aws_s3_bucket.logs_bucket
```
Run `terraform plan` -- Terraform no longer knows about the bucket, but it still exists in AWS.

3. **Re-import it** to bring it back:
```bash
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-<yourname>
```

**Document:** When would you use `state mv` in a real project? When would you use `state rm`?

---

### Task 6: Simulate and Fix State Drift
State drift happens when someone changes infrastructure outside of Terraform -- through the AWS console, CLI, or another tool.

1. Apply your full config so everything is in sync
2. Go to the **AWS console** and manually:
   - Change the Name tag of your EC2 instance to `"ManuallyChanged"`
   - Change the instance type if it's stopped (or add a new tag)
3. Run:
```bash
terraform plan
```
You should see a **diff** -- Terraform detects that reality no longer matches the desired state.

4. You have two choices:
   - **Option A:** Run `terraform apply` to force reality back to match your config (reconcile)
   - **Option B:** Update your `.tf` files to match the manual change (accept the drift)

5. Choose Option A -- apply and verify the tags are restored.

6. Run `terraform plan` again -- it should show "No changes." Drift resolved.

**Document:** How do teams prevent state drift in production? (hint: restrict console access, use CI/CD for all changes)

---

## Hints
- S3 bucket names must be globally unique
- DynamoDB table must have a `LockID` string key -- this is what Terraform uses for locking
- `terraform init -migrate-state` explicitly triggers state migration
- `terraform refresh` (or `terraform apply -refresh-only`) updates state to match real infrastructure without making changes
- State locking only works with backends that support it (S3+DynamoDB, Consul, Terraform Cloud)
- `terraform force-unlock` should only be used when you are sure no other operation is running
- Always version your S3 bucket so you can recover a previous state file if something goes wrong

---

## Documentation
Create `day-64-state-management.md` with:
- Diagram: local state vs remote state setup
- Screenshot of state file in S3 bucket
- Screenshot of the lock error from Task 3
- Steps you followed for `terraform import` and the result
- Explanation of state drift with your real example
- When to use: `state mv`, `state rm`, `import`, `force-unlock`, `refresh`

---

## Submission
1. Add `day-64-state-management.md` to `2026/day-64/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Mastered Terraform state today -- migrated to S3 remote backend with DynamoDB locking, imported existing AWS resources, performed state surgery, and simulated drift. State management is the foundation of reliable infrastructure as code."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
