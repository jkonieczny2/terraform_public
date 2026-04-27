variable "name" {
    type = string
    description = "name of PG"
}

variable "description" {
    type = string
    description = "short description of what PG will be used for"
}

variable "strategy" {
    type = string
    description = "cluster=high speed; partition=different hardware; spread=different racks"
    default = "cluster"
}
