locals {
  terraform_folder_roles = toset([
    "editor",
    "iam.serviceAccounts.admin",
    "resource-manager.admin",
  ])
}

resource "yandex_iam_service_account" "terraform" {
  name        = var.terraform_sa_name
  description = "Terraform: управление инфраструктурой в каталоге"
}

resource "yandex_resourcemanager_folder_iam_member" "terraform_roles" {
  for_each  = local.terraform_folder_roles
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

resource "yandex_storage_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  versioning {
    enabled = true
  }
}

resource "yandex_iam_service_account_static_access_key" "terraform_state" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Terraform S3 backend"
}
