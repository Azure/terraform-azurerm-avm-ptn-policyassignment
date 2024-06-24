<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.5.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

- <a name="provider_time"></a> [time](#provider\_time) (~> 0.9)

## Resources

The following resources are used by this module:

- [azurerm_management_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) (resource)
- [azurerm_management_group_policy_exemption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_exemption) (resource)
- [azurerm_management_group_template_deployment.telemetry_mg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_template_deployment) (resource)
- [azurerm_resource_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) (resource)
- [azurerm_resource_group_policy_exemption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_exemption) (resource)
- [azurerm_resource_group_template_deployment.telemetry_resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_resource_group_template_deployment.telemetry_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_resource_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_assignment) (resource)
- [azurerm_resource_policy_exemption.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_policy_exemption) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_subscription_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment) (resource)
- [azurerm_subscription_policy_exemption.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_exemption) (resource)
- [azurerm_subscription_template_deployment.telemetry_sub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [time_sleep.before_policy_role_assignments](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_default_location"></a> [default\_location](#input\_default\_location)

Description: The default location for resources in this management group. Used for policy managed identities.

Type: `string`

### <a name="input_identity"></a> [identity](#input\_identity)

Description: TODO

Type: `any`

### <a name="input_name"></a> [name](#input\_name)

Description: TODO

Type: `string`

### <a name="input_policy_definition_id"></a> [policy\_definition\_id](#input\_policy\_definition\_id)

Description: TODO

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_delays"></a> [delays](#input\_delays)

Description: A map of delays to apply to the creation and destruction of resources.  
Included to work around some race conditions in Azure.

Type:

```hcl
object({
    before_policy_assignments = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})
    before_policy_role_assignments = optional(object({
      create  = optional(string, "60s")
      destroy = optional(string, "0s")
    }), {})
    before_policy_exemptions = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})
  })
```

Default: `{}`

### <a name="input_description"></a> [description](#input\_description)

Description: TODO

Type: `string`

Default: `""`

### <a name="input_display_name"></a> [display\_name](#input\_display\_name)

Description: TODO

Type: `string`

Default: `""`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_enforce"></a> [enforce](#input\_enforce)

Description: TODO

Type: `string`

Default: `"Default"`

### <a name="input_enforcement_mode"></a> [enforcement\_mode](#input\_enforcement\_mode)

Description: TODO

Type: `string`

Default: `null`

### <a name="input_exemptions"></a> [exemptions](#input\_exemptions)

Description: n/a

Type:

```hcl
list(object({
    resource_id                     = optional(string)
    subscription_id                 = optional(string)
    management_group_id             = optional(string)
    resource_group_id               = optional(string)
    policy_definition_reference_ids = optional(list(string))
    exemption_category              = string
  }))
```

Default: `[]`

### <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids)

Description: TODO

Type: `list(string)`

Default: `[]`

### <a name="input_location"></a> [location](#input\_location)

Description: TODO

Type: `string`

Default: `null`

### <a name="input_management_group_ids"></a> [management\_group\_ids](#input\_management\_group\_ids)

Description: TODO

Type: `list(string)`

Default: `[]`

### <a name="input_metadata"></a> [metadata](#input\_metadata)

Description: TODO

Type: `map(any)`

Default: `{}`

### <a name="input_non_compliance_messages"></a> [non\_compliance\_messages](#input\_non\_compliance\_messages)

Description: TODO

Type:

```hcl
set(object({
    message                        = string
    policy_definition_reference_id = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_not_scopes"></a> [not\_scopes](#input\_not\_scopes)

Description: TODO

Type: `list(string)`

Default: `[]`

### <a name="input_overrides"></a> [overrides](#input\_overrides)

Description: TODO

Type:

```hcl
list(object({
    kind  = string
    value = string
    selectors = optional(list(object({
      kind   = string
      in     = optional(set(string), null)
      not_in = optional(set(string), null)
    })), [])
  }))
```

Default: `[]`

### <a name="input_parameters"></a> [parameters](#input\_parameters)

Description: TODO

Type: `any`

Default: `null`

### <a name="input_resource_group_ids"></a> [resource\_group\_ids](#input\_resource\_group\_ids)

Description: TODO

Type: `list(string)`

Default: `[]`

### <a name="input_resource_ids"></a> [resource\_ids](#input\_resource\_ids)

Description: n/a

Type: `list(string)`

Default: `[]`

### <a name="input_resource_selectors"></a> [resource\_selectors](#input\_resource\_selectors)

Description: TODO

Type:

```hcl
list(object({
    name = string
    selectors = optional(list(object({
      kind   = string
      in     = optional(set(string), null)
      not_in = optional(set(string), null)
    })), [])
  }))
```

Default: `[]`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: TODO

Type: `list(any)`

Default: `[]`

### <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids)

Description: TODO

Type: `list(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### <a name="output_management_group_policy_assignment"></a> [management\_group\_policy\_assignment](#output\_management\_group\_policy\_assignment)

Description: This is the full output for the policy assignment for the management group.

### <a name="output_resource_group_policy_assignment"></a> [resource\_group\_policy\_assignment](#output\_resource\_group\_policy\_assignment)

Description: This is the full output for the policy assignment for the resource group.

### <a name="output_resource_policy_assignment"></a> [resource\_policy\_assignment](#output\_resource\_policy\_assignment)

Description: This is the full output for the policy assignment for the resource.

### <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments)

Description: This is the full output for the role assignments.

### <a name="output_subscription_policy_assignment"></a> [subscription\_policy\_assignment](#output\_subscription\_policy\_assignment)

Description: This is the full output for the policy assignment for the subscription.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->