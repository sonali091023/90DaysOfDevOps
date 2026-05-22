# Day 62 -- Providers, Resources and Dependencies

## Task
Yesterday you created standalone resources. But real infrastructure is connected -- a server lives inside a subnet, a subnet lives inside a VPC, a security group controls what traffic gets in. Today you build a complete networking stack on AWS and learn how Terraform figures out what to create first.

Understanding dependencies is what separates a Terraform beginner from someone who can build production infrastructure.

---

## Expected Output
- A VPC with subnet, internet gateway, route table, security group, and an EC2 instance -- all created via Terraform
- A dependency graph visualized with `terraform graph`
- A markdown file: `day-62-providers-resources.md`

---

## Challenge Tasks

### Task 1: Explore the AWS Provider
1. Create a new project directory: `terraform-aws-infra`
2. Write a `providers.tf` file:
   - Define the `terraform` block with `required_providers` pinning the AWS provider to version `~> 5.0`
   - Define the `provider "aws"` block with your region
3. Run `terraform init` and check the output -- what version was installed?
4. Run 'terraform init -upgrade' This updates .terraform.lock.hcl to match your current provider version. Done! [Due to mismatch of issue we may face issue like The error is clear! Your lock file has AWS provider 6.44.0 but your providers.tf says ~> 5.0.]

<img width="1236" height="950" alt="t1i1" src="https://github.com/user-attachments/assets/a9da8497-b2e8-47e8-80d3-1ff66a9b5f1d" />

4. Read the provider lock file `.terraform.lock.hcl` -- what does it do?

-->The .terraform.lock.hcl file locks the exact provider version (5.100.0) used in the project and ensures Terraform always installs the same version that 

satisfies the constraint ~> 5.0. It also stores hashes to verify the provider’s integrity, ensuring it is secure and not modified.
   
**Document:** What does `~> 5.0` mean? How is it different from `>= 5.0` and `= 5.0.0`?

**--> **~> 5.0** = Stay within version 5, but allow updates inside it Eg: 5.0.1, 5.1.0, 5.9.3

--> **>= 5.0** = Allows 5.0 and any higher version Eg: 5.0.0, 6.5.0, 8.6.1, 9.0.0, 10.0.0 

--> **= 5.0.0** = Exactly same version will get install Eg: Eg: only 5.0.0 and not 5.0.1, 5.5.5

---

### Task 2: Build a VPC from Scratch
Create a `main.tf` and define these resources one by one:

1. `aws_vpc` -- CIDR block `10.0.0.0/16`, tag it `"TerraWeek-VPC"`
2. `aws_subnet` -- CIDR block `10.0.1.0/24`, reference the VPC ID from step 1, enable public IP on launch, tag it `"TerraWeek-Public-Subnet"`
3. `aws_internet_gateway` -- attach it to the VPC
4. `aws_route_table` -- create it in the VPC, add a route for `0.0.0.0/0` pointing to the internet gateway
5. `aws_route_table_association` -- associate the route table with the subnet

Run `terraform plan` -- you should see 5 resources to create.
<img width="1513" height="982" alt="t2i1" src="https://github.com/user-attachments/assets/c6162914-7aaf-4bea-a47b-34a01c078a7c" />
<img width="1437" height="986" alt="t2i2" src="https://github.com/user-attachments/assets/b7e8d688-a432-4bc0-8379-028f866b44b2" />
<img width="1577" height="977" alt="t2i3" src="https://github.com/user-attachments/assets/9bb5f2d7-83fe-4d31-996c-8ad2d800d2e5" />

**Verify:** Apply and check the AWS VPC console. Can you see all five resources connected?
<img width="1562" height="981" alt="image" src="https://github.com/user-attachments/assets/df4ac59e-0c43-492a-85f5-718e2e8ecb54" />
<img width="1162" height="980" alt="image" src="https://github.com/user-attachments/assets/bdc3b4f8-e29f-46d0-9ccb-e2d8d7c55593" />
<img width="1316" height="982" alt="image" src="https://github.com/user-attachments/assets/3aa7d2d0-5c44-4013-9c2b-271b6ac8d456" />

AWS network architecture diagram:
<img width="1037" height="696" alt="image" src="https://github.com/user-attachments/assets/1b40ef3b-49b2-4fbf-8186-bf7d8fcb39eb" />

**Breakdown the diagram:**

**1. Internet:** This is you (your laptop/browser) trying to access your server.

**2. VPC (Virtual Private Cloud):** Think of this as your private network inside AWS in that CIDR block is : 10.0.0.0/16 & Name: TerraWeek-VPC

-->Simple: Like your own private WiFi network in the cloud

