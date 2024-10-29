# datasource.tf

# IAM Policies and Roles for EKS
data "aws_iam_policy" "eks_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "eks_worker_node_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}


# filter latest AMI 
data "aws_ami" "latest-ami" {
  most_recent = true

  owners = ["amazon"]
  filter {
    name   = "name"
    values = ["RHEL-9.4.0_HVM-2024*-x86_64-82-Hourly2-GP3"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_key_pair" "eks-key" {
  key_name = var.key_name
}
