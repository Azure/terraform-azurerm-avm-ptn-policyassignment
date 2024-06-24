locals {
  resource_exemptions = flatten(
    [for ri, resource in var.exemptions : [
      for assignment in merge(azurerm_management_group_policy_assignment.this, azurerm_subscription_policy_assignment.this, azurerm_resource_group_policy_assignment.this) : [
        {
          resource_id                     = lookup(resource, "resource_id", null)
          resource_group_id               = lookup(resource, "resource_group_id", null)
          subscription_id                 = lookup(resource, "subscription_id", null)
          management_group_id             = lookup(resource, "management_group_id", null)
          policy_definition_reference_ids = lookup(resource, "policy_definition_reference_ids", [])
          exemption_category              = resource.exemption_category
          policy_assignment_id            = assignment.id
        }
      ]
      ]
  ])
}


resource "azurerm_resource_policy_exemption" "example" {
  for_each = tomap({
    for vi, v in local.resource_exemptions :
    vi => v if v.resource_id != null
  })

  exemption_category              = each.value.exemption_category
  name                            = "exemption1"
  policy_assignment_id            = each.value.policy_assignment_id
  resource_id                     = each.value.resource_id
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
}

resource "azurerm_resource_group_policy_exemption" "this" {
  for_each = tomap({
    for vi, v in local.resource_exemptions :
    vi => v if v.resource_group_id != null
  })

  exemption_category              = each.value.exemption_category
  name                            = "exemption1"
  policy_assignment_id            = each.value.policy_assignment_id
  resource_group_id               = each.value.resource_group_id
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
}


resource "azurerm_subscription_policy_exemption" "this" {
  for_each = tomap({
    for vi, v in local.resource_exemptions :
    vi => v if v.subscription_id != null
  })

  exemption_category              = each.value.exemption_category
  name                            = "exemption1"
  policy_assignment_id            = each.value.policy_assignment_id
  subscription_id                 = strcontains(each.value.subscription_id, "/subscriptions/") ? each.value.subscription_id : "/subscriptions/${each.value.subscription_id}"
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
}


resource "azurerm_management_group_policy_exemption" "this" {
  for_each = tomap({
    for vi, v in local.resource_exemptions :
    vi => v if v.management_group_id != null
  })

  exemption_category              = each.value.exemption_category
  management_group_id             = each.value.management_group_id
  name                            = "exemption1"
  policy_assignment_id            = each.value.policy_assignment_id
  policy_definition_reference_ids = each.value.policy_definition_reference_ids
}
