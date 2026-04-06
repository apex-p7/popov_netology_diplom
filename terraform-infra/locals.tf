locals {
  # Подсети не должны пересекаться с pod/service CIDR.
  subnet_cidr_a = "10.10.1.0/24"
  subnet_cidr_b = "10.10.2.0/24"
  subnet_cidr_d = "10.10.3.0/24"

  subnet_cidrs = [
    local.subnet_cidr_a,
    local.subnet_cidr_b,
    local.subnet_cidr_d,
  ]

  cluster_ipv4_cidr  = "10.112.0.0/16"
  service_ipv4_cidr  = "10.96.0.0/16"
}
