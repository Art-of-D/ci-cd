# Структура проєкту\

```
lesson-7/
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
│   ├── eks/                 # Модуль для Kubernetes кластера
│   │   ├── eks.tf           # Створення кластера
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│
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

docker buildx build --platform linux/amd64 -t "АДРЕСА ДО РЕПО"/lesson-7-ecr:latest .

docker push "АДРЕСА ДО РЕПО"/lesson-7-ecr:latest

# 5.Підключення до вашого кластеру

aws eks --region us-west-2 update-kubeconfig --name eks-cluster-demo

# 6.Підключення до вашого кластеру

helm upgrade --install django-app ./charts/django-app

# ! Перевірка !
kubectl get pods -o wide
kubectl get svc
kubectl logs <pod-name>

# LAST. Видалення всієї інфраструктури
terraform destroy
```
