variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "policy_definition_id" {
  type        = string
  description = "(Required) The ID of the Policy Definition or Policy Definition Set. Changing this forces a new Policy Assignment to be created."
}

variable "scope" {
  type        = string
  description = "(Required) The Scope at which this Policy Assignment should be applied. Changing this forces a new Policy Assignment to be created."
}

variable "delays" {
  type = object({
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
  default     = {}
  description = <<DESCRIPTION
A map of delays to apply to the creation and destruction of resources.
Included to work around some race conditions in Azure.
DESCRIPTION
}

variable "description" {
  type        = string
  default     = ""
  description = "(Optional) A description which should be used for this Policy Assignment."
}

variable "display_name" {
  type        = string
  default     = ""
  description = "(Optional) The Display Name for this Policy Assignment."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "enforce" {
  type        = string
  default     = "Default"
  description = "(Optional) Specifies if this Policy should be enforced or not? Options are `Default` and `DoNotEnforce`."

  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.enforce)
    error_message = "enforce must be one of `Default` or `DoNotEnforce`."

  }
}

variable "exemptions" {
  type = list(object({
    resource_id                     = string
    policy_definition_reference_ids = optional(list(string))
    exemption_category              = string
  }))
  default     = []
  description = <<DESCRIPTION
  - `name` - (Required) The name of the Policy Exemption. Changing this forces a new resource to be created.
- `resource_id` - (Required) The Resource ID where the Policy Exemption should be applied. Changing this forces a new resource to be created.
- `exemption_category` - (Required) The category of this policy exemption. Possible values are `Waiver` and `Mitigated`.
- `policy_assignment_id` - (Required) The ID of the Policy Assignment to be exempted at the specified Scope. Changing this forces a new resource to be created.
- `description` - (Optional) A description to use for this Policy Exemption.
- `display_name` - (Optional) A friendly display name to use for this Policy Exemption.
- `expires_on` - (Optional) The expiration date and time in UTC ISO 8601 format of this policy exemption.
- `policy_definition_reference_ids` - (Optional) The policy definition reference ID list when the associated policy assignment is an assignment of a policy set definition.
- `metadata` - (Optional) The metadata for this policy exemption. This is a JSON string representing additional metadata that should be stored with the policy exemption.
DESCRIPTION

  validation {
    condition     = alltrue([for e in var.exemptions : e.resource_id != null])
    error_message = "The resource_id needs to be set."
  }
  validation {
    condition     = alltrue([for e in var.exemptions : contains(["Waiver", "Mitigated"], e.exemption_category)])
    error_message = "Exemption category must be one of Waiver or Mitigated."
  }
  validation { # TODO - change to warning
    condition     = alltrue([for e in var.exemptions : length(lookup(e, "display_name", "")) <= 128])
    error_message = "The display_name is too long and will be shortened."
  }
}

variable "identity" {
  type = object({
    type = string
  })
  default     = null
  description = <<DESCRIPTION
  (Optional) An identity block as defined below.
   - `type` - (Required) SystemAssigned or UserAssigned.
  DESCRIPTION
}

variable "metadata" {
  type        = map(any)
  default     = {}
  description = "(Optional) A mapping of any Metadata for this Policy."
}

variable "name" {
  type        = string
  default     = ""
  description = "(Optional) The Display Name for this Policy Assignment."
}

variable "non_compliance_messages" {
  type = set(object({
    message                        = string
    policy_definition_reference_id = optional(string, null)
  }))
  default     = []
  description = <<DESCRIPTION
  (Optional) A set of non compliance message objects to use for the policy assignment. Each object has the following properties:
  - `message` - (Required) The non compliance message.
  - `policy_definition_reference_id` - (Optional) The reference id of the policy definition to use for the non compliance message.
    DESCRIPTION
}

variable "not_scopes" {
  type        = list(string)
  default     = []
  description = "(Optional) Specifies a list of Resource Scopes (for example a Subscription, or a Resource Group) within this Management Group which are excluded from this Policy."
}

variable "overrides" {
  type = list(object({
    kind  = string
    value = string
    selectors = optional(list(object({
      kind   = string
      in     = optional(set(string), null)
      not_in = optional(set(string), null)
    })), [])
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) A list of override objects to use for the policy assignment. Each object has the following properties:
  - `kind` - (Required) The kind of the override.
  - `value` - (Required) The value of the override. Supported values are policy effects: <https://learn.microsoft.com/azure/governance/policy/concepts/effects>.
  - `selectors` - (Optional) A list of selector objects to use for the override. Each object has the following properties:
    - `kind` - (Required) The kind of the selector.
    - `in` - (Optional) A set of strings to include in the selector.
    - `not_in` - (Optional) A set of strings to exclude from the selector.

 DESCRIPTION
}

variable "parameters" {
  type        = map(any)
  default     = null
  description = "(Optional) A mapping of any Parameters for this Policy."
}

variable "resource_selectors" {
  type = list(object({
    name = string
    selectors = optional(list(object({
      kind   = string
      in     = optional(set(string), null)
      not_in = optional(set(string), null)
    })), [])
  }))
  default     = []
  description = <<DESCRIPTION
(Optional) A list of resource selector objects to use for the policy assignment. Each object has the following properties:
  - `name` - (Required) The name of the resource selector.
  - `selectors` - (Optional) A list of selector objects to use for the resource selector. Each object has the following properties:
    - `kind` - (Required) The kind of the selector. Allowed values are: `resourceLocation`, `resourceType`, `resourceWithoutLocation`. `resourceWithoutLocation` cannot be used in the same resource selector as `resourceLocation`.
    - `in` - (Optional) A set of strings to include in the selector.
    - `not_in` - (Optional) A set of strings to exclude from the selector.
  DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the <RESOURCE>. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  
  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

variable "schema_validation_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Specifies if this Policy should be validated against the schema. Defaults to true."
}
