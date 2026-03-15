# AWS Console Manual Setup Guide - VPC Endpoint for S3

Complete step-by-step guide to create VPC Endpoint infrastructure manually using AWS Console (without Terraform).

**Time Required:** 60-90 minutes  
**Difficulty:** Beginner-Friendly  
**Cost:** ~$0.02/hour (~$15/month if left running)

---

## 📋 What You'll Create

By the end of this guide, you'll have:
- 1 VPC with public and private subnets
- 2 EC2 instances (public bastion and private server)
- 1 S3 bucket with sample file
- 1 VPC Endpoint for S3 (Gateway type)
- Complete networking setup (IGW, route tables, security groups)
- IAM role for EC2 to access S3

---

## 🎯 Architecture Overview

```
Internet
   │
   ▼
Internet Gateway
   │
   ▼
Public Subnet (10.0.0.0/24)
   │
   ├─► Public EC2 (Bastion Host)
   │
   ▼
Private Subnet (10.0.1.0/24)
   │
   ├─► Private EC2 (No Internet)
   │
   ▼
VPC Endpoint (Gateway)
   │
   ▼
S3 Bucket
```

---

## Part 1: Create VPC and Subnets (15 minutes)

### Step 1: Create VPC

1. Log in to **AWS Console**: https://console.aws.amazon.com
2. Search for **VPC** in the top search bar
3. Click **VPC** service
4. In the left sidebar, click **Your VPCs**
5. Click **Create VPC** (orange button)

**Configure VPC:**
- **Resources to create:** VPC only
- **Name tag:** `myvpc1`
- **IPv4 CIDR block:** `10.0.0.0/16`
- **IPv6 CIDR block:** No IPv6 CIDR block
- **Tenancy:** Default
- **Tags:** Leave as is

6. Click **Create VPC**

**Expected Result:** ✅ VPC created with ID like `vpc-0123456789abcdef`

📝 **Note down your VPC ID** - you'll need it later!

---

### Step 2: Enable DNS Hostnames

1. Still in **Your VPCs** page
2. Select your VPC (`myvpc1`)
3. Click **Actions** → **Edit VPC settings**
4. Check ✅ **Enable DNS hostnames**
5. Check ✅ **Enable DNS resolution** (should already be checked)
6. Click **Save**

**Why?** This allows EC2 instances to get DNS names.

---

### Step 3: Create Public Subnet

1. In left sidebar, click **Subnets**
2. Click **Create subnet**

**Configure Subnet:**
- **VPC ID:** Select `myvpc1` (your VPC)
- **Subnet name:** `public-subnet`
- **Availability Zone:** Choose first one (e.g., eu-west-2a)
- **IPv4 CIDR block:** `10.0.0.0/24`

3. Click **Create subnet**

**Expected Result:** ✅ Public subnet created

---

### Step 4: Enable Auto-assign Public IP for Public Subnet

1. Select your `public-subnet`
2. Click **Actions** → **Edit subnet settings**
3. Check ✅ **Enable auto-assign public IPv4 address**
4. Click **Save**

**Why?** EC2 instances in this subnet will automatically get public IPs.

---

### Step 5: Create Private Subnet

1. Click **Create subnet** again

**Configure Subnet:**
- **VPC ID:** Select `myvpc1`
- **Subnet name:** `private-subnet`
- **Availability Zone:** Same as public subnet (e.g., eu-west-2a)
- **IPv4 CIDR block:** `10.0.1.0/24`

2. Click **Create subnet**

**Expected Result:** ✅ Private subnet created (no auto-assign public IP)

---

## Part 2: Create Internet Gateway and Route Tables (10 minutes)

### Step 6: Create Internet Gateway

1. In left sidebar, click **Internet Gateways**
2. Click **Create internet gateway**

**Configure:**
- **Name tag:** `myvpc1-igw`

3. Click **Create internet gateway**

**Expected Result:** ✅ IGW created but shows "Detached"

---

### Step 7: Attach Internet Gateway to VPC

