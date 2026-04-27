locals {
  amis = [
    "ami-0d1b5a8c13042c939" # Ubuntu 24.04 LTS
  ]
}

variable "name" {
  type        = string
  description = "value to assign to Name tag of instance"
}

variable "secretsmanager_default_keypair_name" {
  type        = string
  description = "Secrets Manager secret name (not the full ARN) for the default SSH private key used by provisioners"
  default     = "aws_default_keypair"
}

variable "secretsmanager_default_keypair_pub_name" {
  type        = string
  description = "Secrets Manager secret name (not the full ARN) for the public key material (e.g. one line for authorized_keys)"
  default     = "aws_default_keypair.pub"
}

variable "ami" {
  type        = string
  description = "AMI ID to use when building the instance"
  default     = "ami-0d1b5a8c13042c939"

  validation {
    condition     = contains(local.amis, var.ami)
    error_message = "Choose a valid AMI ID from locals.amis."
  }
}

variable "instance_type" {
  type        = string
  description = "Instance type to use"
}

variable "availability_zone" {
  type        = string
  description = "AZ to put the instance in"
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet to put instance in; use one generated from a VPC module"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security groups to associate with the instance"
}

variable "eip_count" {
  type        = number
  description = "Number of elastic IPs to create and assoc with instance"
  default     = 1
}

variable "ipam_pool" {
  type        = string
  description = "ID of IPAM pool to allocate elastic IP from"
  default     = null
}

variable "root_block_size" {
  type        = number
  description = "Size of root block in gigabytes"
  default     = 25
}

variable "root_block_volume_type" {
  type        = string
  description = "Type of root block, defaults to value AMI uses"
  default     = null
}

variable "root_block_device_throughput" {
  type        = string
  description = "Throughput of root block device, only valid if vol type is 'gp3'"
  default     = null
}

variable "key_pair_name" {
  type        = string
  description = "Name of keypair to be used for SSH to this machine"
  default     = "aws_default_keypair"
}

variable "initial_user" {
  type        = string
  description = "Username of user that is allowed to SSH into the machine using default keypair"
  default     = "ubuntu"
}

variable "private_ip" {
  type        = string
  description = "Private IP to assign to this machine, in case we need it to be the same forever"
  default     = null
}

variable "placement_group_id" {
  type        = string
  description = "ID of placement group to spin instance in"
  default     = null
}

variable "ebs_block_size" {
  type        = number
  description = "Number of gigabytes to allocate to EBS drive, if it is required"
  default     = null
}

variable "ebs_volume_type" {
  type        = string
  description = "EBS volume type.  'gp3' should work for most purposes, though 'io2' is best for high i/o workloads.  Can change on the fly if we need to though"
  default     = "gp3"
  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"], var.ebs_volume_type)
    error_message = "Choose a valid EBS block type."
  }
}

variable "ebs_volume_iops" {
  type        = number
  description = "IOPS to allocate to EBS disk, only applicable to 'io1', 'io2', 'gp3' types"
  default     = null
}

variable "ebs_volume_throughput" {
  type        = number
  description = "Throughput to assign to EBS volume.  Only applicable to 'gp3'"
  default     = null
}

variable "ebs_volume_device_name" {
  type        = string
  description = "Name of device to mount EBS volume on"
  default     = "/dev/sdh"
}

variable "snapshot_on_delete" {
  type        = bool
  description = "Take a snapshot of EBS device prior to deleting it"
  default     = false
}

variable "iam_instance_profile" {
  type        = string
  description = "Name of iam instance profile to attach to this instance"
  default     = null
}
