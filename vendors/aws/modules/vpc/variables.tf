variable "cidr_block" {
  type        = string
  description = "CIDR block to allocate to this region, usually a /21 e.g. 10.0.0.0 - 10.0.7.255"
}

variable "name" {
  type        = string
  description = "name of VPC, stored in tag"
}

variable "subnet_cidr_blocks" {
  type        = map(string)
  description = "Map of {AZ: cidr_block}, usually cidr_block is a /24"
}

variable "private_subnet" {
  type        = string
  description = "CIDR block of entire subnet we expect to use across all regions"
  default     = "10.0.0.0/16"
}

variable "admin_ingress_cidr_ipv4" {
  type        = string
  description = "Source CIDR for inbound admin access (SSH, kube API, etc.) from the public internet, e.g. your static IP/32"
}

variable "admin_ingress_tcp_ports" {
  type        = map(number)
  description = "Map of label => TCP port to allow from admin_ingress_cidr_ipv4 (keys are only for stable Terraform resource addresses)"
}
