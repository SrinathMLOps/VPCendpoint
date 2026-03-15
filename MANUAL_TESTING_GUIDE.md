# Manual Testing Guide - VPC Endpoint for S3

## Overview
This guide walks you through manually testing the VPC Endpoint setup to verify that a private EC2 instance can access S3 without internet connectivity.

---

## Pre-Deployment Checklist

- [ ] AWS Account with admin access
- [ ] AWS CLI configured locally (optional)
- [ ] EC2 Key Pair created in eu-west-2 region
- [ ] Key pair .pem file downloaded and saved
- [ ] Terraform installed (v1.0+)
- [ ] Unique S3 bucket name chosen

---

## Part 1: Deploy Infrastructure

### Step 1: Navigate to Project Directory

```powershell
cd vpc-s3-endpoint
```

### Step 2: Update terraform.tfvars

Open `terraform.tfvars` and update:

```hcl
key_name       = "my-aws-key"                    # Your actual key pair name
s3_bucket_name = "srinath-vpc-demo-20260315"     # Unique bucket name
```

### Step 3: Set AWS Credentials

```powershell
$env:AWS_ACCESS_KEY_ID="AKIA..."
$env:AWS_SECRET_ACCESS_KEY="your-secret-key"
$env:AWS_DEFAULT_REGION="eu-west-2"
```

### Step 4: Initialize Terraform

```bash
terraform init
```

**Expected Output:**
```
Terraform has been successfully initialized!
```

### Step 5: Validate Configuration

```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### Step 6: Review Plan

```bash
terraform plan
```

**Expected Output:**
```
Plan: 18 to add, 0 to change, 0 to destroy.
```

Review the resources that will be created.

### Step 7: Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

**Wait Time:** 3-5 minutes

**Expected Output:**
```
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

Outputs:

