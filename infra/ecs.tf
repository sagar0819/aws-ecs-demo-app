# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "ecs-demo-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "ecs-demo-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = []
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "backend" {
  name            = "ecs-demo-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "backend"
    container_port   = 8000
  }
  depends_on = [aws_lb_listener.app_listener]
}

# Application Load Balancer for ECS Service
resource "aws_lb" "app_alb" {
  name                       = "ecs-demo-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.ecs_security_group_id]
  subnets                    = var.ecs_subnet_ids
  drop_invalid_header_fields = true
}

# ALB Listener for ECS Service
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ALB Target Group for ECS Service
resource "aws_lb_target_group" "app_tg" {
  name     = "ecs-demo-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
