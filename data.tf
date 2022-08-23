################################################################################
# AWS
################################################################################

data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_kms_key" "aws_ebs" {
  key_id = "alias/aws/ebs"
}