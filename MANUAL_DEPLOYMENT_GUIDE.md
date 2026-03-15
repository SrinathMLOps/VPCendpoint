# Manual Deployment Guide - VPC Endpoint for S3

Complete step-by-step guide to deploy VPC Endpoint infrastructure manually using Terraform (without GitHub Actions).

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] AWS Account with admin access
- [ ] Terraform installed on your computer
- [ ] AWS CLI installed (optional but recommended)
- [ ] Text editor (VS Code, Notepad++, etc.)
- [ ] Terminal/PowerShell access

---

## Part 1: AWS Setup (15 minutes)

### Step 1: Create AWS Access Keys

1. Log in to AWS Console: https://console.aws.amazon.com
2. Click your username (top right) → **Security Credentials**
3. Scroll down to **Access Keys** section
4. Click **Create Access Key**
5. Select **Command Line Interface (CLI)**
6. Check the confirmation box
7. Click **Create Access Key**
8. **IMPORTANT**: Copy and save both:
   - Access Key ID (looks like: `AKIAIOSFODNN7EXAMPLE`)
   - Secret Access Key (looks like: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)
9. Click **Done**

⚠️ **Keep these credentials safe! You'll need them in Step 5.**

---

### Step 2: Create EC2 Key Pair

1. Go to AWS Console → **EC2**
2. In left sidebar, click **Network & Security** → **Key Pairs**
3. Click **Create Key Pair** (orange button)
4. Enter name: `vpc-endpoint-key` (or any name you prefer)
5. Key pair type: **RSA**
6. Private key format: **.pem**
7. Click **Create Key Pair**
8. The `.pem` file will download automatically
9. **Save this file safely** - you'll need it to SSH into servers

📝 **Remember your key pair name** - you'll use it in Step 6!

---

### Step 3: Note Your AWS Region

Look at the top-right corner of AWS Console. You'll see your region like:
- **London** (eu-west-2)
- **Mumbai** (ap-south-1)
- **N. Virginia** (us-east-1)
- **Oregon** (us-west-2)

📝 **Write down the region code** (e.g., `eu-west-2`)

---

### Step 4: Find the Correct AMI ID for Your Region

