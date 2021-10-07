provider "aws" {
    profile = "default"
    region  = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "tfstat-bucket"
    key    = "terraform-state"
    region = "us-east-2"
    encrypt = true
  }
}

resource "aws_s3_bucket" "tf_test1" {
    bucket = "s3-tf-test-amit-100321"
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

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.prod_vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_subnet" "prod_az1" {
    vpc_id = aws_vpc.prod_vpc.id
    availability_zone = "us-east-2a"
    cidr_block = "152.152.1.0/24"

    tags = {
        "Terraform" : "true"
    }
}

# Associate Management route table to Management subnet
resource "aws_route_table_association" "main-routetable-association" {
    subnet_id = aws_subnet.prod_az1.id
    route_table_id = aws_route_table.main.id
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
    ingress {
        from_port   = 22  # from-to allows you to give range
        to_port     = 22
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

#Instance Role
resource "aws_iam_role" "test_role" {
  name = "test-ssm-ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#Instance Profile
resource "aws_iam_instance_profile" "test_profile" {
  name = "test-ssm-ec2"
  role = "${aws_iam_role.test_role.id}"
}

#Attach Policies to Instance Role
resource "aws_iam_policy_attachment" "test_attach1" {
  name       = "test-attachment"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "test_attach2" {
  name       = "test-attachment"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy_attachment" "test_attach3" {
  name       = "test-attachment"
  roles      = [aws_iam_role.test_role.id]
  policy_arn = "arn:aws:iam::396443123216:policy/s3terraformbackend"
}

resource "aws_instance" "prod_web" {
   # ami  = "ami-00dfe2c7ce89a450b"

    ami           = "ami-070823f562819353d"
    instance_type = "t2.nano"
    key_name="johnyc"
    user_data = "${file("/Users/amitchhatbar/Downloads/repo/aws-templates/ec2/install-ssm2.sh")}"
    subnet_id     = aws_subnet.prod_az1.id
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.id}"
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
