terraform {
  required_version = "~> 1.8"

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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
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


resource "azurerm_resource_group" "example" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = "example-rg"
}

module "assign_policy_at_resource_group" {
  source = "../../"

  location             = module.regions.regions[random_integer.region_index.result].name
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/d8cf8476-a2ec-4916-896e-992351803c44"
  scope                = azurerm_resource_group.example.id
  description          = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  display_name         = "Keys should have a rotation policy ensuring that their rotation is scheduled within the specified number of days after creation."
  # source = "Azure/terraform-azurerm-avm-ptn-policyassignment"
  enable_telemetry = var.enable_telemetry # see variables.tf
  enforce          = "Default"
  name             = "Enforce-GR-Keyvault"
  parameters = {
    maximumDaysToRotate = {
      value = 90
    }
  }
}
