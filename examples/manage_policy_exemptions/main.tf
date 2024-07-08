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
    # azapi = {
    #   source  = "Azure/azapi"
    #   version = ">=1.7.0"
    # }
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

resource "azurerm_management_group" "root" {
  name = "root"
}


resource "azurerm_resource_group" "example" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = "test-storage"
}


resource "azurerm_virtual_network" "example" {
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.example.location
  name                = "test-storage"
  resource_group_name = azurerm_resource_group.example.name
}

data "azurerm_client_config" "current" {}

resource "azurerm_management_group_subscription_association" "example" {
  management_group_id = azurerm_management_group.root.id
  subscription_id     = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

module "manage_policy_exemptions" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  enable_telemetry = var.enable_telemetry # see variables.tf

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = azurerm_management_group.root.id
  name                 = "Enforce-GR-Keyvault"
  display_name         = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  description          = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  enforce              = "Default"
  location             = module.regions.regions[random_integer.region_index.result].name
  identity             = { "type" = "SystemAssigned" }

  role_assignments = {
    contrib = {
      "role_definition_id_or_name" : "Contributor"
      principal_id : "ignored"
    }
  }
  exemptions = [
    {
      resource_id : azurerm_virtual_network.example.id
      exemption_category : "Mitigated"
    },
    {
      resource_id : azurerm_resource_group.example.id
      exemption_category : "Mitigated"
    },
    {
      resource_id : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
      exemption_category : "Mitigated"
    },
    {
      resource_id        = azurerm_management_group.root.id
      exemption_category = "Waiver"
    }
  ]

  parameters = {
    maximumDaysToRotate = {
      value = 90
    }
  }
}
