# main.tf — AWS Cloud Security Lab

# 1. Terraform configuration - This block specifies the providers required by the project
	and the minimum Terraform version supported.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
# The project requires Terraform version 1.6.0 or newer.
  required_version = ">= 1.6.0"
}

# 2. AWS provider — Mumbai region - The provider allows Terraform to communicate with AWS.
provider "aws" {
  region = "ap-south-1"
}

# 3. IAM policy — read-only security investigation to who can access which resource and what aciton they can perform.

resource "aws_iam_policy" "security_analyst_readonly" {
  name        = "AWSCloudSecurityLab-AnalystReadOnly"
  description = "Read-only security monitoring permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
    	# Allow the actions listed below.
        Effect = "Allow"
   
        # These permissions allow reading selected AWS information.
        # Review each action and narrow permissions as required.
	Action = [
	  # Read CloudTrail configuration and event information.
          "cloudtrail:Describe*",
          "cloudtrail:Get*",
          "cloudtrail:List*",
	 
    	  # Read GuardDuty configuration and findings.
          "guardduty:Get*",
          "guardduty:List*",

          # Read EC2 infrastructure information.	  
          "ec2:Describe*",

          # List S3 buckets and read permitted bucket/object data.
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:GetObject"
        ]
	
	# "*" means the actions can apply to all resources
        # supported by these permissions. It is broad, so a
        # production policy should use narrower resource scopes
        # wherever AWS supports them.
        Resource = "*"
      }
    ]
  })
}

# 4. Security Group — restrict SSH to your public IP
resource "aws_security_group" "lab_ec2" {
  # name to display in AWS Console
  name        = "aws-cloud-security-lab-sg"
  description = "Security group for AWS Cloud Security Lab"

  # Inbound: SSH on TCP port 22
  ingress {
    description = "SSH from my IP - (Enter your Public IP Address)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Replace this placeholder with your public IPv4 address.
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  # Outbound: allow all IPv4 traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Before running Terraform
# Replace YOUR_PUBLIC_IP/32 with your current public IPv4 address. Do not use your private Wi-Fi address such as 192.168.x.x.
#Then run these commands in PowerShell from your Terraform project directory:
#1. terraform fmt
#2. terraform validate
#3. terraform plan
