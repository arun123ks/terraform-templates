provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source = "../terraform-aws-vpc"

  name = "ppp"

  cidr = "10.10.75.0/24"

  azs             = ["us-west-1b", "us-west-1c"]
  private_subnets = ["10.10.75.32/27", "10.10.75.64/27"]
  public_subnets  = ["10.10.75.128/27", "10.10.75.160/27"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "SN-NC-Public"
  }

  private_subnet_tags = {
    Name = "SN-NC-Private"
  }


  tags = {
    Owner       = "user"
    Environment = "test"
  }

  vpc_tags = {
    Name = "VPC-NC-QAAROON"
  }
}
