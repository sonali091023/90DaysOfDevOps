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
   <img width="1908" height="845" alt="image" src="https://github.com/user-attachments/assets/6c9b0ff0-e397-44b6-a49f-bdd76d70d6aa" />

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
   <img width="1836" height="963" alt="image" src="https://github.com/user-attachments/assets/fcef406b-18a7-4619-8e09-68722a21174e" />

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

**Note:** So here first need to install package **libs3-2** For that run command: sudo apt update && apt install libs3-2 -y, And then run command: aws s3 ls s3://terraweek-state-sonali-dev-tf-state/dev/ 

<img width="1773" height="962" alt="image" src="https://github.com/user-attachments/assets/1d1a844b-619b-491d-a013-f5d8cda23fb1" />

-->To check DynamoDB table state: aws dynamodb describe-table --table-name terraweek-state-lock --region us-east-1

**Note:** To know the DynamoDB table name Go to AWS console --> then search for DynamoDB -->Select table -->Theere we can find the name of the table  
<img width="1917" height="875" alt="image" src="https://github.com/user-attachments/assets/24b21963-4a3d-4e3c-9579-4c2676000d4b" />

**Note:** Terraform immediately: Connected to S3-->Created state file there-->But no resources existed yet

---

### Task 3: Test State Locking
State locking prevents two people from running `terraform apply` at the same time and corrupting the state.

1. Open **two terminals** in the same project directory
2. In Terminal 1, run:
```bash
terraform apply
```
<img width="1328" height="128" alt="image" src="https://github.com/user-attachments/assets/be27cc3f-4a06-4a11-b4b7-6ef5b8926352" />

3. While Terminal 1 is waiting for confirmation, in Terminal 2 run:
```bash
terraform plan
```

4. Terminal 2 should show a **lock error** with a Lock ID

**Document:** What is the error message? Why is locking critical for team environments?
<img width="518" height="162" alt="image" src="https://github.com/user-attachments/assets/acbc0273-85c2-4c6d-b92a-22f86b775e89" />

-->Terraform uses a state file (terraform.tfstate) to track infrastructure resources, In team environments, multiple engineers may run: terraform apply command at the same time. Without locking: Two users can modify infrastructure simultaneously, So as a result state file can become corrupted, Resources may be duplicated or deleted accidentally and, Infrastructure drift can occur etc. So Locking Prevents This, **Locking ensures: Only one Terraform operation can modify state at a time.** When one user runs terraform apply: Terraform acquires a lock then Other users must wait until operation completes, This guarantees: Safe state updates, Consistent infrastructure & Reliable team collaboration etc.

<img width="367" height="401" alt="image" src="https://github.com/user-attachments/assets/cc90db2a-daf6-4ef5-bc69-778e99f87703" />

This guarantees:

Safe state updates
Consistent infrastructure
Reliable team collaboration

Only one Terraform operation can modify state at a time.
<img width="1881" height="772" alt="image" src="https://github.com/user-attachments/assets/9f67b0a9-66e5-42db-8ad0-89b3702d4d5a" />

5. After the test, if you get stuck with a stale lock:
```bash
terraform force-unlock <LOCK_ID>
```
<img width="1850" height="325" alt="image" src="https://github.com/user-attachments/assets/5ba95623-01c7-40bd-b358-030b2d78134e" />

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

-->**Step 1:** Create S3 Bucket Manually: Go to Amazon Web Services Console: S3 → Create Bucket --> name of bucket: terraweek-import-test-sonali

<img width="1892" height="845" alt="image" src="https://github.com/user-attachments/assets/5a4099bd-81b8-4a7f-adf2-dd943274dd72" />

-->**Step 2:** Now in console create one file name as s3_bucket.tf and, Add Terraform Resource Block

<img width="255" height="58" alt="image" src="https://github.com/user-attachments/assets/4342a558-44dd-4adb-b64d-b1b60346f78d" />

