locals {
  role_assignments_mg = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_management_group_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id   = lookup(role, "role_definition_id", null)
          role_definition_name = lookup(role, "role_definition_name", null)
          principal_id         = identity.principal_id
          scope                = assignment.management_group_id
        }
      ]
      ]
  ])
  role_assignments_resource = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_resource_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id   = lookup(role, "role_definition_id", null)
          role_definition_name = lookup(role, "role_definition_name", null)
          principal_id         = identity.principal_id
          scope                = assignment.resource_id
        }
      ]
      ]
  ])
  role_assignments_rg = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_resource_group_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id   = lookup(role, "role_definition_id", null)
          role_definition_name = lookup(role, "role_definition_name", null)
          principal_id         = identity.principal_id
          scope                = assignment.resource_group_id
        }
      ]
      ]
  ])
  role_assignments_sub = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_subscription_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id   = lookup(role, "role_definition_id", null)
          role_definition_name = lookup(role, "role_definition_name", null)
          principal_id         = identity.principal_id
          scope                = assignment.subscription_id
        }
      ]
      ]
  ])
}

resource "azurerm_role_assignment" "this" {
  for_each = tomap({
    for vi, v in concat(local.role_assignments_sub, local.role_assignments_rg, local.role_assignments_mg) :
    vi => v
  })

  principal_id = each.value.principal_id
  scope        = each.value.scope
  # description          = each.value.description
  # TODO !strcontains(tostring(each.value.role_definition_id), "Microsoft.Authorization/roleDefinitions")
  role_definition_id   = each.value.role_definition_id != null ? "/providers/Microsoft.Authorization/roleDefinitions/${each.value.role_definition_id}" : each.value.role_definition_id
  role_definition_name = each.value.role_definition_name

  depends_on = [time_sleep.before_policy_role_assignments]
}



resource "time_sleep" "before_policy_role_assignments" {
  create_duration  = var.delays.before_policy_role_assignments.create
  destroy_duration = var.delays.before_policy_role_assignments.destroy
  triggers = {
    policy_assignments_management     = sha256(jsonencode(azurerm_management_group_policy_assignment.this))
    policy_assignments_subscription   = sha256(jsonencode(azurerm_subscription_policy_assignment.this))
    policy_assignments_resource_group = sha256(jsonencode(azurerm_resource_group_policy_assignment.this))
  }

  depends_on = [
    azurerm_management_group_policy_assignment.this,
    azurerm_subscription_policy_assignment.this,
    azurerm_resource_group_policy_assignment.this
  ]
}
