mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/policyAssignments/test-policy"
    }
  }

  mock_data "azapi_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000002"
    }
  }
}

mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

override_resource {
  target = azapi_resource.policy_assignment
  values = {
    identity = {
      principal_id = "00000000-0000-0000-0000-000000000001"
      tenant_id    = "00000000-0000-0000-0000-000000000002"
    }
  }
}

variables {
  location             = "eastus"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
  enable_telemetry     = false
  name                 = "test-policy"
}

run "policy_without_roles" {
  command   = apply
  state_key = "policy_without_roles"

  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  assert {
    condition     = length(output.role_assignments) == 0
    error_message = "A policy without role assignments must not create AzureRM role assignments."
  }

  assert {
    condition     = output.policy_assignment_id == output.resource_id
    error_message = "Policy assignment outputs must retain the same resource ID."
  }
}

run "role_assignment_by_name" {
  command   = apply
  state_key = "role_assignment_by_name"

  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    identity = { type = "SystemAssigned" }
    role_assignments = {
      reader = {
        role_definition_id_or_name       = "Reader"
        principal_id                     = "ignored"
        principal_type                   = "ServicePrincipal"
        skip_service_principal_aad_check = true
        description                      = "Policy identity reader"
      }
    }
  }

  assert {
    condition = (
      length(output.role_assignments) == 1 &&
      output.role_assignments["0"].role_definition_name == "Reader" &&
      output.role_assignments["0"].principal_id == "00000000-0000-0000-0000-000000000001" &&
      output.role_assignments["0"].scope == var.scope &&
      output.role_assignments["0"].principal_type == "ServicePrincipal" &&
      output.role_assignments["0"].skip_service_principal_aad_check &&
      output.role_assignments["0"].description == "Policy identity reader"
    )
    error_message = "AzureRM v4 must preserve named roles, policy identity, scope, and optional role assignment settings."
  }
}

run "role_assignment_by_id" {
  command   = apply
  state_key = "role_assignment_by_id"

  providers = {
    azapi   = azapi
    azurerm = azurerm
    modtm   = modtm
    random  = random
    time    = time
  }

  variables {
    identity = { type = "SystemAssigned" }
    role_assignments = {
      reader = {
        role_definition_id_or_name = "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
        principal_id               = "ignored"
        condition                  = "(!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write'}))"
        condition_version          = "2.0"
      }
    }
  }

  assert {
    condition = (
      length(output.role_assignments) == 1 &&
      output.role_assignments["0"].role_definition_id == var.role_assignments.reader.role_definition_id_or_name &&
      output.role_assignments["0"].condition == var.role_assignments.reader.condition &&
      output.role_assignments["0"].condition_version == "2.0"
    )
    error_message = "AzureRM v4 must preserve role definition IDs and role assignment conditions."
  }
}
