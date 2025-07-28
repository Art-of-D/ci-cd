output "argo_cd_server_service" {
  description = "Argo CD server service"
  value       = "argo-cd.${var.namespace}.svc.cluster.local"
}

output "argo_cd_admin_password" {
  description = "Initial admin password"
  value       = "Run: kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
}

output "argo_cd_namespace" {
  value = var.namespace
}

output "argo_apps_release_name" {
  value = helm_release.argo_apps.name
}