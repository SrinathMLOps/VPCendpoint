# Quick Reference Card - VPC Endpoint Manual Deployment

## 🚀 5-Minute Quick Start

### 1. AWS Setup
```
✓ Create Access Keys (AWS Console → Security Credentials)
✓ Create EC2 Key Pair (EC2 → Key Pairs → Create)
✓ Note your region (top-right corner)
```

### 2. Configure Credentials
```powershell
$env:AWS_ACCESS_KEY_ID="YOUR_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET"
$env:AWS_DEFAULT_REGION="eu-west-2"
```

### 3. Update terraform.tfvars
```hcl
key_name       = "your-key-name"      # From AWS
s3_bucket_name = "unique-name-2026"   # Must be unique
```

### 4. Deploy
```bash
terraform init
terraform validate
terraform plan
terraform apply
```
Type `yes` when prompted.

### 5. Test
```bash
# Connect to public server
ssh -i your-key.pem ec2-user@<PUBLIC_IP>

# Copy key to public server (new terminal)
scp -i your-key.pem your-key.pem ec2-user@<PUBLIC_IP>:~/

# On public server, connect to private
chmod 600 your-key.pem
ssh -i your-key.pem ec2-user@<PRIVATE_IP>

# On private server - test VPC endpoint
ping google.com          # Should FAIL (no internet)
aws s3 ls                # Should WORK (via VPC endpoint)
```

### 6. Cleanup
```bash
terraform destroy
```
Type `yes` when prompted.

---

## 📋 Essential Commands

### Terraform Commands
```bash
terraform init          # Initialize (first time only)
terraform validate      # Check syntax
terraform fmt           # Format code
terraform plan          # Preview changes
terraform apply         # Deploy infrastructure
terraform destroy       # Delete everything
terraform output        # Show outputs again
```

### AWS CLI Commands
```bash
aws s3 ls                           # List all buckets
aws s3 ls s3://bucket-name/         # List files in bucket
aws s3 cp s3://bucket/file.txt .    # Download file
aws sts get-caller-identity         # Check AWS credentials
```

### SSH Commands
```bash
ssh -i key.pem ec2-user@<IP>        # Connect to server
scp -i key.pem file user@<IP>:~/    # Copy file to server
chmod 400 key.pem                   # Fix key permissions
exit                                # Disconnect
```

---

## 🎯 What Gets Created

```
18 Resources Total:

Network Layer:
├── 1 VPC (10.0.0.0/16)
├── 2 Subnets (public: 10.0.0.0/24, private: 10.0.1.0/24)
├── 1 Internet Gateway
├── 2 Route Tables
└── 2 Route Table Associations

Security Layer:
├── 2 Security Groups
├── 1 IAM Role
├── 1 IAM Policy Attachment
└── 1 IAM Instance Profile

Compute & Storage:
├── 2 EC2 Instances (public + private)
├── 1 S3 Bucket
└── 1 S3 Object (sample file)

VPC Endpoint:
└── 1 S3 Gateway Endpoint (FREE!)
```

---

## 🔍 Key Testing Points

### ✅ Success Indicators
- Public server has public IP
- Private server has NO public IP
- Can SSH to public server from internet
- Can SSH to private server from public server
- Private server CANNOT ping google.com
- Private server CAN access S3 buckets

### ❌ Failure Indicators
- "InvalidKeyPair.NotFound" → Wrong key name
- "BucketAlreadyExists" → Bucket name not unique
- "UnauthorizedOperation" → Wrong AWS credentials
- Cannot SSH → Check security group or key permissions

---

## 💰 Cost Summary

**Testing (1 hour):** ~$0.02
**Running 24 hours:** ~$0.50
**Running 1 month:** ~$15-20

**Free Resources:**
- VPC, Subnets, Internet Gateway
- Route Tables, Security Groups
- VPC Endpoint (Gateway type)

**Paid Resources:**
- EC2 t3.micro: $0.0104/hour each (2 instances)
- S3 Storage: $0.023/GB/month (minimal)

---

## 📁 Project Files

```
VPCEndpoint/
├── MANUAL_DEPLOYMENT_GUIDE.md  ← Full step-by-step guide
├── QUICK_REFERENCE.md          ← This file
├── QUICKSTART.md               ← 10-minute guide
├── README.md                   ← Architecture & overview
├── VERIFICATION_CHECKLIST.md   ← 27-point checklist
├── main.tf                     ← Infrastructure code
├── variables.tf                ← Input variables
├── outputs.tf                  ← Output values
├── versions.tf                 ← Version requirements
└── terraform.tfvars            ← Your configuration
```

---

## 🎓 Learning Path

**Beginner:** Start here
1. Read MANUAL_DEPLOYMENT_GUIDE.md
2. Follow steps 1-25 exactly
3. Test everything works
4. Destroy resources

**Intermediate:** Customize
1. Modify terraform.tfvars
2. Change instance types
3. Add more subnets
4. Experiment with security groups

**Advanced:** Extend
1. Add NAT Gateway
2. Create VPC Endpoints for other services
3. Implement VPC Flow Logs
4. Add Auto Scaling

---

## 🆘 Quick Troubleshooting

| Problem | Quick Fix |
|---------|-----------|
| Can't SSH | `chmod 400 key.pem` |
| Wrong key pair | Update `terraform.tfvars` |
| Bucket exists | Change bucket name |
| No AWS access | Check credentials in Step 2 |
| Plan fails | Run `terraform validate` |
| Apply hangs | Wait 5 minutes or Ctrl+C and retry |

---

## 📞 Get Help

**Documentation:**
- MANUAL_DEPLOYMENT_GUIDE.md - Complete guide
- README.md - Architecture details
- VERIFICATION_CHECKLIST.md - Testing checklist

**AWS Console:**
- EC2 → Check instances
- VPC → Check endpoints
- S3 → Check buckets
- CloudTrail → Check API calls

**Terraform:**
- `terraform show` - Current state
- `terraform output` - Show outputs
- `terraform state list` - List resources

---

## ✨ Pro Tips

1. **Always run `terraform plan` before `apply`**
2. **Save your outputs** - you'll need IPs for testing
3. **Test incrementally** - don't skip verification steps
4. **Destroy when done** - avoid unnecessary charges
5. **Keep your key file safe** - you can't recover it
6. **Use unique bucket names** - add date/time to ensure uniqueness
7. **Check AWS Console** - visual confirmation helps
8. **Read error messages** - they usually tell you what's wrong

---

## 🎯 Success Checklist

- [ ] AWS credentials configured
- [ ] terraform.tfvars updated
- [ ] `terraform init` successful
- [ ] `terraform apply` successful
- [ ] Can SSH to public server
- [ ] Can SSH to private server
- [ ] Private server cannot ping internet
- [ ] Private server CAN access S3
- [ ] `terraform destroy` successful
- [ ] AWS Console shows no resources

---

**Repository:** https://github.com/SrinathMLOps/VPCendpoint

**Time to Complete:** 45-60 minutes (first time)

**Difficulty:** Beginner-Friendly

**Cost:** ~$0.02 for testing

---

Good luck! 🚀
