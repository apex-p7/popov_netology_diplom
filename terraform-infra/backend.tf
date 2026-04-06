# Скопируйте в backend.tf и задайте bucket после bootstrap, либо используйте:
# terraform init -backend-config=backend.hcl
#
# Содержимое backend.hcl (локально, не коммитить):
#   bucket   = "имя-бакета"
#   key      = "main/terraform.tfstate"
#   region   = "ru-central1"
#   endpoints = { s3 = "https://storage.yandexcloud.net" }
#   skip_region_validation      = true
#   skip_credentials_validation = true
#   skip_requesting_account_id  = true

terraform {
  backend "s3" {}
}
