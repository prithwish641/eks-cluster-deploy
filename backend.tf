terraform {
  backend "s3" {
    bucket = "aiops-logs-bucket"
    key    = "tfstatefolder/terraform.tfstate"
    region = "us-east-1"
  }
}
