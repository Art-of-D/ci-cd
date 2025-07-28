variable "name" {
  description = "Назва Helm-релізу"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "K8s namespace для Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Версія Argo CD чарта"
  type        = string
  default     = "5.46.4" 
}

variable "db_instance_endpoint" { type = string }
variable "db_instance_port"     { type = string }
variable "db_instance_username" { type = string }
variable "db_instance_password" { type = string }
variable "db_instance_name"     { type = string }