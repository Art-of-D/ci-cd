terraform {
  backend "s3" {
    bucket         = "s3-bucket-ln7" # <-- Поміняй тут на імʼя створеного бакету
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}