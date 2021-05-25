provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

resource "aws_s3_bucket" "tf_test1" {
    bucket = "s3-tf-test-amit-05252021"
    acl    = "private"
}
resource "aws_default_vpc" "default" {}

resource "aws_security_group" "prod_web" {
    name = "prod_web"
    description = "Allow standard http and https ports inbound and everything outbund"

    ingress {
        from_port   = 80  # from-to allows you to give range
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 443  # from-to allows you to give range
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1" # alllows all ptrotocol
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_instance" "prod_web" {
   # ami  = "ami-0915bcb5fa77e4892"
    ami           = "ami-012c7314a6f9b09d6"
    instance_type = "t2.nano"

    vpc_security_group_ids = [
        aws_security_group.prod_web.id
    ]

    tags = {
        Name = "tf-web-test1"
        "Terraform" : "true"
    }
}

resource "aws_eip" "prod_web" {
    instance = aws_instance.prod_web.id

    tags = {
        "Terraform" : "true"
    }
}
# ami : ami-012c7314a6f9b09d6 - nginx certified by bitnami