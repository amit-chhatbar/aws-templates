provider "aws" {
    profile = "default"
    region  = "us-east-2"
}

resource "s3_bucket" "s3_friendly_name" {
    bucket = "s3-tf-test-amit-05192021"
}
