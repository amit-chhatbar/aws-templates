provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

resource "aws_s3_bucket" "tf_test1" {
    bucket = "s3-tf-test-amit-05252021"
    acl    = "private"
}

resource "aws_vpc" "prod_vpc" {
    cidr_block = "150.150.0.0/16"
    tags = {
        Name = "prod_vpc"
        "Terraform" : "true"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.prod_vpc.id
    tags = {
        Name = "igw"
    }
}

resource "aws_route_table" "prod_web" {
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "prod_az1" {
    vpc_id = aws_vpc.prod_vpc.id
    availability_zone = "us-east-1a"
    cidr_block = "150.150.1.0/24"

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_subnet" "prod_az2" {
    vpc_id = aws_vpc.prod_vpc.id
    availability_zone = "us-east-1b"
    cidr_block = "150.150.2.0/24"

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_security_group" "prod_web" {
    name = "prod_web"
    description = "Allow standard http and https ports inbound and everything outbund"
    vpc_id      = aws_vpc.prod_vpc.id
    ingress {
        from_port   = 80  # from-to allows you to give range
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.web_whitelist
    }
    ingress {
        from_port   = 443  # from-to allows you to give range
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.web_whitelist
    }
    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1" # alllows all ptrotocol
        cidr_blocks = var.web_whitelist
    }

    tags = {
        "Terraform" : "true"
    }
}

module "elb-ec2" {
    source = "./modules/elb-ec2"

    web_image_id            = var.web_image_id
    web_instance_type       = var.web_instance_type
    web_desired_capacity    = var.web_desired_capacity
    web_max_size            = var.web_max_size
    web_min_size            = var.web_min_size
    subnets                 = [aws_subnet.prod_az1.id,aws_subnet.prod_az2.id]
    security_groups         = [aws_security_group.prod_web.id]
    app                     = "prod"
}