**3. Public Subnet:** A smaller network inside your VPC and CIDR block is: 10.0.1.0/24

-->Simple: A section of your network that can talk to the internet

**4. Internet Gateway (IGW):** This connects your VPC to the internet

-->Simple: Like a door between your private network and the outside world

**5. Route Table:** This tells traffic where to go = 0.0.0.0/0 → IGW

-->Simple: “Send all internet traffic through the Internet Gateway”

**6. Route Table Association:** This connects the route table to the subnet

-->Simple: “This subnet should follow these rules”

**7. EC2 Instance (Your Server):** This is your virtual machine, So Inside public subnet Has public IP

-->Simple: Your server where your app/website runs

**8. Security Group (Firewall):** Controls who can access your server & Allowed: SSH (22) → for login, HTTP (80) → for website, Outbound → everything allowed

-->Simple: Like a security guard deciding who can enter

**Full Flow (Most Important):** Here’s what actually happens:

-->You open browser → go to EC2 public IP-->Request goes to Internet-->Enters via Internet Gateway-->Route table says → send to subnet-->
Reaches your EC2 server-->Security group checks → “allowed?” -->If yes → you see your website

**Final One-Line Summary:**

-->You created a public server [EC2-Instance] in AWS that: 

-->is inside your private network (VPC)

-->connected to internet (IGW + route)

-->and protected by firewall (security group)

---

### Task 3: Understand Implicit Dependencies
Look at your `main.tf` carefully:

1. The subnet references `aws_vpc.main.id` -- this is an implicit dependency
2. The internet gateway references the VPC ID -- another implicit dependency
3. The route table association references both the route table and the subnet

Answer these questions:
- How does Terraform know to create the VPC before the subnet?

--> Terraform figures this out using dependency graph (automatic ordering) — you don’t have to tell it manually. So when your subnet references the vpc, So

terraform understands VPC need to create first and then subnet so this is called explicit dependency no extra configuraton is needed.

Eg:     resource "aws_subnet" "public_subnet" {
        
        vpc_id     = aws_vpc.vpc.id
    
     }

- What would happen if you tried to create the subnet before the VPC existed?

-->The subnet creation would fail because it needs a VPC ID that doesn’t exist yet, So we may face error "InvalidVpcID.NotFound"
  
- Find all implicit dependencies in your config and list them

-->So aws_subnet is depends on aws_vpc

-->aws_internet_gateway is dependens on aws_vpc

-->aws_route_table is depends on aws_vpc

-->aws_route_table_association is depends on public subnet and public route table

---

### Task 4: Add a Security Group and EC2 Instance
Add to your config:

1. `aws_security_group` in the VPC:
   - Ingress rule: allow SSH (port 22) from `0.0.0.0/0`
   - Ingress rule: allow HTTP (port 80) from `0.0.0.0/0`
   - Egress rule: allow all outbound traffic
   - Tag: `"TerraWeek-SG"`

2. `aws_instance` in the subnet:
   - Use Amazon Linux 2 AMI for your region
   - Instance type: `t2.micro`
   - Associate the security group
   - Set `associate_public_ip_address = true`
   - Tag: `"TerraWeek-Server"`

Apply and verify -- your EC2 instance should have a public IP and be reachable.

<img width="1655" height="252" alt="image" src="https://github.com/user-attachments/assets/c7ce3119-d75b-4d80-84f8-c99ba8f0cc04" />

<img width="933" height="372" alt="image" src="https://github.com/user-attachments/assets/7bda1be2-a2e4-4f27-92be-893d02551a46" />

<img width="1622" height="328" alt="image" src="https://github.com/user-attachments/assets/ea254017-ed4a-4d42-9e23-e44368ded926" />

Important commands used when we face "This site cant be reached issue"

1 curl localhost

2 sudo ss -tlnp | grep nginx

3 curl http://<public ip>/latest/meta-data/public-ipv4

4 curl -v <public ip>

5 sudo bash -c 'echo "<h1>Welcome to TerraWeek</h1>" > /usr/share/nginx/html/index.html'    #Used in case of Amazon Linux"

6 cat /usr/share/nginx/html/index.html

7 echo "<h1>Welcome to TerraWeek (Ubuntu)</h1>" > /var/www/html/index.nginx-debian.html  #used in case of ubuntu

8 cat /var/www/html/index.nginx-debian.html

---

**Task 5: Explicit Dependencies with depends_on**

Sometimes Terraform cannot detect a dependency automatically.

Add a second aws_s3_bucket resource for application logs
Add depends_on = [aws_instance.main] to the S3 bucket -- even though there is no direct reference, you want the bucket created only after the instance
Run terraform plan and observe the order
Now visualize the entire dependency tree:

