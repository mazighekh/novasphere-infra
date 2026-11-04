# --- Security Groups chaines ---------------------------------------------

# ALB : le seul point d'entree depuis Internet
resource "aws_security_group" "alb" {
  name        = "novasphere-${var.environment}-alb"
  description = "HTTP public vers ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instances : le port 80 n'accepte QUE le Security Group de ALB (reference, pas de CIDR)
resource "aws_security_group" "web" {
  name        = "novasphere-${var.environment}-web"
  description = "HTTP depuis ALB uniquement"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP depuis ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Launch Template : le moule des instances ----------------------------

resource "aws_launch_template" "web" {
  name_prefix   = "novasphere-${var.environment}-"
  image_id      = data.aws_ami.debian.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = base64encode(file("${path.module}/bootstrap.sh"))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "novasphere-${var.environment}-web" }
  }
}

# --- Application Load Balancer -------------------------------------------

resource "aws_lb" "web" {
  name               = "novasphere-${var.environment}"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "web" {
  name     = "novasphere-${var.environment}-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  # Retrait rapide d'une instance qui quitte le groupe (300 s par defaut)
  deregistration_delay = 30

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 15 # 30 s par defaut : on accelere pour le TP
    healthy_threshold   = 2  # 2 reponses OK pour passer "healthy"
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# --- Auto Scaling Group ---------------------------------------------------

resource "aws_autoscaling_group" "web" {
  name                      = "novasphere-${var.environment}-web"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = module.vpc.public_subnets
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180 # temps laisse a bootstrap.sh pour installer nginx

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "novasphere-${var.environment}-web"
    propagate_at_launch = true
  }
}
