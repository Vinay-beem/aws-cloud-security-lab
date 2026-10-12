# Instead of hardcoding values directly into main.tf, we define reusable inputs in variables.tf.
# For example, if you want to change the AWS region or your allowed SSH IP, you can update a variable rather than searching through your Terraform code.

variables.tf — Input variables for the AWS Cloud Security Lab

1. AWS region where lab resources will be deployed

variable "aws_region" {
description = "AWS region for the security lab"
type        = string
default     = "ap-south-1"
}

2. EC2 instance type used for the lab

variable "instance_type" {
description = "EC2 instance type for the security lab"
type        = string
default     = "t3.micro"
}

3. Public IPv4 address allowed to connect through SSH

Replace the example with your own public IP address.

variable "allowed_ssh_cidr" {
description = "Public IPv4 CIDR allowed to access EC2 through SSH"
type        = string
default     = "YOUR_PUBLIC_IP/32"
}

4. Name tag applied to the EC2 instance

variable "instance_name" {
description = "Name tag for the security lab EC2 instance"
type        = string
default     = "AWS-Security-Lab-EC2"
}

5. Environment tag used to identify lab resources

variable "environment" {
description = "Environment label for lab resources"
type        = string
default     = "Security-Lab"
}