### API HTTP Gateway
resource "aws_apigatewayv2_api" "web" {
  name          = "web"
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = false
    allow_headers     = []
    allow_methods     = ["GET"]
    allow_origins     = []
    expose_headers    = []
    max_age           = 3600
  }
}

resource "aws_apigatewayv2_route" "lambda" {
  api_id    = aws_apigatewayv2_api.web.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.web.id
  integration_type       = "AWS_PROXY"
  payload_format_version = "2.0"
  timeout_milliseconds   = 29000
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.serverless_web.invoke_arn
}

### API Gateway stage with access logs
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.web.id
  name        = "$default"
  auto_deploy = "true"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log.arn
    format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}


# Log group for access logs
resource "aws_cloudwatch_log_group" "log" {
  name       = "${var.name}"
  kms_key_id = aws_kms_key.key.arn
}

output "cloudwatch_console" {
  value = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${var.name}"
}

output "invoke_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
