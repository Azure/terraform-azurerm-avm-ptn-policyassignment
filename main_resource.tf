resource "azurerm_resource_policy_assignment" "this" {
  for_each = tomap({
    for vi, v in var.resource_ids :
    vi => v
  })

  name                 = var.name
  policy_definition_id = var.policy_definition_id
  resource_id          = each.value
  description          = try(var.description, "")
  display_name         = try(var.display_name, "")
  enforce              = try(var.enforce, "Default") == "Default" ? true : false
  location             = try(var.location, null)
  metadata             = jsonencode(try(var.metadata, {}))
  not_scopes           = try(var.not_scopes, [])
  parameters           = try(var.parameters, null) != null && try(var.parameters, {}) != {} ? jsonencode(var.parameters) : null

  dynamic "identity" {
    for_each = try(var.identity.type, "None") != "None" ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "SystemAssigned" ? [] : toset(keys(identity.value.userAssignedIdentities))
    }
  }
  dynamic "non_compliance_message" {
    for_each = try(var.non_compliance_messages, [])

    content {
      content                        = non_compliance_message.value.message
      policy_definition_reference_id = try(non_compliance_message.value.policy_definition_reference_id, null)
    }
  }
  dynamic "overrides" {
    for_each = try(var.overrides, [])

    content {
      value = overrides.value.value

      dynamic "selectors" {
        for_each = try(overrides.value.selectors, [])

        content {
          in     = try(selectors.value.in, null)
          not_in = try(selectors.value.notIn, null)
        }
      }
    }
  }
  dynamic "resource_selectors" {
    for_each = try(var.resource_selectors, [])

    content {
      name = resource_selectors.value.name

      dynamic "selectors" {
        for_each = try(resource_selectors.value.selectors, [])

        content {
          kind   = selectors.value.kind
          in     = try(selectors.value.in, null)
          not_in = try(selectors.value.notIn, null)
        }
      }
    }
  }
}
