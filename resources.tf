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
