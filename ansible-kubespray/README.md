# Ansible / Kubespray (опционально)

Если выбран **самостоятельный** Kubernetes на ВМ:

1. Поднимите минимум 3 ВМ через `terraform` (control-plane + workers или 3 control-plane в зависимости от схемы).
2. Используйте [Kubespray](https://github.com/kubernetes-sigs/kubespray): сгенерируйте инвентарь по IP ВМ, включите прерываемые ноды на уровне Terraform, в `group_vars` ограничьте ресурсы под ваш купон.
3. После развёртывания снимите `kubeconfig` и положите в `~/.kube/config`.

Репозиторий с этим README можно сдать как «конфигурацию ansible», дополнив своим `inventory` и плейбуками после генерации Kubespray.
