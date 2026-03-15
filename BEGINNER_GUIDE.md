# Complete Beginner's Guide

## What You're Building

You're creating an automated system that:
- Writes infrastructure as code (Terraform)
- Stores it in GitHub
- Automatically tests it (GitHub Actions)
- Deploys to AWS with approval
- Creates an EC2 server automatically

Think of it like this: Instead of clicking buttons in AWS console, you write code that creates servers automatically.

---

## Prerequisites Checklist

Before starting, you need:

- [ ] AWS Account (free tier is fine)
- [ ] GitHub Account (free)
- [ ] Kiro IDE installed
- [ ] Git installed
- [ ] Terraform installed

---

## Step-by-Step Setup

### PART 1: AWS Setup (15 minutes)

#### 1.1 Create AWS Access Keys

1. Go to https://aws.amazon.com and log in
2. Click your name (top right) → Security Credentials
3. Scroll to "Access Keys" → Create Access Key
4. Choose "Command Line Interface (CLI)"
5. Check the box and click Next
6. Click "Create Access Key"
7. **IMPORTANT**: Copy both:
   - Access Key ID (looks like: AKIAIOSFODNN7EXAMPLE)
   - Secret Access Key (looks like: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY)
8. Save them in a safe place (you'll need them later)

#### 1.2 Create EC2 Key Pair

1. Go to AWS Console → EC2
2. Left sidebar → Network & Security → Key Pairs
3. Click "Create Key Pair"
4. Name: `my-terraform-key`
5. Key pair type: RSA
6. Private key format: .pem
7. Click "Create Key Pair"
8. Save the `.pem` file (you'll use this to SSH into your server)

#### 1.3 Note Your AWS Region

Look at the top right of AWS Console. You'll see something like:
- Mumbai (ap-south-1)
- N. Virginia (us-east-1)
- Oregon (us-west-2)

Remember this region code (e.g., `ap-south-1`).

---

### PART 2: GitHub Setup (10 minutes)

#### 2.1 Create GitHub Repository

1. Go to https://github.com
2. Click the "+" icon → New Repository
3. Repository name: `terraform-aws-demo`
4. Choose "Public" or "Private"
5. **DO NOT** check "Add README"
6. Click "Create Repository"
7. Keep this page open (you'll need the URL)

#### 2.2 Add GitHub Secrets

1. In your repository, click "Settings" tab
2. Left sidebar → Secrets and variables → Actions
3. Click "New repository secret"
4. Add first secret:
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: (paste your AWS Access Key ID)
   - Click "Add secret"
5. Add second secret:
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: (paste your AWS Secret Access Key)
   - Click "Add secret"

#### 2.3 Create GitHub Environment

1. Still in Settings, left sidebar → Environments
2. Click "New environment"
3. Name: `prod`
4. Click "Configure environment"
5. Check "Required reviewers"
6. Add yourself as a reviewer
7. Click "Save protection rules"

---

### PART 3: Kiro Setup (20 minutes)

#### 3.1 Open Project in Kiro

1. Open Kiro IDE
2. File → Open Folder
3. Create a new folder: `terraform-aws-demo`
4. Open that folder

#### 3.2 Verify Files Created

You should see these files (I already created them):
```
terraform-aws-demo/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
├── .gitignore
├── README.md
├── ARCHITECTURE.md
└── BEGINNER_GUIDE.md (this file)
```

#### 3.3 Update terraform.tfvars

1. Open `terraform.tfvars`
2. Change this line:
   ```
   key_name = "your-key-name-here"
   ```
   To:
   ```
   key_name = "my-terraform-key"
   ```
   (or whatever you named your AWS key pair)

3. If your AWS region is different from `ap-south-1`, change:
   ```
   aws_region = "ap-south-1"
   ```
   To your region (e.g., `us-east-1`)

4. Save the file (Ctrl+S)

#### 3.4 Open Terminal in Kiro

1. View → Terminal (or press Ctrl + `)
2. You'll see a terminal at the bottom

#### 3.5 Check Terraform Installation

In the terminal, type:
```bash
terraform version
```

If you see version info, great! If not, install Terraform:

**Windows:**
```bash
choco install terraform
```

**Mac:**
```bash
brew install terraform
```

**Linux:**
```bash
wget https://releases.hashicorp.com/terraform/1.8.5/terraform_1.8.5_linux_amd64.zip
unzip terraform_1.8.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

#### 3.6 Initialize Git

In the terminal:
```bash
git init
git branch -M main
```

#### 3.7 Test Terraform Locally

Run these commands one by one:

```bash
terraform init
```
Expected output: "Terraform has been successfully initialized!"

```bash
terraform fmt
```
This formats your code.

```bash
terraform validate
```
Expected output: "Success! The configuration is valid."

```bash
terraform plan
```
This shows what Terraform will create. You'll see:
- It will create 1 EC2 instance
- Shows the instance type, AMI, etc.

**IMPORTANT**: Don't run `terraform apply` yet! We'll do that through GitHub Actions.

#### 3.8 Connect to GitHub

Replace `YOUR_USERNAME` with your GitHub username:

```bash
git remote add origin https://github.com/YOUR_USERNAME/terraform-aws-demo.git
```

Example:
```bash
git remote add origin https://github.com/john-doe/terraform-aws-demo.git
```

#### 3.9 Push to GitHub

```bash
git add .
git commit -m "Initial Terraform setup"
git push -u origin main
```

If prompted for credentials:
- Username: your GitHub username
- Password: use a Personal Access Token (not your password)

To create a token:
1. GitHub → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
2. Generate new token
3. Check "repo" scope
4. Copy the token and use it as password

---

### PART 4: Run the Pipeline (10 minutes)

#### 4.1 Check Automatic Plan

1. Go to your GitHub repository
2. Click "Actions" tab
3. You should see a workflow running: "Terraform AWS Deploy"
4. Click on it to see the progress
5. Wait for it to complete (about 2-3 minutes)
6. Check the "Terraform Plan" job
7. You'll see what Terraform will create

#### 4.2 Manually Trigger Apply

1. Still in Actions tab
2. Click "Terraform AWS Deploy" (left sidebar)
3. Click "Run workflow" button (right side)
4. Select branch: main
5. Click "Run workflow"

#### 4.3 Approve the Deployment

1. The workflow starts
2. "Terraform Plan" job runs first
3. "Terraform Apply" job waits for approval
4. You'll see: "Waiting for approval"
5. Click "Review deployments"
6. Check the box next to "prod"
7. Click "Approve and deploy"

#### 4.4 Watch the Deployment

1. The "Terraform Apply" job now runs
2. Watch the logs
3. You'll see Terraform creating the EC2 instance
4. After 2-3 minutes, it completes
5. Check the outputs:
   - Instance ID: i-0123456789abcdef
   - Public IP: 13.x.x.x

---

### PART 5: Verify in AWS (5 minutes)

#### 5.1 Check EC2 Instance

1. Go to AWS Console → EC2
2. Click "Instances" (left sidebar)
3. You should see your instance:
   - Name: Production-Web-Server
   - State: Running
   - Instance Type: t3.micro

#### 5.2 Connect to Your Instance (Optional)

If you want to SSH into your server:

```bash
ssh -i my-terraform-key.pem ec2-user@<PUBLIC_IP>
```

Replace `<PUBLIC_IP>` with the IP from Terraform outputs.

---

## What Just Happened?

1. You wrote infrastructure as code (Terraform files)
2. You pushed code to GitHub
3. GitHub Actions automatically tested your code
4. You manually triggered deployment
5. You approved the deployment
6. Terraform created an EC2 instance in AWS
7. All automatically!

---

## Common Issues & Solutions

### Issue 1: Terraform init fails
**Solution**: Check your AWS credentials in GitHub Secrets

### Issue 2: Terraform plan fails with "InvalidKeyPair.NotFound"
**Solution**: Make sure the key pair name in `terraform.tfvars` matches your AWS key pair

### Issue 3: GitHub Actions workflow doesn't trigger
**Solution**: Make sure you pushed to the `main` branch

### Issue 4: Can't approve deployment
**Solution**: Make sure you added yourself as a required reviewer in the `prod` environment

### Issue 5: AWS charges
**Solution**: t3.micro is free tier eligible. To avoid charges, destroy resources:
```bash
terraform destroy
```

---

## Next Steps

Now that you have the basics working, you can:

1. Add a security group to allow HTTP/HTTPS traffic
2. Add a VPC and subnet
3. Install software on the EC2 instance using user_data
4. Add more environments (staging, production)
5. Implement remote state with S3
6. Add state locking with DynamoDB

---

## Clean Up (To Avoid AWS Charges)

When you're done testing:

1. In Kiro terminal:
   ```bash
   terraform destroy
   ```
2. Type `yes` when prompted
3. This deletes the EC2 instance

Or manually:
1. Go to AWS Console → EC2
2. Select your instance
3. Instance State → Terminate Instance

---

## Need Help?

- Check the logs in GitHub Actions
- Review the Terraform plan output
- Check AWS CloudTrail for API calls
- Verify your AWS credentials are correct

---

## Congratulations!

You've successfully built a complete CI/CD pipeline for infrastructure! This is exactly how professional DevOps engineers work.
