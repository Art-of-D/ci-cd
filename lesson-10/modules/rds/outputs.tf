output "db_instance_endpoint" {
  value = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.standard[0].endpoint
}

output "db_instance_writer_endpoint" {
  value = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : null
}

output "db_instance_name" {
  value = var.db_name
}

output "db_instance_username" {
  value = var.username
  sensitive = true
}

output "db_instance_password" {
  value     = var.password
  sensitive = true
}

output "db_instance_port" {
  value = 5432
}

output "security_group_id" {
  value = aws_security_group.rds.id
}