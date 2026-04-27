variable "name" {
    type = string
    description = "Name of this AssumeRole policy"
}

variable "description" {
    type = string
    description = "Description of this AssumeRole policy"
}

variable "path" {
    type = string
    description = "Path in AWS to place policy, should not need to update this"
    default = "/"
}

variable "principals" {
    type = list(object({
        type = string
        identifiers = list(string)
    }))
    description = "List of [ {type, [identifiers] } ] used to craft AssumeRole policy attached to IAM role"
}

variable "policies" {
    type = list(object({
        actions = list(string)
        resources = list(string)
        effect = string
        sid = string
    }))
    description = "List of [ { [actions], [resources], [principals], effect, sid } ] used to craft policies attached to IAM role"
    default = []
}

variable "managed_policy_attachments" {
    type = list(string)
    description = "List of AWS managed policy attachment ARNs to associate with this role"
    default = []
}