1. Select your IGW (`myvpc1-igw`)
2. Click **Actions** → **Attach to VPC**
3. Select your VPC (`myvpc1`)
4. Click **Attach internet gateway**

**Expected Result:** ✅ State changes to "Attached"

---

### Step 8: Create Public Route Table

1. In left sidebar, click **Route Tables**
2. Click **Create route table**

**Configure:**
- **Name:** `public-route-table`
- **VPC:** Select `myvpc1`

3. Click **Create route table**

---

### Step 9: Add Internet Route to Public Route Table

1. Select `public-route-table`
2. Click **Routes** tab (bottom panel)
3. Click **Edit routes**
4. Click **Add route**

**Configure Route:**
- **Destination:** `0.0.0.0/0`
- **Target:** Internet Gateway → Select `myvpc1-igw`

5. Click **Save changes**

**Expected Result:** ✅ Route to internet added

---

### Step 10: Associate Public Subnet with Public Route Table

1. Still on `public-route-table`
2. Click **Subnet associations** tab
3. Click **Edit subnet associations**
4. Check ✅ `public-subnet`
5. Click **Save associations**

**Expected Result:** ✅ Public subnet now routes to internet

---

### Step 11: Create Private Route Table

1. Click **Create route table**

**Configure:**
- **Name:** `private-route-table`
- **VPC:** Select `myvpc1`

2. Click **Create route table**

**Note:** Don't add internet route - this keeps it private!

---

### Step 12: Associate Private Subnet with Private Route Table

1. Select `private-route-table`
2. Click **Subnet associations** tab
3. Click **Edit subnet associations**
4. Check ✅ `private-subnet`
5. Click **Save associations**

**Expected Result:** ✅ Private subnet has no internet access

---

## Part 3: Create Security Groups (10 minutes)

### Step 13: Create Public Security Group

1. In left sidebar, click **Security Groups**
2. Click **Create security group**

**Configure:**
- **Security group name:** `public-server-sg`
- **Description:** `Security group for public EC2 instance`
- **VPC:** Select `myvpc1`

**Inbound rules:**
- Click **Add rule**
  - **Type:** SSH
  - **Protocol:** TCP
  - **Port range:** 22
  - **Source:** My IP (or 0.0.0.0/0 for anywhere)
  - **Description:** SSH from anywhere

**Outbound rules:**
- Leave default (All traffic to 0.0.0.0/0)

3. Click **Create security group**

📝 **Note down the Security Group ID** (e.g., sg-0123456789abcdef)

---

### Step 14: Create Private Security Group

1. Click **Create security group**

**Configure:**
- **Security group name:** `private-server-sg`
- **Description:** `Security group for private EC2 instance`
- **VPC:** Select `myvpc1`

**Inbound rules:**
- Click **Add rule**
  - **Type:** SSH
  - **Protocol:** TCP
  - **Port range:** 22
  - **Source:** Custom → Select `public-server-sg` (type "sg-" to find it)
  - **Description:** SSH from public subnet

**Outbound rules:**
- Leave default (All traffic to 0.0.0.0/0)

2. Click **Create security group**

**Why?** Private server only accepts SSH from public server.

---

## Part 4: Create IAM Role for S3 Access (10 minutes)

### Step 15: Create IAM Role

1. Search for **IAM** in top search bar
2. Click **IAM** service
3. In left sidebar, click **Roles**
4. Click **Create role**

**Step 1: Select trusted entity**
- **Trusted entity type:** AWS service
- **Use case:** EC2
- Click **Next**

**Step 2: Add permissions**
- Search for: `AmazonS3FullAccess`
- Check ✅ `AmazonS3FullAccess`
- Click **Next**

**Step 3: Name, review, and create**
- **Role name:** `ec2-s3-access-role`
- **Description:** `Allows EC2 instances to access S3`
- Click **Create role**

**Expected Result:** ✅ IAM role created

📝 **Note down the role name:** `ec2-s3-access-role`

---

## Part 5: Create S3 Bucket (5 minutes)