public_server_public_ip = "13.x.x.x"
private_server_private_ip = "10.0.1.x"
s3_bucket_name = "srinath-vpc-demo-20260315"
vpc_endpoint_id = "vpce-xxxxx"
...
```

**IMPORTANT:** Copy these outputs to a notepad!

---

## Part 2: Verify in AWS Console

### Step 1: Verify VPC

1. Go to AWS Console → VPC
2. Region: London (eu-west-2)
3. Find VPC named "myvpc1"
4. CIDR: 10.0.0.0/16

**✓ Verified:** VPC created

### Step 2: Verify Subnets

1. VPC → Subnets
2. Find "public-subnet" (10.0.0.0/24)
3. Find "private-subnet" (10.0.1.0/24)

**✓ Verified:** Subnets created

### Step 3: Verify Internet Gateway

1. VPC → Internet Gateways
2. Find "myvpc1-igw"
3. State: Attached to myvpc1

**✓ Verified:** Internet Gateway attached

### Step 4: Verify Route Tables

1. VPC → Route Tables
2. Find "public-route-table"
   - Routes: 0.0.0.0/0 → igw-xxxxx
   - Associated with public-subnet
3. Find "private-route-table"
   - Routes: 10.0.0.0/16 → local
   - Routes: pl-xxxxx (S3 prefix list) → vpce-xxxxx
   - Associated with private-subnet

**✓ Verified:** Route tables configured correctly

### Step 5: Verify VPC Endpoint

1. VPC → Endpoints
2. Find "s3-vpc-endpoint"
3. Service: com.amazonaws.eu-west-2.s3
4. Type: Gateway
5. State: Available
6. Route tables: Both public and private

**✓ Verified:** VPC Endpoint created

### Step 6: Verify EC2 Instances

1. EC2 → Instances
2. Find "public-server"
   - State: Running
   - Public IP: Yes
   - Private IP: 10.0.0.x
3. Find "private-server"
   - State: Running
   - Public IP: None
   - Private IP: 10.0.1.x

**✓ Verified:** EC2 instances running

### Step 7: Verify S3 Bucket

1. S3 → Buckets
2. Find your bucket (e.g., "srinath-vpc-demo-20260315")
3. Objects: sample-file.txt

**✓ Verified:** S3 bucket created with file

### Step 8: Verify IAM Role

1. IAM → Roles
2. Find "ec2-s3-access-role"
3. Trusted entity: ec2.amazonaws.com
4. Permissions: AmazonS3FullAccess

**✓ Verified:** IAM role configured

---

## Part 3: Test Public Server

### Step 1: SSH to Public Server

```bash
ssh -i my-aws-key.pem ec2-user@<PUBLIC_IP>
```

Replace `<PUBLIC_IP>` with the actual public IP from outputs.

**Expected:**
```
[ec2-user@ip-10-0-0-x ~]$
```

**✓ Connected:** Public server accessible

### Step 2: Verify Internet Access

```bash
ping -c 3 google.com
```

**Expected:**
```
64 bytes from google.com: icmp_seq=1 ttl=xxx time=xx ms
```

**✓ Verified:** Public server has internet access

### Step 3: Test AWS CLI

```bash
aws --version
```

**Expected:**
```
aws-cli/2.x.x Python/3.x.x Linux/x.x.x
```

**✓ Verified:** AWS CLI installed

### Step 4: List S3 Buckets

```bash
aws s3 ls
```

**Expected:**
```
2026-03-15 10:30:00 srinath-vpc-demo-20260315
```

**✓ Verified:** Can list S3 buckets from public server

### Step 5: List Files in Bucket

```bash
aws s3 ls s3://srinath-vpc-demo-20260315/
```

Replace with your bucket name.

**Expected:**
```
2026-03-15 10:30:00         45 sample-file.txt
```

**✓ Verified:** Can list files in bucket

### Step 6: Download File from S3

```bash
aws s3 cp s3://srinath-vpc-demo-20260315/sample-file.txt .
cat sample-file.txt
```

**Expected:**
```
download: s3://srinath-vpc-demo-20260315/sample-file.txt to ./sample-file.txt
This is a sample file accessed via VPC Endpoint!
```

**✓ Verified:** Can download files from S3

---

## Part 4: Test Private Server (THE CRITICAL TEST!)

### Step 1: Copy Key to Public Server

From your local machine:

```bash
scp -i my-aws-key.pem my-aws-key.pem ec2-user@<PUBLIC_IP>:~/
```

**Expected:**
```
my-aws-key.pem                100%  1704    xx.xKB/s   00:00
```

**✓ Verified:** Key copied to public server

### Step 2: SSH to Private Server from Public Server

On public server:

```bash
chmod 600 my-aws-key.pem
ssh -i my-aws-key.pem ec2-user@<PRIVATE_IP>
```

Replace `<PRIVATE_IP>` with private server IP (10.0.1.x).

**Expected:**
```
[ec2-user@ip-10-0-1-x ~]$
```

**✓ Connected:** Private server accessible from public server

### Step 3: Verify NO Internet Access

```bash
ping -c 3 google.com
```

**Expected:**
```
ping: google.com: Name or service not known
```

OR

```
Request timeout
```

**✓ VERIFIED:** Private server has NO internet access (This is correct!)

### Step 4: Try HTTP Request (Should Fail)

```bash
curl -I https://google.com --max-time 10
```

**Expected:**
```
curl: (28) Connection timed out
```

**✓ VERIFIED:** No internet connectivity (This is correct!)

### Step 5: Test AWS CLI

```bash
aws --version
```

**Expected:**
```
aws-cli/2.x.x Python/3.x.x Linux/x.x.x
```

**✓ Verified:** AWS CLI installed

### Step 6: List S3 Buckets (CRITICAL TEST!)

```bash
aws s3 ls
```

**Expected:**
```
2026-03-15 10:30:00 srinath-vpc-demo-20260315
```

**✓ SUCCESS!** Private server can access S3 without internet!

### Step 7: List Files in Bucket

```bash
aws s3 ls s3://srinath-vpc-demo-20260315/
```

**Expected:**
```
2026-03-15 10:30:00         45 sample-file.txt
```

**✓ SUCCESS!** Can list files via VPC Endpoint!

### Step 8: Download File from S3

```bash
aws s3 cp s3://srinath-vpc-demo-20260315/sample-file.txt .
cat sample-file.txt
```

**Expected:**
```
download: s3://srinath-vpc-demo-20260315/sample-file.txt to ./sample-file.txt
This is a sample file accessed via VPC Endpoint!
```

**✓ SUCCESS!** Can download files via VPC Endpoint!

### Step 9: Upload File to S3

```bash
echo "Uploaded from private server via VPC Endpoint!" > test-upload.txt
aws s3 cp test-upload.txt s3://srinath-vpc-demo-20260315/
```

**Expected:**
```
upload: ./test-upload.txt to s3://srinath-vpc-demo-20260315/test-upload.txt
```

**✓ SUCCESS!** Can upload files via VPC Endpoint!

### Step 10: Verify Upload

```bash
aws s3 ls s3://srinath-vpc-demo-20260315/
```

**Expected:**
```
2026-03-15 10:30:00         45 sample-file.txt
2026-03-15 10:35:00         50 test-upload.txt
```

**✓ SUCCESS!** File uploaded successfully!

---

## Part 5: Final Verification

### Verification Checklist

- [✓] VPC created with correct CIDR
- [✓] Public and private subnets created
- [✓] Internet Gateway attached
- [✓] Route tables configured correctly
- [✓] VPC Endpoint for S3 created
- [✓] Public EC2 has public IP
- [✓] Private EC2 has NO public IP
- [✓] Can SSH to public server
- [✓] Can SSH to private server from public
- [✓] Public server has internet access
- [✓] Private server has NO internet access
- [✓] Private server CAN access S3
- [✓] Can list S3 buckets from private server
- [✓] Can download from S3 via private server
- [✓] Can upload to S3 via private server

### Success Criteria

**✅ VPC Endpoint is Working Correctly!**

The private server:
- Has NO internet connectivity
- CAN access S3 buckets
- CAN download files from S3
- CAN upload files to S3

This proves the VPC Endpoint is routing S3 traffic privately through AWS network!

---

## Part 6: Understanding the Flow

### Traffic Flow Diagram

```
Private Server (10.0.1.x)
         │
         │ aws s3 ls
         ▼
