output "management_group_policy_assignment" {
  description = "This is the full output for the policy assignment for the management group."
  value       = azurerm_management_group_policy_assignment.this
}

output "resource" {
  description = "This is the resource of the policy assignment."
  value = concat(
    azurerm_management_group_policy_assignment.this[*],
    azurerm_resource_group_policy_assignment.this[*],
    azurerm_resource_policy_assignment.this[*],
  azurerm_subscription_policy_assignment.this[*])[0]
}

output "resource_group_policy_assignment" {
  description = "This is the full output for the policy assignment for the resource group."
  value       = azurerm_resource_group_policy_assignment.this
}

output "resource_id" {
  description = "This is the resource id of the policy assignment."
  value = coalesce(
    azurerm_management_group_policy_assignment.this[*],
    azurerm_resource_group_policy_assignment.this[*],
    azurerm_resource_policy_assignment.this[*],
  azurerm_subscription_policy_assignment.this[*])
}

output "resource_policy_assignment" {
  description = "This is the full output for the policy assignment for the resource."
  value       = azurerm_resource_policy_assignment.this
}

output "role_assignments" {
  description = "This is the full output for the role assignments."
  value       = azurerm_role_assignment.this
}

output "subscription_policy_assignment" {
  description = "This is the full output for the policy assignment for the subscription."
  value       = azurerm_subscription_policy_assignment.this
}
