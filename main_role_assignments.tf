locals {
  role_assignments_mg = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_management_group_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id_or_name             = lookup(role, "role_definition_id_or_name", null)
          principal_id                           = identity.principal_id
          scope                                  = assignment.management_group_id
          description                            = lookup(role, "description", null)
          condition                              = lookup(role, "condition", null)
          condition_version                      = lookup(role, "condition_version", null)
          skip_service_principal_aad_check       = lookup(role, "skip_service_principal_aad_check", false)
          delegated_managed_identity_resource_id = lookup(role, "delegated_managed_identity_resource_id", null)
          principal_type                         = lookup(role, "principal_type", null)
        }
      ]
      ]
  ])
  role_assignments_resource = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_resource_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id_or_name             = lookup(role, "role_definition_id_or_name", null)
          principal_id                           = identity.principal_id
          scope                                  = assignment.resource_id
          description                            = lookup(role, "description", null)
          condition                              = lookup(role, "condition", null)
          condition_version                      = lookup(role, "condition_version", null)
          skip_service_principal_aad_check       = lookup(role, "skip_service_principal_aad_check", false)
          delegated_managed_identity_resource_id = lookup(role, "delegated_managed_identity_resource_id", null)
          principal_type                         = lookup(role, "principal_type", null)
        }
      ]
      ]
  ])
  role_assignments_rg = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_resource_group_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id_or_name             = lookup(role, "role_definition_id_or_name", null)
          principal_id                           = identity.principal_id
          scope                                  = assignment.resource_group_id
          description                            = lookup(role, "description", null)
          condition                              = lookup(role, "condition", null)
          condition_version                      = lookup(role, "condition_version", null)
          skip_service_principal_aad_check       = lookup(role, "skip_service_principal_aad_check", false)
          delegated_managed_identity_resource_id = lookup(role, "delegated_managed_identity_resource_id", null)
          principal_type                         = lookup(role, "principal_type", null)
        }
      ]
      ]
  ])
  role_assignments_sub = flatten(
    [for ri, role in var.role_assignments : [
      for assignment in azurerm_subscription_policy_assignment.this : [
        for identity in assignment.identity :
        {
          role_definition_id_or_name             = lookup(role, "role_definition_id_or_name", null)
          principal_id                           = identity.principal_id
          scope                                  = assignment.subscription_id
          description                            = lookup(role, "description", null)
          condition                              = lookup(role, "condition", null)
          condition_version                      = lookup(role, "condition_version", null)
          skip_service_principal_aad_check       = lookup(role, "skip_service_principal_aad_check", false)
          delegated_managed_identity_resource_id = lookup(role, "delegated_managed_identity_resource_id", null)
          principal_type                         = lookup(role, "principal_type", null)
        }
      ]
      ]
  ])
}

resource "azurerm_role_assignment" "this" {
  for_each = tomap({
    for vi, v in concat(local.role_assignments_resource, local.role_assignments_rg, local.role_assignments_sub, local.role_assignments_mg) :
    vi => v
  })

  principal_id                           = each.value.principal_id
  scope                                  = each.value.scope
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  description                            = each.value.description
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check

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
