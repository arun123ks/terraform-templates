provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../terraform-aws-vpc"

  name = "AROON-PROD-CSE"

  cidr = "10.93.25.0/24"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.93.25.0/27", "10.93.25.32/27", "10.93.25.64/27"]
  public_subnets  = ["10.93.25.96/27", "10.93.25.128/27", "10.93.25.160/27"]

  assign_generated_ipv6_cidr_block = false

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "SN-NV-AROON-PROD-CSE-Public"
  }

  private_subnet_tags = {
    Name = "SN-NV-AROON-PROD-CSE-Private"
  }



  vpc_tags = {
    Name = "VPC-NV-AROON-PROD-CSE"
  }
}
