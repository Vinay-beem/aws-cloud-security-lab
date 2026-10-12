# AWS Cloud Security Monitoring Lab

## 1. Project Overview

This project builds a small AWS security environment to learn and demonstrate basic cloud security monitoring, investigation, and infrastructure security.

The lab uses **Terraform** to create and manage AWS resources and native AWS security services to monitor and investigate activity.

The goal is to understand **why each component is used**, how the components work together, and how a security analyst could investigate activity in an AWS environment.

**Status:** In Progress

---

## 2. 🎯 Goal

Build a small, reproducible AWS security lab that demonstrates:

- AWS Identity and Access Management (IAM)
- Least-privilege access
- Infrastructure as Code (Terraform)
- EC2 security and hardening
- Security Groups
- S3 security
- CloudTrail logging
- GuardDuty threat detection
- Basic security investigation
- Basic incident-response concepts

The lab is intentionally small so it can be deployed for testing and destroyed afterward.

---

## 3. 🧠 Learning Objectives & Technologies

### Learning Objectives

By completing this lab, you will learn how to:

- Create AWS infrastructure using Terraform
- Understand IAM users, policies, roles, and least privilege
- Secure an EC2 instance
- Configure a restrictive Security Group
- Apply basic S3 security controls
- Understand AWS CloudTrail activity logging
- Understand GuardDuty threat detection
- Investigate suspicious AWS activity
- Document security findings
- Use Terraform to reproduce and destroy infrastructure

### Technologies

- AWS
- Terraform
- AWS CLI
- IAM
- EC2
- S3
- Security Groups
- CloudTrail
- GuardDuty
- Linux

---

## 4. 🏗️ Lab Architecture

```text
                    AWS Cloud
                       |
          +------------+-------------+
          |                          |
        IAM                        CloudTrail
          |                          |
   Least-Privilege             Activity Logs
      Access                        |
          |                          |
          +------------+-------------+
                       |
                    AWS Account
                       |
              +--------+--------+
              |                 |
             EC2               S3
              |                 |
        Security Group     Secure Storage
              |
        Linux Host
              |
       Security Monitoring
              |
          GuardDuty
              |
        Threat Findings
```

---

## 5. 📋 Prerequisites

Before starting the lab, install and configure:

- An AWS account
- AWS CLI
- Terraform
- Git
- Basic Linux/CLI knowledge
- Basic networking and cybersecurity knowledge

### Verify AWS CLI

```powershell
aws --version
```

### Verify AWS Authentication

```powershell
aws sts get-caller-identity
```

This should return information about the AWS account and identity currently being used by the AWS CLI.

### Verify Terraform

```powershell
terraform version
```

---

# 6. 🚀 Lab Steps

The lab will be completed in the following order:

1. Terraform setup
2. IAM least-privilege policy
3. EC2 deployment
4. Security Group configuration
5. S3 security
6. CloudTrail logging
7. GuardDuty threat detection
8. Security investigation
9. Test scenarios
10. Cleanup

---

# 7. Terraform Setup

Terraform is used as the **Infrastructure as Code (IaC)** tool for this lab.

Instead of manually creating every AWS resource through the AWS Console, we define infrastructure using configuration files.

The basic flow is:

```text
Terraform Code
      |
      v
Terraform
      |
      v
AWS Provider
      |
      v
AWS Resources
```

## Terraform Directory

```text
terraform/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
└── .gitignore
```

## Terraform Workflow

Initialize Terraform:

```powershell
terraform init
```

Format the configuration:

```powershell
terraform fmt
```

Validate the configuration:

```powershell
terraform validate
```

Preview changes:

```powershell
terraform plan
```

Apply the infrastructure:

```powershell
terraform apply
```

Destroy the lab when finished:

```powershell
terraform destroy
```

### Important

Do not blindly copy Terraform code.

Understand what each resource does before applying it.

---

# 8. 🔐 IAM — Least Privilege

IAM controls access to AWS resources.

For this lab, we create a read-only security analyst policy.

The idea is:

```text
Security Analyst
       |
       v
Read Security Data
       |
       +--> CloudTrail
       +--> GuardDuty
       +--> EC2
       +--> S3
```

The analyst should be able to investigate activity but should not have unnecessary permissions to modify or delete resources.

Example Terraform resource:

