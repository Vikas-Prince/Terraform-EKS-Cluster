# variables.tf

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet1_cidr" {
  description = "The CIDR block for the first subnet"
  type        = string
}

variable "subnet2_cidr" {
  description = "The CIDR block for the second subnet"
  type        = string
}

variable "subnet3_cidr" {
  description = "The CIDR block for the third subnet"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the EKS nodes"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}



