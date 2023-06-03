provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Name     = "Clairol Zam Salazar"
      Course   = "CLO835"
      Activity = "Assignment1"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "assignment1-czcs"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}