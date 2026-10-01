# azapi provider!! 1.14 --> 
# ignore pipeline output avm/pr-check : 
# output guidance: https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs

resource "azapi_resource" "policy_assignment" {
  location  = try(var.location, null)
  name      = var.name
  parent_id = var.scope
  type      = "Microsoft.Authorization/policyAssignments@2024-04-01"
  body = {
    properties = {
      # assignmentType  = "string" # TODO MISSING

      metadata              = try(var.metadata, {})
      description           = try(var.description, "")
      displayName           = try(var.display_name, "")
      enforcementMode       = try(var.enforce, "Default") == "Default" ? "Default" : "DoNotEnforce" # TODO: agree on default
      nonComplianceMessages = try(var.non_compliance_messages, [])
      notScopes             = try(var.not_scopes, [])
      overrides             = try(var.overrides, [])
      parameters            = var.parameters
      policyDefinitionId    = var.policy_definition_id
      resourceSelectors     = try(var.resource_selectors, [])
    }
  }
  schema_validation_enabled = var.schema_validation_enabled

  dynamic "identity" {
    for_each = try(var.identity.type, "None") != "None" ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.type == "SystemAssigned" ? [] : toset(keys(identity.value.userAssignedIdentities))
    }
  }
}
