### Variables
variable "aws_region" {}
variable "s3_staging_bucket" {}
variable "lambda_version" {}
variable "name" {}


### AWS Provider
provider "aws" {
  region = var.aws_region
}
