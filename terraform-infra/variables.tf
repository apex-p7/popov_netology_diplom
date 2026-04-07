variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "network_name" {
  type    = string
  default = "k8s-lab-network"
}

variable "cluster_name" {
  type    = string
  default = "k8s-lab"
}

variable "k8s_version" {
  type        = string
  default     = ""
}

variable "registry_name" {
  description = "Имя Container Registry (уникально в каталоге)."
  type        = string
}

variable "node_cores" {
  type        = number
  default     = 2
}

variable "node_memory_gb" {
  type    = number
  default = 4
}

variable "node_disk_gb" {
  type    = number
  default = 32
}

variable "node_count_per_zone" {
  description = "Количество прерываемых нод в каждой из трёх зон."
  type        = number
  default     = 1
}

variable "ssh_allowed_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