1. Go to AWS Console → **EC2**
2. Click **Launch Instance** (don't actually launch, just checking)
3. In the AMI selection, find **Amazon Linux 2023 AMI**
4. Look for the AMI ID (looks like: `ami-0acc77abdfc7ed5a6`)
5. **Copy this AMI ID** - you'll need it in Step 6

Or use these common AMI IDs:

| Region | AMI ID | Name |
|--------|--------|------|
| eu-west-2 (London) | ami-0acc77abdfc7ed5a6 | Amazon Linux 2023 |
| ap-south-1 (Mumbai) | ami-0c2af51e265bd5e0e | Amazon Linux 2023 |
| us-east-1 (N. Virginia) | ami-0453ec754f44f9a4a | Amazon Linux 2023 |
| us-west-2 (Oregon) | ami-0aff18ec83b712f05 | Amazon Linux 2023 |

---

## Part 2: Local Setup (10 minutes)

### Step 5: Configure AWS Credentials

Open **PowerShell** (Windows) or **Terminal** (Mac/Linux) and run:

**Windows PowerShell:**
```powershell
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID_HERE"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY_HERE"
$env:AWS_DEFAULT_REGION="eu-west-2"
```

**Linux/Mac Terminal:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID_HERE"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY_HERE"
export AWS_DEFAULT_REGION="eu-west-2"
```

Replace:
- `YOUR_ACCESS_KEY_ID_HERE` with your actual Access Key ID from Step 1
- `YOUR_SECRET_ACCESS_KEY_HERE` with your actual Secret Access Key from Step 1
- `eu-west-2` with your region from Step 3

**Alternative Method (Permanent):**
```bash
aws configure
```
Then enter:
- AWS Access Key ID: [paste your key]
- AWS Secret Access Key: [paste your secret]
- Default region name: [your region, e.g., eu-west-2]
- Default output format: json

---

### Step 6: Update terraform.tfvars

Open the file `terraform.tfvars` in your text editor and update these values:

```hcl
# Terraform Variables - Update these values

aws_region     = "eu-west-2"                              # Your region from Step 3
ami_id         = "ami-0acc77abdfc7ed5a6"                  # Your AMI ID from Step 4
instance_type  = "t3.micro"                               # Keep as is (free tier)
key_name       = "vpc-endpoint-key"                       # Your key pair name from Step 2
s3_bucket_name = "srinath-vpc-endpoint-test-2026-march"   # Choose unique name
```

**Important for S3 bucket name:**
- Must be globally unique across ALL AWS accounts
- Use lowercase letters, numbers, and hyphens only
- Suggestion: `yourname-vpc-endpoint-test-YYYY-MM`

**Save the file** after making changes.

---

## Part 3: Deploy Infrastructure (10 minutes)

### Step 7: Open Terminal in Project Directory

1. Open PowerShell (Windows) or Terminal (Mac/Linux)
2. Navigate to your project folder:
   ```bash
   cd C:\Users\SRINATH\Desktop\VPCEndpoint
   ```

---

### Step 8: Initialize Terraform

Run this command:
```bash
terraform init
```

**Expected Output:**
```
Terraform has been successfully initialized!
```

**What this does:** Downloads the AWS provider plugin needed to create resources.

---

### Step 9: Validate Configuration

Run this command:
```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

**What this does:** Checks your Terraform files for syntax errors.

---

### Step 10: Preview What Will Be Created

Run this command:
```bash
terraform plan
```

**Expected Output:**
```
Plan: 18 to add, 0 to change, 0 to destroy.
```

**What this does:** Shows you exactly what resources Terraform will create:
- 1 VPC (Virtual Private Cloud)
- 2 Subnets (public and private)
- 1 Internet Gateway
- 2 Route Tables
- 2 Route Table Associations
- 2 Security Groups
- 1 IAM Role
- 1 IAM Role Policy Attachment
- 1 IAM Instance Profile
- 2 EC2 Instances (public and private servers)
- 1 S3 Bucket
- 1 S3 Object (sample file)
- 1 VPC Endpoint for S3

**Review the output carefully!** Make sure:
- ✅ No errors appear
- ✅ The key pair name is correct
- ✅ The S3 bucket name is unique
- ✅ The region is correct

---

### Step 11: Deploy the Infrastructure

Run this command:
```bash
terraform apply
```

**You'll see the plan again, then a prompt:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

**Type:** `yes` and press Enter

**Wait 3-5 minutes** while Terraform creates all resources.

**Expected Output:**
```
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

Outputs:

public_server_public_ip = "13.40.123.45"
private_server_private_ip = "10.0.1.234"
s3_bucket_name = "srinath-vpc-endpoint-test-2026-march"
vpc_endpoint_id = "vpce-0123456789abcdef"
vpc_id = "vpc-0123456789abcdef"
```

📝 **IMPORTANT: Copy these outputs!** You'll need them for testing.

---

## Part 4: Verify in AWS Console (5 minutes)

### Step 12: Check VPC

1. Go to AWS Console → **VPC**
2. Click **Your VPCs** in left sidebar
3. You should see: **myvpc1** with CIDR `10.0.0.0/16`

---

### Step 13: Check Subnets

1. In VPC Console, click **Subnets**
2. You should see:
   - **public-subnet** (10.0.0.0/24)
   - **private-subnet** (10.0.1.0/24)

---

### Step 14: Check EC2 Instances

1. Go to AWS Console → **EC2**
2. Click **Instances** in left sidebar
3. You should see 2 instances:
   - **public-server** (with public IP)
   - **private-server** (no public IP)
4. Both should be in **Running** state

---

### Step 15: Check S3 Bucket

1. Go to AWS Console → **S3**
2. You should see your bucket (e.g., `srinath-vpc-endpoint-test-2026-march`)
3. Click on the bucket
4. You should see a file: **sample-file.txt**

---

### Step 16: Check VPC Endpoint

1. Go to AWS Console → **VPC**
2. Click **Endpoints** in left sidebar
3. You should see an endpoint for S3
4. Status should be: **Available**
5. Service name: `com.amazonaws.eu-west-2.s3` (or your region)

---

## Part 5: Test VPC Endpoint (20 minutes)

This is the most important part - proving that the private server can access S3 without internet!

### Step 17: Connect to Public Server

Open PowerShell/Terminal and run:

```bash
ssh -i vpc-endpoint-key.pem ec2-user@13.40.123.45
```

Replace:
- `vpc-endpoint-key.pem` with your key file name
- `13.40.123.45` with your actual public IP from Step 11 outputs

**If you get "permission denied":**
```bash
chmod 400 vpc-endpoint-key.pem
```

**Expected:** You're now connected to the public server!

---

### Step 18: Test S3 Access from Public Server

On the public server, run:

```bash
# List all S3 buckets
aws s3 ls
```

**Expected:** You see your bucket listed

```bash
# List files in your bucket
aws s3 ls s3://srinath-vpc-endpoint-test-2026-march/
```

Replace with your actual bucket name.

**Expected:** You see `sample-file.txt`

```bash
# Download the file
aws s3 cp s3://srinath-vpc-endpoint-test-2026-march/sample-file.txt .

# View the file
cat sample-file.txt
```

**Expected:** You see: "This is a sample file accessed via VPC Endpoint!"

✅ **Public server can access S3 - this is normal (it has internet).**

---

### Step 19: Copy Your Key to Public Server

**Open a NEW terminal/PowerShell window** (keep the SSH session open).

From your local machine, run:

```bash
scp -i vpc-endpoint-key.pem vpc-endpoint-key.pem ec2-user@13.40.123.45:~/
```

Replace with your key file name and public IP.

**Expected:** Key file copied successfully.

---

### Step 20: Connect to Private Server

**Go back to your SSH session** on the public server.

Run these commands:

```bash
# Set correct permissions on the key
chmod 600 vpc-endpoint-key.pem

# Connect to private server
ssh -i vpc-endpoint-key.pem ec2-user@10.0.1.234
```

Replace `10.0.1.234` with your actual private IP from Step 11 outputs.

**Expected:** You're now connected to the private server!

---

### Step 21: Verify NO Internet Access (Critical Test!)

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

✅ **This proves the private server has NO internet access!**

---

### Step 22: Verify S3 Access via VPC Endpoint (THE KEY TEST!)

Still on the private server, run:

```bash
# List all S3 buckets - should WORK
aws s3 ls
```

**Expected:** You see your bucket listed! 🎉

```bash
# List files in your bucket - should WORK
aws s3 ls s3://srinath-vpc-endpoint-test-2026-march/
```

**Expected:** You see `sample-file.txt`! 🎉

```bash
# Download the file - should WORK
aws s3 cp s3://srinath-vpc-endpoint-test-2026-march/sample-file.txt .

# View the file - should WORK
cat sample-file.txt
```

**Expected:** You see: "This is a sample file accessed via VPC Endpoint!" 🎉

---

## 🎉 SUCCESS!

**You just proved that:**
1. ❌ Private server has NO internet access
2. ✅ Private server CAN access S3 via VPC Endpoint
3. ✅ All traffic stays within AWS network (secure and fast!)

This is exactly what VPC Endpoints are designed for!

---

## Part 6: Clean Up (5 minutes)

**IMPORTANT:** To avoid AWS charges, destroy all resources when done testing.

### Step 23: Exit SSH Sessions

```bash
# On private server
exit

# On public server
exit
```

You're back on your local machine.

---

### Step 24: Destroy Infrastructure

In your project directory, run:

```bash
terraform destroy
```

**You'll see a plan, then a prompt:**
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

**Type:** `yes` and press Enter

**Wait 3-5 minutes** while Terraform deletes all resources.

**Expected Output:**
```
Destroy complete! Resources: 18 destroyed.
```

---

### Step 25: Verify Cleanup in AWS Console

1. **EC2 Console** → Instances should be terminated
2. **VPC Console** → VPC should be deleted
3. **S3 Console** → Bucket should be deleted
4. **VPC Console** → Endpoints should be deleted

---

## 📊 Cost Breakdown

If you leave resources running:

| Resource | Cost |
|----------|------|
| VPC | Free |
| Subnets | Free |
| Internet Gateway | Free |
| Route Tables | Free |
| VPC Endpoint (Gateway) | Free |
| EC2 t3.micro (2 instances) | ~$0.0104/hour each = ~$0.50/day |
| S3 Storage | ~$0.023/GB/month (minimal) |

**Total if left running:** ~$15-20/month

**For testing (1 hour):** ~$0.02

---

## 🔧 Troubleshooting

### Error: "InvalidKeyPair.NotFound"
**Solution:** Update `key_name` in `terraform.tfvars` to match your actual AWS key pair name

### Error: "BucketAlreadyExists"
**Solution:** Change `s3_bucket_name` in `terraform.tfvars` to a different unique name

### Error: "UnauthorizedOperation"
**Solution:** Check your AWS credentials are set correctly (Step 5)

### Error: "Permission denied (publickey)" when SSH
**Solution:** 
```bash
chmod 400 vpc-endpoint-key.pem
```

### Cannot access S3 from private server
**Solution:** 
1. Check VPC Endpoint is created: AWS Console → VPC → Endpoints
2. Check IAM role is attached: AWS Console → EC2 → Instance → Security tab
3. Wait 2-3 minutes after deployment for IAM role to propagate

---

## 📚 What You Learned

1. ✅ How to create AWS infrastructure using Terraform
2. ✅ How VPC Endpoints work
3. ✅ How to secure private resources without internet access
4. ✅ How to test connectivity and access
5. ✅ How to clean up resources to avoid charges

---

## 🎯 Next Steps

- Modify the Terraform code to add more resources
- Try creating VPC Endpoints for other services (DynamoDB)
- Add more EC2 instances to the private subnet
- Implement VPC Flow Logs for monitoring
- Create a NAT Gateway for private instances to access internet (optional)

---

## 📞 Need Help?

- Review VERIFICATION_CHECKLIST.md for detailed checks
- Check README.md for architecture details
- Review Terraform logs for error messages
- Check AWS CloudTrail for API call history

---

**Congratulations!** 🎉 You've successfully deployed and tested VPC Endpoint infrastructure manually!
