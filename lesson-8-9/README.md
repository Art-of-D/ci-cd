# Структура проєкту\

```
Progect/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію
│   │
│   ├── eks/                      # Модуль для Kubernetes кластера
│   │   ├── eks.tf                # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │
│   └── argo-cd/             # Новий модуль для Helm-установки Argo CD
│       ├── argo_cd.tf       # Helm release для Jenkins
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│		    └──charts/                  # Helm-чарт для створення app'ів
│ 	 	    ├── Chart.yaml
│	  	    ├── values.yaml          # Список applications, repositories
│			    └── templates/
│		        ├── application.yaml
│		        └── repository.yaml
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap зі змінними середовища


```

## 🚀 Команди для запуску

```bash
# 1. Ініціалізація Terraform-проєкту
terraform init

# 2. Перевірка, що буде створено
terraform plan

# 3. Створення інфраструктури
terraform apply

# 4.Пуш образу на сервер
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "АДРЕСА ДО РЕПО"

docker buildx build --platform linux/amd64 -t "АДРЕСА ДО РЕПО"/lesson-8-9-ecr:latest .

docker push "АДРЕСА ДО РЕПО"/lesson-8-9-ecr:latest

# 5.Підключення до вашого кластеру

aws eks --region us-west-2 update-kubeconfig --name eks-cluster-demo

# 6.Створити namespace для передачі токену jenkins & argo-cd

kubectl create namespace argocd
kubectl create namespace jenkins

# Створити секрет для Argo CD

kubectl create secret generic github-token-secret \
 --from-literal=github_username=your_github_username \
 --from-literal=github_token=ghp_xxxxxxxxx_token \
 --namespace=argocd

# Створити той самий секрет для Jenkins

kubectl create secret generic github-token-secret \
 --from-literal=github_username=your_github_username \
 --from-literal=github_token=ghp_xxxxxxxxx_token \
 --namespace=jenkins


# 7.Запуск helm

helm upgrade --install django-app ./charts/django-app

# У разі виникнення проблем з доступом до токену можна додатково застосувати

helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install jenkins jenkins/jenkins -n jenkins -f ./jenkins-values.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace

# ! Перевірка !
kubectl get pods -o wide
kubectl get svc
kubectl logs <pod-name>

# Перевірка argo-cd
kubectl get secret argocd-initial-admin-secret -n argocd -o yaml

# LAST. Видалення всієї інфраструктури
terraform destroy
```
