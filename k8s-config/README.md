# Конфигурация Kubernetes

## Мониторинг (kube-prometheus-stack)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f monitoring/kube-prometheus-values.yaml
```

После установки получите внешний IP Grafana:

```bash
kubectl -n monitoring get svc kube-prometheus-grafana
```

Откройте в браузере `http://EXTERNAL_IP/` (логин по умолчанию `admin`, пароль из `kube-prometheus-values.yaml` — обязательно смените).

Встроенные дашборды Kubernetes доступны в разделе Dashboards.

## Тестовое приложение

Перед применением замените в `app/deployment.yaml` образ на собранный в Yandex Container Registry.

```bash
kubectl apply -f app/namespace.yaml
kubectl apply -f app/deployment.yaml
kubectl apply -f app/service.yaml
kubectl -n sample-app get svc static-site
```

Проверка: `curl http://EXTERNAL_IP/`.