### Step 16: Create S3 Bucket

1. Search for **S3** in top search bar
2. Click **S3** service
3. Click **Create bucket**

**Configure:**
- **Bucket name:** `your-unique-name-vpc-endpoint-2026` (must be globally unique!)
- **AWS Region:** Same as your VPC (e.g., eu-west-2)
- **Block Public Access:** Keep all checked (default)
- **Bucket Versioning:** Disable
- **Tags:** Optional
- **Default encryption:** Enable (default)

4. Click **Create bucket**

**Expected Result:** ✅ S3 bucket created

📝 **Note down your bucket name**

---

### Step 17: Upload Sample File to S3

1. Click on your bucket name
2. Click **Upload**
3. Click **Add files**
4. Create a text file on your computer named `sample-file.txt` with content:
   ```
   This is a sample file accessed via VPC Endpoint!
   ```
5. Select the file and upload
6. Click **Upload**

**Expected Result:** ✅ File uploaded to S3

---

## Part 6: Create VPC Endpoint for S3 (5 minutes)

### Step 18: Create VPC Endpoint

1. Go back to **VPC** service
2. In left sidebar, click **Endpoints**
3. Click **Create endpoint**

**Configure:**
- **Name tag:** `s3-vpc-endpoint`
- **Service category:** AWS services
- **Services:** 
  - Search for: `s3`
  - Select: `com.amazonaws.eu-west-2.s3` (Gateway type)
- **VPC:** Select `myvpc1`
- **Route tables:** 
  - Check ✅ `public-route-table`
  - Check ✅ `private-route-table`
- **Policy:** Full access (default)

4. Click **Create endpoint**

**Expected Result:** ✅ VPC Endpoint created with status "Available"

📝 **Note down the VPC Endpoint ID** (e.g., vpce-0123456789abcdef)

**What this does:** Automatically adds routes to S3 in both route tables!

---

## Part 7: Launch EC2 Instances (15 minutes)

### Step 19: Launch Public EC2 Instance

1. Search for **EC2** in top search bar
2. Click **EC2** service
3. Click **Launch instance**

**Configure:**

**Name and tags:**
- **Name:** `public-server`

**Application and OS Images (AMI):**
- **Quick Start:** Amazon Linux
- **Amazon Machine Image (AMI):** Amazon Linux 2023 AMI
- **Architecture:** 64-bit (x86)

**Instance type:**
- **Instance type:** t3.micro (free tier eligible)

**Key pair:**
- **Key pair name:** Select your existing key pair (or create new)
- 📝 **Remember your key pair name!**

**Network settings:**
- Click **Edit**
- **VPC:** Select `myvpc1`
- **Subnet:** Select `public-subnet`
- **Auto-assign public IP:** Enable
- **Firewall (security groups):** Select existing security group
  - Select `public-server-sg`

**Advanced details:**
- Scroll down to **IAM instance profile**
- Select `ec2-s3-access-role`
- **User data:** (optional, paste this to auto-install AWS CLI)
  ```bash
  #!/bin/bash
  yum update -y
  yum install -y aws-cli
  ```

4. Click **Launch instance**

**Expected Result:** ✅ Public EC2 instance launching

📝 **Note down the Instance ID and Public IP**

---

### Step 20: Launch Private EC2 Instance

1. Click **Launch instance** again

**Configure:**

**Name and tags:**
- **Name:** `private-server`

**Application and OS Images (AMI):**
- **Quick Start:** Amazon Linux
- **Amazon Machine Image (AMI):** Amazon Linux 2023 AMI
- **Architecture:** 64-bit (x86)

**Instance type:**
- **Instance type:** t3.micro

**Key pair:**
- **Key pair name:** Same as public server

**Network settings:**
- Click **Edit**
- **VPC:** Select `myvpc1`
- **Subnet:** Select `private-subnet`
- **Auto-assign public IP:** Disable (should be disabled by default)
- **Firewall (security groups):** Select existing security group
  - Select `private-server-sg`

