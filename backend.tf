resource "aws_s3_bucket" "terraform_state_002" {
  bucket = "bosun-enoch-tfstate-002"

  tags = {
    Name = "terraform-state"
    Env  = "test"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state_002.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state_002.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks_002" {
  name         = "terraform-locks-002"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "bosun-enoch-tfstate-002"
    key            = "project18/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-002"
    encrypt        = true
  }
}