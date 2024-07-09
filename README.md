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

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 1.14)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.71)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (~> 1.14)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.71)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.5)

- <a name="provider_time"></a> [time](#provider\_time) (~> 0.9)

## Resources

The following resources are used by this module:

- [azapi_resource.policy_assignment](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.policy_exemption](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.telemetry](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [time_sleep.before_policy_role_assignments](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: (Required) The Azure Region where the Policy Assignment should exist. Changing this forces a new Policy Assignment to be created.

Type: `string`

### <a name="input_policy_definition_id"></a> [policy\_definition\_id](#input\_policy\_definition\_id)

Description: (Required) The ID of the Policy Definition or Policy Definition Set. Changing this forces a new Policy Assignment to be created.

Type: `string`

### <a name="input_scope"></a> [scope](#input\_scope)

Description: (Required) The Scope at which this Policy Assignment should be applied. Changing this forces a new Policy Assignment to be created.

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

Description: (Optional) A description which should be used for this Policy Assignment.

Type: `string`

Default: `""`

### <a name="input_display_name"></a> [display\_name](#input\_display\_name)

Description: (Optional) The Display Name for this Policy Assignment.

Type: `string`

Default: `""`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_enforce"></a> [enforce](#input\_enforce)

Description: (Optional) Specifies if this Policy should be enforced or not? Options are `Default` and `DoNotEnforce`.

Type: `string`

Default: `"Default"`

### <a name="input_exemptions"></a> [exemptions](#input\_exemptions)

Description:   - `name` - (Required) The name of the Policy Exemption. Changing this forces a new resource to be created.
- `resource_id` - (Required) The Resource ID where the Policy Exemption should be applied. Changing this forces a new resource to be created.
- `exemption_category` - (Required) The category of this policy exemption. Possible values are `Waiver` and `Mitigated`.
- `policy_assignment_id` - (Required) The ID of the Policy Assignment to be exempted at the specified Scope. Changing this forces a new resource to be created.
- `description` - (Optional) A description to use for this Policy Exemption.
- `display_name` - (Optional) A friendly display name to use for this Policy Exemption.
- `expires_on` - (Optional) The expiration date and time in UTC ISO 8601 format of this policy exemption.
- `policy_definition_reference_ids` - (Optional) The policy definition reference ID list when the associated policy assignment is an assignment of a policy set definition.
- `metadata` - (Optional) The metadata for this policy exemption. This is a JSON string representing additional metadata that should be stored with the policy exemption.

Type:

```hcl
list(object({
    resource_id                     = string
    policy_definition_reference_ids = optional(list(string))
    exemption_category              = string
  }))
```

Default: `[]`

### <a name="input_identity"></a> [identity](#input\_identity)

Description:   (Optional) An identity block as defined below.
   - `type` - (Required) SystemAssigned or UserAssigned.

Type:

```hcl
object({
    type = string
  })
```

Default: `null`

### <a name="input_metadata"></a> [metadata](#input\_metadata)

Description: (Optional) A mapping of any Metadata for this Policy.

Type: `map(any)`

Default: `{}`

### <a name="input_name"></a> [name](#input\_name)

Description: (Optional) The Display Name for this Policy Assignment.

Type: `string`

Default: `""`

### <a name="input_non_compliance_messages"></a> [non\_compliance\_messages](#input\_non\_compliance\_messages)

Description:   (Optional) A set of non compliance message objects to use for the policy assignment. Each object has the following properties:
  - `message` - (Required) The non compliance message.
  - `policy_definition_reference_id` - (Optional) The reference id of the policy definition to use for the non compliance message.

Type:

```hcl
set(object({
    message                        = string
    policy_definition_reference_id = optional(string, null)
  }))
```

Default: `[]`

### <a name="input_not_scopes"></a> [not\_scopes](#input\_not\_scopes)

Description: (Optional) Specifies a list of Resource Scopes (for example a Subscription, or a Resource Group) within this Management Group which are excluded from this Policy.

Type: `list(string)`

Default: `[]`

### <a name="input_overrides"></a> [overrides](#input\_overrides)

Description: (Optional) A list of override objects to use for the policy assignment. Each object has the following properties:
  - `kind` - (Required) The kind of the override.
  - `value` - (Required) The value of the override. Supported values are policy effects: <https://learn.microsoft.com/azure/governance/policy/concepts/effects>.
  - `selectors` - (Optional) A list of selector objects to use for the override. Each object has the following properties:
    - `kind` - (Required) The kind of the selector.
    - `in` - (Optional) A set of strings to include in the selector.
    - `not_in` - (Optional) A set of strings to exclude from the selector.

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

Description: (Optional) A mapping of any Parameters for this Policy.

Type: `map(any)`

Default: `null`

### <a name="input_resource_selectors"></a> [resource\_selectors](#input\_resource\_selectors)

Description: (Optional) A list of resource selector objects to use for the policy assignment. Each object has the following properties:
  - `name` - (Required) The name of the resource selector.
  - `selectors` - (Optional) A list of selector objects to use for the resource selector. Each object has the following properties:
    - `kind` - (Required) The kind of the selector. Allowed values are: `resourceLocation`, `resourceType`, `resourceWithoutLocation`. `resourceWithoutLocation` cannot be used in the same resource selector as `resourceLocation`.
    - `in` - (Optional) A set of strings to include in the selector.
    - `not_in` - (Optional) A set of strings to exclude from the selector.

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

Description:   A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name = string
    # principal_id                           = optional(string, null) # TODO the principal_id is not known before policy assignment
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_policy_assignment_id"></a> [policy\_assignment\_id](#output\_policy\_assignment\_id)

Description: This is the id of the policy assignment

### <a name="output_policy_assignment_name"></a> [policy\_assignment\_name](#output\_policy\_assignment\_name)

Description: This is the name of the policy assignment

### <a name="output_resource"></a> [resource](#output\_resource)

Description: Deprecated

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: This is the resource id of the policy assignment.

### <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments)

Description: This is the full output for the role assignments.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->