terraform {
  backend "s3" {
    bucket         = "s3-bucket-ln7"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}