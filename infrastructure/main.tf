### Variables
variable "aws_region" {}

### AWS Provider
provider "aws" {
  region = var.aws_region
}

# Used to get Account ID
data "aws_caller_identity" "current" {}