Private Route Table
         │
         │ Checks routes
         ▼
VPC Endpoint (vpce-xxxxx)
         │
         │ Private AWS Network
         ▼
S3 Service (eu-west-2)
         │
         │ Returns bucket list
         ▼
Private Server
```

### Key Points

1. **No Internet Gateway** in private route table
2. **VPC Endpoint route** added automatically
3. **S3 prefix list** (pl-xxxxx) routes to VPC Endpoint
4. **Traffic never leaves AWS** network
5. **IAM role** provides authentication
6. **Security groups** control access

---

## Part 7: Cleanup

### Step 1: Exit from Servers

```bash
# Exit from private server
exit

# Exit from public server
exit
```

### Step 2: Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

**Wait Time:** 3-5 minutes

**Expected Output:**
```
Destroy complete! Resources: 18 destroyed.
```

### Step 3: Verify in AWS Console

1. EC2 → Instances: Should be terminated
2. VPC → VPCs: myvpc1 should be deleted
3. S3 → Buckets: Bucket should be deleted
4. VPC → Endpoints: Endpoint should be deleted

**✓ Verified:** All resources cleaned up

---

## Troubleshooting

### Issue: Cannot SSH to public server

**Solution:**
- Check security group allows SSH from your IP
- Verify key pair name matches
- Check public IP is assigned

### Issue: Cannot SSH to private server

**Solution:**
- Verify key is copied to public server
- Check key permissions (chmod 600)
- Verify private IP is correct

### Issue: Private server cannot access S3

**Solution:**
- Check VPC Endpoint is created
- Verify route tables include endpoint
- Check IAM role is attached to instance
- Wait 2-3 minutes after creation

### Issue: Terraform apply fails

**Solution:**
- Check AWS credentials
- Verify key pair exists in eu-west-2
- Ensure S3 bucket name is unique
- Check IAM permissions

---

## Cost Analysis

| Resource | Cost | Notes |
|----------|------|-------|
| VPC | Free | No charge |
| Subnets | Free | No charge |
| Internet Gateway | Free | No data transfer yet |
| Route Tables | Free | No charge |
| VPC Endpoint (Gateway) | Free | S3 gateway endpoints are free |
| EC2 t3.micro (2x) | $0.0104/hour each | ~$15/month if left running |
| S3 Storage | $0.023/GB/month | Minimal for testing |
| **Total** | **~$15-20/month** | If left running 24/7 |

**For Testing:** Run for 1 hour = ~$0.02

---

## Key Learnings

1. **VPC Endpoints** provide private connectivity to AWS services
2. **Gateway Endpoints** (S3, DynamoDB) are free
3. **Private subnets** can access S3 without NAT Gateway
4. **IAM roles** are better than access keys
5. **Security** is enhanced by avoiding internet exposure
6. **Performance** is better through AWS backbone
7. **Cost savings** by not needing NAT Gateway (~$32/month)

---

## Next Steps

- Add more EC2 instances
- Create VPC Endpoint for DynamoDB
- Implement VPC Flow Logs
- Add CloudWatch monitoring
- Create Auto Scaling groups
- Add Application Load Balancer
- Implement multi-AZ setup

---

## Conclusion

**✅ VPC Endpoint Setup Successful!**

You have successfully:
- Created a VPC with public and private subnets
- Deployed EC2 instances in both subnets
- Created an S3 bucket
- Configured VPC Endpoint for S3
- Verified private server can access S3 without internet
- Tested upload and download operations

This setup demonstrates how to securely access AWS services from private subnets without exposing them to the internet!

