# Terraform AWS GitHub Actions Demo

Complete CI/CD pipeline for AWS infrastructure using Terraform and GitHub Actions.

## Architecture Flow

```
Developer (Kiro IDE)
    │
    │ git push
    ▼
GitHub Repository
    │
    │ triggers
    ▼
GitHub Actions
    │
    ├─► Terraform Plan (automatic on push)
    │   ├─ terraform init
    │   ├─ terraform fmt -check
    │   ├─ terraform validate
    │   └─ terraform plan
    │
    └─► Terraform Apply (manual trigger + approval)
        │
        │ waits for approval
        ▼
    Environment: prod
        │
        │ reviewer approves
        ▼
    Terraform Apply
        │
        │ AWS API calls
        ▼
    AWS Cloud
        └─► EC2 Instance Created
```

## Prerequisites

1. AWS Account with:
   - Access Key ID
   - Secret Access Key
   - EC2 key pair created

2. GitHub Account

3. Terraform installed locally (for testing)

## Setup Instructions

### Step 1: AWS Setup

1. Log in to AWS Console
2. Go to IAM → Users → Create User
3. Attach policy: `AmazonEC2FullAccess`
4. Create Access Key → Save the credentials
5. Go to EC2 → Key Pairs → Create Key Pair
6. Save the `.pem` file

### Step 2: GitHub Repository Setup

1. Create new repository on GitHub
2. Go to Settings → Environments → New Environment
3. Create environment named: `prod`
4. Add Required Reviewers (yourself or team member)
5. Go to Settings → Secrets and Variables → Actions
6. Add repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Step 3: Local Setup in Kiro

1. Open terminal in Kiro (Ctrl + `)
2. Initialize git:
   ```bash
   git init
   git branch -M main
   ```

3. Update `terraform.tfvars`:
   - Change `key_name` to your AWS key pair name

4. Test Terraform locally:
   ```bash
   terraform init
   terraform fmt
   terraform validate
   terraform plan
   ```

5. Connect to GitHub:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   ```

6. Push code:
   ```bash
   git add .
   git commit -m "Initial Terraform AWS setup"
   git push -u origin main
   ```

### Step 4: Run the Pipeline

1. Push triggers automatic Terraform Plan
2. Check GitHub Actions tab to see the plan
3. To apply:
   - Go to Actions → Terraform AWS Deploy
   - Click "Run workflow"
   - Select branch: main
   - Click "Run workflow"
4. Workflow waits for approval
5. Approve in Environments section
6. Terraform applies and creates EC2 instance

## Files Explanation

- `versions.tf` - Terraform and provider versions
- `main.tf` - AWS resources definition
- `variables.tf` - Input variables
- `outputs.tf` - Output values after apply
- `terraform.tfvars` - Variable values
- `.github/workflows/terraform.yml` - CI/CD pipeline

## Important Notes

- Never commit AWS credentials to git
- Always review Terraform plan before applying
- Use approval gates for production
- Monitor AWS costs

## Next Steps

- Add VPC and Security Groups
- Implement remote state with S3
- Add state locking with DynamoDB
- Use OIDC instead of static keys
