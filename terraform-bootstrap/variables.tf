variable "cloud_id" {
  description = "Идентификатор облака Yandex Cloud."
  type        = string
  default     = "b1gcjrlk0i1d3op3q77a"
}

variable "folder_id" {
  description = "Идентификатор каталога, где создаётся инфраструктура."
  type        = string
  default     = "b1geh8jbc1scqn4i6uuh"
}

variable "default_zone" {
  description = "Зона по умолчанию для провайдера (например ru-central1-a)."
  type        = string
  default     = "ru-central1-a"
}

variable "yc_token" {
  description = "OAuth/IAM токен Yandex Cloud для bootstrap (опционально, лучше через YC_TOKEN)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "yc_service_account_key_file" {
  description = "Путь к JSON-ключу SA для аутентификации провайдера (опционально)."
  type        = string
  default     = "/home/master/keys/authorized_key.json"
}

variable "terraform_sa_name" {
  description = "Имя сервисного аккаунта для Terraform (уникально в облаке)."
  type        = string
  default     = "terraform-ops"
}

variable "state_bucket_name" {
  description = "Глобально уникальное имя бакета Object Storage для state."
  type        = string
}
