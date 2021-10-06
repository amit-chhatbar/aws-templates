provider "aws" {
    profile = "default"
    region  = "us-east-1"
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