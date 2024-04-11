resource "aws_eks_cluster" "cloudquick" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cloudquick.arn

  vpc_config {
    subnet_ids              = var.aws_private_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.node_group_one1.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudquick-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cloudquick-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "cloudquick" {
  cluster_name    = aws_eks_cluster.cloudquick.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.cloudquick2.arn
  subnet_ids      = var.aws_private_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one1.id]
    ec2_ssh_key               = var.key_pair
    #public_ip                 = false
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudquick-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cloudquick-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cloudquick-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "node_group_one1" {
  name_prefix = "node_group_one1"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "cloudquick" {
  name = "eks-cluster-cloudquick"

  assume_role_policy = <<POLICY
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
POLICY
}


resource "aws_iam_role_policy_attachment" "cloudquick-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cloudquick.name
}

resource "aws_iam_role_policy_attachment" "cloudquick-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cloudquick.name
}

resource "aws_iam_role" "cloudquick2" {
  name = "eks-node-group-cloudquick"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}




resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.cloudquick2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}


resource "aws_iam_role_policy_attachment" "cloudquick-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cloudquick2.name
}

resource "aws_iam_role_policy_attachment" "cloudquick-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cloudquick2.name
}

resource "aws_iam_role_policy_attachment" "cloudquick-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cloudquick2.name
}

resource "aws_iam_role_policy_attachment" "cloudquick-AmazonDynamoDBFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.cloudquick2.name
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name      = aws_eks_cluster.cloudquick.name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.27.0-eksbuild.1"  # Specify the version you want to use. Check the latest compatible version with your EKS.
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.cloudquick
  ]
}

#resource "aws_eks_addon" "ebs_csi" {
#  cluster_name      = aws_eks_cluster.cloudquick.name
#  addon_name        = "aws-ebs-csi-driver"
#  addon_version     = "v1.27.0-eksbuild.1"  # Specify the version you want to use. Check the latest compatible version with your EKS.
#  resolve_conflicts_on_create = "OVERWRITE"
#  resolve_conflicts_on_update = "OVERWRITE"
#  resolve_conflicts = "OVERWRITE"  # Indicates how to resolve parameter conflicts.
#  service_account_role_arn = aws_iam_role.cloudquick2.arn  # Assuming you want to use the same role for the add-on.
  
#  depends_on = [
#    aws_eks_cluster.cloudquick
#  ]
#}
