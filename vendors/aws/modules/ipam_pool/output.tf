output "ipam_pool_id" {
    value = aws_vpc_ipam_pool.public.id
    description = "ID of CIDR block that EIPs can be pulled from"
}
