# terraform-aws-eks

## Overview
This is just a simple EKS module for terraform which I am using for learning and testing purposes.

An optionable bastian host can be created if you intend to protect your cluster in a private network, thus not accessible from internet. If that's the case, then set the variable `create_bastion_host` to `true`.

*The work here is currently in progress.*

## CI Tooling

### Pre-commit
[..]

### Terraform-docs
[..]

### Semantic-Release
Configured to react on changes for the following branches:
```
main
dev/*
feature/*
hotfix/*
ci/*
```
It relies on `formalzed commit message convention` to document changes and while producing a new release version.
Link [here](https://semantic-release.gitbook.io/semantic-release)

### Commit message convention
`Angular` conceived a truly good reference, here is their official [resource](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#-commit-message-format)

## Terraform
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.68.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.ec2_ondemand](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eksrole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.workernoderole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.AmazonEKSVPCResourceController](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.EC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.EKS_CNI_Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.WorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_default_tags.vars](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.eksassumepolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.eks_ami_release_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons"></a> [addons](#input\_addons) | n/a | <pre>list(object({<br>    name    = string<br>    version = string<br>  }))</pre> | n/a | yes |
| <a name="input_ami_subnet"></a> [ami\_subnet](#input\_ami\_subnet) | \_\_todo\_\_ | `string` | n/a | yes |
| <a name="input_capacity_type"></a> [capacity\_type](#input\_capacity\_type) | Define the EKS capacity type (ON\_DEMAND, SPOT) | `string` | n/a | yes |
| <a name="input_create_bastion_host"></a> [create\_bastion\_host](#input\_create\_bastion\_host) | It defines whether to create a bastion host or not | `bool` | `false` | no |
| <a name="input_eks_subnets"></a> [eks\_subnets](#input\_eks\_subnets) | \_\_todo\_\_ | `list(any)` | n/a | yes |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | Version of EKS | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | \_\_todo\_\_ | `string` | n/a | yes |
| <a name="input_private_access"></a> [private\_access](#input\_private\_access) | Enable / Disable private access to the cluster | `bool` | `"false"` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Enable / Disable public access to the cluster | `bool` | `"false"` | no |
| <a name="input_public_keys"></a> [public\_keys](#input\_public\_keys) | A list of public keys used to connect to the server | `list(any)` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | \_\_todo\_\_ | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | n/a |
<!-- END_TF_DOCS -->

## Prerequisites
Before getting your hands dirty, make sure you have the following tools installed in your developer machine:

- **Terraform**
- **Kubectl** (this is only needed if your cluster is exposed to public internet)
