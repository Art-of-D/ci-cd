/*
output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}
*/

output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.ecr_repository_url
}

output "ecr_repository_name" {
  description = "Назва ECR репозиторію"
  value       = module.ecr.ecr_repository_name
}

output "ecr_repository_arn" {
  description = "ARN ECR репозиторію"
  value       = module.ecr.ecr_repository_arn
}

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

output "argo_cd_server_service" {
  value = module.argo_cd.argo_cd_server_service
}

output "argo_cd_namespace" {
  value = module.argo_cd.argo_cd_namespace
}

output "argo_cd_admin_password_secret" {
  value = module.argo_cd.argo_cd_admin_password
}

output "argo_cd_apps_release" {
  value = module.argo_cd.argo_apps_release_name
}

output "db_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_port" {
  value = module.rds.db_instance_port
}

output "db_name" {
  value = module.rds.db_instance_name
}

output "db_username" {
  value = module.rds.db_instance_username
}

output "db_security_group_id" {
  value = module.rds.security_group_id
}