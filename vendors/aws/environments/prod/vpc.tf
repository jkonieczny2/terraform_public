module "vpc_us_east_2" {
  source = "../../modules/vpc"
  providers = {
    aws = aws.us-east-2
  }

  name = "us-east-2"

  cidr_block = "10.0.0.0/21"

  subnet_cidr_blocks = {
    "us-east-2a" = "10.0.0.0/24"
    "us-east-2b" = "10.0.1.0/24"
    "us-east-2c" = "10.0.2.0/24"
  }

  admin_ingress_cidr_ipv4 = var.admin_ingress_cidr_ipv4
  admin_ingress_tcp_ports = var.admin_ingress_tcp_ports
}
