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

variable "service_account_key_file" {
  description = "JSON-ключ сервисного аккаунта Terraform (создаётся вручную после bootstrap, не коммитить)."
  type        = string
  default     = ""
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
  description = "Версия Kubernetes. Оставьте пустой (\"\") для выбора поддерживаемой версии по умолчанию."
  type        = string
  default     = ""
}

variable "registry_name" {
  description = "Имя Container Registry (уникально в каталоге)."
  type        = string
}

variable "node_cores" {
  description = "vCPU на ноду (минимизируйте для экономии купона)."
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