**Note:** Your region should be same otherwise may face issue, To get location/region: **aws s3api get-bucket-location --bucket terraweek-import-test-sonali**
<img width="1877" height="482" alt="image" src="https://github.com/user-attachments/assets/6bc5c681-a349-495d-bab7-cbaa6dc1f0c8" />
<img width="1828" height="91" alt="image" src="https://github.com/user-attachments/assets/f8fc0454-2a04-492c-91ed-4ba018ba8e28" />

-->**Step 3:** Initialize Terraform: terraform init 

-->**Step 4:** Import Existing Bucket for that use command: terraform import aws_s3_bucket.imported terraweek-import-test-sonali
<img width="1907" height="897" alt="image" src="https://github.com/user-attachments/assets/026ed749-a291-4fd7-bcd1-ed41d93045e3" />
-->So here terraform apply Is NOT Needed, Because: Resource already exists in AWS, Terraform import only tells Terraform: "Start managing this existing resource.", No infrastructure creation is required.

---

### Task 5: State Surgery -- mv and rm
Sometimes you need to rename a resource or remove it from state without destroying it in AWS.

1. **Rename a resource in state:**
```bash
terraform state list                              # Note the current resource names
terraform state mv aws_s3_bucket.imported aws_s3_bucket.logs_bucket
```
Update your `.tf` file to match the new name. Run `terraform plan` -- it should show no changes.

<img width="1918" height="966" alt="image" src="https://github.com/user-attachments/assets/a406eb5c-b4f9-4b23-8e45-9f41191e69b4" />
<img width="1652" height="967" alt="image" src="https://github.com/user-attachments/assets/007d35c0-40b6-4135-862a-08531c35c859" />
<img width="1912" height="982" alt="image" src="https://github.com/user-attachments/assets/81266dd7-99d0-49c6-ae2c-242ae3291e92" />

2. **Remove a resource from state (without destroying it):**
```bash
terraform state rm aws_s3_bucket.logs_bucket

Run `terraform plan` -- Terraform no longer knows about the bucket, but it still exists in AWS.
```
<img width="1780" height="968" alt="image" src="https://github.com/user-attachments/assets/e802756b-100c-4c17-ac88-22390754c8de" />
<img width="1872" height="975" alt="image" src="https://github.com/user-attachments/assets/6229d1a3-0b88-4569-8522-1e86714cac44" />

3. **Re-import it** to bring it back:
```bash
terraform import aws_s3_bucket.logs_bucket terraweek-import-test-<yourname>
```
<img width="1910" height="717" alt="image" src="https://github.com/user-attachments/assets/782581c2-c8b1-4186-8c47-a2f506f90326" />
-->While importing the previous changes we have faced issue as "resource address "aws_s3_bucket.logs_bucket" does not exist in the configuration." That is because we have made chnages io file too, To solve it if we make chnages in file and rerun the import command then that error will get resolve.
<img width="581" height="560" alt="image" src="https://github.com/user-attachments/assets/97b0b4fe-ffc0-4f8c-b9d2-9797ec367779" />

**Document:** When would you use `state mv` in a real project? When would you use `state rm`?

-->In Terraform, the Terraform state file tracks infrastructure resources and their mapping to Terraform configuration. Commands like terraform state mv and terraform state rm are used to manipulate the state safely without modifying actual infrastructure.

1. terraform state mv
-->Purpose: terraform state mv is used to move or rename a resource inside the Terraform state file without recreating the actual infrastructure. It updates Terraform’s tracking information only.

Syntax: terraform state mv SOURCE DESTINATION

<img width="446" height="662" alt="image" src="https://github.com/user-attachments/assets/fbbab9cc-ba48-4e24-8521-5dddf573613f" />
<img width="472" height="660" alt="image" src="https://github.com/user-attachments/assets/d95b5698-cb4b-4cf8-863d-6ccfc6ca3a01" />
-->Important Characteristic state mv: DOES NOT destroy infrastructure, DOES NOT create infrastructure, ONLY changes Terraform state mapping etc.

2. terraform state rm
-->Purpose: terraform state rm removes a resource from Terraform state without deleting the actual AWS resource, Terraform stops managing the resource.

