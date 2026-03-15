# VPC Endpoint Setup for S3 Bucket

Complete Terraform automation for setting up AWS VPC with S3 Gateway Endpoint, enabling private EC2 instances to access S3 buckets without internet connectivity.

## 🎯 Project Goal

Demonstrate how to access S3 buckets from a private EC2 instance (without public IP or internet access) using VPC Endpoints. This setup enhances security by keeping all traffic within the AWS network.

## 📋 What is a VPC Endpoint?

A VPC (Virtual Private Cloud) endpoint is a network gateway that enables you to privately connect your AWS resources to AWS services without traversing the public internet. 

### Benefits:
- **Enhanced Security**: Resources never exposed to public internet
- **Reduced Latency**: Direct connection through AWS backbone network
- **Cost Savings**: No NAT Gateway required (~$32/month savings)
- **Simplified Architecture**: No complex routing configurations
- **Compliance**: Data never leaves AWS network

### Types of VPC Endpoints:

1. **Gateway Endpoint** (Used in this project)
   - For S3 and DynamoDB
   - Free of charge
   - Scalable and highly available

2. **Interface Endpoint**
   - For other AWS services (Lambda, CloudWatch, etc.)
   - Uses AWS PrivateLink
   - Charged per hour and per GB

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                        │
│                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐     │
│  │  Public Subnet       │    │  Private Subnet      │     │
│  │  (10.0.0.0/24)       │    │  (10.0.1.0/24)       │     │
│  │                      │    │                      │     │
│  │  ┌────────────┐      │    │  ┌────────────┐     │     │
│  │  │ Public EC2 │      │    │  │ Private EC2│     │     │
│  │  │ (Bastion)  │◄─────┼────┼──┤ (No Internet)    │     │
│  │  └────────────┘      │    │  └────────────┘     │     │
│  │         │            │    │         │           │     │
│  └─────────┼────────────┘    └─────────┼───────────┘     │
│            │                           │                  │
│     ┌──────▼──────┐            ┌───────▼────────┐        │
│     │   Internet  │            │  VPC Endpoint  │        │
│     │   Gateway   │            │   for S3       │        │
│     └─────────────┘            └────────┬───────┘        │
│                                         │                 │
└─────────────────────────────────────────┼─────────────────┘
                                          │
                                   ┌──────▼──────┐
                                   │  S3 Bucket  │
                                   │ (with files)│
                                   └─────────────┘
```

## 📦 Resources Created

| Resource | Name | Purpose |
|----------|------|---------|
| VPC | myvpc1 | Main network (10.0.0.0/16) |
| Public Subnet | public-subnet | Internet-accessible (10.0.0.0/24) |
| Private Subnet | private-subnet | Isolated subnet (10.0.1.0/24) |
| Internet Gateway | myvpc1-igw | Internet access for public subnet |
| Public Route Table | public-route-table | Routes for public subnet |
| Private Route Table | private-route-table | Routes for private subnet |
| Public Security Group | public-server-sg | Firewall for bastion host |
| Private Security Group | private-server-sg | Firewall for private server |
| IAM Role | ec2-s3-access-role | S3 access permissions |
| Public EC2 | public-server | Bastion host with public IP |
| Private EC2 | private-server | App server without public IP |
| S3 Bucket | (your-bucket-name) | Object storage |
| VPC Endpoint | s3-vpc-endpoint | Private S3 access gateway |

## 🚀 Quick Start

### Prerequisites

1. AWS Account with appropriate permissions
2. AWS CLI configured or Access Keys ready
3. EC2 Key Pair created in your target region
4. Terraform installed (v1.5.0 or higher)

### Step 1: Clone Repository

```bash
git clone https://github.com/SrinathMLOps/VPCendpoint.git
cd VPCendpoint
```

### Step 2: Configure Variables

Edit `terraform.tfvars`:

```hcl
aws_region     = "ap-south-1"                              # Your AWS region
ami_id         = "ami-0c2af51e265bd5e0e"                   # Amazon Linux 2023 AMI
instance_type  = "t3.micro"                                # Instance type
key_name       = "your-key-name"                           # Your AWS key pair name
s3_bucket_name = "your-unique-bucket-name-12345"           # Globally unique name
```

### Step 3: Set AWS Credentials

**Option 1: Environment Variables (Windows PowerShell)**
```powershell
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
$env:AWS_DEFAULT_REGION="ap-south-1"
```

**Option 2: AWS CLI Configuration**
```bash
aws configure
```

### Step 4: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Deploy resources
terraform apply
```

