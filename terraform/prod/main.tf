# Image to be used by app EC2
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# App Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.env}-${var.prefix}-app-sg"
  description = "app-security-group"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description = "allow all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from private IP of Cloud9 machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }

  egress {
    description = "outbound rules"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    "Name" = "${var.env}-${var.prefix}-app-sg"
  }
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = "${var.env}-app-key"
  public_key = file("${var.env}-key.pub")
}

# EC2 server
resource "aws_instance" "app" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.web_key.key_name
  subnet_id                   = data.aws_subnets.default.ids[0]
  security_groups             = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = data.aws_iam_instance_profile.lab_profile.name

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    service docker start
    usermod -a -G docker ec2-user
    sudo yum install mysql
  EOF

  tags = {
    "Name" = "${var.env}-${var.prefix}-app-${var.owner}"
  }
}