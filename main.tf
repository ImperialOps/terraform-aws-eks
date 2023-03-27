################################################################################
# GLOBAL LOCALS
################################################################################

locals {
  name            = var.cluster_name
  cluster_version = var.cluster_version

  create = var.create

  tags = var.tags
}

################################################################################
# EKS
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  create                          = local.create
  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = coalescelist(var.control_plane_subnet_ids, var.subnet_ids)

  enable_irsa = true

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter_irsa.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]

  fargate_profiles = merge(
    { for i in range(0, length(var.subnet_ids)) :
      "${local.name}-kube-system-${i}" => {
        selectors = [
          { namespace = "kube-system" }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(var.subnet_ids, i)]
      }
    },
    local.create_karpenter ? { for i in range(0, length(var.subnet_ids)) :
      "${local.name}-karpenter-${i}" => {
        selectors = [
          { namespace = "karpenter" }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(var.subnet_ids, i)]
      }
    } : {},
    local.create_crossplane ? { for i in range(0, length(var.subnet_ids)) :
      "${local.name}-crossplane-${i}" => {
        selectors = [
          { namespace = local.crossplane_namespace }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(var.subnet_ids, i)]
      }
    } : {},
  )

  # Encryption key
  create_kms_key = false
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = module.kms.key_arn
  }

  tags = merge(local.tags, {
    (var.karpenter_tag_key) = local.name
  })
}

################################################################################
# IAM
################################################################################

resource "aws_iam_service_linked_role" "spot" {
  count = local.create && var.create_spot_service_linked_role ? 1 : 0

  aws_service_name = "spot.amazonaws.com"
}

################################################################################
# KARPENTER
################################################################################

locals {
  create_karpenter             = local.create && var.create_karpenter
  create_karpenter_provisioner = local.create && var.create_karpenter_provisioner
  subnet_account_id            = coalesce(var.subnet_account_id, data.aws_caller_identity.current.account_id)
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 19.0"

  create                 = local.create_karpenter
  cluster_name           = module.eks.cluster_name
  irsa_name              = local.name
  queue_name             = local.name
  iam_role_name          = local.name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  irsa_subnet_account_id = local.subnet_account_id
  irsa_tag_key           = var.karpenter_tag_key

  tags = local.tags
}

module "karpenter_helm" {
  source  = "terraform-module/release/helm"
  version = "2.8.0"

  namespace  = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"

  app = {
    deploy              = local.create_karpenter
    create_namespace    = local.create_karpenter
    repository_username = data.aws_ecrpublic_authorization_token.virginia.user_name
    repository_password = data.aws_ecrpublic_authorization_token.virginia.password
    name                = "karpenter"
    version             = "v0.27.0"
    chart               = "karpenter"
  }

  set = [
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = module.karpenter_irsa.irsa_arn
    },
    {
      name  = "settings.aws.defaultInstanceProfile"
      value = module.karpenter_irsa.instance_profile_name
    },
    {
      name  = "settings.aws.interruptionQueueName"
      value = module.karpenter_irsa.queue_name
    },
    {
      name  = "settings.aws.clusterName"
      value = module.eks.cluster_name
    },
    {
      name  = "settings.aws.clusterEndpoint"
      value = module.eks.cluster_endpoint
    },
    {
      name  = "replicas"
      value = "2"
    },
    {
      name  = "loglevel"
      value = "info"
    }
  ]

  depends_on = [module.eks]
}

resource "kubectl_manifest" "karpenter_provisioner" {
  count = local.create_karpenter_provisioner ? 1 : 0

  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default
  spec:
    consolidation:
      enabled: true
    ttlSecondsUntilExpired: 2592000 # 30 Days
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values: ["spot", "on-demand"]
      - key: "karpenter.k8s.aws/instance-category"
        operator: In
        values: ["m", "c", "r"]
      - key: "karpenter.k8s.aws/instance-cpu"
        operator: In
        values: ["1", "2", "4", "8", "16", "32"]
    limits:
      resources:
        cpu: ${var.karpenter_provisioner_max_cpu}
        memory: ${var.karpenter_provisioner_max_memory}Gi
    kubeletConfiguration:
      containerRuntime: containerd
      systemReserved:
        cpu: 100m
        memory: 100Mi
        ephemeral-storage: 1Gi
      kubeReserved:
        cpu: 200m
        memory: 100Mi
        ephemeral-storage: 3Gi
      evictionHard:
        memory.available: 5%
        nodefs.available: 5%
        nodefs.inodesFree: 5%
      evictionSoft:
        memory.available: 10%
        nodefs.available: 10%
        nodefs.inodesFree: 10%
      evictionSoftGracePeriod:
        memory.available: 1m
        nodefs.available: 1m30s
        nodefs.inodesFree: 2m
      evictionMaxPodGracePeriod: 180
      podsPerCore: 4
      maxPods: 40
    providerRef:
      name: default
  YAML

  depends_on = [module.karpenter_helm]
}

