output "api_gateway_url" {
  value = aws_apigatewayv2_api.main.api_endpoint
}

output "load_balancer_dns_name" {
  value = aws_lb.ingress.dns_name
}
