variable "env" {
  type        = string
  default     = "prod"
  description = "Deployment Environment"
}

variable "prefix" {
  type        = string
  default     = "assignment1"
  description = "Label"
}

variable "owner" {
  type        = string
  default     = "ClairolZam"
  description = "My name"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "Type of the instance"
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
  description = "Ingress rules for the Security Group"
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "outbound rules"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  description = "Egress rules for the Security Group"
}