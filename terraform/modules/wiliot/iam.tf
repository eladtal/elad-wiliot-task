
resource "aws_iam_role" "eks_node_role" {
  name = "${var.name_prefix}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Airflow IRSA IAM Role
data "aws_caller_identity" "current" {}

# data "aws_eks_cluster" "cluster" {
#   name = var.eks_cluster_name
# }

data "aws_eks_cluster_auth" "auth" {
  name = var.eks_cluster_name
}

# locals {
#   oidc_issuer_raw = jsondecode(jsonencode(data.aws_eks_cluster.cluster.identity)).oidc.issuer
#   oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_issuer_raw, "https://", "")}"
# }

locals {
  oidc_provider_url = replace(var.eks_oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "https://")
  oidc_provider_arn = var.eks_oidc_provider_arn
}


resource "aws_iam_role" "airflow_irsa" {
  name = "${var.name_prefix}-airflow-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = var.eks_oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(local.oidc_provider_arn, "https://", "")}:sub" : "system:serviceaccount:airflow:airflow"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.name_prefix}-airflow-irsa"
  }
}

resource "aws_iam_policy" "airflow_policy" {
  name        = "${var.name_prefix}-airflow-policy"
  description = "Permissions for Airflow to access RDS and ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "rds:*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "airflow_policy_attachment" {
  role       = aws_iam_role.airflow_irsa.name
  policy_arn = aws_iam_policy.airflow_policy.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "airflow_irsa_role_arn" {
  value = aws_iam_role.airflow_irsa.arn
}