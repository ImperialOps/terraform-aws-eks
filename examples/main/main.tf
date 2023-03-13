################################################################################
# GLOBAL LOCALS
################################################################################

locals {
  cluster_name    = var.cluster_name
  cluster_version = "1.25"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
}

################################################################################
# EKS
################################################################################

module "eks" {
  source = "../.."

  providers = {
    aws          = aws
    aws.virginia = aws.virginia
  }

  create          = true
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets
  subnet_account_id        = data.aws_caller_identity.current.account_id

  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true
  create_spot_service_linked_role = false

  create_karpenter                 = true
  create_karpenter_provisioner     = true
  karpenter_provisioner_max_cpu    = 40
  karpenter_provisioner_max_memory = 80
  karpenter_node_volume_size       = 40
  karpenter_tag_key                = "karpenter.sh/discovery/${local.cluster_name}"

  tags = var.tags
}

################################################################################
# SUPPORTING RESOURCES
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.cluster_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for i, v in local.azs : cidrsubnet(local.vpc_cidr, 4, i)]
  public_subnets  = [for i, v in local.azs : cidrsubnet(local.vpc_cidr, 8, i + 48)]
  intra_subnets   = [for i, v in local.azs : cidrsubnet(local.vpc_cidr, 8, i + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"              = 1
    "karpenter.sh/discovery/${local.cluster_name}" = local.cluster_name
  }

  tags = var.tags
}
