resource "aws_s3_bucket" "prod_s3_test" {
    bucket = "s3-tf-test-amit-05232021"
    acl    = "private"
}

resource "aws_default_vpc" "default" {}


