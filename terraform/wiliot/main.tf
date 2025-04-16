module "wiliot_stack" {
  source       = "../modules/wiliot"
  name_prefix  = var.name_prefix
  region       = var.region
  db_username  = var.db_username
  db_password  = var.db_password
  eks_cluster_name   = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  airflow_admin_username = var.airflow_admin_username
  airflow_admin_password = var.airflow_admin_password
}

module "eks" {
  source      = "../modules/eks"
  name_prefix = var.name_prefix
  vpc_id      = module.wiliot_stack.vpc_id
  subnet_ids  = module.wiliot_stack.private_subnet_ids
  eks_node_role_arn     = module.wiliot_stack.eks_node_role_arn
}