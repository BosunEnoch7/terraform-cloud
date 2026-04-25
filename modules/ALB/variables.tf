variable "region" {
  default = "us-east-1"
}


variable "vpc_cidr" {
  default = "172.16.0.0/16"
}



variable "enable_dns_support" {
  default = true
}


variable "enable_dns_hostnames" {
  default = true
}


variable "preferred_number_of_public_subnets" {
  default = 2
}


variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "name" {
  type    = string
  default = "ACS"
}


variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}


variable "images" {
  type = map(string)

  default = {
    us-east-1 = "ami-0c02fb55956c7d316"
  }
}


variable "keypair" {
  type        = string
  description = "key pair for the instances"
}


variable "account_no" {
  type        = number
  description = "the account number"
}


variable "master_username" {
  type        = string
  description = "RDS admin username"
}


variable "master_password" {
  type        = string
  description = "RDS master password"
}


variable "images" {
  type = map(string)

  default = {
    us-east-1 = "ami-0c02fb55956c7d316"
    us-west-2 = "ami-xxxxxxxx"
  }
}