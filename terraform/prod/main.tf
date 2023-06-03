# Image to be used by app EC2
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# To get my cloud9 instance public ip
data "http" "icanhazip" {
  url = "https://ipv4.icanhazip.com/"
}

# To get availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Get existing default vpc metadata. Change the VPC id in inputs.tf
data "aws_vpc" "default" {
  default = true
}

# Create a public subnet to host app
resource "aws_subnet" "default_public" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = cidrsubnet(data.aws_vpc.default.cidr_block, 4, 1)
  availability_zone = data.aws_availability_zones.default.names[0]
}

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.env}-${var.prefix}-app-sg"
  description = "app-security-group"
  vpc_id      = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules

    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    "Name" = "${var.env}-${var.prefix}-app-sg"
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = "${var.env}-app-key"
  public_key = file("${var.env}.pub")
}

# EC2 server
resource "aws_instance" "app" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = aws_subnet.default_public.id
  security_groups             = [aws_security_group.aws_security_group.app_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.app.name

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name" = "${var.env}-${var.prefix}-app-${var.owner}"
  }
}