mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry     = false
  location             = "eastus"
  name                 = "policy-assignment-test"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
}

run "sets_user_assigned_identity_ids" {
  command = apply

  variables {
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test" = {}
      }
    }
  }

  assert {
    condition     = azapi_resource.policy_assignment.identity[0].type == "UserAssigned"
    error_message = "The policy assignment should use a user-assigned identity."
  }

  assert {
    condition = jsonencode(azapi_resource.policy_assignment.identity[0].identity_ids) == jsonencode(toset([
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"
    ]))
    error_message = "User-assigned identity resource IDs should be passed to the AzAPI identity_ids argument."
  }
}

run "requires_user_assigned_identity_ids" {
  command = plan

  variables {
    identity = {
      type = "UserAssigned"
    }
  }

  expect_failures = [
    var.identity,
  ]
}
