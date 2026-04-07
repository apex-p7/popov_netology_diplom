resource "yandex_kubernetes_cluster" "this" {
  name        = var.cluster_name
  description = "Региональный master, ноды в трёх зонах (прерываемые)"
  network_id  = yandex_vpc_network.this.id

  cluster_ipv4_range = local.cluster_ipv4_cidr
  service_ipv4_range = local.service_ipv4_cidr

  master {
    version   = var.k8s_version != "" ? var.k8s_version : null
    public_ip = true

    regional {
      region = "ru-central1"
      dynamic "location" {
        for_each = yandex_vpc_subnet.this
        content {
          zone      = location.value.zone
          subnet_id = location.value.id
        }
      }
    }

    security_group_ids = [
      yandex_vpc_security_group.k8s_cluster_nodegroup_traffic.id,
      yandex_vpc_security_group.k8s_cluster_traffic.id,
    ]
  }

  service_account_id      = yandex_iam_service_account.k8s.id
  node_service_account_id = yandex_iam_service_account.k8s.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_sa_roles,
  ]
}

resource "yandex_kubernetes_node_group" "workers" {
  name       = "${var.cluster_name}-workers"
  cluster_id = yandex_kubernetes_cluster.this.id
  version    = var.k8s_version != "" ? var.k8s_version : null

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores  = var.node_cores
      memory = var.node_memory_gb
    }

    boot_disk {
      type = "network-hdd"
      size = var.node_disk_gb
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      nat        = true
      subnet_ids = [for subnet in values(yandex_vpc_subnet.this) : subnet.id]
      security_group_ids = [
        yandex_vpc_security_group.k8s_cluster_nodegroup_traffic.id,
        yandex_vpc_security_group.k8s_nodegroup_traffic.id,
        yandex_vpc_security_group.k8s_services_access.id,
        yandex_vpc_security_group.k8s_ssh_access.id,
      ]
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count_per_zone * length(local.subnets)
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = local.subnets
      content {
        zone = location.value.zone
      }
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 1
  }
}
