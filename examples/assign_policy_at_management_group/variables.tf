variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "parent_management_group_id" {
  type        = string
  default     = "/providers/Microsoft.Management/managementGroups/avm-test"
  description = "The resource ID of the existing parent management group under which to create the example management group."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Management/managementGroups", var.parent_management_group_id))
    error_message = "parent_management_group_id must be a valid management group resource ID."
  }
}
