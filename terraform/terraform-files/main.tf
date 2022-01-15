terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.35"
    }
  }
}

data "template_file" "user_data" {
  template = file("ssh-web-app.yaml")
}

provider "aws" {
  profile = "default"
  region = "us-east-2"
  shared_credentials_file = "./credentials-ynov"
}

resource "aws_instance" "Fabien" {
  ami = "ami-0d97ef13c06b05a19"
  instance_type = "t2.micro"
  user_data = data.template_file.user_data.rendered
  key_name = "id_rsa"
  vpc_security_group_ids = [aws_security_group.sg-Fabien.id]
  associate_public_ip_address = true

  tags = {
    Name = "Augros-Fabien-APP"
    Groups = "app"
    Owner = "fabien.augros@ynov.com"
  }
}

resource "aws_key_pair" "id_rsa" {
  public_key = file("./ssh/id_rsa.pub")
  key_name = "id_rsa.pub"
}

resource "aws_security_group" "sg-Fabien" {

  vpc_id = "vpc-a00c78cb"

  ingress {
    description = "SSH"
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    protocol  = "tcp"
    to_port   = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.Fabien.*.id
}

output "public_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.Fabien.*.public_ip
}

output userdata {
  value = "\n${data.template_file.user_data.rendered}"
}