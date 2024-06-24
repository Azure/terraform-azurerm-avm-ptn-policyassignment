variable "default_location" {
  type        = string
  description = <<DESCRIPTION
The default location for resources in this management group. Used for policy managed identities.
DESCRIPTION
}

variable "identity" {
  description = "TODO"
}

variable "name" {
  type        = string
  description = "TODO"
}

variable "policy_definition_id" {
  type        = string
  description = "TODO"
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
  description = "TODO"
}

variable "display_name" {
  type        = string
  default     = ""
  description = "TODO"
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
  description = "TODO"
}

variable "enforcement_mode" {
  type        = string
  default     = null
  description = "TODO"
}

variable "exemptions" {
  type = list(object({
    resource_id                     = optional(string)
    subscription_id                 = optional(string)
    management_group_id             = optional(string)
    resource_group_id               = optional(string)
    policy_definition_reference_ids = optional(list(string))
    exemption_category              = string
  }))
  default = []

  validation {
    condition     = alltrue([for e in var.exemptions : e.resource_id != null || e.subscription_id != null || e.management_group_id != null || e.resource_group_id != null])
    error_message = "One of the following must be set: resource_id, subscription_id, management_group_id or resource_group_id."
  }
  validation {
    condition     = alltrue([for e in var.exemptions : contains(["Waiver", "Mitigated"], e.exemption_category)])
    error_message = "exemption category must be one of Waiver or Mitigated."
  }
}

variable "identity_ids" {
  type        = list(string)
  default     = []
  description = "TODO"
}

variable "location" {
  type        = string
  default     = null
  description = "TODO"
}

variable "management_group_ids" {
  type        = list(string)
  default     = []
  description = "TODO"
}

variable "metadata" {
  type        = map(any)
  default     = {}
  description = "TODO"
}

variable "non_compliance_messages" {
  type = set(object({
    message                        = string
    policy_definition_reference_id = optional(string, null)
  }))
  default     = []
  description = "TODO"
}

variable "not_scopes" {
  type        = list(string)
  default     = []
  description = "TODO"
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
  description = "TODO"
}

variable "parameters" {
  # type        = map(any)
  default     = null
  description = "TODO"
}

variable "resource_group_ids" {
  type        = list(string)
  default     = []
  description = "TODO"
}

variable "resource_ids" {
  type        = list(string)
  default     = []
  description = ""
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
  description = "TODO"
}

variable "role_assignments" {
  type        = list(any)
  default     = []
  description = "TODO"
}

variable "subscription_ids" {
  type        = list(string)
  default     = []
  description = "TODO"
}
