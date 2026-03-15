# Temporary AWS Credentials Setup
# Replace these with your actual AWS credentials

$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID_HERE"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY_HERE"
$env:AWS_DEFAULT_REGION="ap-south-1"

Write-Host "AWS credentials set for this session"
Write-Host "Run: terraform plan"
