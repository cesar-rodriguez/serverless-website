/*
Docs:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api

Security issues to look at:
- cors_configuration - (Optional) The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs.
Check for allow_origins [*]

*/
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
    # allow_origins     = ["*"]
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

/*
Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage

Security issues to looks for:
- access_log_settings - (Optional) Settings for logging access in this stage. Use the aws_api_gateway_account resource to configure permissions for CloudWatch Logging.
*/
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.web.id
  name        = "$default"
  auto_deploy = "true"

  access_log_settings {
    destination_arn = ""
    format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

/*
Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group

Security issues to look for:
- kms_key_id - (Optional) The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.
*/
resource "aws_cloudwatch_log_group" "log" {
  name = "${var.name}-logs"
}

output "invoke_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}
