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

variable "tags" {
  description = "Allow tests to set tags"
  type        = map(string)
  default = {
    project_code = "PO-1234"
    project_name = "EXAMPLE"
    github_repo  = "terraform-aws-eks"
    owner        = "platforms"
    environment  = "shared"
  }
}
