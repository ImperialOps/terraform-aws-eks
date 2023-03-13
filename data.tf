################################################################################
# AWS
################################################################################

data "aws_caller_identity" "current" {}

data "aws_kms_key" "aws_ebs" {
  key_id = "alias/aws/ebs"
}

data "aws_ecrpublic_authorization_token" "virginia" {
  provider = aws.virginia
}
