output "kubernetes_cluster_id" {
  description = "ID кластера для yc managed-kubernetes cluster get-credentials"
  value       = yandex_kubernetes_cluster.this.id
}

output "kubernetes_cluster_name" {
  value = yandex_kubernetes_cluster.this.name
}

output "container_registry_id" {
  value = yandex_container_registry.this.id
}

output "container_registry_endpoint" {
  value = "cr.yandex/${yandex_container_registry.this.id}"
}

output "kubectl_config_hint" {
  description = "Идентификатор облака для kubectl (после установки yc CLI)."
  value       = <<-EOT
    yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.this.id} --external --force
    kubectl get pods -A
  EOT
}
