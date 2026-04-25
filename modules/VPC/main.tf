# Get list of availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "= 3.8.1"
    }
  }
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = "Name of the resource"
    },
  )
}
