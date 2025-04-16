variable "name_prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

# variable "vpc_id" {
#   type = string
# }

# variable "subnet_ids" {
#   type = list(string)
# }

variable "eks_cluster_name" {
  type = string
}

# variable "eks_cluster_auth" {
#   type = string
# }

variable "eks_oidc_provider_arn" {
  type = string
}

variable "airflow_admin_username" {
  type = string
}

variable "airflow_admin_password" {
  type = string
}