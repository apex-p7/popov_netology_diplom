# Лаборатория: Yandex Cloud, Kubernetes, мониторинг, CI/CD

Монорепозиторий с заготовками под учебное задание: Terraform (bootstrap + инфраструктура), Managed Kubernetes с региональным мастером и прерываемыми нодами, Container Registry, Helm-стек мониторинга, тестовое nginx-приложение и примеры GitHub Actions / Atlantis.

## Структура

| Каталог | Назначение |
|--------|------------|
| `terraform-bootstrap/` | Сервисный аккаунт Terraform, бакет Object Storage для remote state (state слоя — локальный). |
| `terraform-infra/` | VPC (3 подсети в ru-central1-a/b/d), Security Groups, **Managed Kubernetes** (региональный master), группа нод (прерываемые), **Container Registry**. |
| `k8s-config/` | Манифесты приложения и values для `kube-prometheus-stack`. |
| `sample-app/` | Статика + nginx + `Dockerfile`. |
| `ansible-kubespray/` | Заготовка описания для варианта с Kubespray на ВМ. |
| `atlantis/` | Пример `atlantis.yaml` для планов/апплаев Terraform. |
| `.github/workflows/` | CI/CD: образ приложения и опционально Terraform. |

## Предварительные условия

- Установлены [Terraform](https://www.terraform.io/) ≥ 1.5, [Yandex Cloud CLI](https://cloud.yandex.ru/docs/cli/quickstart) (`yc`), `kubectl`, при необходимости [Helm](https://helm.sh/).
- Создано облако и каталог, известны `cloud_id` и `folder_id`.
- Для первого шага — аутентификация пользователя: `yc init` или переменная `YC_TOKEN`.

## 1. Bootstrap (локальный state)

```bash
cd terraform-bootstrap
cp terraform.tfvars.example terraform.tfvars   # заполните
terraform init
terraform apply
```

Сохраните вывод: имя бакета, `access_key` / `secret_key` для S3-backend (или возьмите из `terraform output -raw`).

Создайте **JSON-ключ** для сервисного аккаунта Terraform (для провайдера в основном слое), не публикуйте его:

```bash
yc iam key create --service-account-id "$(terraform output -raw terraform_service_account_id)" \
  -o ../terraform-sa.json
```

## 2. Основная инфраструктура (state в бакете)

```bash
export AWS_ACCESS_KEY_ID="..."      # из bootstrap output
export AWS_SECRET_ACCESS_KEY="..."  # из bootstrap output
unset AWS_SESSION_TOKEN             # важно для Yandex Object Storage backend

cd ../terraform-infra
cp terraform.tfvars.example terraform.tfvars   # заполните registry_name, путь к ключу
cp backend.hcl.example backend.hcl               # подставьте имя бакета

terraform init -reconfigure -backend-config=backend.hcl
terraform apply
```

Проверка Kubernetes:

```bash
yc managed-kubernetes cluster get-credentials "$(terraform output -raw kubernetes_cluster_id)" --external --force
kubectl get pods -A
```

Должно выполняться без ошибок (как в условии задания).

## 3. Мониторинг и приложение

См. [k8s-config/README.md](k8s-config/README.md): Helm-установка `kube-prometheus-stack`, затем `kubectl apply` для `sample-app`.

- Grafana: `Service` типа `LoadBalancer`, порт **80** (пароль задайте в `kube-prometheus-values.yaml`).
- Тестовое приложение: `LoadBalancer` на порту **80** после подстановки образа из реестра.

## 4. Сборка образа и CI/CD

### Ручная сборка в YCR

```bash
cd sample-app
docker build -t cr.yandex/<REGISTRY_ID>/sample-static-site:latest .
docker push cr.yandex/<REGISTRY_ID>/sample-static-site:latest
```

Обновите `k8s-config/app/deployment.yaml` и примените манифесты.

### GitHub Actions

Заполните секреты репозитория:

| Секрет | Смысл |
|--------|--------|
| `YC_SA_JSON` | JSON ключ сервисного аккаунта с правами на push в реестр |
| `YC_REGISTRY` | Префикс образа, например `cr.yandex/<REGISTRY_ID>` |
| `KUBE_CONFIG_B64` | `cat ~/.kube/config \| base64 -w0` для job деплоя по тегу |

Поведение:

- Любой push в `main` — сборка и push тега `latest`.
- Тег `v1.0.0` — сборка образа с semver-тегом и `kubectl set image` (job `deploy-on-tag`).

При разнесении по репозиториям перенесите `sample-app/` и workflow в репозиторий приложения.

## 5. Terraform pipeline (на выбор)

- **Terraform Cloud**: подключите VCS, backend `remote`, выполните успешный run из UI (скриншот для отчёта).
- **Atlantis**: разверните Atlantis в кластере, укажите репозиторий и webhook; используйте [atlantis/atlantis.yaml](atlantis/atlantis.yaml) (путь к `backend.hcl` настройте под ваш процесс).
- **GitHub Actions**: workflow [terraform-main.yml](.github/workflows/terraform-main.yml) — план на каждый push; для auto-apply добавьте job с `terraform apply` и защищённым `environment`.

Секреты для `terraform-main.yml`: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (статические ключи SA для бакета), `TF_STATE_BUCKET`, `YC_SA_JSON` (JSON SA Terraform), `YC_CLOUD_ID`, `YC_FOLDER_ID`, `YC_REGISTRY_NAME` (как в `terraform.tfvars`).

## 6. Самостоятельный Kubernetes (альтернатива)

Если выбираете ВМ + Kubespray: см. [ansible-kubespray/README.md](ansible-kubespray/README.md); в Terraform добавьте отдельный модуль с прерываемыми worker-нодами и минимальными `cores`/`memory`.

## Экономия купона

- Managed K8s: региональный master по заданию; **прерываемые** ноды (`scheduling_policy.preemptible = true`), минимальные `node_cores` / `memory` / `disk` в `terraform-infra/variables.tf`.
- Отключайте лишние реплики и persistence в Grafana при учебной нагрузке.

## Что подготовить к сдаче

- Репозиторий(и) с Terraform, манифестами k8s, Dockerfile.
- Доказательство Terraform pipeline (PR с Atlantis / скрин Terraform Cloud / CI).
- Ссылка на образ в реестре, URL Grafana и тестового приложения (внешние IP из `LoadBalancer`), учётные данные Grafana (после смены пароля).

Все чувствительные файлы (`terraform-sa.json`, `backend.hcl` с ключами) храните только локально и в секретах CI; в git они не коммитятся (см. `.gitignore`).
