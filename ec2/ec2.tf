provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

resource "aws_s3_bucket" "tf_test1" {
    bucket = "s3-tf-test-amit-05252021"
    acl    = "private"
}

resource "aws_vpc" "prod_vpc" {
    cidr_block = "152.152.0.0/16"
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
resource "aws_subnet" "prod_az1" {
    vpc_id = aws_vpc.prod_vpc.id
    availability_zone = "us-east-1a"
    cidr_block = "152.152.1.0/24"

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
    subnet_id     = aws_subnet.prod_az1.id
    
    vpc_security_group_ids = [
        aws_security_group.prod_web.id
    ]

    tags = {
        Name = "tf-web-test"
        "Terraform" : "true"
    }
}

resource "aws_eip" "web" {
  vpc = true
}

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.prod_web.id
  allocation_id = aws_eip.web.id
} 
