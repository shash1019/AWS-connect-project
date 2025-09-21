terraform {
  backend "s3" {}  # values injected by -backend-config in your workflow
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

# Latest Amazon Linux 2 AMI in ap-southeast-2 (owner = Amazon)
data "aws_ami" "amzn2" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group in default VPC (no inbound; allow all outbound)
resource "aws_security_group" "demo" {
  name        = "demo-sg"
  description = "Demo SG (egress only)"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "demo-sg" }
}

# Default VPC + a default subnet (any one)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Pick first subnet just for the demo
locals {
  demo_subnet_id = data.aws_subnets.default.ids[0]
}

# Tiny EC2 instance (no key pair, no inbound SSH)
resource "aws_instance" "demo" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = "t3.micro"
  subnet_id                   = local.demo_subnet_id
  vpc_security_group_ids      = [aws_security_group.demo.id]
  associate_public_ip_address = true

  tags = { Name = "tf-demo-ec2" }
}

output "instance_id"  { value = aws_instance.demo.id }
output "public_ip"    { value = aws_instance.demo.public_ip }
output "ami_id"       { value = data.aws_ami.amzn2.id }