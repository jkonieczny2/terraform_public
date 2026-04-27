variable "admin_ingress_cidr_ipv4" {
  type        = string
  description = "CIDR to allow for admin SSH, kube, and related ports (e.g. your public x.x.x.x/32)"
}

variable "admin_ingress_tcp_ports" {
  type        = map(number)
  description = "TCP ports to open to admin_ingress_cidr_ipv4; map keys are labels (used in resource addresses, not in AWS)"
}
