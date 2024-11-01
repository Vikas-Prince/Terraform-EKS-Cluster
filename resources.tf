# resources.tf

# Create a VPC with a specified CIDR block for the EKS cluster
resource "aws_vpc" "myVpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Eks-vpc"
  }
}

# Create the first public subnet in the specified VPC
resource "aws_subnet" "vpcSubnet1" {
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = var.subnet1_cidr
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Eks-subnet-1"
  }
}

# Create the second public subnet in a different availability zone
resource "aws_subnet" "vpcSubnet2" {
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = var.subnet2_cidr
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Eks-subnet-2"
  }
}

# Create the third public subnet in yet another availability zone
resource "aws_subnet" "vpcSubnet3" {
  vpc_id                  = aws_vpc.myVpc.id
  cidr_block              = var.subnet3_cidr
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Eks-subnet-3"
  }
}

# Create an Internet Gateway for the VPC to allow external access
resource "aws_internet_gateway" "vpcGateway" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "Eks-Gateway"
  }
}

# Create a Route Table to manage routing for the VPC
resource "aws_route_table" "vpcRouteTable" {
  vpc_id = aws_vpc.myVpc.id

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.vpcGateway.id  
  }

  tags = {
    Name = "Eks-Route-table"
  }
}

# Associate the first subnet with the route table
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.vpcSubnet1.id
  route_table_id = aws_route_table.vpcRouteTable.id
}

# Associate the second subnet with the route table
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.vpcSubnet2.id
  route_table_id = aws_route_table.vpcRouteTable.id
}

# Associate the third subnet with the route table
resource "aws_route_table_association" "route_table_association_3" {
  subnet_id      = aws_subnet.vpcSubnet3.id
  route_table_id = aws_route_table.vpcRouteTable.id
}

# Create a Security Group for the EKS cluster to control inbound and outbound traffic
resource "aws_security_group" "terraSecuritygp" {
  name        = "EKSSecurityGroup"
  description = "Creating New Security Group for this VPC"
  vpc_id      = aws_vpc.myVpc.id

  # Allow all inbound traffic (not recommended for production)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = "Eks-sg"
  }
}

# Create an IAM Role for the EKS cluster to allow it to manage AWS resources
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [{
      Action: "sts:AssumeRole",
      Effect: "Allow",
      Principal: { Service: "eks.amazonaws.com" } 
    }]
  })
}

# Attach the AmazonEKSClusterPolicy to the EKS role
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = data.aws_iam_policy.eks_policy.arn
}

# Create an IAM Role for the EKS worker nodes
resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [{
      Action: "sts:AssumeRole",
      Effect: "Allow",
      Principal: { Service: "ec2.amazonaws.com" } 
    }]
  })
}

# Attach the necessary policies to the worker node role
resource "aws_iam_role_policy_attachment" "worker_node_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = data.aws_iam_policy.eks_worker_node_policy.arn
}

# Attach the AmazonEC2ContainerRegistryReadOnly policy for ECR access
resource "aws_iam_role_policy_attachment" "ecr_read_only_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create the EKS Cluster resource
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_role.arn  

  vpc_config {
    subnet_ids          = [
      aws_subnet.vpcSubnet1.id,
      aws_subnet.vpcSubnet2.id,
      aws_subnet.vpcSubnet3.id,
    ]
    security_group_ids  = [aws_security_group.terraSecuritygp.id] 
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_attachment  
  ]
}

# Create the EKS Node Group for worker nodes in the cluster
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn  
  subnet_ids      = [
    aws_subnet.vpcSubnet1.id,
    aws_subnet.vpcSubnet2.id,
    aws_subnet.vpcSubnet3.id,
  ]

  # Specify the launch template for the nodes
  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = "$Latest"  
  }

  # Scaling configuration for the node group
  scaling_config {
    desired_size = 2  
    max_size     = 3  
    min_size     = 1 
  }

  depends_on = [
    aws_eks_cluster.my_cluster  
  ]

  tags = {
    Name = "Worker Nodes"
  }
}

# Create a Launch Template for the EKS worker nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-"  
  image_id      = data.aws_ami.latest-ami.id  
  instance_type = var.instance_type 

  key_name = data.aws_key_pair.eks-key.key_name  

  lifecycle {
    create_before_destroy = true  
  }
}
