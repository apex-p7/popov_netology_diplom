resource "yandex_iam_service_account" "k8s" {
  name        = "${var.cluster_name}-sa"
  description = "Managed Kubernetes: control plane и worker nodes"
}

locals {
  k8s_folder_roles = toset([
    "k8s.clusters.agent",
    "k8s.tunnelClusters.agent",
    "vpc.publicAdmin",
    "container-registry.images.puller",
    "load-balancer.admin",
  ])
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_sa_roles" {
  for_each  = local.k8s_folder_roles
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s.id}"
}
