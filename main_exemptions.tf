resource "azapi_resource" "policy_exemption" {
  for_each = tomap({
    for vi, v in var.exemptions :
    vi => v
  })

  name      = lookup(each.value, "name", "Exemption for ${azapi_resource.policy_assignment.name}")
  parent_id = each.value.resource_id
  type      = "Microsoft.Authorization/policyExemptions@2022-07-01-preview"
  body = {
    properties = {
      policyAssignmentId           = azapi_resource.policy_assignment.id
      policyDefinitionReferenceIds = lookup(each.value, "policy_definition_reference_ids", [])
      description                  = lookup(each.value, "description", "Resource exempted: ${each.value.resource_id}")
      displayName                  = substr(lookup(each.value, "display_name", "Resource exempted: ${each.value.resource_id}"), 0, 128)
      exemptionCategory            = lookup(each.value, "exemption_category", "Waiver")
      expiresOn                    = lookup(each.value, "expires_on", null)
      metadata                     = lookup(each.value, "metadata", null)
    }
  }

  depends_on = [time_sleep.before_policy_role_assignments]
}