**Advanced details:**
- **IAM instance profile:** Select `ec2-s3-access-role`
- **User data:**
  ```bash
  #!/bin/bash
  yum update -y
  yum install -y aws-cli
  ```

2. Click **Launch instance**

**Expected Result:** ✅ Private EC2 instance launching (no public IP)

📝 **Note down the Instance ID and Private IP**

---

### Step 21: Wait for Instances to be Running

1. Go to **EC2** → **Instances**
2. Wait until both instances show:
   - **Instance state:** Running
   - **Status check:** 2/2 checks passed (takes 2-3 minutes)

---

## Part 8: Test VPC Endpoint (20 minutes)

### Step 22: Connect to Public Server

1. In EC2 Console, select `public-server`
2. Note the **Public IPv4 address** (e.g., 35.178.235.246)
3. Open your terminal/PowerShell
4. Run:
   ```bash
   ssh -i your-key.pem ec2-user@<PUBLIC_IP>
   ```

Replace:
- `your-key.pem` with your key file
- `<PUBLIC_IP>` with actual public IP

**If permission error:**
```bash
chmod 400 your-key.pem
```

**Expected:** ✅ Connected to public server

---

### Step 23: Test S3 Access from Public Server

On the public server, run:

```bash
# List all S3 buckets
aws s3 ls
```

**Expected:** You see your bucket listed

```bash
# List files in your bucket
aws s3 ls s3://your-bucket-name/
```

**Expected:** You see `sample-file.txt`

```bash
# Download the file
aws s3 cp s3://your-bucket-name/sample-file.txt .

# View the file
cat sample-file.txt
```

**Expected:** You see the file content

✅ **Public server can access S3 (normal - it has internet)**

---

### Step 24: Copy Your Key to Public Server

**Open a NEW terminal** (keep SSH session open).

From your local machine:

```bash
scp -i your-key.pem your-key.pem ec2-user@<PUBLIC_IP>:~/
```

**Expected:** Key copied successfully

---

### Step 25: Connect to Private Server from Public Server

**Go back to your SSH session** on public server.

1. Note the private IP of private server from EC2 Console (e.g., 10.0.1.245)

2. On public server, run:
   ```bash
   # Set correct permissions
   chmod 600 your-key.pem
   
   # Connect to private server
   ssh -i your-key.pem ec2-user@<PRIVATE_IP>
   ```

Replace `<PRIVATE_IP>` with actual private IP (10.0.1.x)

**Expected:** ✅ Connected to private server

---

### Step 26: Verify NO Internet Access (Critical Test!)

On the private server, run:

```bash
# Try to ping Google - should FAIL
ping -c 3 google.com
```

**Expected:** `ping: google.com: Name or service not known` or timeout

```bash
# Try to access a website - should FAIL
curl https://google.com
```

**Expected:** Connection timeout or failure

✅ **This proves private server has NO internet access!**

---

### Step 27: Verify S3 Access via VPC Endpoint (THE KEY TEST!)

Still on the private server, run:

```bash
# List all S3 buckets - should WORK
aws s3 ls
```

**Expected:** 🎉 You see your bucket listed!

```bash
# List files in your bucket - should WORK
aws s3 ls s3://your-bucket-name/
```

**Expected:** 🎉 You see `sample-file.txt`!

```bash
# Download the file - should WORK
aws s3 cp s3://your-bucket-name/sample-file.txt .

# View the file - should WORK
cat sample-file.txt
```

**Expected:** 🎉 You see: "This is a sample file accessed via VPC Endpoint!"

---

## 🎉 SUCCESS!

**You just proved that:**
1. ❌ Private server has NO internet access
2. ✅ Private server CAN access S3 via VPC Endpoint
3. ✅ All traffic stays within AWS network (secure and fast!)

This is exactly what VPC Endpoints are designed for!

---

## Part 9: Verify in AWS Console (5 minutes)

### Step 28: Check Route Tables

