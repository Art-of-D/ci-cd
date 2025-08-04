# Структура проєкту\

```
Project/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
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
│   ├── rds/                 # Модуль для RDS
│   │   ├── rds.tf           # Створення RDS бази даних
│   │   ├── aurora.tf        # Створення aurora кластера бази даних
│   │   ├── shared.tf        # Спільні ресурси
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   └── outputs.tf
│   │
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
│       ├── values.yaml.tpl  # Для передачі згенерованих паролів і інших секретів з тераформ в helm
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
└──Django
			 ├── django\
			 ├── Dockerfile
			 ├── Jenkinsfile
       ├── requirements
			 └── django_pr\

```

Створений:

- DynamoDB таблиця

```
aws dynamodb create-table \
   --table-name terraform-locks \
   --attribute-definitions AttributeName=LockID,AttributeType=S \
   --key-schema AttributeName=LockID,KeyType=HASH \
   --billing-mode PAY_PER_REQUEST \
   --region us-west-2
```

- S3 bucket

```
aws s3api create-bucket \
  --bucket СВОЄ ІМʼЯ \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2
```

## 🚀 Команди для запуску

```bash
# 1. Ініціалізація Terraform-проєкту
terraform init

# 2. Перевірка, що буде створено
terraform plan

# 3. Створення інфраструктури
terraform apply

# 4. Пуш образу на сервер
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "АДРЕСА ДО РЕПО"

docker buildx build --platform linux/amd64 -t "АДРЕСА ДО РЕПО"/"ТВІЙ БАКЕТ":latest .

docker push "АДРЕСА ДО РЕПО"/"ТВІЙ БАКЕТ":latest

# 5. Підключення до вашого кластеру

aws eks --region us-west-2 update-kubeconfig --name eks-cluster-demo

# 6. Створити namespace для передачі токену jenkins & argo-cd

kubectl create namespace argocd
kubectl create namespace jenkins

# Створити секрет для Argo CD

kubectl create secret generic github-token-secret \
 --from-literal=GITHUB_USERNAME=your_github_username \
 --from-literal=GITHUB_TOKEN=ghp_xxxxxxxxx_token \
 --namespace=argocd

# Створити той самий секрет для Jenkins

kubectl create secret generic github-token-secret \
 --from-literal=GITHUB_USERNAME=your_github_username \
 --from-literal=GITHUB_TOKEN=ghp_xxxxxxxxx_token \
 --namespace=jenkins

# 7. Додати jenkins argo-cd
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install jenkins jenkins/jenkins -n jenkins -f modules/jenkins/values.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace

# 8. Підключення до jenkins
kubectl port-forward svc/jenkins 8080:8080 -n jenkins

# Щоб отримати пароль для admin
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# Обовʼязкові кроки в інтерфейсі
Manage Jenkins → In-process Script Approval → Approve

Перейти до seed-job → Build now

Перейти до django-pipeline → Build now

# Підключення до argo-cd
kubectl port-forward service/argocd-server -n argocd 8083:443

# Отримати пароль для admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

#Перевірити роботу app

# LAST. Видалення всієї інфраструктури
terraform destroy
```

# ! Вимоги !

    • AWS CLI налаштований (aws configure)
    • Terraform ≥ 1.3
    • Права доступу до:
    • s3
    • dynamodb
    • ecr

    Змінити у values.yaml & jenkinsfile (argo-cd & jenkins) посилання на GIT та AWS

📘 RDS Terraform Module — PostgreSQL / Aurora

# Опис змінних

