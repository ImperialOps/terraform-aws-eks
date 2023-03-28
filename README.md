# AWS EKS Terraform module :ghost:

[![validate](https://github.com/ImperialOps/terraform-aws-eks/workflows/validate/badge.svg)](https://github.com/ImperialOps/terraform-aws-eks/actions)
[![release](https://github.com/ImperialOps/terraform-aws-eks/workflows/release/badge.svg)](https://github.com/ImperialOps/terraform-aws-eks/actions)

Terraform module which creates a simple public EKS cluster and all supporting resources.

## Usage

```hcl
module "eks" {
  source = "github.com/stuxcd/terraform-aws-eks"

  ## required
  cluster_name = "demo"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets

  ## optional
  cluster_version                  = "1.24"
  cluster_endpoint_private_access  = false
  cluster_endpoint_public_access   = true
  node_volume_size                 = 40
  deploy_karpenter_provisioner     = true
  karpenter_provisioner_max_cpu    = 40
  karpenter_provisioner_max_memory = 80
  create_spot_service_linked_role  = false
  tags                             = {}
}
```

## Contribute

```bash
# install requirements
make install_reqs

# checkout your branch
git checkout -b branch
# make your changes
git add <files>

# commit changes
pre-commit run --all
cz commit

# test your changes
make test

# push and make PR
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

| Name                                                                        | Version  |
| --------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                      | >= 4.0   |
| <a name="requirement_helm"></a> [helm](#requirement_helm)                   | >= 2.0   |
| <a name="requirement_kubectl"></a> [kubectl](#requirement_kubectl)          | >= 1.0   |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement_kubernetes) | >= 2.0   |
| <a name="requirement_time"></a> [time](#requirement_time)                   | >= 0.0   |

## Providers

| Name                                                                        | Version |
| --------------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                            | >= 4.0  |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider_aws.virginia) | >= 4.0  |
| <a name="provider_kubectl"></a> [kubectl](#provider_kubectl)                | >= 1.0  |
| <a name="provider_kubernetes"></a> [kubernetes](#provider_kubernetes)       | >= 2.0  |
| <a name="provider_time"></a> [time](#provider_time)                         | >= 0.0  |

## Modules

| Name                                                                             | Source                                                                   | Version |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------------ | ------- |
| <a name="module_crossplane_helm"></a> [crossplane_helm](#module_crossplane_helm) | terraform-module/release/helm                                            | 2.8.0   |
| <a name="module_crossplane_irsa"></a> [crossplane_irsa](#module_crossplane_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | >= 5.14 |
| <a name="module_ebs_csi_irsa"></a> [ebs_csi_irsa](#module_ebs_csi_irsa)          | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | >= 5.14 |
| <a name="module_eks"></a> [eks](#module_eks)                                     | terraform-aws-modules/eks/aws                                            | ~> 19.0 |
| <a name="module_karpenter_helm"></a> [karpenter_helm](#module_karpenter_helm)    | terraform-module/release/helm                                            | 2.8.0   |
| <a name="module_karpenter_irsa"></a> [karpenter_irsa](#module_karpenter_irsa)    | terraform-aws-modules/eks/aws//modules/karpenter                         | ~> 19.0 |
| <a name="module_kms"></a> [kms](#module_kms)                                     | terraform-aws-modules/kms/aws                                            | 1.5.0   |

## Resources

| Name                                                                                                                                                       | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_service_linked_role.spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role)                    | resource    |
| [kubectl_manifest.crossplane_controller_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest)                | resource    |
| [kubectl_manifest.crossplane_provider](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest)                         | resource    |
| [kubectl_manifest.crossplane_provider_config](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest)                  | resource    |
| [kubectl_manifest.karpenter_node_template](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest)                     | resource    |
| [kubectl_manifest.karpenter_provisioner](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest)                       | resource    |
| [kubernetes_storage_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class)                          | resource    |
| [time_sleep.wait_30_seconds_provider_destroy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                          | resource    |
| [time_sleep.wait_30_seconds_provider_install](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                          | resource    |
| [time_sleep.wait_60_seconds_karpenter](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                 | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                              | data source |
| [aws_ecrpublic_authorization_token.virginia](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |
| [aws_iam_policy.crossplane](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy)                                     | data source |
| [aws_kms_key.aws_ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key)                                              | data source |

## Inputs

| Name                                                                                                                              | Description                                                                                                                                                                                    | Type           | Default                    | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | -------------------------- | :------: |
| <a name="input_cluster_endpoint_private_access"></a> [cluster_endpoint_private_access](#input_cluster_endpoint_private_access)    | Expose Kubernetes API in private subnets                                                                                                                                                       | `bool`         | `true`                     |    no    |
| <a name="input_cluster_endpoint_public_access"></a> [cluster_endpoint_public_access](#input_cluster_endpoint_public_access)       | Expose Kubernetes API publicly                                                                                                                                                                 | `bool`         | `false`                    |    no    |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name)                                                             | Name of the EKS cluster                                                                                                                                                                        | `string`       | n/a                        |   yes    |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version)                                                    | Version of the EKS cluster                                                                                                                                                                     | `string`       | `"1.24"`                   |    no    |
| <a name="input_control_plane_subnet_ids"></a> [control_plane_subnet_ids](#input_control_plane_subnet_ids)                         | A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane  | `list(string)` | `[]`                       |    no    |
| <a name="input_create"></a> [create](#input_create)                                                                               | Controls if EKS resources should be created (affects nearly all resources)                                                                                                                     | `bool`         | `true`                     |    no    |
| <a name="input_create_crossplane"></a> [create_crossplane](#input_create_crossplane)                                              | Controls whether to deploy CrossPlane and the AWS provider with Admin access                                                                                                                   | `bool`         | `true`                     |    no    |
| <a name="input_create_karpenter"></a> [create_karpenter](#input_create_karpenter)                                                 | Controls whether to deploy the a Karpenter                                                                                                                                                     | `bool`         | `true`                     |    no    |
| <a name="input_create_karpenter_provisioner"></a> [create_karpenter_provisioner](#input_create_karpenter_provisioner)             | Controls whether to deploy the a default Karpenter provisioner                                                                                                                                 | `bool`         | `true`                     |    no    |
| <a name="input_create_spot_service_linked_role"></a> [create_spot_service_linked_role](#input_create_spot_service_linked_role)    | Controls whether or not to create the spot.amazonaws.com service linked role                                                                                                                   | `bool`         | `true`                     |    no    |
| <a name="input_karpenter_node_volume_size"></a> [karpenter_node_volume_size](#input_karpenter_node_volume_size)                   | Volume size of nodes in the cluster in GB                                                                                                                                                      | `number`       | `40`                       |    no    |
| <a name="input_karpenter_provisioner_max_cpu"></a> [karpenter_provisioner_max_cpu](#input_karpenter_provisioner_max_cpu)          | The max number of cpu's the default provisioner will deploy                                                                                                                                    | `number`       | `40`                       |    no    |
| <a name="input_karpenter_provisioner_max_memory"></a> [karpenter_provisioner_max_memory](#input_karpenter_provisioner_max_memory) | The max memory the default provisioner will deploy in Gi                                                                                                                                       | `number`       | `80`                       |    no    |
| <a name="input_karpenter_tag_key"></a> [karpenter_tag_key](#input_karpenter_tag_key)                                              | Tag key (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner. Used when creating multiple cluster in a single VPC                                    | `string`       | `"karpenter.sh/discovery"` |    no    |
| <a name="input_subnet_account_id"></a> [subnet_account_id](#input_subnet_account_id)                                              | Account ID of where the subnets Karpenter will utilize resides. Used when subnets are shared from another account                                                                              | `string`       | `""`                       |    no    |
| <a name="input_subnet_ids"></a> [subnet_ids](#input_subnet_ids)                                                                   | A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets | `list(string)` | n/a                        |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                     | A map of tags to add to all resources                                                                                                                                                          | `map(string)`  | `{}`                       |    no    |
| <a name="input_vpc_id"></a> [vpc_id](#input_vpc_id)                                                                               | ID of vpc to deploy cluster into                                                                                                                                                               | `string`       | n/a                        |   yes    |

## Outputs

| Name                                                                                                                                      | Description                                                                                 |
| ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| <a name="output_cluster_arn"></a> [cluster_arn](#output_cluster_arn)                                                                      | The Amazon Resource Name (ARN) of the cluster                                               |
| <a name="output_cluster_certificate_authority_data"></a> [cluster_certificate_authority_data](#output_cluster_certificate_authority_data) | Base64 encoded certificate data required to communicate with the cluster                    |
| <a name="output_cluster_endpoint"></a> [cluster_endpoint](#output_cluster_endpoint)                                                       | Endpoint for your Kubernetes API server                                                     |
| <a name="output_cluster_id"></a> [cluster_id](#output_cluster_id)                                                                         | The id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name)                                                                   | The name of the EKS cluster                                                                 |
| <a name="output_cluster_status"></a> [cluster_status](#output_cluster_status)                                                             | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`                |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