1. Go to **VPC** → **Route Tables**
2. Select `private-route-table`
3. Click **Routes** tab
4. You should see a route like:
   - **Destination:** pl-xxxxxx (prefix list for S3)
   - **Target:** vpce-xxxxx (your VPC endpoint)

**This route was automatically added by the VPC Endpoint!**

---

### Step 29: Check VPC Endpoint

1. Go to **VPC** → **Endpoints**
2. Select your endpoint (`s3-vpc-endpoint`)
3. Verify:
   - **Status:** Available
   - **Route tables:** Both route tables listed
   - **Policy:** Full access

---

## Part 10: Clean Up (15 minutes)

**IMPORTANT:** To avoid AWS charges, delete all resources when done testing.

### Step 30: Terminate EC2 Instances

1. Go to **EC2** → **Instances**
2. Select both instances (`public-server` and `private-server`)
3. Click **Instance state** → **Terminate instance**
4. Click **Terminate**
5. Wait for instances to terminate (2-3 minutes)

---

### Step 31: Delete VPC Endpoint

1. Go to **VPC** → **Endpoints**
2. Select your endpoint (`s3-vpc-endpoint`)
3. Click **Actions** → **Delete VPC endpoints**
4. Type `delete` to confirm
5. Click **Delete**

---

### Step 32: Delete S3 Bucket

1. Go to **S3**
2. Select your bucket
3. Click **Empty** (to delete all files first)
4. Type `permanently delete` to confirm
5. Click **Empty**
6. Go back, select bucket again
7. Click **Delete**
8. Type bucket name to confirm
9. Click **Delete bucket**

---

### Step 33: Delete NAT Gateway (if any)

1. Go to **VPC** → **NAT Gateways**
2. If any exist, select and delete them
3. Wait for deletion (takes a few minutes)

---

### Step 34: Detach and Delete Internet Gateway

1. Go to **VPC** → **Internet Gateways**
2. Select `myvpc1-igw`
3. Click **Actions** → **Detach from VPC**
4. Confirm detachment
5. Select it again
6. Click **Actions** → **Delete internet gateway**
7. Confirm deletion

---

### Step 35: Delete Subnets

1. Go to **VPC** → **Subnets**
2. Select `public-subnet`
3. Click **Actions** → **Delete subnet**
4. Confirm deletion
5. Repeat for `private-subnet`

---

### Step 36: Delete Route Tables

1. Go to **VPC** → **Route Tables**
2. Select `public-route-table`
3. Click **Actions** → **Delete route table**
4. Confirm deletion
5. Repeat for `private-route-table`

**Note:** You cannot delete the main route table.

---

### Step 37: Delete Security Groups

1. Go to **VPC** → **Security Groups**
2. Select `public-server-sg`
3. Click **Actions** → **Delete security groups**
4. Confirm deletion
5. Repeat for `private-server-sg`

**Note:** You cannot delete the default security group.

---

### Step 38: Delete VPC

1. Go to **VPC** → **Your VPCs**
2. Select `myvpc1`
3. Click **Actions** → **Delete VPC**
4. Type `delete` to confirm
5. Click **Delete**

---

### Step 39: Delete IAM Role

1. Go to **IAM** → **Roles**
2. Search for `ec2-s3-access-role`
3. Select it
4. Click **Delete**
5. Type role name to confirm
6. Click **Delete**

---

## 📊 Resource Summary

### What You Created (18 Resources)

| Resource | Name | Purpose |
|----------|------|---------|
| VPC | myvpc1 | Main network (10.0.0.0/16) |
| Public Subnet | public-subnet | Internet-accessible (10.0.0.0/24) |
| Private Subnet | private-subnet | Isolated (10.0.1.0/24) |
| Internet Gateway | myvpc1-igw | Internet access for public subnet |
| Public Route Table | public-route-table | Routes for public subnet |
| Private Route Table | private-route-table | Routes for private subnet |
| Public Security Group | public-server-sg | Firewall for bastion |
| Private Security Group | private-server-sg | Firewall for private server |
| IAM Role | ec2-s3-access-role | S3 access permissions |
| Public EC2 | public-server | Bastion host |
| Private EC2 | private-server | App server (no internet) |
| S3 Bucket | your-bucket-name | Object storage |
| VPC Endpoint | s3-vpc-endpoint | Private S3 access |

