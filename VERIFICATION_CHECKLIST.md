# VPC Endpoint Project - Verification Checklist

Use this checklist to verify everything is working correctly.

## ✅ Local Verification (Before Deployment)

### 1. Terraform Installation
```bash
terraform version
```
**Expected**: Terraform v1.5.0 or higher
**Status**: ✅ Terraform v1.13.3 installed

### 2. Terraform Initialization
```bash
terraform init
```
**Expected**: "Terraform has been successfully initialized!"
**Status**: ✅ Passed

### 3. Terraform Validation
```bash
terraform validate
```
**Expected**: "Success! The configuration is valid."
**Status**: ✅ Passed

### 4. Terraform Format Check
```bash
terraform fmt -check
```
**Expected**: No output (all files properly formatted)
**Status**: ✅ Passed

### 5. Configuration File Check
Edit `terraform.tfvars` and verify:
- [ ] `aws_region` is set to your target region
- [ ] `ami_id` matches your region's Amazon Linux 2023 AMI
- [ ] `key_name` is set to YOUR AWS key pair name
- [ ] `s3_bucket_name` is globally unique

**Current Configuration:**
```hcl
aws_region     = "eu-west-2"
ami_id         = "ami-0acc77abdfc7ed5a6"
instance_type  = "t3.micro"
key_name       = "my-aws-key"                              # ⚠️ CHANGE THIS
s3_bucket_name = "vpc-endpoint-demo-bucket-unique-12345"   # ⚠️ CHANGE THIS
```

## ✅ GitHub Repository Verification

### 6. GitHub Remote URL
```bash
git remote -v
```
**Expected**: `https://github.com/SrinathMLOps/VPCendpoint.git`
**Status**: ✅ Correct

### 7. GitHub Repository Check
Visit: https://github.com/SrinathMLOps/VPCendpoint

Verify these files exist:
- [ ] README.md (comprehensive documentation)
- [ ] QUICKSTART.md (quick setup guide)
- [ ] MANUAL_TESTING_GUIDE.md (testing steps)
- [ ] main.tf (Terraform configuration)
- [ ] variables.tf (input variables)
- [ ] outputs.tf (output values)
- [ ] versions.tf (version requirements)
- [ ] terraform.tfvars (configuration values)
- [ ] .github/workflows/terraform.yml (deploy workflow)
- [ ] .github/workflows/terraform-destroy.yml (destroy workflow)

### 8. GitHub Actions Workflows
Go to: https://github.com/SrinathMLOps/VPCendpoint/actions

Check:
- [ ] "VPC Endpoint for S3 - Deploy" workflow exists
- [ ] "VPC Endpoint - Destroy Infrastructure" workflow exists

## ✅ AWS Prerequisites

### 9. AWS Credentials
Check you have:
- [ ] AWS Access Key ID
- [ ] AWS Secret Access Key
- [ ] Credentials configured (via `aws configure` or environment variables)

**Test AWS CLI:**
```bash
aws sts get-caller-identity
```
**Expected**: Your AWS account details

### 10. EC2 Key Pair
Check in AWS Console:
- [ ] EC2 → Key Pairs → Your key pair exists in target region
- [ ] You have the .pem file saved locally

### 11. IAM Permissions
Verify your AWS user/role has permissions for:
- [ ] EC2 (create instances, security groups)
- [ ] VPC (create VPC, subnets, route tables, endpoints)
- [ ] S3 (create buckets, upload objects)
- [ ] IAM (create roles, attach policies)

## ✅ Terraform Plan Test (Dry Run)

### 12. Run Terraform Plan
```bash
terraform plan
```

**Expected Output:**
```
Plan: 18 to add, 0 to change, 0 to destroy.
```

**Resources to be created:**
- 1 VPC
- 2 Subnets (public, private)
- 1 Internet Gateway
- 2 Route Tables
- 2 Route Table Associations
- 2 Security Groups
- 1 IAM Role
- 1 IAM Role Policy Attachment
- 1 IAM Instance Profile
- 2 EC2 Instances (public, private)
- 1 S3 Bucket
- 1 S3 Object (sample file)
- 1 VPC Endpoint

**Check for errors:**
- [ ] No "Error" messages
- [ ] No "InvalidKeyPair.NotFound" errors
- [ ] No "BucketAlreadyExists" errors

## ✅ Deployment Verification (After terraform apply)

### 13. Terraform Apply Success
```bash
terraform apply
```
**Expected**: "Apply complete! Resources: 18 added, 0 changed, 0 destroyed."

### 14. Terraform Outputs
```bash
terraform output
```
**Expected outputs:**
- `public_server_public_ip` = "x.x.x.x"
- `private_server_private_ip` = "10.0.1.x"
- `s3_bucket_name` = "your-bucket-name"
- `vpc_endpoint_id` = "vpce-xxxxx"
- `vpc_id` = "vpc-xxxxx"

### 15. AWS Console Verification

**VPC:**
- [ ] Go to VPC Console → Your VPCs
- [ ] VPC "myvpc1" exists with CIDR 10.0.0.0/16

**Subnets:**
- [ ] Public subnet (10.0.0.0/24) exists
- [ ] Private subnet (10.0.1.0/24) exists

