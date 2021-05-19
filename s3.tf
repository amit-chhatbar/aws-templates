terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
provider "aws" {
    profile = "default"
    region  = "us-east-2"
}

resource "aws_s3_bucket" "s3_friendly_name" {
    bucket = "s3-tf-test-amit-05192021"
    acl    = "private"
}