resource "kubectl_manifest" "karpenter_node_template" {
  count = local.create_karpenter_provisioner ? 1 : 0

  yaml_body = <<-YAML
  apiVersion: karpenter.k8s.aws/v1alpha1
  kind: AWSNodeTemplate
  metadata:
    name: default
  spec:
    subnetSelector:
      ${var.karpenter_tag_key}: ${local.name}
    securityGroupSelector:
      ${var.karpenter_tag_key}: ${local.name}
    tags:
      ${var.karpenter_tag_key}: ${local.name}
      Name: karpenter/${local.name}/default
      karpenter.sh/provisioner-name: default
    blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: "${var.karpenter_node_volume_size}Gi"
          volumeType: gp3
          iops: 5000
          encrypted: true
          kmsKeyID: ${data.aws_kms_key.aws_ebs.arn}
          deleteOnTermination: true
          throughput: 125
  YAML

  depends_on = [module.karpenter_helm]
}

################################################################################
# STORAGE CLASS
################################################################################

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = ">= 5.14"

  create_role           = local.create
  role_name             = "ebs-csi-${local.name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

resource "kubernetes_storage_class" "this" {
  count = local.create ? 1 : 0

  metadata {
    name = "gp2-encrypted"
  }

  storage_provisioner = "ebs.csi.aws.com"
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"

  parameters = {
    encrypted = "true"
    kmsKeyId  = data.aws_kms_key.aws_ebs.arn
  }
}

################################################################################
# CROSSPLANE
################################################################################

locals {
  create_crossplane    = local.create && var.create_crossplane
  crossplane_namespace = "crossplane-system"
}

module "crossplane_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = ">= 5.14"

  create_role                = local.create_crossplane
  role_name                  = "crossplane-${local.name}"
  assume_role_condition_test = "StringLike"

  role_policy_arns = {
    "administrator" = data.aws_iam_policy.crossplane.arn
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${local.crossplane_namespace}:provider-aws-*"]
    }
  }

  tags = local.tags
}

module "crossplane_helm" {
  source  = "terraform-module/release/helm"
  version = "2.8.0"

  namespace  = local.crossplane_namespace
  repository = "https://charts.crossplane.io/stable"

  app = {
    deploy           = local.create_crossplane
    create_namespace = local.create_crossplane
    name             = "crossplane"
    version          = "1.11.2"
    chart            = "crossplane"
  }

  depends_on = [module.eks]
}

resource "kubectl_manifest" "crossplane_controller_config" {
  count = local.create_crossplane ? 1 : 0

  yaml_body = <<-YAML
  apiVersion: pkg.crossplane.io/v1alpha1
  kind: ControllerConfig
  metadata:
    name: aws-config
    annotations:
      eks.amazonaws.com/role-arn: ${module.crossplane_irsa.iam_role_arn}
  spec:
    podSecurityContext:
      fsGroup: 2000
  YAML

  depends_on = [module.crossplane_helm]
}

# allow time for provider to be terminated
resource "time_sleep" "wait_30_seconds_provider_destroy" {
  count = local.create_crossplane ? 1 : 0

  destroy_duration = "60s"

  depends_on = [kubectl_manifest.crossplane_controller_config]
}

resource "kubectl_manifest" "crossplane_provider" {
  count = local.create_crossplane ? 1 : 0

  yaml_body = <<-YAML
  apiVersion: pkg.crossplane.io/v1
  kind: Provider
  metadata:
    name: provider-aws
  spec:
    package: xpkg.upbound.io/crossplane-contrib/provider-aws:v0.38.0
    controllerConfigRef:
      name: aws-config
  YAML

  depends_on = [time_sleep.wait_30_seconds_provider_destroy]
}

# allow time for provider CRDs
resource "time_sleep" "wait_30_seconds_provider_install" {
  count = local.create_crossplane ? 1 : 0

  create_duration = "30s"

  depends_on = [kubectl_manifest.crossplane_provider]
}

resource "kubectl_manifest" "crossplane_provider_config" {
  count = local.create_crossplane ? 1 : 0

  yaml_body = <<-YAML
  apiVersion: aws.crossplane.io/v1beta1
  kind: ProviderConfig
  metadata:
    name: aws-provider
  spec:
    credentials:
      source: InjectedIdentity
  YAML

  depends_on = [time_sleep.wait_30_seconds_provider_install]
}

################################################################################
# KMS
################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  create                  = local.create
  aliases                 = ["eks/${local.name}"]
  description             = "${local.name} cluster encryption key"
  enable_default_policy   = true
  key_owners              = [data.aws_caller_identity.current.arn]
  deletion_window_in_days = 7

  tags = local.tags
}
