locals {
  role_assigments_scope = flatten(
    [for ri, role in var.role_assignments : [
      for identity in azapi_resource.policy_assignment.identity :
      {
        role_definition_id_or_name             = lookup(role, "role_definition_id_or_name", null)
        principal_id                           = identity.principal_id
        scope                                  = var.scope
        description                            = lookup(role, "description", null)
        condition                              = lookup(role, "condition", null)
        condition_version                      = lookup(role, "condition_version", null)
        skip_service_principal_aad_check       = lookup(role, "skip_service_principal_aad_check", false)
        delegated_managed_identity_resource_id = lookup(role, "delegated_managed_identity_resource_id", null)
        principal_type                         = lookup(role, "principal_type", null)
      }
      ]
  ])
}

resource "azurerm_role_assignment" "this" {
  for_each = tomap({
    for vi, v in local.role_assigments_scope :
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
    policy_assignment = sha256(jsonencode(azapi_resource.policy_assignment))
  }

  depends_on = [
    azapi_resource.policy_assignment
  ]
}
