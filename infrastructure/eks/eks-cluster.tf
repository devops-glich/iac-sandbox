# EKS Cluster
#  * Create the EKS cluster
#  * Create the IAM role for the EKS cluster
#  * Attach the necessary policies to the IAM role
#  * Create a security group for the EKS cluster

# Create the EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "sohtek-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
  }

  tags = {
    Name = "eks-cluster"
  }
}

# Create the IAM role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name = "eks-cluster-role"
  }
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Create a security group for the EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name        = "eks-cluster-sg"
  description = "Security group for the EKS cluster"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}
