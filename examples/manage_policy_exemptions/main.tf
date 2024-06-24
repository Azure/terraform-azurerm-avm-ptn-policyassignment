terraform {
  required_version = "~> v1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

data "azurerm_management_group" "root" {
  name = "root"
}


data "azurerm_resource_group" "example" {
  name = "test-storage"
}



data "azurerm_virtual_network" "example" {
  name                = "test-storage"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_client_config" "current" {}

module "test_management_group" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  default_location = module.regions.regions[random_integer.region_index.result].name

  enable_telemetry = var.enable_telemetry # see variables.tf

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  management_group_ids = [data.azurerm_management_group.root.id]
  name                 = "Enforce-GR-Keyvault"
  display_name         = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  description          = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  enforce              = "Default"
  location             = module.regions.regions[random_integer.region_index.result].name
  identity             = { "type" = "SystemAssigned" }

  role_assignments = [
    {
      "role_definition_name" : "Contributor"
    }
  ]
  exemptions = [
    {
      resource_id : data.azurerm_virtual_network.example.id
      exemption_category : "Mitigated"
    },
    {
      resource_group_id : data.azurerm_resource_group.example.id
      exemption_category : "Mitigated"
    },
    {
      subscription_id : data.azurerm_client_config.current.subscription_id
      exemption_category : "Mitigated"
    },
    {
      management_group_id = data.azurerm_management_group.root.id
      exemption_category  = "Waiver"
    }
  ]

  parameters = {
    maximumDaysToRotate = {
      value = 90
    }
  }
}
