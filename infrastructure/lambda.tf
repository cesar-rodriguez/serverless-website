/*
Docs:
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function

Security issues to look for:
- vpc_config - (Optional) Provide this to allow your function to access your VPC. Fields documented below. See Lambda in VPC

- kms_key_arn - (Optional) Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key. If this configuration is provided when environment variables are not in use, the AWS Lambda API does not save this configuration and Terraform will show a perpetual difference of adding the key. To fix the perpetual difference, remove this configuration.
*/
resource "aws_lambda_function" "serverless_web" {
  function_name = var.name

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
  name = var.name

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
  name        = var.name
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

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.policy.arn
}

### Policy granting API Gateway access to the lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_web.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.web.execution_arn}/*/*"
}
