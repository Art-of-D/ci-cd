variable "ecr_name" {
  type        = string
  description = "Назва ECR репозиторію"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "scan_on_push" {
  type        = bool
  default     = true
}