---

## 💰 Cost Breakdown

| Resource | Cost |
|----------|------|
| VPC, Subnets, IGW, Route Tables | Free |
| Security Groups | Free |
| VPC Endpoint (Gateway) | Free |
| EC2 t3.micro (2 instances) | $0.0104/hour each |
| S3 Storage | $0.023/GB/month |

**Total:** ~$0.02/hour (~$15/month if left running)

---

## 🔍 Comparison: Manual vs Terraform

### Manual (AWS Console)
**Pros:**
- ✅ Visual interface - see what you're creating
- ✅ Great for learning and understanding
- ✅ No code required
- ✅ Immediate feedback

**Cons:**
- ❌ Time-consuming (60-90 minutes)
- ❌ Error-prone (easy to miss steps)
- ❌ Hard to replicate
- ❌ No version control
- ❌ Manual cleanup required

### Terraform (Infrastructure as Code)
**Pros:**
- ✅ Fast deployment (3-5 minutes)
- ✅ Repeatable and consistent
- ✅ Version controlled
- ✅ Easy cleanup (`terraform destroy`)
- ✅ Can be automated

**Cons:**
- ❌ Requires learning Terraform syntax
- ❌ Less visual feedback
- ❌ Debugging can be harder

**Recommendation:** Learn manually first to understand concepts, then use Terraform for production!

---

## 🎓 What You Learned

1. ✅ How to create a VPC from scratch
2. ✅ How to configure public and private subnets
3. ✅ How to set up internet gateway and routing
4. ✅ How to configure security groups
5. ✅ How to create IAM roles for EC2
6. ✅ How to launch EC2 instances
7. ✅ How to create S3 buckets
8. ✅ How to create VPC Endpoints
9. ✅ How to test connectivity and access
10. ✅ How to clean up resources

---

## 🔧 Troubleshooting

### Cannot SSH to public server
- Check security group allows SSH from your IP
- Verify instance is running
- Check public IP is assigned
- Verify key permissions: `chmod 400 key.pem`

### Cannot SSH from public to private
- Check private security group allows SSH from public SG
- Verify key is copied to public server
- Check private IP is correct

### Cannot access S3 from private server
- Verify IAM role is attached to instance
- Check VPC Endpoint is created and available
- Verify route tables include VPC Endpoint routes
- Wait 2-3 minutes for IAM role to propagate

### Private server can access internet
- Check subnet is associated with private route table
- Verify private route table has NO route to IGW
- Check there's no NAT Gateway in the route table

---

## 📚 Additional Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS VPC Endpoints Guide](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [AWS S3 Gateway Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)

---

## ✨ Pro Tips

1. **Take screenshots** as you go - helps with troubleshooting
2. **Note down all IDs** - VPC ID, subnet IDs, security group IDs
3. **Use consistent naming** - makes it easier to find resources
4. **Test incrementally** - verify each step before moving on
5. **Clean up immediately** after testing - avoid unnecessary charges
6. **Use tags** - add tags to all resources for easy identification
7. **Check region** - ensure all resources are in the same region

---

## 🎯 Next Steps

After mastering manual creation:
1. Try creating the same setup in a different region
2. Add more EC2 instances to private subnet
3. Create VPC Endpoints for other services (DynamoDB)
4. Implement VPC Flow Logs for monitoring
5. Learn Terraform to automate this process

---

**Congratulations!** 🎉 You've successfully created a complete VPC Endpoint infrastructure manually in AWS Console!

**Time to Complete:** 60-90 minutes  
**Resources Created:** 18  
**Skills Learned:** VPC networking, EC2, S3, IAM, Security Groups, VPC Endpoints

---

**Repository:** https://github.com/SrinathMLOps/VPCendpoint

**For automated deployment, use the Terraform files in this repository!**