```hcl
resource "aws_iam_policy" "security_analyst_readonly" {
  name        = "AWSCloudSecurityLab-AnalystReadOnly"
  description = "Read-only security monitoring permissions for the AWS Cloud Security Lab"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudtrail:Describe*",
          "cloudtrail:Get*",
          "cloudtrail:List*",
          "guardduty:Get*",
          "guardduty:List*",
          "ec2:Describe*",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Why Read-Only?

This follows the **principle of least privilege**.

The analyst needs enough permission to investigate security events, but does not need full administrator access.

---

# 9. 🔒 Security Group

A Security Group acts as a virtual firewall for AWS resources such as EC2.

For this lab, SSH access should only be allowed from the user's public IP.

Example:

```hcl
resource "aws_security_group" "lab_ec2" {
  name        = "aws-cloud-security-lab-sg"
  description = "Security group for AWS Cloud Security Lab"

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

Replace:

```text
YOUR_IP/32
```

with your actual public IP.

### Why `/32`?

`/32` represents one IPv4 address.

For example:

```text
203.0.113.10/32
```

means only that specific IP address is allowed.

### Security Note

Do not use:

```text
0.0.0.0/0
```

for SSH access unless there is a specific reason and appropriate security controls.

---

# 10. 🖥️ EC2

EC2 provides a Linux virtual machine that can be used as the lab host.

The instance should be attached to the Security Group created earlier.

Example structure:

```hcl
resource "aws_instance" "security_lab" {
  ami           = "YOUR_REGION_SPECIFIC_AMI"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.lab_ec2.id
  ]

  tags = {
    Name        = "AWS-Security-Lab-EC2"
    Environment = "Security-Lab"
  }
}
```

### Important

AMI IDs are **region-specific**.

The AMI used in `ap-south-1` may not work in another AWS region.

Use a current Amazon Linux AMI appropriate for your selected region instead of blindly reusing an old AMI ID.

---

# 11. 🪣 S3 Security

S3 is AWS object storage.

The lab will use S3 to understand basic cloud storage security.

Important security concepts include:

- Block Public Access
- Bucket permissions
- IAM permissions
- Encryption
- Bucket policies
- Logging and monitoring

The goal is to ensure that sensitive objects are not accidentally exposed publicly.

---

# 12. 📜 CloudTrail

AWS CloudTrail records AWS API and account activity.

It can help answer questions such as:

- Who performed an action?
- What AWS API call was made?
- When did it happen?
- Which resource was involved?
- From which source IP did the request originate?

Example investigation flow:

```text
Suspicious Activity
       |
       v
CloudTrail
       |
       v
Identify API Call
       |
       v
Identify Identity
       |
       v
Check Source IP
       |
       v
Determine Impact
```

CloudTrail is an important source of evidence during AWS security investigations.

---

# 13. 🛡️ GuardDuty

Amazon GuardDuty is AWS's threat detection service.

It analyzes supported AWS activity and data sources to identify potentially malicious or suspicious behavior.

The lab will use GuardDuty to understand:

- Findings
- Threat detection
- Finding severity
- Finding type
- Affected resources
- Investigation workflow

Basic workflow:

```text
AWS Activity
     |
     v
GuardDuty
     |
     v
Finding
     |
     v
Security Investigation
     |
     v
Response
```

---

# 14. 🔍 Security Investigation

The investigation section demonstrates how a security analyst can investigate suspicious activity.

A basic investigation workflow:

```text
Alert / Finding
      |
      v
Validate the Alert
      |
      v
Identify Affected Resource
      |
      v
Review CloudTrail Activity
      |
      v
Check IAM Identity
      |
      v
Check Source IP
      |
      v
Determine Impact
      |
      v
Document Findings
      |
      v
Recommend Response
```

Questions to ask during an investigation:

1. What happened?
2. When did it happen?
3. Which resource was affected?
4. Which identity performed the action?
5. What IP address was involved?
6. Was the activity expected?
7. What was the potential impact?
8. What response should be taken?

---

# 15. 🧪 Test Scenarios

The lab can be tested with controlled scenarios.

Possible scenarios:

### Scenario 1 — IAM Activity

Perform a normal AWS action and investigate it using CloudTrail.

### Scenario 2 — EC2 Security

Review the Security Group and verify that SSH is restricted to the expected IP.

### Scenario 3 — S3 Security

Verify that the S3 bucket is not publicly accessible.

### Scenario 4 — GuardDuty

Review GuardDuty findings and understand how a security analyst would investigate them.

### Scenario 5 — Suspicious Activity Investigation

Use CloudTrail data to identify:

- Identity
- API action
- Timestamp
- Source IP
- Resource
- Potential impact

---

# 16. 📸 Evidence & Results

Screenshots and evidence will be added after the lab is deployed.

Possible evidence:

- Terraform plan
- Terraform apply
- IAM policy
- Security Group
- EC2 instance
- S3 configuration
- CloudTrail configuration
- GuardDuty findings
- Investigation results

Suggested structure:

```text
screenshots/
├── terraform/
├── iam/
├── ec2/
├── s3/
├── cloudtrail/
└── guardduty/
```

Evidence should demonstrate what was actually configured rather than only showing code.

---

# 17. 💰 Cost & Cleanup

AWS resources can potentially incur charges.

This lab is intentionally designed to be small and temporary.

After completing the exercises, destroy resources that are no longer required.

```powershell
terraform destroy
```

Review the Terraform plan before confirming destruction.

Also verify in the AWS Console that resources that were created outside Terraform are no longer required.

### Cost Safety

Before deploying resources:

- Check current AWS pricing
- Check your account's Free Tier eligibility
- Avoid leaving unnecessary resources running
- Destroy the lab after testing

The GitHub repository and Terraform code can remain available even after the AWS resources are destroyed.

---

# 18. 📚 What I Learned

This section will be updated as the lab is completed.

Topics covered:

- AWS fundamentals
- IAM and least privilege
- Terraform
- Infrastructure as Code
- Security Groups
- EC2 security
- S3 security
- CloudTrail
- GuardDuty
- AWS security investigation
- Basic cloud incident response

---

# 19. 🎯 Conclusion

This lab demonstrates how basic AWS infrastructure and security services can be combined to create a small cloud security monitoring environment.

The main objective is not simply to deploy AWS resources, but to understand:

- How cloud infrastructure is secured
- How permissions are controlled
- How activity is logged
- How threats are detected
- How security analysts investigate suspicious activity
- How Infrastructure as Code makes the environment reproducible

The completed project will serve as both a learning resource and a portfolio project.

---

# 20. ⚠️ Security Notes

- Never commit AWS access keys or secret keys to GitHub.
- Never commit passwords, tokens, API keys, or private SSH keys.
- Do not expose SSH to the entire internet unnecessarily.
- Use least-privilege permissions.
- Review Terraform plans before applying changes.
- Destroy temporary AWS resources after completing the lab.
- Do not publish sensitive IP addresses or account information.
- Use test data rather than real sensitive information.