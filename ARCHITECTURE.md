# Architecture Diagram

## Complete CI/CD Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DEVELOPER WORKSTATION                        │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                        Kiro IDE                               │  │
│  │                                                               │  │
│  │  ├── main.tf                                                 │  │
│  │  ├── variables.tf                                            │  │
│  │  ├── outputs.tf                                              │  │
│  │  └── .github/workflows/terraform.yml                         │  │
│  │                                                               │  │
│  │  Terminal:                                                    │  │
│  │  $ terraform init                                             │  │
│  │  $ terraform plan                                             │  │
│  │  $ git push origin main                                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────┬─────────────────────────────────┘
                                    │
                                    │ git push
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           GITHUB                                     │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    Git Repository                             │  │
│  │                                                               │  │
│  │  • Source Code                                                │  │
│  │  • Terraform Files                                            │  │
│  │  • Workflow Definitions                                       │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                    │                                 │
│                                    │ triggers                        │
│                                    ▼                                 │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                  GitHub Actions                               │  │
│  │                                                               │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │  JOB 1: Terraform Plan (Automatic)                     │ │  │
│  │  │                                                         │ │  │
│  │  │  Step 1: Checkout Code                                 │ │  │
│  │  │  Step 2: Configure AWS Credentials                     │ │  │
│  │  │  Step 3: Setup Terraform                               │ │  │
│  │  │  Step 4: terraform init                                │ │  │
│  │  │  Step 5: terraform fmt -check                          │ │  │
│  │  │  Step 6: terraform validate                            │ │  │
│  │  │  Step 7: terraform plan -out=tfplan                    │ │  │
│  │  │  Step 8: Upload Plan Artifact                          │ │  │
│  │  │                                                         │ │  │
│  │  │  ✅ Plan Complete                                       │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  │                                    │                          │  │
│  │                                    │ manual trigger           │  │
│  │                                    ▼                          │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │  JOB 2: Terraform Apply (Manual + Approval)           │ │  │
│  │  │                                                         │ │  │
│  │  │  ⏸️  Waiting for Environment Approval...               │ │  │
│  │  │                                                         │ │  │
│  │  │  Environment: prod                                     │ │  │
│  │  │  Required Reviewers: [Your Name]                       │ │  │
│  │  │                                                         │ │  │
│  │  │  👤 Reviewer Approves ✅                                │ │  │
│  │  │                                                         │ │  │
│  │  │  Step 1: Checkout Code                                 │ │  │
│  │  │  Step 2: Configure AWS Credentials                     │ │  │
│  │  │  Step 3: Setup Terraform                               │ │  │
│  │  │  Step 4: terraform init                                │ │  │
│  │  │  Step 5: Download Plan Artifact                        │ │  │
│  │  │  Step 6: terraform apply -auto-approve tfplan          │ │  │
│  │  │                                                         │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                    │                                 │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                GitHub Secrets                                 │  │
│  │                                                               │  │
│  │  • AWS_ACCESS_KEY_ID                                         │  │
│  │  • AWS_SECRET_ACCESS_KEY                                     │  │
│  └──────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────┬─────────────────────────────────┘
                                    │
                                    │ AWS API Calls
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          AWS CLOUD                                   │
│                                                                       │
│  Region: ap-south-1 (Mumbai)                                         │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                      EC2 Service                              │  │
│  │                                                               │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │         EC2 Instance                                    │ │  │
│  │  │                                                         │ │  │
│  │  │  Type: t3.micro                                        │ │  │
│  │  │  AMI: Amazon Linux 2023                                │ │  │
│  │  │  Public IP: 13.x.x.x                                   │ │  │
│  │  │  Key Pair: your-key-name                               │ │  │
│  │  │                                                         │ │  │
│  │  │  Tags:                                                  │ │  │
│  │  │    Name: Production-Web-Server                         │ │  │
│  │  │    Environment: dev                                    │ │  │
│  │  │    ManagedBy: Terraform                                │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Breakdown

### 1. Developer Workstation (Kiro IDE)
- Write Terraform infrastructure code
- Test locally before pushing
- Use integrated terminal for Terraform commands
- Commit and push to GitHub

### 2. GitHub Repository
- Stores all source code
- Version control for infrastructure
- Triggers CI/CD workflows

### 3. GitHub Actions
- Automated CI/CD pipeline
- Two jobs:
  - Plan: Runs automatically on every push
  - Apply: Runs manually with approval gate

### 4. GitHub Secrets
- Securely stores AWS credentials
- Never exposed in logs
- Injected at runtime

### 5. GitHub Environments
- `prod` environment with required reviewers
- Approval gate before infrastructure changes
- Protection for production resources

### 6. AWS Cloud
- Target infrastructure platform
- EC2 instance created by Terraform
- Resources tagged and managed

## Data Flow

1. Developer writes Terraform code in Kiro
2. Developer pushes code to GitHub
3. GitHub Actions automatically runs Terraform Plan
4. Plan shows what will be created/changed
5. Developer manually triggers Apply workflow
6. Workflow waits for approval (prod environment)
7. Reviewer approves the deployment
8. Terraform Apply executes
9. AWS API creates the EC2 instance
10. Outputs show instance ID and public IP

## Security Layers

1. AWS credentials stored as GitHub Secrets
2. Environment protection with required reviewers
3. Manual approval before any infrastructure changes
4. Terraform plan review before apply
5. Git history for audit trail
