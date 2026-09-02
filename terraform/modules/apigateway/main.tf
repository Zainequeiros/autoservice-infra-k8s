data "aws_elb_service_account" "main" {
  region = var.aws_region
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${var.project_name}-${var.environment}-alb-access-logs"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-access-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowELBAccessLogs"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.alb_logs.id}/*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-${var.environment}-api-gateway-logs"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "alb" {
  domain_name       = "${var.project_name}-${var.environment}.example.com"
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-cert"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "ingress" {
  name               = "${var.project_name}-${var.environment}-ingress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ingress_security_group_id]
  subnets            = var.public_subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ingress"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "cluster" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    port                = 443
    path                = "/healthz"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_autoscaling_attachment" "cluster" {
  autoscaling_group_name = var.node_group_autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.cluster.arn
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ingress.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cluster.arn
  }
}

resource "aws_apigatewayv2_vpc_link" "cluster" {
  name               = "${var.project_name}-${var.environment}-vpc-link"
  security_group_ids = [var.ingress_security_group_id]
  subnet_ids         = var.public_subnet_ids
}

resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-${var.environment}-gateway"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.project_name}-${var.environment}-gateway"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "cluster" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = "https://${aws_lb.ingress.dns_name}"
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.cluster.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.cluster.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      sourceIp         = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      protocol         = "$context.protocol"
      httpMethod       = "$context.httpMethod"
      routeKey         = "$context.routeKey"
      status           = "$context.status"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-stage"
    Project     = var.project_name
    Environment = var.environment
  }
}
