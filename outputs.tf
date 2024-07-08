output "policy_assignment_id" {
  description = "This is the id of the policy assignment"
  value       = azapi_resource.policy_assignment.id
}

output "policy_assignment_name" {
  description = "This is the name of the policy assignment"
  value       = azapi_resource.policy_assignment.name
}

output "resource" {
  description = "Deprecated"
  value = {
    "resource_id" : azapi_resource.policy_assignment.id
  }
}

output "resource_id" {
  description = "This is the resource id of the policy assignment."
  value       = azapi_resource.policy_assignment.id
}

output "role_assignments" {
  description = "This is the full output for the role assignments."
  value       = azurerm_role_assignment.this
}