Type `yes` when prompted. Deployment takes 3-5 minutes.

### Step 5: Note the Outputs

After deployment, save these outputs:
- `public_server_public_ip` - Public server IP address
- `private_server_private_ip` - Private server IP address
- `s3_bucket_name` - Your S3 bucket name
- `vpc_endpoint_id` - VPC Endpoint ID

## 🧪 Testing the VPC Endpoint

### Test 1: Connect to Public Server

```bash
ssh -i your-key.pem ec2-user@<PUBLIC_IP>
```

### Test 2: Verify S3 Access from Public Server

```bash
# List all S3 buckets
aws s3 ls

# List files in your bucket
aws s3 ls s3://your-bucket-name/

# Download sample file
aws s3 cp s3://your-bucket-name/sample-file.txt .
cat sample-file.txt
```

### Test 3: Copy Key to Public Server

From your local machine:

```bash
scp -i your-key.pem your-key.pem ec2-user@<PUBLIC_IP>:~/
```

### Test 4: Connect to Private Server

```bash
# On public server
chmod 600 your-key.pem
ssh -i your-key.pem ec2-user@<PRIVATE_IP>
```

### Test 5: Verify NO Internet Access on Private Server

```bash
# On private server - these should FAIL
ping google.com
curl https://google.com
```

### Test 6: Verify S3 Access Works (THE KEY TEST!)

```bash
# On private server - these should WORK
aws s3 ls
aws s3 ls s3://your-bucket-name/
aws s3 cp s3://your-bucket-name/sample-file.txt .
cat sample-file.txt
```

**✅ SUCCESS!** If you can access S3 from the private server without internet, the VPC Endpoint is working correctly!

## 🔍 How It Works

1. **Private Server** has no public IP and no route to Internet Gateway
2. **VPC Endpoint** creates a private gateway to S3 within AWS network
3. **Route Tables** automatically route S3 traffic through VPC Endpoint
4. **IAM Role** provides S3 access permissions to EC2 instances
5. **All traffic stays within AWS** - never touches the public internet

## 💰 Cost Estimate

| Resource | Cost |
|----------|------|
| VPC | Free |
| Subnets | Free |
| Internet Gateway | Free |
| Route Tables | Free |
| VPC Endpoint (Gateway) | Free |
| EC2 t3.micro (2 instances) | ~$0.0104/hour each |
| S3 Storage | ~$0.023/GB/month |

**Total: ~$15-20/month** if left running continuously

## 🧹 Clean Up

To avoid ongoing charges, destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

## 📚 Project Structure

```
VPCendpoint/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Terraform and provider versions
├── terraform.tfvars        # Variable values (customize this)
├── .gitignore              # Git ignore rules
├── README.md               # This file
└── MANUAL_TESTING_GUIDE.md # Step-by-step testing guide
```

## 🔧 Troubleshooting

### Cannot SSH to public server
- Verify security group allows SSH (port 22) from your IP
- Check you're using the correct key pair
- Ensure public IP is assigned to instance

### Cannot SSH from public to private server
- Verify key is copied to public server with correct permissions (chmod 600)
- Check private security group allows SSH from public subnet
- Confirm private IP address is correct

### Cannot access S3 from private server
- Verify IAM role is attached to EC2 instance
- Check VPC Endpoint is created and active
- Ensure route tables include VPC Endpoint routes
- Confirm S3 bucket exists and has files

### Terraform apply fails
- Check AWS credentials are correctly set
- Verify EC2 key pair exists in your region
- Ensure S3 bucket name is globally unique
- Confirm you have necessary IAM permissions

## 📖 Additional Resources

- [AWS VPC Endpoints Documentation](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS S3 Gateway Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints-s3.html)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 👤 Author

**Srinath**
- GitHub: [@SrinathMLOps](https://github.com/SrinathMLOps)

## ⭐ Show Your Support

Give a ⭐️ if this project helped you understand VPC Endpoints!

---

**Note**: This is a demonstration project for learning purposes. For production use, implement additional security measures, monitoring, and backup strategies.
