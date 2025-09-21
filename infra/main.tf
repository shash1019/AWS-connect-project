terraform {
  backend "s3" {}  # values injected by -backend-config in your workflow
}

provider "aws" {
  region = var.aws_region
}

# --- Data sources ---
data "aws_ami" "amzn2" {
  owners      = ["137112412989"] # Amazon
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# --- Locals ---
locals {
  demo_subnet_id = data.aws_subnets.default.ids[0]
}

# --- Resources ---
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

resource "aws_instance" "demo" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = "t3.micro"
  subnet_id                   = local.demo_subnet_id
  vpc_security_group_ids      = [aws_security_group.demo.id]
  associate_public_ip_address = true

  tags = { Name = "tf-demo-ec2" }
}