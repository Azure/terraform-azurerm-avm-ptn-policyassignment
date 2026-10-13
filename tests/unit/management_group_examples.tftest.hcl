mock_provider "azapi" {}
mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {
  mock_resource "random_integer" {
    defaults = {
      result = 0
    }
  }
}
mock_provider "time" {}

variables {
  enable_telemetry = false
}

override_module {
  target = module.naming
  outputs = {
    management_group = {
      name_unique = "mg-unit-test-unique"
    }
  }
}

run "exemptions_use_test_parent_and_unique_name" {
  command = apply

  module {
    source = "./examples/manage_policy_exemptions"
  }

  override_module {
    target  = module.manage_policy_exemptions
    outputs = {}
  }

  assert {
    condition     = azurerm_management_group.root.parent_management_group_id == "/providers/Microsoft.Management/managementGroups/avm-test"
    error_message = "The exemptions example must create its child beneath avm-test by default."
  }

  assert {
    condition     = azurerm_management_group.root.name == "mg-unit-test-unique"
    error_message = "The exemptions example must use the naming module's unique management-group name."
  }
}

run "exemptions_accept_another_parent" {
  command = apply

  module {
    source = "./examples/manage_policy_exemptions"
  }

  variables {
    parent_management_group_id = "/providers/Microsoft.Management/managementGroups/custom-parent"
  }

  override_module {
    target  = module.manage_policy_exemptions
    outputs = {}
  }

  assert {
    condition     = azurerm_management_group.root.parent_management_group_id == var.parent_management_group_id
    error_message = "The exemptions example must create its child beneath the caller's parent."
  }
}

run "exemptions_reject_invalid_parent_ids" {
  command = plan

  module {
    source = "./examples/manage_policy_exemptions"
  }

  variables {
    parent_management_group_id = "avm-test"
  }

  override_module {
    target  = module.manage_policy_exemptions
    outputs = {}
  }

  expect_failures = [var.parent_management_group_id]
}

run "assignment_uses_test_parent_and_unique_name" {
  command = apply

  module {
    source = "./examples/assign_policy_at_management_group"
  }

  override_module {
    target  = module.assign_policy_at_management_group
    outputs = {}
  }

  assert {
    condition     = azurerm_management_group.root.parent_management_group_id == "/providers/Microsoft.Management/managementGroups/avm-test"
    error_message = "The assignment example must create its child beneath avm-test by default."
  }

  assert {
    condition     = azurerm_management_group.root.name == "mg-unit-test-unique"
    error_message = "The assignment example must use the naming module's unique management-group name."
  }
}

run "assignment_accepts_another_parent" {
  command = apply

  module {
    source = "./examples/assign_policy_at_management_group"
  }

  variables {
    parent_management_group_id = "/providers/Microsoft.Management/managementGroups/custom-parent"
  }

  override_module {
    target  = module.assign_policy_at_management_group
    outputs = {}
  }

  assert {
    condition     = azurerm_management_group.root.parent_management_group_id == var.parent_management_group_id
    error_message = "The assignment example must create its child beneath the caller's parent."
  }
}

run "assignment_rejects_invalid_parent_ids" {
  command = plan

  module {
    source = "./examples/assign_policy_at_management_group"
  }

  variables {
    parent_management_group_id = "avm-test"
  }

  override_module {
    target  = module.assign_policy_at_management_group
    outputs = {}
  }

  expect_failures = [var.parent_management_group_id]
}
