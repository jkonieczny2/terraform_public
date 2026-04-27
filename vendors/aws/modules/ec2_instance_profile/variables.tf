variable "name" {
    type = string
    description = "Name to give to this instance profile"
}

variable "iam_role_name" {
    type = string
    description = "Name of IAM role to attach to this instance profile"
}
