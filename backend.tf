terraform {
  backend "s3" {
    bucket  = "my-terraform-state-302263077442-us-east-1-an"
    key     = "env"
    region  = "us-east-1"
    encrypt = true
  }
}