Syntax: terraform state rm RESOURCE_ADDRESS

<img width="435" height="602" alt="image" src="https://github.com/user-attachments/assets/bda5a361-82ff-428e-8da6-e7969188b34f" />
<img width="823" height="671" alt="image" src="https://github.com/user-attachments/assets/6e17ee84-a8fe-4471-bc80-e2dab3a97996" />

-->Important Characteristic state rm: DOES NOT destroy AWS resource, ONLY removes resource from Terraform state, Terraform no longer manages the resource.

<img width="757" height="745" alt="image" src="https://github.com/user-attachments/assets/a96f6e96-da55-4c5d-981b-d458b4360662" />

---

### Task 6: Simulate and Fix State Drift
State drift happens when someone changes infrastructure outside of Terraform -- through the AWS console, CLI, or another tool. causing actual AWS resources to differ from Terraform configuration/state.

1. Apply your full config so everything is in sync
<img width="1812" height="980" alt="image" src="https://github.com/user-attachments/assets/83292f09-3ae0-446f-bfd8-0c50dfdb383d" />
<img width="1697" height="948" alt="image" src="https://github.com/user-attachments/assets/1f314019-288c-48f1-b954-c1e078cd4232" />

2. Go to the **AWS console** and manually:
   - Change the Name tag of your EC2 instance to `"ManuallyChanged"`
   - Change the instance type if it's stopped (or add a new tag)
3. Run:
```bash
terraform plan
```
You should see a **diff** -- Terraform detects that reality no longer matches the desired state.
<img width="1913" height="878" alt="image" src="https://github.com/user-attachments/assets/a5743312-562b-4fae-8433-059a083956b1" />
<img width="1873" height="907" alt="image" src="https://github.com/user-attachments/assets/4d091a41-696b-462a-8a0d-3acb0ddd6d11" />

4. You have two choices:
   - **Option A:** Run `terraform apply` to force reality back to match your config (reconcile)
   - **Option B:** Update your `.tf` files to match the manual change (accept the drift)

5. Choose Option A -- apply and verify the tags are restored.
<img width="1520" height="925" alt="image" src="https://github.com/user-attachments/assets/d6e74327-3159-49e7-8bc0-dbd73c998b22" />

6. Run `terraform plan` again -- it should show "No changes." Drift resolved.
<img width="1207" height="397" alt="image" src="https://github.com/user-attachments/assets/b3605d7b-bc3f-4f31-aa6f-94899502909c" />

**Document:** How do teams prevent state drift in production? (hint: restrict console access, use CI/CD for all changes)
-->Preventing Terraform State Drift in Production: State drift occurs when infrastructure changes are made outside Terraform, causing actual cloud resources to differ from Terraform configuration and state. In production environments, unmanaged drift can lead to: inconsistent infrastructure, failed deployments, security risks, outages
configuration conflicts etc. To prevent drift, engineering teams follow strict Infrastructure as Code (IaC) practices.

<img width="712" height="377" alt="image" src="https://github.com/user-attachments/assets/9427de30-aced-4f0a-af6f-c6c9c0a514a9" />
<img width="636" height="562" alt="image" src="https://github.com/user-attachments/assets/fc759b07-6e09-4559-92e1-c0999a25f52a" />
<img width="566" height="280" alt="image" src="https://github.com/user-attachments/assets/8c02ecc5-7d67-489a-b70b-c0b88ab7a614" />
<img width="551" height="673" alt="image" src="https://github.com/user-attachments/assets/fc7d679b-d340-4bc7-9693-2ca2b4dfc124" />
<img width="463" height="817" alt="image" src="https://github.com/user-attachments/assets/b2659af0-7764-4634-ab42-7766a4f84722" />
<img width="622" height="743" alt="image" src="https://github.com/user-attachments/assets/098e8c33-016d-469c-a5f4-739e4eb5c3f5" />

-->These practices ensure infrastructure remains: predictable, secure, consistent, reproducible, easy to manage at scale etc.

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
