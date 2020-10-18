### Variables
variable "aws_region" {}
variable "s3_staging_bucket" {}
variable "lambda_version" {}


### AWS Provider
provider "aws" {
  region = var.aws_region
}


## Lambda
resource "aws_lambda_function" "serverless_web" {
  function_name = "ServerlessWeb"

  s3_bucket = var.s3_staging_bucket
  s3_key    = "v${var.lambda_version}/lambda.zip"

  handler = "main.lambda_handler"
  runtime = "python3.8"

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}


### IAM role for lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_web_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "serverless_web_lambda"
  path        = "/"
  description = "Policy for lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "s3:List*",
        "s3:GetObject*"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.policy.arn
}

### Policy granting API Gateway access to the lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_web.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_apigatewayv2_api.web.execution_arn}/*/*"
}
