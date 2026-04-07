resource "yandex_vpc_network" "this" {
  name        = var.network_name
  description = "VPC для Managed Kubernetes"
}

resource "yandex_vpc_subnet" "this" {
  for_each = local.subnets

  name           = "${var.network_name}-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [each.value.cidr]
}

resource "yandex_vpc_security_group" "k8s_cluster_nodegroup_traffic" {
  name        = "${var.cluster_name}-cluster-nodegroup"
  description = "Служебный трафик master и node groups"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description       = "Health checks NLB"
    from_port         = 0
    to_port           = 65535
    protocol          = "TCP"
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "Трафик между master и нодами"
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "ICMP health checks из подсетей VPC"
    protocol       = "ICMP"
    v4_cidr_blocks = local.subnet_cidrs
  }

  egress {
    description       = "Исходящий служебный трафик"
    from_port         = 0
    to_port           = 65535
    protocol          = "ANY"
    predefined_target = "self_security_group"
  }
}

resource "yandex_vpc_security_group" "k8s_nodegroup_traffic" {
  name        = "${var.cluster_name}-node-internal"
  description = "Pod/Service и внешний выход нод"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "Трафик между pod и service"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = [local.cluster_ipv4_cidr, local.service_ipv4_cidr]
  }

  egress {
    description    = "Исходящий в интернет"
    from_port      = 0
    to_port        = 65535
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_services_access" {
  name        = "${var.cluster_name}-nodeport-lb"
  description = "Доступ к сервисам (NodePort / NLB)"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "NodePort диапазон"
    from_port      = 30000
    to_port        = 32767
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTP"
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS"
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_ssh_access" {
  name        = "${var.cluster_name}-ssh"
  description = "SSH на ноды (ограничьте trusted CIDR, bastion или VPN)"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "SSH"
    port           = 22
    protocol       = "TCP"
    v4_cidr_blocks = var.ssh_allowed_cidrs
  }
}

resource "yandex_vpc_security_group" "k8s_cluster_traffic" {
  name        = "${var.cluster_name}-master-api"
  description = "Доступ к API Kubernetes"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "Kubernetes API 443"
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Kubernetes API 6443"
    port           = 6443
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "К metric-server на нодах"
    port           = 4443
    protocol       = "TCP"
    v4_cidr_blocks = [local.cluster_ipv4_cidr]
  }
}
