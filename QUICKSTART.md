# Quick Start Guide - VPC Endpoint for S3

Get up and running in 10 minutes!

## Prerequisites Checklist

- [ ] AWS Account
- [ ] AWS Access Key ID and Secret Access Key
- [ ] EC2 Key Pair created in your AWS region
- [ ] Terraform installed (v1.5.0+)

## 5-Step Setup

### 1️⃣ Clone and Navigate

```bash
git clone https://github.com/SrinathMLOps/VPCendpoint.git
cd VPCendpoint
```

### 2️⃣ Configure Your Settings

Edit `terraform.tfvars`:

```hcl
aws_region     = "ap-south-1"                    # Change to your region
ami_id         = "ami-0c2af51e265bd5e0e"         # Amazon Linux 2023 AMI for your region
instance_type  = "t3.micro"                      # Free tier eligible
key_name       = "YOUR-KEY-NAME-HERE"            # ⚠️ CHANGE THIS
s3_bucket_name = "your-unique-name-12345"        # ⚠️ MUST BE GLOBALLY UNIQUE
```

**Important**: 
- Replace `YOUR-KEY-NAME-HERE` with your actual AWS key pair name
- S3 bucket name must be globally unique across all AWS accounts

### 3️⃣ Set AWS Credentials

**Windows PowerShell:**
```powershell
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
$env:AWS_DEFAULT_REGION="ap-south-1"
```

**Linux/Mac:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
export AWS_DEFAULT_REGION="ap-south-1"
```

**Or use AWS CLI:**
```bash
aws configure
```

### 4️⃣ Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted. Wait 3-5 minutes.

### 5️⃣ Test VPC Endpoint

After deployment, note the outputs:

```bash
# Connect to public server
ssh -i your-key.pem ec2-user@<PUBLIC_IP>

# Copy your key to public server (from local machine)
scp -i your-key.pem your-key.pem ec2-user@<PUBLIC_IP>:~/

# On public server, connect to private server
chmod 600 your-key.pem
ssh -i your-key.pem ec2-user@<PRIVATE_IP>

# On private server, test S3 access (NO INTERNET!)
aws s3 ls
aws s3 ls s3://your-bucket-name/
aws s3 cp s3://your-bucket-name/sample-file.txt .
cat sample-file.txt
```

**✅ Success!** If you can access S3 from the private server, VPC Endpoint is working!

## What You Just Created

```
Internet → Public EC2 (Bastion) → Private EC2 (No Internet)
                                        ↓
                                  VPC Endpoint
                                        ↓
                                    S3 Bucket
```

- **Public EC2**: Has internet access, used as jump server
- **Private EC2**: NO internet access, but can access S3 via VPC Endpoint
- **VPC Endpoint**: Private gateway to S3 (free, secure, fast)

## Verify It's Working

### Test 1: Private server has NO internet
```bash
# On private server - should FAIL
ping google.com
curl https://google.com
```

### Test 2: Private server CAN access S3
```bash
# On private server - should WORK
aws s3 ls
aws s3 ls s3://your-bucket-name/
```

This proves traffic goes through VPC Endpoint, not internet!

## Clean Up (Avoid Charges)

```bash
terraform destroy
```

Type `yes` when prompted.

## Cost

- **VPC Endpoint**: FREE
- **EC2 t3.micro (2 instances)**: ~$15/month
- **S3 Storage**: ~$0.023/GB/month

**Total**: ~$15-20/month if left running

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Cannot SSH to public server | Check security group allows SSH from your IP |
| Terraform apply fails | Verify AWS credentials and key pair exists |
| S3 bucket name error | Choose a globally unique name |
| Cannot access S3 from private | Check IAM role is attached to instance |

## Next Steps

- Read [README.md](README.md) for detailed architecture
- Follow [MANUAL_TESTING_GUIDE.md](MANUAL_TESTING_GUIDE.md) for comprehensive testing
- Explore the Terraform code in `main.tf`

## Need Help?

- Check AWS Console for resource status
- Review Terraform outputs: `terraform output`
- View detailed logs: `terraform apply -auto-approve`

---

**Happy Learning! 🚀**

If this helped you, give the repo a ⭐️ on GitHub!
