output "ecr_repository_name" {
  description = "Назва створеного ECR репозиторію"
  value = aws_ecr_repository.app_repo.name
}

output "ecr_repository_url" {
  description = "Повний URL для Docker push/pull"
  value = aws_ecr_repository.app_repo.repository_url
}

output "ecr_repository_arn" {
  description = "ARN створеного репозиторію"
  value       = aws_ecr_repository.app_repo.arn
}