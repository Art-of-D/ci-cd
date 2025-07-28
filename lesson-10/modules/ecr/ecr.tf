resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE" # або "IMMUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.ecr_name
    Environment = var.environment
  }
}