
provider "aws" {
  region = "ap-south-1"
}

# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "surge-ready-vpc"
  }
}

# Public subnet - Availability Zone A
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "surge-ready-public-a"
  }
}

# Private subnet - Availability Zone A
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "surge-ready-private-a"
  }
}

# Public subnet - Availability Zone B
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "surge-ready-public-b"
  }
}

# Private subnet - Availability Zone B
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "surge-ready-private-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "surge-ready-igw"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "surge-ready-public-rt"
  }
}

# Associate public subnet A with the public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Associate public subnet B with the public route table
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "surge-ready-alb-sg"
  description = "Allow HTTP traffic to load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "surge-ready-alb-sg"
  }
}

# Security group for ECS application
resource "aws_security_group" "app" {
  name        = "surge-ready-app-sg"
  description = "Allow traffic only from the load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "surge-ready-app-sg"
  }
}

# Amazon ECR repository
resource "aws_ecr_repository" "app" {
  name                 = "surge-ready-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "surge-ready-app"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "surge-ready-cluster"

  tags = {
    Name = "surge-ready-cluster"
  }
}

# IAM role that allows ECS tasks to access AWS services
resource "aws_iam_role" "ecs_task_execution" {
  name = "surge-ready-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWS-managed ECS task execution permissions
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for SurgeReady
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/surge-ready"
  retention_in_days = 7

  tags = {
    Name = "surge-ready-logs"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "surge-ready-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "surge-ready-container"
      image     = "965984381610.dkr.ecr.ap-south-1.amazonaws.com/surge-ready-app:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = "ap-south-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "surge-ready-task"
  }
}

# Target Group for SurgeReady ECS application
resource "aws_lb_target_group" "app" {
  name        = "surge-ready-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "surge-ready-target-group"
  }
}

# Application Load Balancer
resource "aws_lb" "app" {
  name               = "surge-ready-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]

  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]

  tags = {
    Name = "surge-ready-alb"
  }
}

# ALB Listener
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Service
resource "aws_ecs_service" "app" {

  name            = "surge-ready-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]

    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "surge-ready-container"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [
    aws_lb_listener.app,
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = {
    Name = "surge-ready-service"
  }
}

# CloudWatch Memory Alarm
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "surge-ready-high-memory"
  alarm_description   = "Triggers when ECS service memory utilization exceeds 70%."
  alarm_actions       = [aws_sns_topic.alerts.arn]
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "MemoryUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"
  threshold          = 70

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  treat_missing_data = "notBreaching"
}

# CloudWatch CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "surge-ready-high-cpu"
  alarm_description   = "Triggers when ECS service CPU utilization exceeds 70%."
  alarm_actions       = [aws_sns_topic.alerts.arn]
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2
  metric_name        = "CPUUtilization"
  namespace          = "AWS/ECS"
  period             = 60
  statistic          = "Average"
  threshold          = 70

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  treat_missing_data = "notBreaching"
}

# SNS Topic
resource "aws_sns_topic" "alerts" {
  name = "surge-ready-alerts"

  tags = {
    Name = "surge-ready-alerts"
  }
}

# SNS Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "ashishvitta458@gmail.com"
}

# ECS Service Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ECS CPU Target Tracking Scaling Policy
resource "aws_appautoscaling_policy" "ecs_cpu_scaling" {
  name               = "surge-ready-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 60
    scale_in_cooldown  = 60
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}