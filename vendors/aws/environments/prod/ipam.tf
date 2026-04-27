module "ipam_us_east_2_public_1" {
  source = "../../modules/ipam_pool"
  providers = {
    aws = aws.us-east-2
  }

  name           = "us_east_2_public_ipam_1"
  description    = "First public IPAM address pool to use in us-east-1"
  netmask_length = "29"
}
