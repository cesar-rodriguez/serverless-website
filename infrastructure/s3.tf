### S3 Bucket hosting website
variable "bucket_name" {}
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name = var.bucket_name
  }
}

output "index_html" {
  value = "http://${aws_s3_bucket.b.bucket_domain_name}/index.html"
}

/*
resource "aws_s3_bucket_policy" "b" {
  bucket = aws_s3_bucket.b.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}/*"
            ]
        }
    ]
}
POLICY
}
*/
resource "aws_s3_bucket_object" "html" {
  bucket       = aws_s3_bucket.b.bucket
  key          = "index.html"
  source       = "${path.module}/static/index.html"
  acl          = "private"
  content_type = "text/html"
  etag         = filemd5("${path.module}/static/index.html")
}

resource "aws_s3_bucket_object" "logo" {
  bucket       = aws_s3_bucket.b.bucket
  key          = "/static/terrascan_logo.png"
  source       = "${path.module}/static/terrascan_logo.png"
  acl          = "private"
  content_type = "image/png"
  etag         = filemd5("${path.module}/static/terrascan_logo.png")
}

resource "aws_s3_bucket_object" "logo_dark" {
  bucket       = aws_s3_bucket.b.bucket
  key          = "/static/terrascan_logo_dark.png"
  source       = "${path.module}/static/terrascan_logo_dark.png"
  acl          = "private"
  content_type = "image/png"
  etag         = filemd5("${path.module}/static/terrascan_logo_dark.png")
}
