# Now outputs.tf is used to displays useful information about the resources after deployment everything from main.tf file.
# For example, after creating an EC2 instance, Terraform can display its instance ID and public IP address.

# 1. Display the IAM policy ARN

output "security_analyst_policy_arn" {
description = "ARN of the read-only security analyst IAM policy"
value       = aws_iam_policy.security_analyst_readonly.arn
}

# 2. Display the Security Group ID

output "security_group_id" {
description = "ID of the EC2 lab Security Group"
value       = aws_security_group.lab_ec2.id
}


# 3. Understand each output - Output 1 — IAM policy ARN

output "security_analyst_policy_arn" {
  description = "ARN of the read-only security analyst IAM policy"
  value       = aws_iam_policy.security_analyst_readonly.arn
}


# 4. How will outputs change when we add EC2? - Later, when we add the EC2 resource to main.tf, we'll add outputs like these:
# Display the EC2 instance ID

output "ec2_instance_id" {
  description = "ID of the security lab EC2 instance"
  value       = aws_instance.security_lab.id
}


# 5. Test your Terraform files - now we update and restart the Terraform again 
# From your terraform directory, run:
# terraform fmt
# terraform validate
# terraform plan