**EC2 Instances:**
- [ ] Go to EC2 Console → Instances
- [ ] "public-server" is running with public IP
- [ ] "private-server" is running without public IP

**S3 Bucket:**
- [ ] Go to S3 Console
- [ ] Your bucket exists
- [ ] "sample-file.txt" is in the bucket

**VPC Endpoint:**
- [ ] Go to VPC Console → Endpoints
- [ ] S3 endpoint exists and is "Available"
- [ ] Associated with both route tables

## ✅ Functional Testing

### 16. SSH to Public Server
```bash
ssh -i your-key.pem ec2-user@<PUBLIC_IP>
```
**Expected**: Successfully connected
**Status**: [ ]

### 17. S3 Access from Public Server
```bash
aws s3 ls
aws s3 ls s3://your-bucket-name/
```
**Expected**: Lists buckets and files
**Status**: [ ]

### 18. Copy Key to Public Server
```bash
scp -i your-key.pem your-key.pem ec2-user@<PUBLIC_IP>:~/
```
**Expected**: Key copied successfully
**Status**: [ ]

### 19. SSH to Private Server
```bash
# On public server
chmod 600 your-key.pem
ssh -i your-key.pem ec2-user@<PRIVATE_IP>
```
**Expected**: Successfully connected to private server
**Status**: [ ]

### 20. Verify NO Internet on Private Server
```bash
# On private server
ping -c 3 google.com
curl https://google.com
```
**Expected**: Both commands FAIL (no internet access)
**Status**: [ ]

### 21. Verify S3 Access via VPC Endpoint (KEY TEST!)
```bash
# On private server
aws s3 ls
aws s3 ls s3://your-bucket-name/
aws s3 cp s3://your-bucket-name/sample-file.txt .
cat sample-file.txt
```
**Expected**: All commands WORK (S3 accessible via VPC Endpoint)
**Status**: [ ]

## ✅ GitHub Actions CI/CD Verification

### 22. GitHub Secrets Configuration
Go to: https://github.com/SrinathMLOps/VPCendpoint/settings/secrets/actions

Verify secrets exist:
- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`

### 23. GitHub Environment Configuration
Go to: https://github.com/SrinathMLOps/VPCendpoint/settings/environments

Verify:
- [ ] "prod" environment exists
- [ ] Required reviewers are configured

### 24. Test Automatic Plan Workflow
```bash
git commit --allow-empty -m "Test workflow"
git push origin main
```
Go to: https://github.com/SrinathMLOps/VPCendpoint/actions

**Expected**: 
- [ ] "VPC Endpoint for S3 - Deploy" workflow runs automatically
- [ ] "Terraform Plan" job completes successfully

### 25. Test Manual Apply Workflow
Go to: https://github.com/SrinathMLOps/VPCendpoint/actions

- [ ] Click "VPC Endpoint for S3 - Deploy"
- [ ] Click "Run workflow"
- [ ] Select branch: main
- [ ] Click "Run workflow"
- [ ] Approve deployment in "prod" environment
- [ ] "Terraform Apply" job completes successfully

## ✅ Cleanup Verification

### 26. Terraform Destroy
```bash
terraform destroy
```
**Expected**: "Destroy complete! Resources: 18 destroyed."
**Status**: [ ]

### 27. AWS Console Cleanup Check
Verify all resources are deleted:
- [ ] EC2 instances terminated
- [ ] VPC deleted
- [ ] S3 bucket deleted (or empty)
- [ ] VPC Endpoint deleted

## 📊 Summary

### Configuration Status
- ✅ Terraform installed and working
- ✅ Configuration files valid
- ✅ GitHub repository correct
- ⚠️ AWS credentials need to be set
- ⚠️ terraform.tfvars needs customization

### Next Steps
1. **Update terraform.tfvars** with your AWS key pair name and unique S3 bucket name
2. **Set AWS credentials** via `aws configure` or environment variables
3. **Run terraform plan** to verify configuration
4. **Run terraform apply** to deploy infrastructure
5. **Test VPC Endpoint** following steps 16-21
6. **Run terraform destroy** when done testing

## 🔧 Troubleshooting

### Common Issues

**Issue**: "InvalidKeyPair.NotFound"
**Solution**: Update `key_name` in terraform.tfvars to match your AWS key pair

**Issue**: "BucketAlreadyExists"
**Solution**: Change `s3_bucket_name` to a globally unique name

**Issue**: "UnauthorizedOperation"
**Solution**: Check AWS credentials and IAM permissions

**Issue**: Cannot SSH to public server
**Solution**: Check security group allows SSH from your IP

**Issue**: Cannot access S3 from private server
**Solution**: Verify VPC Endpoint is created and IAM role is attached

## 📞 Support

If you encounter issues:
1. Check this verification checklist
2. Review README.md for detailed documentation
3. Follow MANUAL_TESTING_GUIDE.md for step-by-step testing
4. Check AWS CloudTrail for API errors
5. Review Terraform logs for detailed error messages

---

**Last Updated**: $(date)
**Project**: VPC Endpoint for S3 Bucket
**Repository**: https://github.com/SrinathMLOps/VPCendpoint
