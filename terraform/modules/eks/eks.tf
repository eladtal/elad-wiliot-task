
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.15.3"

  cluster_name    = "${var.name_prefix}-eks"
  cluster_version = "1.29"

  # vpc_id = aws_vpc.this.id
  # subnet_ids = aws_subnet.private[*].id
  # vpc_id     = var.vpc_id
  # subnet_ids = var.subnet_ids
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  node_security_group_additional_rules = {
    egress_all = {
      protocol  = "-1"
      from_port = 0
      to_port   = 0
      type      = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  enable_irsa     = true

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1
      iam_role_arn   = var.eks_node_role_arn
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = var.name_prefix
    Terraform   = "true"
  }
}


output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
}

# output "node_group_role_arn" {
#   value = module.eks.eks_managed_node_groups.default.iam_role_arn
# }

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}