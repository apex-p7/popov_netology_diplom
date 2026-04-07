locals {
  # Подсети не должны пересекаться с pod/service CIDR.
  subnets = {
    "a" = {
      zone = "ru-central1-a"
      cidr = "10.10.1.0/24"
    }
    "b" = {
      zone = "ru-central1-b"
      cidr = "10.10.2.0/24"
    }
    "d" = {
      zone = "ru-central1-d"
      cidr = "10.10.3.0/24"
    }
  }

  subnet_cidrs = [for subnet in values(local.subnets) : subnet.cidr]

  cluster_ipv4_cidr = "10.112.0.0/16"
  service_ipv4_cidr = "10.96.0.0/16"
}
