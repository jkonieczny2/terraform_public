output "subnet_ids" {
  value = {
    for name, subnet in aws_subnet.main : subnet.availability_zone => subnet.id
  }

  description = "Map of {AZ: subnet_id}"
}

output "security_group_ids" {
  value = [
    aws_security_group.ec2.id,
  ]

  description = "List of security groups creeated in this VPC module"
}
