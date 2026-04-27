variable "description" {
    type = string
    description = "Description of this KMS key"
}

variable "enable_key_rotation" {
    type = bool
    description = "Enable key rotation of this KMS key"
    default = true
}

variable "rotation_period_in_days" {
    type = number
    description = "Number of days between each rotation.  Note AWS will still keep old versions to decrypt previous data"
    default = 365
}

variable "deletion_window_in_days" {
    type = number
    description = "Number of ways to wait before actually deleting key"
    default = 30
}

variable "policy" {
    type = string
    description = "Policy controlling who has access / can administer the key.  If not passed then all users in owning account will get full access"
    default = null
}
