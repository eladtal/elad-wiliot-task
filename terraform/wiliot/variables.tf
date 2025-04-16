variable "name_prefix" {
  type        = string
  description = "Prefix for naming AWS resources"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "airflow_admin_username" {
  type = string
}

variable "airflow_admin_password" {
  type = string
}