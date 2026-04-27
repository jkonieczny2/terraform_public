resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "main" {
  for_each = var.subnet_cidr_blocks

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = each.value
  }
}

# VPC must have IG for EC2 instances to have public IPs
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Add internet GW route to VPC's main route table, which is auto-created by AWS
resource "aws_route" "internet" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

###################################
# START: DEFAULT EC2 SECURITY GROUP
###################################

resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "Default security group for EC2 instances"
  vpc_id      = aws_vpc.main.id
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "ec2_all" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = aws_vpc.main.cidr_block
  ip_protocol       = -1
}

# Inbound from your public IP (or office/VPN CIDR), set via admin_ingress_cidr_ipv4
resource "aws_vpc_security_group_ingress_rule" "external_apps" {
  for_each = var.admin_ingress_tcp_ports

  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = var.admin_ingress_cidr_ipv4
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}

#################################
# END: DEFAULT EC2 SECURITY GROUP
#################################

