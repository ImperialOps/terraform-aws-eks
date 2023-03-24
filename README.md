# AWS EKS Terraform module :ghost:

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

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_aws.virginia"></a> [aws.virginia](#provider\_aws.virginia) | >= 4.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#module\_ebs\_csi\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | >= 5.13 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.0 |
| <a name="module_karpenter_helm"></a> [karpenter\_helm](#module\_karpenter\_helm) | terraform-module/release/helm | 2.8.0 |
| <a name="module_karpenter_irsa"></a> [karpenter\_irsa](#module\_karpenter\_irsa) | terraform-aws-modules/eks/aws//modules/karpenter | ~> 19.0 |
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_service_linked_role.spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [kubectl_manifest.karpenter_node_template](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.karpenter_provisioner](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_storage_class.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecrpublic_authorization_token.virginia](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecrpublic_authorization_token) | data source |
| [aws_kms_key.aws_ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Expose Kubernetes API in private subnets | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Expose Kubernetes API publicly | `bool` | `false` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster | `string` | n/a | yes |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Version of the EKS cluster | `string` | `"1.24"` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane | `list(string)` | `[]` | no |
| <a name="input_create"></a> [create](#input\_create) | Controls if EKS resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_create_karpenter"></a> [create\_karpenter](#input\_create\_karpenter) | Controls whether to deploy the a Karpenter | `bool` | `true` | no |
| <a name="input_create_karpenter_provisioner"></a> [create\_karpenter\_provisioner](#input\_create\_karpenter\_provisioner) | Controls whether to deploy the a default Karpenter provisioner | `bool` | `true` | no |
| <a name="input_create_spot_service_linked_role"></a> [create\_spot\_service\_linked\_role](#input\_create\_spot\_service\_linked\_role) | Controls whether or not to create the spot.amazonaws.com service linked role | `bool` | `true` | no |
| <a name="input_karpenter_node_volume_size"></a> [karpenter\_node\_volume\_size](#input\_karpenter\_node\_volume\_size) | Volume size of nodes in the cluster in GB | `number` | `40` | no |
| <a name="input_karpenter_provisioner_max_cpu"></a> [karpenter\_provisioner\_max\_cpu](#input\_karpenter\_provisioner\_max\_cpu) | The max number of cpu's the default provisioner will deploy | `number` | `40` | no |
| <a name="input_karpenter_provisioner_max_memory"></a> [karpenter\_provisioner\_max\_memory](#input\_karpenter\_provisioner\_max\_memory) | The max memory the default provisioner will deploy in Gi | `number` | `80` | no |
| <a name="input_karpenter_tag_key"></a> [karpenter\_tag\_key](#input\_karpenter\_tag\_key) | Tag key (`{key = value}`) applied to resources launched by Karpenter through the Karpenter provisioner. Used when creating multiple cluster in a single VPC | `string` | `"karpenter.sh/discovery"` | no |
| <a name="input_subnet_account_id"></a> [subnet\_account\_id](#input\_subnet\_account\_id) | Account ID of where the subnets Karpenter will utilize resides. Used when subnets are shared from another account | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of vpc to deploy cluster into | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The Amazon Resource Name (ARN) of the cluster |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for your Kubernetes API server |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The id of the EKS cluster. Will block on cluster creation until the cluster is really ready |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the EKS cluster |
| <a name="output_cluster_status"></a> [cluster\_status](#output\_cluster\_status) | Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED` |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
