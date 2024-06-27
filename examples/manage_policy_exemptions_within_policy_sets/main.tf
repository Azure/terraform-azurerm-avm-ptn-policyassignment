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

resource "azurerm_management_group" "root" {
  name = "root"
}

data "azurerm_client_config" "current" {}

module "manage_policy_exemptions_within_policy_sets" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  enable_telemetry = var.enable_telemetry # see variables.tf

  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/f5bf694c-cca7-4033-b883-3a23327d5485"
  management_group_ids = [azurerm_management_group.root.id]
  name                 = "Azure-Monitor-AMA"
  display_name         = "Enable Azure Monitor for VMSS with Azure Monitoring Agent(AMA)"
  description          = "Enable Azure Monitor for the virtual machines scale set (VMSS) with AMA."
  enforce              = "Default"
  location             = module.regions.regions[random_integer.region_index.result].name
  identity             = { "type" = "SystemAssigned" }

  exemptions = [
    {
      resource_id : "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
      exemption_category : "Waiver"
      policy_definition_reference_ids : ["AddUserAssignedManagedIdentity_VMSS"]
    }
  ]
}