| Змінна                          | Тип            | Обов’язково | Опис                                                    |
| ------------------------------- | -------------- | ----------- | ------------------------------------------------------- |
| `name`                          | `string`       | ✅          | Назва RDS-ресурсу та Security Group                     |
| `use_aurora`                    | `bool`         | ✅          | Якщо `true` — створюється Aurora, інакше стандартна RDS |
| `aurora_instance_count`         | `number`       | ❌          | Кількість Aurora реплік (не writer)                     |
| `engine`                        | `string`       | ✅          | `postgres`, `aurora-postgresql`, тощо                   |
| `engine_version`                | `string`       | ✅          | Версія рушія (наприклад, `17.2`)                        |
| `parameter_group_family_rds`    | `string`       | ✅          | Наприклад, `postgres17`                                 |
| `parameter_group_family_aurora` | `string`       | ❌          | Якщо Aurora, наприклад `aurora-postgresql13`            |
| `instance_class`                | `string`       | ✅          | Наприклад, `db.t3.medium`                               |
| `allocated_storage`             | `number`       | ✅          | Тільки для RDS (обсяг в GB)                             |
| `db_name`                       | `string`       | ✅          | Назва бази даних                                        |
| `username`                      | `string`       | ✅          | Користувач бази даних                                   |
| `password`                      | `string`       | ✅          | Пароль бази даних                                       |
| `subnet_private_ids`            | `list(string)` | ✅          | Приватні підмережі (якщо `publicly_accessible = false`) |
| `subnet_public_ids`             | `list(string)` | ✅          | Публічні підмережі (якщо `publicly_accessible = true`)  |
| `publicly_accessible`           | `bool`         | ✅          | Чи буде БД доступною ззовні                             |
| `multi_az`                      | `bool`         | ✅          | Розгортання у кількох зонах доступності                 |
| `backup_retention_period`       | `number`       | ✅          | Тривалість збереження резервних копій (у днях)          |
| `parameters`                    | `map(string)`  | ❌          | Додаткові параметри до Parameter Group                  |
| `vpc_id`                        | `string`       | ✅          | ID VPC, у якій буде розміщена БД                        |
| `tags`                          | `map(string)`  | ❌          | Користувацькі теги для всіх ресурсів                    |

# Як змінити тип бази даних, рушій, клас інстансу:

! Змінити з RDS на Aurora:

use_aurora = true
engine = "aurora-postgresql"
engine_version = "17.2"
parameter_group_family_aurora = "aurora-postgresql13"

Примітка: При use_aurora = true створюється:
• 1 кластер (aws_rds_cluster.aurora)
• 1 writer + aurora_instance_count reader-реплік
• окрема Parameter Group для кластеру

# Outputs

Output Опис
db_instance_endpoint DNS ім’я інстансу (host без порту)
db_instance_writer_endpoint Якщо Aurora — DNS endpoint writer’а
db_instance_name Ім’я бази даних
db_instance_username Ім’я користувача
db_instance_password Пароль (sensitive)
db_instance_port Порт (стандартно 5432)
security_group_id ID створеного SG

# Додатково

    •	Якщо publicly_accessible = true, RDS буде доступною з Інтернету (відкритий SG, CIDR 0.0.0.0/0) — не рекомендується для продакшн.
    •	Якщо використовується Aurora, обовʼязково задати engine_cluster, parameter_group_family_aurora.
    •	Ви можете кастомізувати параметри БД через parameters = {}.

# Підключення до БД із застосунку:

POSTGRES_HOST: ${module.rds.db_instance_endpoint}
POSTGRES_PORT: ${module.rds.db_instance_port}
POSTGRES_DB: ${module.rds.db_instance_name}
POSTGRES_USER: ${module.rds.db_instance_username}
POSTGRES_PASSWORD: ${module.rds.db_instance_password}

# Підключення Prometheus & Grafana

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm install prometheus prometheus-community/prometheus --namespace monitoring

kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

```
helm repo add grafana https://grafana.github.io/helm-charts

helm install grafana grafana/grafana --namespace monitoring --create-namespace --set adminPassword=admin123

```

!!! Отримати пароль ~ kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Після авторизації

Відкрийте налаштування джерел даних

1. Зліва натисніть на іконку шестерні (⚙️ Settings) — це розділ «Configuration».

2. Далі — оберіть «Data sources».

3. У правому верхньому куті натисніть «Add data source».

4. Знайдіть і натисніть Prometheus.

5. Натисніть кнопку «Add new data source»

6. В connection додайте - http://prometheus-server.monitoring.svc:80

7. Натисніть кнопку «Save & test»

# Створити дашборд можна наступним чином

1. У лівому меню оберіть «Dashboards».

2. Натисніть «Create dashboard».

3. Натискаємо «Add visualization».

4. Вибираємо «Prometheus».

! Після цього можете вибирати необхідні метрики, стилі та інші значення для відображенння необхідної інформації.
