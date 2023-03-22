variable "aws_region" {
  description = "Allow tests to set AWS Region"
  type        = string
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "Allow tests to set cluster name"
  type        = string
  default     = "main-example"
}
