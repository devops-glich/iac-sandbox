# VPC RESOURCES
#  * Create a VPC for the EKS cluster
#  * Create an internet gateway and attach it to the VPC
#  * Create a public subnet for the EKS cluster
#  * Create a Route table for the EKS cluster

# Create a VPC for the EKS cluster
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

# Create an internet gateway and attach it to the VPC
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# Create a public subnet for the EKS cluster
resource "aws_subnet" "eks_subnet_1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet"
  }
}

resource "aws_subnet" "eks_subnet_2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet"
  }
}

# Create a Route table for the EKS cluster
resource "aws_route_table" "eks_vpc" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
}

resource "aws_route_table_association" "subnet_1" {
  subnet_id      = aws_subnet.eks_subnet_1.id
  route_table_id = aws_route_table.eks_vpc.id
}

resource "aws_route_table_association" "subnet_2" {
  subnet_id      = aws_subnet.eks_subnet_2.id
  route_table_id = aws_route_table.eks_vpc.id
}