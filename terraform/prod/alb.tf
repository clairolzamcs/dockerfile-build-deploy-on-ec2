resource "aws_lb" "app" {
  name               = "${var.env}-${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = [for subnet in data.aws_subnets.default.ids : subnet]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app" {
  name     = "${var.env}-${var.prefix}-tg"
  port     = 80
  protocol = "HTTP"
  ip_address_type = "ipv4"
  target_type = "ip"
  
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group_attachment" "blue" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.private_ip
  port             = 8081
}

resource "aws_lb_target_group_attachment" "pink" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.private_ip
  port             = 8082
}

resource "aws_lb_target_group_attachment" "lime" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.private_ip
  port             = 8083
}