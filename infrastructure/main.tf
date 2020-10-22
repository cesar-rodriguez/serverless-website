### Variables
variable "aws_region" {}
variable "s3_staging_bucket" {}
variable "lambda_version" {}
variable "name" {}
variable "subnet" {}
variable "vpc" {}
variable "security_group" {}

### AWS Provider
provider "aws" {
  region = var.aws_region
}

# Used to get Account ID
data "aws_caller_identity" "current" {}
