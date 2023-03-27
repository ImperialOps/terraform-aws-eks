################################################################################
# GLOBAL
################################################################################

variable "create" {
  description = "Controls if EKS resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# EKS
################################################################################

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.24"
}

variable "cluster_endpoint_private_access" {
  description = "Expose Kubernetes API in private subnets"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Expose Kubernetes API publicly"
  type        = bool
  default     = false
}

################################################################################
# NETWORKING
################################################################################

variable "vpc_id" {
  description = "ID of vpc to deploy cluster into"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane"
  type        = list(string)
  default     = []
}

variable "subnet_account_id" {
  description = "Account ID of where the subnets Karpenter will utilize resides. Used when subnets are shared from another account"
  type        = string
  default     = ""
}

################################################################################
# KARPENTER
################################################################################

variable "create_karpenter" {
  description = "Controls whether to deploy the a Karpenter"
  type        = bool
  default     = true
}

variable "create_karpenter_provisioner" {
  description = "Controls whether to deploy the a default Karpenter provisioner"
  type        = bool
  default     = true
}

variable "karpenter_node_volume_size" {
  description = "Volume size of nodes in the cluster in GB"
  type        = number
  default     = 40
}

variable "karpenter_provisioner_max_cpu" {
  description = "The max number of cpu's the default provisioner will deploy"
  type        = number
  default     = 40
}

variable "karpenter_provisioner_max_memory" {
  description = "The max memory the default provisioner will deploy in Gi"
  type        = number
  default     = 80
}

variable "karpenter_tag_key" {
  description = "Tag key (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner. Used when creating multiple cluster in a single VPC"
  type        = string
  default     = "karpenter.sh/discovery"
}

################################################################################
# CROSSPLANE
################################################################################

variable "create_crossplane" {
  description = "Controls whether to deploy CrossPlane and the AWS provider with Admin access"
  type        = bool
  default     = true
}

################################################################################
# IAM
################################################################################

variable "create_spot_service_linked_role" {
  description = "Controls whether or not to create the spot.amazonaws.com service linked role"
  type        = bool
  default     = true
}
