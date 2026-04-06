output "terraform_service_account_id" {
  description = "ID сервисного аккаунта Terraform."
  value       = yandex_iam_service_account.terraform.id
}

output "state_bucket_name" {
  description = "Имя бакета для backend."
  value       = yandex_storage_bucket.terraform_state.bucket
}

output "s3_access_key_id" {
  description = "Ключ для переменных AWS_ACCESS_KEY_ID при backend s3."
  value       = yandex_iam_service_account_static_access_key.terraform_state.access_key
  sensitive   = true
}

output "s3_secret_access_key" {
  description = "Секрет для AWS_SECRET_ACCESS_KEY."
  value       = yandex_iam_service_account_static_access_key.terraform_state.secret_key
  sensitive   = true
}

output "backend_config_snippet" {
  description = "Подсказка для backend.hcl (не храните секреты в git)."
  value       = <<-EOT
    bucket     = "${yandex_storage_bucket.terraform_state.bucket}"
    key        = "main/terraform.tfstate"
    region     = "ru-central1"
    endpoint   = "https://storage.yandexcloud.net"
    skip_region_validation      = true
    skip_credentials_validation = true
  EOT
}
