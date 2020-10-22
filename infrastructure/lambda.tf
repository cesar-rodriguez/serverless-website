### Lambda function
resource "aws_lambda_function" "serverless_web" {
  function_name = var.name

  s3_bucket = var.s3_staging_bucket
  s3_key    = "v${var.lambda_version}/lambda.zip"

  handler = "main.lambda_handler"
  runtime = "python3.8"

  role        = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}

output "lambda_invoke_cmd" {
  value = "aws lambda invoke --function-name ${var.name} --region ${var.aws_region} response.ignore"
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
