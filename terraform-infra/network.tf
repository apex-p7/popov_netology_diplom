resource "yandex_vpc_network" "this" {
  name        = var.network_name
  description = "VPC для Managed Kubernetes"
}

resource "yandex_vpc_subnet" "subnet_a" {
  name           = "${var.network_name}-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [local.subnet_cidr_a]
}

resource "yandex_vpc_subnet" "subnet_b" {
  name           = "${var.network_name}-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [local.subnet_cidr_b]
}

resource "yandex_vpc_subnet" "subnet_d" {
  name           = "${var.network_name}-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [local.subnet_cidr_d]
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
    port             = 80
    protocol         = "TCP"
    v4_cidr_blocks   = ["0.0.0.0/0"]
  }

  ingress {
    description    = "HTTPS"
    port             = 443
    protocol         = "TCP"
    v4_cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_ssh_access" {
  name        = "${var.cluster_name}-ssh"
  description = "SSH на ноды (по необходимости сузьте CIDR)"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "SSH"
    port             = 22
    protocol         = "TCP"
    v4_cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_cluster_traffic" {
  name        = "${var.cluster_name}-master-api"
  description = "Доступ к API Kubernetes"
  network_id  = yandex_vpc_network.this.id

  ingress {
    description    = "Kubernetes API 443"
    port             = 443
    protocol         = "TCP"
    v4_cidr_blocks   = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Kubernetes API 6443"
    port             = 6443
    protocol         = "TCP"
    v4_cidr_blocks   = ["0.0.0.0/0"]
  }

  egress {
    description    = "К metric-server на нодах"
    port             = 4443
    protocol         = "TCP"
    v4_cidr_blocks   = [local.cluster_ipv4_cidr]
  }
}
