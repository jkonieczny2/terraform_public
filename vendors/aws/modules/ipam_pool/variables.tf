variable "name" {
    type = string
    description = "name of the IPAM pool"
}

variable "description" {
    type = string
    description = "description of this IPAM pool, to be saved in tag"
    default = ""
}

variable "address_family" {
    type = string
    description = "IP address family to use"
    default = "ipv4"

    validation {
        condition = contains(["ipv4", "ipv6"], var.address_family)
        error_message = "address_family variable must be one of {ipv4, ipv6}"
    }
}

variable "public_ip_source" {
    type = string
    description = "Choose whether to use BYOIP or AWS-owned address space"
    default = "amazon"

    validation {
        condition = contains(["amazon", "byoip"], var.public_ip_source)
        error_message = "public_ip_source must be one of {amazon, byoip}"
    }
}

variable "ipam_public_scope_id" {
    type = string
    description = "public scope ID of top-level IP Address Manager.  Must be created by admin"
    default = "ipam-scope-026d6f565bd4d4b07"
}

variable "ipam_private_scope_id" {
    type = string
    description = "private scope ID of top-level IP Address Manager.  Must be created by admin"
    default = "ipam-scope-05fc5b8bfae7be9e4"
}

variable "cidr" {
    type = string
    description = "CIDR block to allocate to IPAM pool CIDR allocation. conflicts with 'cidr', and unused ATM since we are only using AWS-owned IPs"
    default = null
}

variable "netmask_length" {
    type = string
    description = "netmask e.g. 24 to select the next available block of netmask size.  conflicts with 'cidr'"
}

variable "aws_service" {
    type = string
    description = "AWS service where pool will pull amazon-owned IPs from"
    default = "ec2"

    validation {
        condition = contains(["ec2"], var.aws_service)
        error_message = "aws_service must be one of {ec2}"
    }
}
