data "aws_region" "current" {}

resource "aws_vpc_ipam_pool" "public" {
    address_family = var.address_family
    ipam_scope_id = var.ipam_public_scope_id
    locale = data.aws_region.current.name
    public_ip_source = var.public_ip_source
    aws_service = var.public_ip_source == "amazon" ? var.aws_service : null

    tags = {
        Name = var.name
        Description = var.description
    }
}

resource "aws_vpc_ipam_pool_cidr" "public_1" {
    ipam_pool_id = aws_vpc_ipam_pool.public.id
    netmask_length = var.netmask_length
}
