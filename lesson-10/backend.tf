terraform {
  backend "s3" {
    bucket         = "s3-bucket-ja" # <-- Поміняй тут на імʼя створеного бакету
    key            = "lesson-10/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}