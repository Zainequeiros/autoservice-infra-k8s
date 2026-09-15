data "aws_elb_service_account" "main" {
  region = var.aws_region
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

resource "aws_lb" "ingress" {
  name               = "${var.project_name}-${var.environment}-ingress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.ingress_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-ingress"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "cluster" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    port                = "80"
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

# AQUI ESTÁ O AJUSTE: integration_uri aponta para aws_lb_listener.http.arn
resource "aws_apigatewayv2_integration" "cluster" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = aws_lb_listener.http.arn
  integration_method     = "ANY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.cluster.id
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_integration" "auth_lambda" {
  count = var.auth_lambda_function_name != "" && var.auth_lambda_invoke_arn != "" ? 1 : 0

  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.auth_lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_cpf" {
  count = var.auth_lambda_function_name != "" && var.auth_lambda_invoke_arn != "" ? 1 : 0

  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /auth/cpf"
  target    = "integrations/${aws_apigatewayv2_integration.auth_lambda[0].id}"
}

resource "aws_lambda_permission" "auth_cpf_apigw" {
  count = var.auth_lambda_function_name != "" && var.auth_lambda_invoke_arn != "" ? 1 : 0

  statement_id  = "AllowAPIGatewayInvokeCpfAuth"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*/auth/cpf"
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