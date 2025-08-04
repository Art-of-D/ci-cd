resource "helm_release" "argo_cd" {
  name       = var.name
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  create_namespace = true
}

resource "helm_release" "argo_apps" {
  name       = "${var.name}-apps"
  chart      = "${path.module}/charts"
  namespace  = var.namespace
  create_namespace = false

  values = [
    file("${path.module}/values.yaml"), # базові значення з Git
    templatefile("${path.module}/values.yaml.tpl", { # динамічні з RDS
      db_host     = var.db_instance_endpoint
      db_port     = var.db_instance_port
      db_user     = var.db_instance_username
      db_password = var.db_instance_password
      db_name     = var.db_instance_name
    })
  ]

  depends_on = [helm_release.argo_cd]
}

