# Terraform Infrastructure Project — Lesson 5

Цей проєкт створює базову інфраструктуру в AWS за допомогою Terraform. Інфраструктура включає:

- S3-бакет для зберігання стану (`terraform.tfstate`) та DynamoDB для блокування,
- VPC із публічними і приватними підмережами,
- ECR-репозиторій для зберігання Docker-образів.

---

## 📁 Структура проєкту

```
lesson-5/
│
├── main.tf # Головний файл для підключення модулів
├── backend.tf # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf # Загальне виведення ресурсів
│
├── modules/ # Каталог з усіма модулями
│ │
│ ├── s3-backend/ # Модуль для S3 та DynamoDB
│ │ ├── s3.tf # Створення S3-бакета
│ │ ├── dynamodb.tf # Створення DynamoDB
│ │ ├── variables.tf # Змінні для S3
│ │ └── outputs.tf # Виведення інформації про S3 та DynamoDB
│ │
│ ├── vpc/ # Модуль для VPC
│ │ ├── vpc.tf # Створення VPC, підмереж, Internet Gateway
│ │ ├── routes.tf # Налаштування маршрутизації
│ │ ├── variables.tf # Змінні для VPC
│ │ └── outputs.tf # Виведення інформації про VPC
│ │
│ └── ecr/ # Модуль для ECR
│ ├── ecr.tf # Створення ECR репозиторію
│ ├── variables.tf # Змінні для ECR
│ └── outputs.tf # Виведення URL репозиторію ECR
│
└── README.md # Документація проєкту
```

## 🚀 Команди для запуску

```bash
# 1. Ініціалізація Terraform-проєкту
terraform init

# 2. Перевірка, що буде створено
terraform plan

# 3. Створення інфраструктури
terraform apply

# 4. Видалення всієї інфраструктури
terraform destroy
```

📦 Опис модулів

📁 modules/s3-backend

Модуль створює:

    • S3-бакет для зберігання terraform.tfstate
    • Увімкнене versioning
    • DynamoDB-таблицю для state locking

📁 modules/vpc

Модуль створює:

    • VPC з вказаним CIDR-блоком
    • Публічні та приватні підмережі у 3-х зонах доступності
    • Internet Gateway, NAT Gateway та Route Tables

📁 modules/ecr

Модуль створює:

    • Amazon ECR репозиторій з імʼям, переданим у ecr_name
    • Налаштовує сканування образів на наявність вразливостей (якщо scan_on_push = true)
    • Повертає URL, ARN та назву репозиторію через outputs

⸻

📋 ! Вимоги !

    • AWS CLI налаштований (aws configure)
    • Terraform ≥ 1.3
    • Права доступу до:
    • s3
    • dynamodb
    • ecr

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

⸻

🧩 Outputs

Після terraform apply будуть виведені:

    • s3_bucket_name
    • dynamodb_table_name
    • ecr_repository_name
    • ecr_repository_url
    • ecr_repository_arn
