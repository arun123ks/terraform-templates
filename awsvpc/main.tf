provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source = "terraform-aws-vpc/"

  name = "complete-example"

  cidr = "10.10.0.0/16"

  azs                 = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets      = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]

  create_database_subnet_group = false

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = false

  enable_s3_endpoint       = false
  enable_dynamodb_endpoint = false

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "NV-DST"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}
