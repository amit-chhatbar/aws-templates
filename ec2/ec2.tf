provider "aws" {
    profile = "default"
    region  = "us-east-2"
}

resource "aws_instance" "web"
    ami  = "ami-0742b4e673072066f"
    Name = "Tf-test-ec2" 
}
