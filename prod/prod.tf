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

resource "aws_instance" "prod_web_1" {
   # ami  = "ami-0915bcb5fa77e4892"

    ami           = "ami-012c7314a6f9b09d6"
    instance_type = "t2.nano"
    subnet_id     = aws_subnet.prod_az1.id
    
    vpc_security_group_ids = [
        aws_security_group.prod_web.id
    ]

    tags = {
        Name = "tf-web-test1"
        "Terraform" : "true"
    }
}

resource "aws_instance" "prod_web_2" {
   # ami  = "ami-0915bcb5fa77e4892"

    ami           = "ami-012c7314a6f9b09d6"
    instance_type = "t2.nano"
    subnet_id     = aws_subnet.prod_az2.id
    
    vpc_security_group_ids = [
        aws_security_group.prod_web.id
    ]

    tags = {
        Name = "tf-web-test2"
        "Terraform" : "true"
    }
}

resource "aws_elb" "prod_web" {
    name            = "prod-web-lb"
    cross_zone_load_balancing = true
    instances       = [aws_instance.prod_web_1.id,aws_instance.prod_web_2.id]
    subnets         = [aws_subnet.prod_az1.id, aws_subnet.prod_az2.id]
    security_groups = [aws_security_group.prod_web.id]

    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
    health_check {
        healthy_threshold   = 5
        unhealthy_threshold = 5
        target              = "TCP:443"
        interval            = 30
        timeout             = 10
    }
}

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_eip_association" "web_1" {
  instance_id   = aws_instance.prod_web_1.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "web_2" {
  vpc = true
}

resource "aws_eip_association" "web_2" {
  instance_id   = aws_instance.prod_web_2.id
  allocation_id = aws_eip.web_2.id
}
# ami : ami-012c7314a6f9b09d6 - nginx certified by bitnami