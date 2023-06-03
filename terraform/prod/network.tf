# To get my cloud9 instance public ip
data "http" "icanhazip" {
  url = "https://ipv4.icanhazip.com/"
}

# Get existing default vpc metadata. Change the VPC id in inputs.tf
data "aws_vpc" "default" {
  default = true
}

# Get existing subnet
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
