provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
  token                    = var.yc_token != "" ? var.yc_token : null
  service_account_key_file = var.yc_service_account_key_file != "" ? var.yc_service_account_key_file : null
}
