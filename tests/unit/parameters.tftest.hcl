mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}
mock_provider "time" {}

variables {
  enable_telemetry     = false
  location             = "eastus"
  name                 = "policy-assignment-test"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00"
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
}

run "accepts_mixed_parameter_types" {
  command = apply

  variables {
    parameters = {
      effect                   = { value = "Deny" }
      allowedCapabilities      = { value = [] }
      requiredDropCapabilities = { value = ["ALL"] }
      excludedNamespaces       = { value = ["kube-system", "gatekeeper-system"] }
    }
  }

  assert {
    condition     = azapi_resource.policy_assignment.body.properties.parameters.effect.value == "Deny"
    error_message = "String parameter values should be passed through unchanged."
  }

  assert {
    condition     = length(azapi_resource.policy_assignment.body.properties.parameters.allowedCapabilities.value) == 0
    error_message = "Empty list parameter values should be passed through unchanged."
  }

  assert {
    condition     = jsonencode(azapi_resource.policy_assignment.body.properties.parameters.requiredDropCapabilities.value) == jsonencode(["ALL"])
    error_message = "List parameter values should be passed through unchanged alongside string values."
  }
}

run "accepts_null_parameters" {
  command = plan

  variables {
    parameters = null
  }
}

run "rejects_parameters_without_value_attribute" {
  command = plan

  variables {
    parameters = {
      effect = "Deny"
    }
  }

  expect_failures = [
    var.parameters,
  ]
}