terraform graph | dot -Tpng > graph.png
If you don't have dot (Graphviz) installed, use:

<img width="1463" height="226" alt="image" src="https://github.com/user-attachments/assets/e7c25784-2c57-4a6d-83b1-d531e0a7d97c" />

terraform graph
and paste the output into an online Graphviz viewer.

**Document:** When would you use depends_on in real projects? Give two examples.

depends_on is used to enforce the creation order of resources when Terraform cannot automatically determine it.

**Example:**

RDS depends on VPC & Subnets Ensure the VPC and subnets exist before creating the RDS database.

EC2 depends on IAM Role Make sure an IAM role with S3 access is created before attaching it to an EC2 instance.

ACM Certificate depends on CloudFront Ensure the ACM certificate is issued before attaching it to the CloudFront distribution.

### Task 6: Lifecycle Rules and Destroy
1. Add a `lifecycle` block to your EC2 instance:
```hcl
lifecycle {
  create_before_destroy = true
}
```
2. Change the AMI ID to a different one and run `terraform plan` -- observe that Terraform plans to create the new instance before destroying the old one

<img width="1258" height="462" alt="image" src="https://github.com/user-attachments/assets/59832f10-72ba-4e66-bca5-774d43f6bd00" />

3. Destroy everything:
```bash
terraform destroy
```
4. Watch the destroy order -- Terraform destroys in reverse dependency order. Verify in the AWS console that everything is cleaned up.

<img width="1675" height="446" alt="image" src="https://github.com/user-attachments/assets/a4dcb5d0-4d11-4425-8bd4-a3d0ab457d77" />

<img width="1643" height="88" alt="image" src="https://github.com/user-attachments/assets/882a1f4e-eb71-4cbf-ba6a-224928d99325" />

**Document:** What are the three lifecycle arguments (`create_before_destroy`, `prevent_destroy`, `ignore_changes`) and when would you use each?
-->create_before_destroy By default, Terraform destroys a resource before creating a new one; with create_before_destroy = true, Terraform first creates the new resource and then destroys the old one.

Example Update RDS instance without downtime.
prevent_destroy Protects a resource from accidental or intentional deletion; Terraform will block destroy operations and raise an error if attempted.

Example Prevent deletion of a production S3 bucket and database containing critical data.
ignore_changes Specifies resource attributes to ignore during updates; Terraform will not manage these attributes, useful when they are changed outside Terraform

Example Ignore EC2 instance tags or security group rules that are managed manually

**Note:** Why Terraform Defaults to ap-south-1

-->When you ran aws configure initially, you set a default region. Terraform picks that up automatically from your AWS CLI configuration. 

-->Best Practice — Always Explicitly Set Region in Terraform

<img width="751" height="432" alt="image" src="https://github.com/user-attachments/assets/6faddd13-e1a1-4ba0-8b35-06c76ad3d04e" />

**How terraform processes the file:** Each file has a specific responsibility but they all work together automatically because they're in the same folder.
<img width="702" height="392" alt="image" src="https://github.com/user-attachments/assets/db279a3a-b6c6-4e2b-a9ae-2cf84cac77f5" />
**Real World project structure:**
<img width="607" height="197" alt="image" src="https://github.com/user-attachments/assets/c5a3ad39-e9cd-4485-b70a-f79739cee552" />

---

## Hints
- `aws_vpc.main.id` syntax: `<resource_type>.<resource_name>.<attribute>`
- Use `terraform fmt` to keep your HCL clean
- CIDR `10.0.0.0/16` gives you 65,536 IPs, `10.0.1.0/24` gives you 256
- If you cannot SSH into the instance, check: security group rules, public IP, route table, internet gateway
- `terraform graph` outputs DOT format -- paste it into webgraphviz.com if you don't have Graphviz
- Always destroy resources when done to avoid AWS charges

---

## Documentation
Create `day-62-providers-resources.md` with:
- Your full `main.tf` with comments explaining each resource
- Screenshot of `terraform apply` output
- Screenshot of the VPC and its resources in the AWS console
- The dependency graph (image or text)
- Explanation of implicit vs explicit dependencies in your own words

---

## Submission
1. Add `day-62-providers-resources.md` to `2026/day-62/`
2. Commit and push to your fork

---

## Learn in Public
Share on LinkedIn: "Built a complete AWS networking stack with Terraform today -- VPC, subnets, internet gateway, route tables, security groups, and an EC2 instance. All connected through dependency graphs. Terraform decides the order, you define the desired state."

`#90DaysOfDevOps` `#TerraWeek` `#DevOpsKaJosh` `#TrainWithShubham`

Happy Learning!
**TrainWithShubham**
