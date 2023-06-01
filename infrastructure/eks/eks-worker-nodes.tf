# EKS Worker Node
#  * Create the IAM role for the Worker node
#  * Attach the necessary policies to the IAM role
#  * Create Instance profile for worker node
#  * Create an assigned node group for EKS Cluster

# Create the IAM role for the Worker node
resource "aws_iam_role" "worker-node" {
  name = "terraform-eks-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker-node.name
}

resource "aws_iam_role_policy_attachment" "worker-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker-node.name
}

# Create Instance profile for worker node
resource "aws_iam_instance_profile" "worker-node" {
  name = "terraform-eks-worker"
  role = aws_iam_role.worker-node.name
}

# Create an assigned node group for EKS Cluster
resource "aws_eks_node_group" "worker-node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "worker-node"
  node_role_arn   = aws_iam_role.worker-node.arn
  subnet_ids      = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.worker-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.worker-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}