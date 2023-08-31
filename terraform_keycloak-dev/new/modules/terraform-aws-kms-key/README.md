# AWS KMS Key/Alias module

## Resources created by this module

- KMS Key
- KMS Key Alias

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_name | Name of the current account. | `string` | n/a | yes |
| alias\_name | The display name of the alias. Do not include the word `alias` followed by a forward slash (`alias/`). | `string` | n/a | yes |
| aws\_organizations\_account\_resource | The complete resource that holds all information about the created aws\_organization\_account(s) | `map` | n/a | yes |
| deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. | `number` | `30` | no |
| description | The description of the key as viewed in AWS console. | `string` | n/a | yes |
| key\_policy | A valid policy JSON document. | `string` | `null` | no |
| key\_usage | Specifies the intended use of the key. | `string` | `"ENCRYPT_DECRYPT"` | no |
| organization | Complete name of the organisation | `string` | n/a | yes |
| region | The region of the account | `string` | n/a | yes |
| stage | Name of a dedicated system or application | `string` | n/a | yes |
| system | Name of a dedicated system or application | `string` | n/a | yes |
| tags | Tag that should be applied to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| alias\_arn | The `arn` of the key alias. |
| alias\_name | The name of the key alias. |
| arn | The `arn` of the key. |
| id | The globally unique identifier for the key. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
